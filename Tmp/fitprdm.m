% fitprdm
% maximum likelihood fit for Proportional Rate Diffusion Model
% see Palmer et al., J. Vision, 2005
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [b fval]=fitprdm(X,r,n,rt,SErt)

if nargin==0
    for i=1:100
    % fake data (Table 2, Palmer et al.)
    A  = 0.71;
    k  = 21+randn(1)*5;
    tR = 0.347;

    X        = -0.5:0.05:0.5;
    u        = k.*X;
    Pc       = 1./(1+exp(-2*u*A));
    rt       = zeros(size(u));
    rt(u~=0) = A./u(u~=0) .* tanh(A.*u(u~=0)) + tR;
    rt(u==0) = A.^2 + tR;
    RT(i,:)  = rt;
    x(i,:)   = X;
    n        = ones(size(rt)).*50;
    r        = round(n.*Pc);
    n(r>n)   = r(r>n);
    end
    SErt=ones(size(X));   
    clf;
    
    subplot(2,1,1);
    plot(X,rt,'b.');
    ylabel('Reaction Time');
    hold on;

    subplot(2,1,2);
    plot(X,r./n,'b.');
    hold on;
    xlabel('Stimulus Strength');
    ylabel('Probability');
    hold on;

else
    X=X(:);
    r=r(:);
    n=n(:);
    rt=rt(:);
    SErt=SErt(:);

end

% fit the parameters on the simulated data
Opts  = optimset('fminsearch');
Opts  = optimset(Opts,'display','off');

b0  = [1  0.1  0.05]; % first guess for parameters. Should be reasonable to get a good fit.
fun = @(b) nlprdm(b,X,r,n,rt,SErt);
[b, fval ]  = fminsearch(fun,b0,Opts);

if nargin==0
    % compute and plot fit results
    A  = b(1);
    k  = b(2);
    tR = b(3);

    u        = k.*X;
    Pc       = 1./(1+exp(-2*u*A));
    rt(u~=0) = A./u(u~=0) .* tanh(A.*u(u~=0)) + tR;
    rt(u==0) = A.^2 + tR;

    subplot(2,1,1);
    plot(X,rt,'r-');
    subplot(2,1,2);
    plot(X,Pc,'r-');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nl=nlprdm(b,X,r,n,rt,SErt)
% negative log-likelihood function for the model
% see Palmer, Huk & Shadlen, J. Vision, 2005
% X  = coherence level
% r  = observed number of correct responses for each X
% n  = number of trials for each X
% rt = mean observed reaction time for each X

A  = b(1);  % normalized diffusion boundary
k  = b(2);  % normalized rate of accumulation
tR = b(3);  % mean residual time

% normalized rated of accumulation is proportional to stimulus strength
u  = k.*X;
u0 = u==0;
u1 = ~u0;

% predicted psychometric function for accuracy given the parameters
pC = 1./(1+exp(-2.*(u).*A));

% predicted chronometric function for the mean response time
tT     = zeros(size(u));
tT(u1) = A./u(u1) .* tanh(A.*u(u1)) + tR;
tT(u0) = A.^2 + tR;

% Because of the assumed additively of decision and residual time, the
% predicted variability of the total response time is simply
% VAR(tT) = VAR(tD) + VAR(tR)
% VAR_tR     = (0.1.*tR).^2;  %??? how to estimate ???
% VAR_tT     = zeros(size(u));
% VAR_tT(u1) = ( A.*tanh(A.*u(u1))-A.*u(u1).*sech(A.*u(u1)).^2 )./ u(u1).^3 + VAR_tR;
% VAR_tT(u0) = 2/3.*A.^4 + VAR_tR;
% VAR_tT     = 0.2.*ones(size(u));
% measured standard errors
VAR_tT     = SErt;

% Likelihood Lp of the observed proportions of correct responses r/n given the
% predicted proportion correct responses pC
Lp = binopdf(r,n,pC);

% the likelihood Lt of the observed mean response time rT given the predicted
% mean response times tT (Gaussian approximation).
Lt = normpdf(tT,rt,sqrt(VAR_tT./n));
% Lt = normpdf(tT,rt,sqrt(VAR_tT));
for a=1:length(Lt);
if Lt(a)==0; Lt(a)=0.000000000000001;end  % a zero destroys the fitting process. This isn't a very nice solution, but it seems to work.
if Lp(a)==0; Lp(a)=0.000000000000001;end  % a zero destroys the fitting process. This isn't a very nice solution, but it seems to work.
end

% log likelihoods summed over stimulus strength conditions
nl = -sum( log(Lp) + log(Lt) );

% [tT(:) r(:) n(:) rt(:) SErt(:) Lp(:) Lt(:)]
% nl
% pause
