function [postSummary,histInfo] = pa_plotdist(Samples, varargin)
% PA_PLOTDIST(SAMPLES)
%
% plot the distribution of MCMC parameter sample vector SAMPLES
%
% POSTSUMMARY = PA_PLOTDIST(SAMPLES)
%
% See also 

% Original plotPost in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% 2013, Modified to Matlab code: Marc M. van Wanrooij


%% Check arguments
% At least this is better in R
% Override defaults of hist function, if not specified by user
if nargin<1
	Samples = 1;
end
credMass	= pa_keyval('credMass', varargin); if isempty(credMass), credMass = 0.95; end;
showMode	= pa_keyval('showMode', varargin); if isempty(showMode), showMode = false; end;
showCurve	= pa_keyval('showCurve', varargin); if isempty(showCurve), showCurve = false; end;
compVal		= pa_keyval('compVal', varargin);
ROPE		= pa_keyval('ROPE', varargin);
yaxt		= pa_keyval('yaxt', varargin);
ylab		= pa_keyval('ylab', varargin);
xlab		= pa_keyval('xlab', varargin); if isempty(xlab), xlab = 'Parameter'; end;
xl			= pa_keyval('xlim', varargin); if isempty(xl), xl = minmax([compVal; Samples]'); end;
main		= pa_keyval('main', varargin);
col			= pa_keyval('col', varargin); if isempty(col), col = [.7 .7 .7]; end;
breaks		= pa_keyval('breaks', varargin);
edge		= pa_keyval('edge', varargin); if isempty(edge), edge='w'; end;

%% Determine interesting parameters
postSummary.mean	= mean(Samples);
postSummary.median	= median(Samples);
[mcmcDensity.y,mcmcDensity.x] = ksdensity(Samples);
[~,indx]			= max(mcmcDensity.y);
postSummary.mode	= mcmcDensity.x(indx);
HDI					= HDIofMCMC(Samples,credMass);
postSummary.hdiMass = credMass;
postSummary.hdiLow	= HDI(1);
postSummary.hdiHigh	= HDI(2);

%% Plot histogram.
hold on
if isempty(breaks)
	by=(HDI(2)-HDI(1))/18;
	breaks = unique([min(Samples):by:max(Samples) max(Samples)]);
end

N					= histc(Samples,breaks);
db					= mean(diff(breaks));
histInfo.N			= N;
histInfo.density	= N./db/sum(N);
if ~showCurve
	h = bar(breaks,histInfo.density,'style','histc');
	delete(findobj('marker','*')); % Matlab bug?
	set(h,'FaceColor',col,'EdgeColor',edge);
end
if showCurve
	[densCurve.y,densCurve.x] = ksdensity(Samples);
	h = plot(densCurve.x, densCurve.y,'b-');
	set(h,'Color',col,'LineWidth',2);
end
xlabel(xlab);
ylabel(ylab);
box off
xlim(xl);
title(main);
if ~isempty(yaxt)
	set(gca,'YTick',yaxt);
end

cenTendHt	= 0.9*nanmax(histInfo.density);
cvHt		= 0.7*nanmax(histInfo.density);
ROPEtextHt	= 0.55*nanmax(histInfo.density);

% Display mean or mode:
if ~showMode
	str			= ['mean = ' num2str(postSummary.mean,2)];
	text(postSummary.mean,cenTendHt,str,'HorizontalAlignment','center');
else
	[~,indx]	= max(mcmcDensity.y);
	modeParam	= mcmcDensity.x(indx);
	str			= ['mode = ' num2str(postSummary.mode,2)];
	text(modeParam, cenTendHt, str,'HorizontalAlignment','center');
end

%% Display the comparison value.
if ~isempty(compVal)
	cvCol					= [0 .3 0];
	pcgtCompVal				= round(100*sum(Samples>compVal)/length(Samples)); % percentage greater than
	pcltCompVal				= 100 - pcgtCompVal; % percentage lower than
	plot([compVal compVal],[0.96*cvHt 0],'k-','Color',cvCol,'LineWidth',2);
	str						= [num2str(pcltCompVal) '% < ' num2str(compVal,3) ' < ' num2str(pcgtCompVal) '%'];
	text(compVal,cvHt,str,'HorizontalAlignment','center','Color',cvCol);
	postSummary.compVal		= compVal;
	postSummary.pcGTcompVal = sum(Samples>compVal)/length(Samples);
end
%% Display the ROPE.
if ~isempty(ROPE)
	ropeCol = [.5 0 0];
	pcInROPE = sum(Samples>ROPE(1) & Samples<ROPE(2))/length(Samples);
	plot(ROPE([1 1]),[0 0.96*ROPEtextHt],':','LineWidth',2,'Color',ropeCol);
	plot(ROPE([2 2]),[0 0.96*ROPEtextHt],':','LineWidth',2,'Color',ropeCol);
	
	str = [num2str(round(100*pcInROPE)) '% in ROPE'];
	text(mean(ROPE),ROPEtextHt,str,'Color',ropeCol,'HorizontalAlignment','center');
	
	postSummary.ROPElow		= ROPE(1);
	postSummary.ROPEhigh	= ROPE(2);
	postSummary.pcInROPE	= pcInROPE;
end
%% Additional stuff: To make Matlab figure look more like R figure
ax		= axis;
yl		= ax([3 4]);
ydiff	= yl(2)-yl(1);
yl		= [yl(1)-ydiff/20 yl(2)];
ylim(yl);
set(gca,'TickDir','out');
axis square;

%% Display the HDI.
plot(HDI,[0 0],'k-','LineWidth',4);
str = [num2str(100*credMass,2) '% HDI'];
text(mean(HDI),ydiff/20+ydiff/20,str,'HorizontalAlignment','center');
str = num2str(HDI(1),2);
text(HDI(1),ydiff/20,str,'HorizontalAlignment','center');
str = num2str(HDI(2),2);
text(HDI(2),ydiff/20,str,'HorizontalAlignment','center');



