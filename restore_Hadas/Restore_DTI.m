function [ ] = Restore_DTI( mdcFile, outFile, opt )
% function [] = Restore_DTI( mdcFile, outFile, opt )
% 
% Input:
%   mdcFile         -   ExploreDTI HARDI data file (md_c, trafo, etc.)
%   outFile         -   Location to save the restore result, if not
%                       specified will default to appending
%                       "_restored.mat" to the mdcFile name.
%   opt             -   OPTIONAL input
%                           If opt is a 3d volume it will be used to
%                           specify the voxels that are to be used to
%                           estimate SDNoise (by default the whole brain
%                           will be used).
%                           If opt is a single value this will be assumed
%                           to be a precalculated SDNoise estimate. Walker
%                           SDNoise approximation will therefore not be
%                           performed.
% 
% Output:
%       Saves modified mdcFile to location specified by outFile.
%       File will contain all usual ExploreDTI contents including
%       "outlier", a 4D volume that indicate the location of rejected data
%       points. The revised mat file will also contain additional QA data
%       including:
%           a)  BadFit      : Location of voxels that failed the initial
%                             goodness of fit testing.
%           b) PerReject    : Map signal rejection percentages per voxel.
%           c) SDNoise      : The Walker derived SDNoise estimate or, if a
%                             specific value was supplied this will record
%                             the supplied information.
%           d) residuals    : Residuals to the final DT fit.
% 
% Example usage:
%       Restore_DTI( mdcFile )  
%           Will perform non linear RESTORE on the specified hardi file.
%           Result will be stored as "<mdc_file>_restored.mat" in your
%           current working directory.
%       Restore_DTI( mdcFile, outFile )
%           Will perform non linear RESTORE on the specified hardi file.
%           Result will be stored in location specified by outFile
%       Restore_DTI( mdcFile, outFile, opt )
%           Where size(opt) = [1 1]; (i.e. a single number)
%           Will perform RESTORE on mdcFile, saving result in outFile.
%           Will NOT perform Walker SDNoise approximation, will instead use
%           the value supplied in opt.
%       Restore_DTI( mdcFile, outFile, opt)
%           Where opt is a mask with dimensions equal to those of the
%           diffusion weighted image.
%           Will perform RESTORE on the mdcFile, saving result in outFile.
%           Will perform Walker SDNoise approximation BUT will only use
%           voxels labelled (with value 1) in mask parameter opt.
%       Restore_DTI( mdcFile, [], opt )
%           Will perform RESTORE on the specified mdcFile using a Walker
%           noise approximation behaviour linked to the size of opt.
%           Will SAVE the result as "<mdcFile>_restored.mat" in your
%           current working directory.
% 
% References:
% RESTORE (basic algorithm):  
%           Chang LC, Jones DK, Pierpaoli C. RESTORE: robust estimation of
%           tensors by outlier rejection. 2005. Magnetic Resonance in
%           Medicine. 53(5):1088-1095
% 
% Noise Estimation (if no user specified SDNoise was supplied):
%           Walker L, Chang L-C, Koay CG, Sharma N, Cohen L, Verma R,
%           Pierpaoli C. Effects of physiological noise in population
%           analysis of diffusion tensor MRI data. 2011. NeuroImage.
%           54(2):1168-1177
% 
% Leverage (used for residual correction during robust fitting step):
%           DuMouchel WH, O'Brien FL. Integrating a Robust Option into a
%           Multiple Regression Computing Environment. 1989. Computer
%           Scient and Statistics: Proc. 21st Symposium on the Interface.
%           Alexandria, VA: American Statistical Association.
% 
% ExploreDTI (implementation based on Alex's original code):
%           Leemans A, Jeurissen B, Sijbers J, Jones DK. ExploreDTI: A
%           Graphical Toolbox for Processing, Analyzing and Visualising
%           Diffusion MR Data. 2009. Proc. 17th Annual Meeting of the
%           International Society for Magnetic Resonance in Medicine,
%           Hawaii, page 3537.

tic;

% start the matlabpool.
% matlabpool_start;

% load the required parameters from the existing mdcFile
load(mdcFile, 'DWI', 'g', 'bval', 'NrB0', 'FA', 'b', 'VDims');

% input check on opt
if nargin == 3 && numel(opt) > 1
    if ~all(size(opt)==size(FA))
        error(['Error with optional unput: opt must be either a single',...
               ' value (numel(opt)==1) providing a user specified SDNoise',...
               ' estimate OR a mask with dimensions equal to those of the',...
               ' first three dimensions of the DW-MRI image.']);
    end
end

% work aroun for parfor loops not recognising variables loaded directly
% from a .mat file.
bmat = b; nb = NrB0; NrB0 = nb;

% if no outFile was specified, generate an appropriate save file name
if nargin == 1 || isempty(outFile)
    [~, n] = fileparts(mdcFile);
    outFile = [n '_restored.mat'];
end

%% Step 1. Compute an initial unweighted non-linear least squares fit
disp('Performing Initial Non-Linear Fit.');

% linearise the DW-MRI image data
dwi         = get_dwi_4_resp_func_2(DWI, 0, FA);

% prep for breaking the data into "ncores" blocks for parallel processing
ncores      = feature('numCores');
sblock      = floor( length(dwi) / ncores );
resid       = cell(1, ncores);
dtfit       = cell(1, ncores);
chi_sq      = cell(1, ncores);
chi_sq_iqr  = cell(1, ncores);

% a few constants required for least squares fitting
B = [ones(size(bmat,1),1), -bmat];
diffusion_equation = @(p, x) p(1)*exp(-x*p(2:end));

% for each CPU core
parfor a=1:ncores
   
    % grab a block of signal data
    if a~=ncores
        dwb = dwi(:, sblock*(a-1)+1:sblock*a);
    else
        dwb = dwi(:, sblock*(a-1)+1:end);
    end
    
    dtf     = zeros(7, length(dwb));
    rsb    = zeros(size(dwb));
    chisq   = zeros(1, length(dwb));
    chiiqr  = zeros(1, length(dwb));
    
    warning off all
    for x=1:length(dwb)
        
        % intital unweighted non-linear least squares fit
        [X, ~] = dti_nonlinear_leastsquares(dwb(:, x), B, bmat, diffusion_equation);
        
        % approximate a signal based on that fit
        fit  = sqrt((X(1)*exp(-bmat*X(2:end))).^2);
        
        % calculate residuals
        rsb(:, x) = fit - dwb(:, x);
        
        % saving DT fit
        dtf(:, x) = X;
        
        % calculate chi_sq and chi_sq_iqr, use same method as ExploreDTI
        y = prctile(abs(rsb(:, x)), [25 50 75]);
        chisq(x)  =        y(2);
        chiiqr(x) = y(3) - y(1);
        
    end
    
    % package it all up
    resid{a}      =    rsb;
    dtfit{a}      =    dtf;
    chi_sq{a}     =  chisq;
    chi_sq_iqr{a} = chiiqr;
    
end

% unpack the data
resid      =      cell2mat(resid);
dtfit      =      cell2mat(dtfit);
chi_sq     =     cell2mat(chi_sq);
chi_sq_iqr = cell2mat(chi_sq_iqr);

%% Step 2. Use initial residuals to approximate SDNoise (Walker method)
disp('Estimating SDNoise');

% if no explicit mask or SDNoise approximation was supplied
if nargin < 3
    
    % use the ~isnan(FA) masked data to approximate SDNoise
    res = resid.^2;
    
% or, if an expicit mask was supplied
elseif nargin == 3 && numel(opt) > 1
    res = unvec(resid, ~isnan(FA));
    res = get_dwi_4_resp_func_2(res, 0.0001, opt);
    res = res.^2;
end

% if no explicit SDNoise approximation was given, estimate it using the
% Walker method
if nargin < 3 || numel(opt) > 1
    
    res     = sum(res, 1);
    v       = size(dwi, 1) - 7; % calculate the degrees of freedom, 
                                % #datapoints - #parameters fit
                                
    % normalise the sum of squared residuals by the degrees of freedom
    normed  = res / v;
    
    % get rid of nans
    normed(isnan(normed)) = [];
    
    % and find the median value
    med     = median(normed);
    
    % approximate walkers alpha parameter. In the paper Walker suggests
    % this value is suffiiently close to 1 to ignore completely, but
    % including it anyway for completeness.
    y = [0.934, 0.966, 0.977, 0.983, 0.986, 0.988, 0.99, 0.991, 0.992, 0.993];
    x=10:10:100;
    pp = spline(x, y);
    v = ppval(v, pp);
    
    % finally, approximate the SDNoise
    SDNoise = sqrt((1/v) * med);

% or, if an explicit SDNoise was supplied, use that value    
elseif numel(opt) == 1
    SDNoise = opt;
end

disp(['SDNoise = ' num2str(SDNoise)]);

%% Step 3. Perform the initial Goodness-of-fit test.
outliers = abs(resid) > 3 * SDNoise;
badfit   = sum(outliers, 1) > 0;
BadFit   = unvec(double(badfit), ~isnan(FA));   % mask of failed voxels for the QA output

%% Step 4. ROBUST fit those voxels that failed the initial goodness of fit.

% prune out the failed data to be reprocessed
badDwi      = dwi(:, badfit == 1);
badDtF      = dtfit(:, badfit == 1);
badResid    = zeros(size(resid, 1), length(badDtF));
badOut      = zeros(size(resid, 1), length(badDtF));
badChi      = zeros(1, length(badDtF));
badChiIqr   = zeros(1, length(badDtF));

disp('Performing RESTORE (very slow)');
parfor x=1:size(badDwi, 2)
    
    warning off all     % unfortunately necessary
    
    % perform a robust non-linear fit, use previous fit as the initial
    % estimation.
    X = robust_nlinfit(bmat, badDwi(:, x), diffusion_equation, badDtF(:, x));
    
    % approximate the signal
    fit = sqrt((X(1)*exp(-bmat*X(2:end))).^2);
    
    % calculate the new residual
    br             = fit - badDwi(:, x);
    badResid(:, x) = fit - badDwi(:, x);
    
    % calculate the new outliers
    badOut(:, x) = abs(badResid(:, x)) > 3*SDNoise;
    
    % refit the diffusion tensor using the remaining points
    bo = badOut(:, x);
    
    % Problem :  What to do if ALL the b0 images are labelled as corrupt?
    % The restore paper doesn't have much to say about this outcome.
    if sum(bo(1:NrB0)) == NrB0
        
        % I see three obvious solutions, either
        % a) ignore all b0 rejections
        % bo(1:NrB0) = true;
        
        % b) replace the corrupted b0 values
        % with a median filtered approximation of local non corrupt
        % intensities -> doesnt work when all local values are corrupt
        
        % c) for now, just go with the least "corrupt" values
        f = find(br(1:NrB0) == min(br(1:NrB0)));
        bo(f) = false;
        
        % save which ever change is made
        badOut(:, x) = bo;
        
    end
    
    % finally, recalculate the diffusion tensor using the remaining data
    % points
    dw = badDwi(:, x);      bm = B;     bm = bm(~bo, :);
    X  = dti_nonlinear_leastsquares(dw(~bo), bm, bmat(~bo,:), diffusion_equation);
    
    % save the new tensor fit
    badDtF(:, x) = X;
    
    % recalculate chi_sq and chi_sq_iqr based on the refined fit
    y = prctile(abs(badResid(:, x)), [25 50 75]);
    badChi(x)    = y(2);
    badChiIqr(x) = y(3) - y(1);
    
    warning on all
    
