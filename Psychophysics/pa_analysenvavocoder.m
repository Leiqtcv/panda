function analysenvavocoder(fname)
% ANALYSENVAVOCODER(FNAME)
%
% Analyze/visualize the results of an NVO-vocoder experiment FNAME

% 2012 Erik

%% Initial stuff
if nargin<1
	fname = 'E:\DATA\KNO\NVA\EXP_1_20120702T121231.mat';
	close all;
	clc;
end
[path,fname,ext] = fileparts(fname);
% path = 'C:\Users\Erik Groot Jebbink\Dropbox\TG\M2\M2-4\Matlab\Metingen_experiment';
if ~isempty(path)
	cd(path);
end
fname = [fname ext];

%% load data
load(fname);

%% Analysis
nWords		= 12; % Number of words in a NVA-list
nChan		= 16; % number of channels in vocoder
maxScore	= 36; % one list contains 12 words with 3 phonemes each
chanArray	= 1:nChan;

score		= zeros(nWords+2,nChan); % Initialize score
xyn			= NaN(nChan,3);
for jj = 1:nChan
	start	= nWords*(jj-1)+1; % start of list
	offset	= nWords*(jj); % end of list
	
	kk = 1;
	for ii = start:offset
		score(kk,jj)	= str2double(resultaat_experiment{ii,2}); %#ok<USENS>
		kk = kk+1;
	end
	
	% score v/h kanaal
	percentage		= 100*getperformance(score(1:nWords,jj),maxScore); %determine performance (%)
	perfSD			= 100*std(bootstrp(1000,@getperformance,score(1:nWords,jj),maxScore)); % Bootstrapped standard deviation
	score(13,jj)	= percentage;
	score(14,jj)	= 1.96*perfSD./sqrt(nWords); % 95% confidence interval

	xyn(jj,:) = [jj score(13,jj) nWords]; % data for psychometric fit
end
%% Psychometric function
shape		= 'w';
x			= 0:0.01:nChan+2;

S			= pfit(xyn,'no plot', 'shape',shape, 'n_intervals', 1); % from psignifit tool
params		= S.params.est;% estimated psychometric function parameters
pf			= 100*psi(shape, params, x); % graph
[~,indx]	= min(abs(pf-80));

%% Visualization
figure
h = errorbar(chanArray, score(13,:), score(14,:),'ko','MarkerFaceColor','w','MarkerSize',10,'LineWidth',2);
set(h,'Color',[.7 .7 .7]);
hold on
plot(x,pf,'k-','LineWidth',2);
xlabel ('Number of channels');
ylabel ('Performance (%)');
axis([0 17 -20 120]);
axis square;
pa_horline([0 100]);
ax = axis;
plot([x(indx) x(indx)],[ax(3) 80],'r:','LineWidth',2);
plot([ax(1) x(indx)],[80 80],'r:','LineWidth',2);
set(gca,'Xtick',sort([2:2:16 round(x(indx)*2)/2]),'YTick',0:20:100);
box off;

%% Save figure
pa_datadir;
print('-depsc',mfilename);
print('-dpng',mfilename);

function percentage = getperformance(score,maxScore)
punten			= sum(score);
percentage		= punten/maxScore;