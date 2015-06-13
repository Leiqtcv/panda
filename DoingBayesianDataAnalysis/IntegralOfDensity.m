% RunningProportion
%
% Graph of normal probability density function, with comb of intervals.
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all
clear all

meanval = 0.0; % Specify mean of distribution.
sdval	= 0.2; % Specify standard deviation of distribution.
xlow	= meanval - 3*sdval; % Specify low end of x-axis.
xhigh	= meanval + 3*sdval; % Specify high end of x-axis.
dx		= 0.02; % Specify interval width on x-axis
% Specify comb points along the x axis:
x = xlow:dx:xhigh;
% Compute y values, i.e., probability density at each value of x:
y = ( 1/(sdval*sqrt(2*pi)) ) * exp( -.5 * ((x-meanval)/sdval).^2 );
% Plot the function. "plot" draws the intervals. "lines" draws the bell curve.
plot(x,y,'k-');
% stem(x,y);
hold on
stem(x,y,'k-','Marker','none');
xlabel('x');
ylabel('p(x)');
title('Normal Probability Density');
xlim([xlow xhigh]);
% Approximate the integral as the sum of width * height for each interval.
area = sum(dx*y);
% Display info in the graph.
text(-sdval,.9*max(y), ['\mu = ' num2str(meanval)],'HorizontalAlignment','right')
text(-sdval,.8*max(y), ['\sigma = ' num2str(sdval)],'HorizontalAlignment','right')
text(sdval,.9*max(y), ['\Deltax = ' num2str(dx)],'HorizontalAlignment','left')
text(sdval,.8*max(y), ['\Sigma_x \Deltax p(x) = ' num2str(area,3)],'HorizontalAlignment','left')

% To save graph
print('-depsc','-painter',mfilename);