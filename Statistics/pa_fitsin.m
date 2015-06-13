function Par = pa_fitsin(X,Y,Inipar)
% PA_FITSIN   Fit a sine through data.
%
%   PAR = FITSIN(X,Y) returns parameters of the sine a*sin(b*X+c)+d,
%   in the following order: [a b c d].
%
%   See also FMINSEARCH, NORM

% 2011, Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

if nargin<3
  Inipar(1)=15000;
  Inipar(2)=pi/180;
  Inipar(3)=0;
  Inipar(4)=0;
end
Par = fminsearch(@sinerr,Inipar,[],X,Y);

function y = sinfun(X,Par)
% SINFUN   Function of the sine a*sin(b*X+c)+d.
a = Par(1);
b = Par(2);
c = Par(3);
d = Par(4);
y = a*sin(b*X+c)+d;

function err =  sinerr(Par,X,Y)
%SINERR   Determines error between experimental data and calculated sine.
%   [ERR]=SINERR(PAR,X,Y) returns the error between the calculated parameters
%   PAR, given by FITSIN and the parameters given by experimental data X and Y.
err = norm(Y-sinfun(X,Par));
% chi = norm((Y-sinfun(X,beta))./sd);



