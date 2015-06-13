function beta = pa_tls(X,Y)
% X = PA_TLS(X,Y)
%
% Total least squares analysis

% 2012: ripped from http://en.wikipedia.org/wiki/Total_least_squares
% see also: http://www.mathworks.nl/products/statistics/examples.html;jsessionid=ea22fa050ecc9a13569f1ee522ab?file=/products/demos/shipping/stats/orthoregdemo.html
%
% e: marcvanwanrooij@neural-code.com

A       = X;
B       = Y;
n       = size(A,2);          % n is the width of A (A is m by n)
C       = [A B];              % C is A augmented with B.
[~,~,V] = svd(C,0);           % find the SVD of C.
VAB		= V(1:n,1+n:end);     % Take the block of V consisting of the first n rows and the n+1 to last column
VBB		= V(1+n:end,1+n:end); % Take the bottom-right block of V.
beta	= -VAB/VBB;
