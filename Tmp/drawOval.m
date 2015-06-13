% function [h, j] = drawOval(centerX, centerY, R, lineStyle, markChar, markSize, displayOn, sigma) 

%| function [h, j] = drawOval(centerX, centerY, R, lineStyle, markChar, markSize, displayOn, sigma) 
%| 
%| INPUTS: 
%|   (centerX, centerY) define the center of the oval. 
%|   R is a covariance matrix of which we want to plot the 1-sigma 
%|     uncertainty ellipse. 
%|   The oval is drawn with axis lengths equal to the std deviation on each axis, 
%|     and axis equal to the eigenvectors of R.  
%|   The 'linestyle' string must have the first character as a color (eg 'r') 
%| 
%|  Neal Patwari, 10/1/03  (http://www.engin.umich.edu/~npatwari/) 
%| 

function h = drawOval(Mu,SD,Phi,varargin)
% PA_ELLIPSEPLOY(MU,SD,A)
%
%  draw an ellipse with long and short axes SD(1) and SD(2)
%  with orientation A (in deg) at point Mu(1),Mu(2).
%
% see also PA_ELLIPSE

% 2011  Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

if nargin<1
	Mu = [0 0];
	SD = [1 1];
end
%% Initialization
col         = pa_keyval('Color',varargin);
if isempty(col)
    col = 'k';
end
Xo	= Mu(1);
Yo	= Mu(2);
Xr	= SD(1);
Yr	= SD(2);
DTR = pi/180;

%% Ellipse
wt  = (0:.1:360).*DTR;
X   = cos(wt);
Y   = sin(wt);

% % x&2/a^2+y^2*t(x)/b^2=1
x = -0.3;
t = 1./(1-x*X);
% t = exp(x*X);
Y = Y.*t;

X = Xr*X+Xo;
Y = Yr*Y+Yo;
close all
%% Graphics
h = patch(X,Y,col);
hold on
alpha(h,.2);
set(h,'EdgeColor',col,'LineWidth',2);
pa_verline(x);

%% Rest
% wt = [0 180]*DTR;
% X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
% Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% plot(X,Y,'-','Color',Sty);
% 
% wt = [90 270]*DTR;
% X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
% Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% plot(X,Y,'-','Color',Sty);

return
% % x^2+y^2+z^2*(1.5*cos((z+a/2)/a)))^2=a
% % x&2/a^2+y^2*t(x)/b^2=1
% if nargin<1
% 	 centerX = 1;
% end
% if nargin<2
% 	 centerY = 1;
% end
% if nargin<2
% 	 centerX = 1;
% end
% 
% if ~exist('sigma') 
%     sigma = 1; 
% end 
% if ~exist('displayOn') 
%    displayOn = 0; 
% end 
%  
% if abs(R(1,2)) < eps, 
%    alpha1 = 0; 
%    alpha2 = pi/2; 
%    rads   = sqrt(diag(R)); 
%    v      = [1 0; 0 1]; 
% elseif max(max(R))==inf || max(max(R))== NaN, 
%     disp('Unable to display oval for R') 
%     disp(R); 
%     alpha1=0; 
%     alpha2=pi/2; 
%     rads=[eps eps]; 
% else 
%    [v, d] = eig(R); 
%    alpha1 = atan2(v(2,1),v(1,1)); 
%    alpha2 = atan2(v(2,2),v(1,2)); 
%    rads   = sqrt(diag(d)); 
% end 
% deltaT = 2*pi/100; 
% theta  = 0:deltaT:2*pi; 
% x      = sigma*rads(1).*cos(theta); 
% y      = sigma*rads(2).*sin(theta); 
% xprime = centerX + x.*cos(alpha1) - y.*sin(alpha1); 
% yprime = centerY + x.*sin(alpha1) + y.*cos(alpha1); 
% h = plot(xprime, yprime, lineStyle); 
% set(h,'LineWidth',2) 
% j = plot(centerX, centerY, sprintf('%s%s',lineStyle(1), markChar)); 
% if exist('markSize'), 
%    set(j,'MarkerSize',markSize) 
%    set(j,'MarkerFaceColor',lineStyle(1)) 
% end 
% if displayOn, 
%     R 
%     v 
%     rads 
%     disp([alpha1, alpha2]) 
%    axis1 = [v(:,1), -v(:,1)] * rads(1) * 1.1; 
%    axis2 = [v(:,2), -v(:,2)] * rads(2) * 1.1; 
%    plot(centerX + axis1(1,:), centerY + axis1(2,:), 'k:') 
%    plot(centerX + axis2(1,:), centerY + axis2(2,:), 'k:') 
%    set(gca,'ylim',[-0.1 1.1]) 
%    set(gca,'xlim',[-0.1 1.1]) 
%    grid 
%    set(gca,'DataAspectRatio',[1,1,1]) 
% end 