end

%% Step 5. Reintegrate the RESTOREd data
dtfit(:, badfit == 1)       = badDtF;
resid(:, badfit == 1)       = badResid;
outliers(:, badfit == 1)    = badOut;
chi_sq(badfit == 1)         = badChi;
chi_sq_iqr(badfit == 1)     = badChiIqr;

mask = ~isnan(FA);

% unvec the data to create 3/4D volumes
outlier     =  unvec(double(outliers), mask);
PerReject   = sum(outlier, 4) / size(dwi, 1);
chi_sq      =            unvec(chi_sq, mask);
chi_sq_iqr  =        unvec(chi_sq_iqr, mask);
residuals   =             unvec(resid, mask);

% rework the diffusion tensor
DT = E_DTI_DWI_mat2cell(unvec(dtfit, mask));
DT = DT(2:end); % ignore the first volume, just contains b0's.

%% Step 6. Recalculate tensor based parameters.
disp('Recalculating Tensor Maps');
[FEFA, FA, FE, SE, eigval] = E_DTI_View3DDTMaps_vec(DT, ~isnan(FA));

%% Step 7. Save output.

% load some parameters that can be directly transferred
load(mdcFile, 'VDims', 'MDims', 'info', 'NrB0', 'DWIB0');
save(outFile, 'DT', 'DWI', 'b', 'FE', 'SE', 'FA', 'FEFA', 'VDims', 'MDims',...
              'eigval', 'bval', 'g', 'info', 'NrB0', 'chi_sq', 'chi_sq_iqr',...
              'DWIB0', 'outlier', 'BadFit', 'residuals', 'SDNoise',...
              'PerReject', '-v7.3');

ti = toc;

m=ti/60;
disp(['RESTORE computation complete, time taken: ' num2str(m) ' min.'])
          
end

% function starts (or expands) the matlabpool
% function [] = matlabpool_start
% 
% warning off all
% isOpen = matlabpool('size') == feature('numCores');
% if ~isOpen
%     try
%         matlabpool close force
%     catch e
%         throw(e)
%     end
% 
%     try 
%         matlabpool('open', feature('numCores'));
%     catch e
%         throw(e)
%     end
% end
% warning on all
% end


% Reproduction of E_DTI_get_dwi_4_resp_func_2
% credit goes to Alexander Leemans
% function vectorises 4D DW-MRI data based upon a supplied mask (FA)
% thresholded above a certain value (FA_T)
function dwi = get_dwi_4_resp_func_2(DWI, FA_T, FA)

if ~iscell(DWI)
    DWI = E_DTI_DWI_mat2cell(DWI);
end

if FA_T~=0
    fa_mask = FA>=FA_T*sqrt(3);
elseif FA_T==0
    fa_mask = ~isnan(FA);
end

dwi = zeros(length(DWI),sum(fa_mask(:)),'single');

for i=1:length(DWI)
    dwi(i,:) = single(DWI{i}(fa_mask(:))');
end

end



