% RunningProportion
%
% Goal: Toss a coin N times and compute the running proportion of heads.
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all
clear all

N			= 500;	% Specify the total number of flips, denoted N.
% Generate a random sample of N flips for a fair coin (heads=1, tails=0);
flipsequence = binornd(ones(1,N),.5);

% Compute the running proportion of heads:
r			= cumsum(flipsequence); % The function "cumsum" is built in to Matlab.
n			= 1:N; % n is a vector.
runprop		= r./n; % component by component division.
% Graph the running proportion:
h = semilogx(n,runprop,'ko-');
xt = [1 2 5 10 20 50 100 200 500];
set(h,'MarkerFaceColor','w');
set(gca,'XTick',xt,'XTickLabel',xt,'TickDir','out');
axis([1 N 0 1]);
xlabel('Flip number');
ylabel('Proportion heads');
title('Running proportion of heads');
box off
axis square;

% Plot a dotted horizontal line at y=.5, just as a reference line:
pa_horline(.5,'k:');
% % Display the beginning of the flip sequence. These string and character
% % manipulations may seem mysterious, but you can de-mystify by unpacking
% % the commands starting with the innermost parentheses or brackets and
% % moving to the outermost.
flipletters = 'TH';
flipletters = flipletters(flipsequence(1:10)+1);
displaystring = ['Flip sequence = ' flipletters '...'];
text(5,.9,displaystring);
% % Display the relative frequency at the end of the sequence.
str = ['End Proportion =',num2str(runprop(N))];
text(N,.3, str,'HorizontalAlignment','right')
% To save graph
if ispc
	print('-depsc','-painter',mfilename);
elseif ismac
	print('-depsc','-painters',mfilename);
end
	