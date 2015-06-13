function [p,d]=pa_ks2test(x1,y1,x2,y2)
% [P,D] = PA_KS2TEST(X1,Y1,X2,Y2)
%
%  Two dimensional Kolmogorov-Smirnov test.
%  Tests wether the two dimensional distributions (x1,y1) and (x2,y2)
%  are different. See also Press et.al. pp 645
%
%  P = significance level
%  D = K-S statistic
%

% (c) 2011 Marc van Wanrooij, Jeroen Goossens


n1 = length(x1);
n2 = length(x2);
d1 = 0;
for ii = 1:1:n1,
  % first use points in the first set as origins
  [fa,fb,fc,fd] = quadct(x1(ii),y1(ii),x1,y1);
  [ga,gb,gc,gd] = quadct(x1(ii),y1(ii),x2,y2);
  d1 = max([d1,abs(fa-ga)]);
  d1 = max([d1,abs(fb-gb)]);
  d1 = max([d1,abs(fc-gc)]);
  d1 = max([d1,abs(fd-gd)]);
end

d2 = 0;
for ii=1:1:n2,
  % Then use points in the second set as origins
  [fa,fb,fc,fd] = quadct(x2(ii),y2(ii),x1,y1);
  [ga,gb,gc,gd] = quadct(x2(ii),y2(ii),x2,y2);
  d2 = max([d2,abs(fa-ga)]);
  d2 = max([d2,abs(fb-gb)]);
  d2 = max([d2,abs(fc-gc)]);
  d2 = max([d2,abs(fd-gd)]);
end;

%% Average the K-S statistics
d		= 0.5*(d1+d2);   
sqen	= sqrt( n1*n2/(n1+n2) );

%% get linear correlation coefficient for each set
r1 = pearsn(x1,y1);
r2 = pearsn(x2,y2);
rr = sqrt(1-0.5*(r1*r1+r2*r2));

%% Estimate the probability 
p = probks( d*sqen/(1+rr*(0.25-0.75/sqen)) );


function [fa,fb,fc,fd]=quadct(x,y,xx,yy)
% Quadrant count
%
%  Given an origin (x,y), and coordinates xx,yy this
%  procedure counts how many of the points are in each
%  quadrant around the origin, and returns the normalized
%  fractions. Quadrants are labeled alphabetically, 
%  counterclockwise from the upper right. 
%  See also Press et. al. pp 648

na = sum( (yy>y)  & (xx>x)  );
nb = sum( (yy>y)  & (xx>=x) );
nc = sum( (yy<=y) & (xx>=x) );
nd = sum( (yy<=y) & (xx>x)  );

nn = length(xx);
ff = 1/nn;
fa = ff*na;
fb = ff*nb;
fc = ff*nc;
fd = ff*nd;

