function [beta, cause] = robust_nlinfit(X, y, model, beta)
% Perform a robust non-linear least squares fit of the model ("model") to
% the observed signal data ("y"). Method adapted from ExploreDTI 4.8.3.
% Primary credit goes to Alexander Leemans.
% input :   
%           X       :   b-matrix
%           y       :   dw-mri signal data
%           model   :   diffusion tensor fitting equation
%           beta    :   initial non-linear LS estimate for the DT-MRI fit

% first, calculate the jacobian from the existing non-linear least squares
% fit
fdiffstep = 6.0555e-006;
yfit = model(beta, X);
nans = (isnan(y(:)) | isnan(yfit(:)));
J = get_jacobian(beta, fdiffstep, model, X, yfit, nans);

% then calculate the robust non-linear fit
[beta, cause] = nlin_robust_fit(X, y, beta, model, J);


end

function [beta, cause] = nlin_robust_fit(x, y, beta, model, J)
% the actual robust fitting

% set up parameters and required functions
maxiter     =   200;            % number of times to iterate the robust fitting.
WgtFun      =   @GMM;           % robust fitting function (Geman McClure M-estimator)
cause       =   0;              % flag indicating cause of optimisation termination.

% initial model signal estimate 
yfit    =   model(beta, x);
fullr   =   y(:) - yfit(:);
ok      =   ~isnan(fullr);
r       =   fullr(ok);

% machine epsilon for the signal data class (hardware dependent)
Delta = sqrt(eps(class(x)));


% Adaptation made by Alex to adjust the residuals using leverage, as
% advised by DuMouchel & O'Brien.

% QR decomposition of the jacobian, 0 indicates an "Economy Size"
% decomposition, not 100% sure on what that means,
Q = qr(J, 0);
h = min(0.9999, sum(Q.*Q, 2));

% Compute adjustment factor
adjfactor = 1 ./ sqrt(1-h);
radj      = r .* adjfactor;

% To further quote Alex:
% If we get a perfect or near perfect fit, the whole idea of finding
% outliers by comparing them to the residual standard deviation becomes
% diffifult. We'lldeal with that by never allowing our estimate of the
% standard deviation of the error term to get below a value that is a small
% fraction of the standard deviation of the raw response values
tiny_s = 1e-6 * std(y);
if tiny_s == 0
    tiny_s = 1;
end

% Main loop of repeated nonlinear fits, asjust weights each time
totiter = 0;
w = NaN(size(y));

while maxiter > 0
    
    % save the old fit
    beta0 = beta;
    s = madsigma(radj, numel(beta)); % robust estimate of sigma for residual
    
    % compute robust weights based on current residuals
    w(ok) = feval(WgtFun, radj/max(s, tiny_s));
    
    % then perform the weighted non linear ls fit
    sw      =   sqrt(w);
    yw      =   y .* sw;
    modelw  =   @(b, x) sqrt(w).*model(b, x);
    
    % perform the weighted non-linear fit
    [beta,~, lsiter, cause] = LMfit(x, yw, modelw, beta0);
%     [beta, ~, lsiter, cause] = nlinfit(x, yw, modelw, beta0);
    
    % some administration of iteration counts
    totiter = totiter + lsiter;
    maxiter = maxiter - lsiter;
    
    % work out new residuals
    yfit    = model(beta, x);
    fullr   = y - yfit;
    r       = fullr(ok);
    radj    = r .* adjfactor;
    
    % if there is no change in any coefficient, the iterations stop.
    if all(abs(beta-beta0) < Delta*max(abs(beta), abs(beta0)))
        break;
    end
    
end

if maxiter <= 0
    cause = 1;
end

end

% basic jacobian calculation via finite difference method.
function J = get_jacobian(beta,fdiffstep,model,X,yfit,nans)
p = numel(beta);
delta = zeros(size(beta));
for k = 1:p
    if (beta(k) == 0)
        nb = sqrt(norm(beta));
        delta(k) = fdiffstep * (nb + (nb==0));
    else
        delta(k) = fdiffstep*beta(k);
    end
    yplus = model(beta+delta,X);
    dy = yplus(:) - yfit(:);
    dy(nans) = [];
    J(:,k) = dy/delta(k);
    delta(k) = 0;
end
end

% the Geman McClure M-estimator.
function w = GMM(r) 
C = 1.4826*(median(abs(r-median(r))));
w = 1./(r.^2 + C^2);
end

function s = madsigma(r,p)
%MADSIGMA    Compute sigma estimate using MAD of residuals from 0
n = length(r);
rs = sort(abs(r));
s = median(rs(max(1,min(n,p)):end)) / 0.6745;
end