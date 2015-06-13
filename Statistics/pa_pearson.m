function [r,prob,z] = pearson(x,y,mode)

% function (r,prob,z) = PEARSON(x,y,mode) computes the correlation
% coefficient r, Student's t probabilty prob, and Fisher's z
% for two vectors x and y. Adapted from Press, Teukolsky, Vetterling
% and Flannery, Numerical Recipes in Fortran p632. 1e-20 terms allow
% for perfect correlation. Checked with example on p187 of Numerical
% Recipes Example Book
%
% Version 1.0 RHS 8/11/93
% Version 1.1 RHS 1/3/94
%		% mode argument added

if nargin<3
	mode=1;		% default is return only r
end

xl=length(x); yl=length(y);	% check vectors are same length
if xl~=yl
	error('Vectors must be the same length')
end

meanx=mean(x);meany=mean(y);	% find means

rnum=sum((x-meanx).*(y-meany));			% numerator of r
rdenom=sqrt(sum((x-meanx).^2)*sum((y-meany).^2));	% denominator of r
r=rnum/rdenom;

if mode~=1
	z=0.5*log((1+r+1e-20)/(1-r+1e-20));	% Fisher's z transformation

	t=r*sqrt((xl-2)/((1-r+1e-20)*(1+r+1e-20)));	% t statistic
	prob=betainc((xl-2)/(xl-2+t^2),0.5*(xl-2),0.5);	% Student's t probability
else
	z=0;prob=0;
end
