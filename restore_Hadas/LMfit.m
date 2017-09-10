function  [beta,J,iter,cause] = LMfit(X,y, model,beta) 
% Levenberg-Marquardt algorithm for nonlinear regression

% Set up convergence tolerances from options.
maxiter = 200;
betatol = 1.0000e-008;
rtol = 1.0000e-008;
fdiffstep = 6.0555e-006;
funValCheck = 0;
verbose = 0;

% Set initial weight for LM algorithm.
lambda = .01;

% Set the iteration step
sqrteps = sqrt(eps(class(beta)));

p = numel(beta);

% treatment for nans
yfit = model(beta,X);
r = y(:) - yfit(:);
nans = (isnan(y(:)) | isnan(yfit(:))); % a col vector
r(nans) = [];

sse = r'*r;

zerosp = zeros(p,1,class(r));
iter = 0;
breakOut = false;
cause = '';

while iter < maxiter
    iter = iter + 1;
    betaold = beta;
    sseold = sse;

    % Compute a finite difference approximation to the Jacobian
    J = getjacobian(beta,fdiffstep,model,X,yfit,nans);

    % Levenberg-Marquardt step: inv(J'*J+lambda*D)*J'*r
    diagJtJ = sum(abs(J).^2, 1);
    if funValCheck && ~all(isfinite(diagJtJ)), checkFunVals(J(:)); end
    Jplus = [J; diag(sqrt(lambda*diagJtJ))];
    rplus = [r; zerosp];
    step = Jplus \ rplus;
    beta(:) = beta(:) + step;

    % Evaluate the fitted values at the new coefficients and
    % compute the residuals and the SSE.
    yfit = model(beta,X);
    r = y(:) - yfit(:);
    r(nans) = [];
    sse = r'*r;
    if funValCheck && ~isfinite(sse), checkFunVals(r); end
    % If the LM step decreased the SSE, decrease lambda to downweight the
    % steepest descent direction.  Prevent underflowing to zero after many
    % successful steps; smaller than eps is effectively zero anyway.
    if sse < sseold
        lambda = max(0.1*lambda,eps);
        
    % If the LM step increased the SSE, repeatedly increase lambda to
    % upweight the steepest descent direction and decrease the step size
    % until we get a step that does decrease SSE.
    else
        while sse > sseold
            lambda = 10*lambda;
            if lambda > 1e16
                breakOut = true;
                break
            end
            Jplus = [J; diag(sqrt(lambda*sum(J.^2,1)))];
            step = Jplus \ rplus;
            beta(:) = betaold(:) + step;
            yfit = model(beta,X);
            r = y(:) - yfit(:);
            r(nans) = [];
            sse = r'*r;
            if funValCheck && ~isfinite(sse), checkFunVals(r); end
        end
    end 
    if verbose > 2 % iter
        disp(sprintf('      %6d    %12g    %12g    %12g', ...
                     iter,sse,norm(2*r'*J),norm(step)));
    end

    % Check step size and change in SSE for convergence.
    if norm(step) < betatol*(sqrteps+norm(beta))
        cause = 'tolx';
        break
    elseif abs(sse-sseold) <= rtol*sse
        cause = 'tolfun';
        break
    elseif breakOut
        cause = 'stall';
        break
    end
end
if (iter >= maxiter)
    cause = 'maxiter';
end


function checkFunVals(v)
% check if the function has finite output
if any(~isfinite(v))
    error('stats:nlinfit:NonFiniteFunOutput', ...
          'MODELFUN has returned Inf or NaN values.');
end


function J = getjacobian(beta,fdiffstep,model,X,yfit,nans)
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