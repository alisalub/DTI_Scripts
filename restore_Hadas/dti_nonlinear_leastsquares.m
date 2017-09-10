function [ beta, cause ] = dti_nonlinear_leastsquares(S, B, b, model)
% perform a non-linear least squares fit using levenberg marquardt
% code adapted and optimized from ExploreDTI sources, primary credit goes 
% to Alexander Leemans
% input :
%       S       :       DW-MRI signal data
%       B       :       modified b-matrix for initial linear least squares
%                       fit
%       b       :       unmodified (actual) b-matrix for nonlinear least
%                       squares fit.
%       model   :       Diffusion tensor fitting equation.
% 
% output :
%       beta    :       fitted diffusion tensor parameters
%       cause   :       flag indicating reason for levenberg marquardt
%                       termination
%                           Value 1 : terminated due to fitting tolerance,
%                                     i.e. fitted values changed negligably
%                                     between iterations.
%                           Value 2 : terminated due to residual tolerance,
%                                     i.e. residuals changed negligably
%                                     between fitting iterations
%                           Value 3 : terminated due to break out, i.e.
%                                     fitting reached a position at which 
%                                     no increase in lambda would yeald 
%                                     an improved fit.
%                           Value 4 : terminated due to exceeding iteration
%                                     limit. If a significant proportion of
%                                     your data terminates due to this
%                                     condition consider increasing the
%                                     iteration limit variable "maxiter"


% initial linear least squares estimate
covar = diag(S.^2);
X = (B'*covar*B)\(B'*covar)*log(S);
beta = [exp(X(1)); X(2:end)];

% levenberg marquard fitting parameters
maxiter     = 200;              % number of fitting iterations
betatol     = 1.0000e-008;      % tolerance for change in fitted parameters
rtol        = betatol;          % tolerance for change in sum of squared errors
fdiffstep   = 6.0555e-006;      % the finite difference step for jacobian estimation
funValCheck = 0;                % whether or not to check solutions for nans/inf's

% initial weight
lambda = 0.01;

% iteration step
sqrteps = sqrt(eps(class(beta)));

p = numel(beta);

% deal with nans
yfit = model(beta, b);
r = S(:) - yfit(:);
nans = (isnan(S(:)) | isnan(yfit(:))); % a col vector
r(nans) = [];

% sum of squared errors
sse = r'*r;

% output information
zerosp = zeros(p, 1, class(r));
iter = 0;
breakOut = false;
cause = 0;

while iter < maxiter
    
    % store the last iterations result
    iter = iter + 1;
    betaold = beta;
    sseold = sse;

    % estimate jacobian
    J = get_jacobian(beta, fdiffstep, model, b, yfit, nans);
    
    % Levenberg-Marquardt step: inv(J'*j+lambda*D)*J'*r
    diagJtJ = sum(abs(J).^2, 1);
    
    % check if the jacobian gave sensible output
    if funValCheck && ~all(isfinite(diagJtJ))
        % provide an error if anything resulted in a nan or inf
       	if any(~isfinite(J))
            error('stats:nlinfit:NonFiniteFunOutput', ...
                  'MODELFUN has returned Inf or NaN values.');
        end
    end
    Jplus = [J; diag(sqrt(lambda*diagJtJ))];
    rplus = [r; zerosp];
    step = Jplus \ rplus;
    
    % update the current fit by the suggested step
    beta(:) = beta(:) + step;
    
    % Evaluate the fitted values at the new coefficients and comput the
    % residuals and SSE
    yfit = model(beta, b);
    r = S(:) - yfit(:);
    r(nans) = [];
    sse = r'*r;
    
    % check if the sum of squared errors gave sensible output
    if funValCheck && ~all(isfinite(sse))
        % provide an error if anything resulted in a nan or inf
       	if any(~isfinite(r))
            error('stats:nlinfit:NonFiniteFunOutput', ...
                  'MODELFUN has returned Inf or NaN values.');
        end
    end
    
    % if the sum of squared errors improved
    if sse < sseold
        % reduce the lambda by a factor of 10
        % up to a minimum step size determined by 
        % the systems hardware
        lambda = max(0.1*lambda, eps);
    
    % if the step increased the sum of squared errors
    % repeatedly increase lambda to upweight the steepest descent 
    % direction and decrease the step size until we get a step that does
    % decrease the sum of squared errors
    else
        
        while sse > sseold
            lambda = 10*lambda;
            
            % if lambda becomes too large, declare break out and stop the
            % iteratations
            if lambda > 1e16;
                breakOut = true;
                break
            end
            % calculate a new step
            Jplus = [J; diag(sqrt(lambda*sum(J.^2, 1)))];
            step  = Jplus \ rplus;
            % apply that step and refit the model
            beta(:) = betaold(:) + step;
            yfit = model(beta, b);
            r = S(:) - yfit(:);
            r(nans) = [];
            sse = r'*r;
            
            % check if the sum of squared errors gave sensible output
            if funValCheck && ~all(isfinite(sse))
                % provide an error if anything resulted in a nan or inf
                if any(~isfinite(r))
                    error('stats:nlinfit:NonFiniteFunOutput', ...
                          'MODELFUN has returned Inf or NaN values.');
                end
            end
        end
    end
    
    % Check step size and change in SSE for convergence
    if norm(step) < betatol*(sqrteps+norm(beta))
        cause = 1;
        break;
    elseif abs(sse-sseold) <= rtol*sse
        cause = 2;
        break
    elseif breakOut
        cause = 3;
        break
    end
end
if (iter >= maxiter)
    cause = 4;
end

end

% estimate Jacobian using finite difference method
function [ J ] = get_jacobian(beta, fdiffstep, model, X, yfit, nans)

% number of fit parameters (7 for DTI)
p = numel(beta);
delta = zeros(size(beta));

% storage for the jacobian matrix
% J = zeros( length(X), p );

% for each fitted parameter
for k=1:p
    
    % perturb the parameter by a small (finite ammount)
    if (beta(k) == 0)
        nb = sqrt(norm(beta));
        delta(k) = fdiffstep * (nb + (nb==0));
    else
        delta(k) = fdiffstep * beta(k);
    end
    % and calculate the change in fit caused by that alteration
    yplus = model(beta+delta, X);
    dy = yplus(:) - yfit(:);
    dy(nans) = [];
    J(:, k) = dy/delta(k);
    delta(k) = 0;
end

end
