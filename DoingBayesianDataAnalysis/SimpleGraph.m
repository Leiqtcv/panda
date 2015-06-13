% SimpleGraph
%
% Plot a simple graph of a square function
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij


%% Data
x = -2:0.1:2; % specify vector of x values
y = x.^2; % Specify corresponding y values.

%% Graph
plot(x,y,'k-'); % Make a graph of the x,y points.

xlabel('x'); % set a label for the ordinate
ylabel('y'); % set a label for the abscissa
axis square; % make the figure square
box off; % just removing the upper and left outline of the box in which the data is plotted
set(gca,'TickDir','out'); % and the ticks on the axes are directed outwards

%% To save graph
if ispc
	print('-depsc','-painter',mfilename);
elseif ismac
	print('-depsc','-painters',mfilename);
end