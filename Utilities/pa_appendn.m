function X = pa_appendn(X,N,c)
% PA_APPENDN(X,N)
%
% Append N zeros to signal X
%
% PA_APPENDN(X,N,C)
%
% Append N Cs to signal X

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

if nargin<3
	c = 0; % 20 ms
end



X		= X(:);
Nzero	= repmat(c,N,1); %This will create a vector with N zeros
X		= [X; Nzero]; %This pre- and ap-pends the zerovector to the signal

