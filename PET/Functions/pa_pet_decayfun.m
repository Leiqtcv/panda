function A0 = pa_pet_decayfun(beta,At)
% D = PA_PET_DECAYFUN(BETA,X)
%
% Functional decay of PET counts of the form:
% D  = X/A0*exp(-lambda.*dur);
% BETA = [A,DT,THALF]
%
% with A [A0 X] number of counts or Bq with time interval DT (min), and a
% half-time decay of THALF(s) [lambda = log(2)/thalf)].

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
R0		= beta(1);
dt		= beta(2);
thalf   = 109.771; % half-time fluorine-18 (min)
thalf   = thalf*60;	% half-time (s)
lambda  = log(2)/thalf;		% decay constant (1/s)
t1		= 0;

%% Decay
% A0       = 100*At./R0.*exp(-lambda.*dt);
A0 = At.*exp(lambda*t1)*lambda*dt./(1-exp(-lambda*dt)); %decay-corrected radioactivity (counts)
A0 = 100*A0/R0; % start-amount corrected (MBq)
