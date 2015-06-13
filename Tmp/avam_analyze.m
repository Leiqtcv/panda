function avam_analyze
%% Clean
close all
% clear all

%% Load
cd('/Users/marcw/DATA/Student/Marleen/DATA') % change this to your own liking, as set by avam_readdat
load('allavamdata');

% Note that all reaction times are (or will be) defined relative to the onset of the
% sound modulation. As such it is by definition not a reaction time, as the
% subject could react to the LED intensity change...

%% Selection
% subjects = {'MH','MF','PB','RG','RM','NB','TB'};
% save('allavamdata','PER','DT','RTSND','RTLED','INT','SUB');

% Select subjects, and apply selection to all parameters
sel			= ismember(SUB,1:7);
PER			= PER(sel); %#ok<*NODEF> % modulation period (ms)
INT			= INT(sel); % LED intensity (au)
RTSND		= RTSND(sel); % time re sound (ms)
RTLED		= RTLED(sel); % time re LED (ms)
DT			= DT(sel); % time delays, SOA (ms)
RT			= RTSND; % Response time re sound

% Select NAN-reaction times in SND, and then replace with RT LEDs
sel				= isnan(RTSND);
RT(sel)			= RTLED(sel);

PER(isnan(PER))	= 0; % if there is no sound modulation, let's arbitrarily define period as 0 (instead of NaN or Inf).

%% Define the unique modulation periods, delays, intensities
% and determine the number of variables
% this is useful for later selection in for-loops
uper				= unique(PER);
nper				= numel(uper);
uint				= unique(INT);
nint				= numel(uint);
udt					= unique(DT(~isnan(DT)));
ndt					= numel(udt);



%%
t = 0:1:1000; % time intervals for reaction time density estimation (ms)

%% Some extra plots
figure(901)
% plotvisual(xV);
% plotinvdata(x,xA,xV,t,ulrich,gielen,colonius); % inverse probit plot
% unimodal visual
col = [0.6 0 0; 0.9 0 0];
for ii = 1:2
	sel					= PER==0 & INT==uint(ii) & ~isnan(RTLED); % selection vector
	rtV					= RTLED(sel);
	xV			= getcdf(rtV,t);
	[~,h(ii)] = plotprobit(xV,col(ii,:));
end
xtick	= sort(-1./(250+[0 pa_oct2bw(50,-1:3)])); % some arbitrary xticks
set(gca,'XTick',xtick,'XTickLabel',-1./xtick);
set(gca,'TickDir','out');
xlim([min(xtick) max(xtick)]);
legend(h,{'40';'80'},'Location','SE');
xlabel('Reaction time');
title('LED intensity change');
print('-depsc','-painters',['LEDunimodal']);


%% Some extra plots
figure(902)
% plotvisual(xV);
% plotinvdata(x,xA,xV,t,ulrich,gielen,colonius); % inverse probit plot
% unimodal visual
% col = [0 0.6 0;0 0.7 0;0 0.8 0;0 0.9 0];
% col = [0 0 0.6;0 0 0.7;0 0 0.8;0 0 0.9];
col = parula(4);
for ii = 2:5
		% unimodal auditory
			sel					= PER==uper(ii) & INT==100 & ~isnan(RTLED); % selection vector
			rtA					= RTSND(sel);
			xA			= getcdf(rtA,t);
	[~,h(ii-1)] = plotprobit(xA,col(ii-1,:));
end
xtick	= sort(-1./(300+[0 pa_oct2bw(50,-1:3)])); % some arbitrary xticks
set(gca,'XTick',xtick,'XTickLabel',-1./xtick);
set(gca,'TickDir','out');
xlim([min(xtick) max(xtick)]);
legend(h,num2str(round(uper(2:5))),'Location','SE');
xlabel('Reaction time');
title('Sound envelope modulation');
print('-depsc','-painters',['Aunimodal']);

return
% Loop through all LED intensities,sound modulation periods, and time
% delays/ stimulus onset asynchronies
% Determine response times per condition, in every iteration
% also the unimodal response times are determined in every iteration
% the LED rt is adjusted to take into account the SOA
% three race models are determined (statistical facilitation, ulrich/coactivation/sum and
% colonius/inhibitory/max), first by estimating the cumulative probability
% densities of the actual responses
D = NaN(nint-1,nper-1,ndt);
B = D;
G = D;
BA = D;
GA = D;
BV = D;
GV = D;
for kk = 1:ndt; % SOA
	for ii = 1:nint-1 % Intensities, except for 100 condition, as this is no change
		cnt = 0; % counter
		for jj = 2:nper % for all periods, except 0, as this is no change
			cnt = cnt+1; % counting
			
			%% bimodal
			sel					= PER==uper(jj) & INT==uint(ii) & DT==udt(kk); % selection vector
			rt					= RTSND(sel); % bimodal response time
			x			= getcdf(rt,t); % density estimation
			% 			Nbi  = sum(sel);
			
			% unimodal auditory
			sel					= PER==uper(jj) & INT==100 & ~isnan(RTLED); % selection vector
			rtA					= RTSND(sel);
			[xA,~,ksA]			= getcdf(rtA,t);
			% 			Na = sum(sel);
			% unimodal visual
			sel					= PER==0 & INT==uint(ii) & ~isnan(RTLED); % selection vector
			rtV					= RTLED(sel)-udt(kk);
			[xV,~,ksV]			= getcdf(rtV,t);
			% 			Nv = sum(sel);
			
			% 			[Nbi Na Nv]
			% race models
			ulrich				= ksA+ksV; 		% race ulrich, SUM
			ulrich(ulrich>1)	= 1;
			colonius			= max(ksA,ksV); 		% race colonius, MAX
			gielen				= ksA+ksV-ksA.*ksV; % Statistical facilitation
			

			figure(kk)
			subplot(2,4,(jj-1)+(ii-1)*4)
			[b,bA,bV] = plotinvdata(x,xA,xV,t,ulrich,gielen,colonius); % inverse probit plot
			% plot difference cdfs
			B(ii,jj-1,kk) = b.beta(1);
			G(ii,jj-1,kk) = b.beta(2);
			
			BA(ii,jj-1,kk) = bA.beta(1);
			GA(ii,jj-1,kk) = bA.beta(2);
			
			BV(ii,jj-1,kk) = bV.beta(1);
			GV(ii,jj-1,kk) = bV.beta(2);
			
			

			
		end
	end
end



%% Nice contour plots of bias and gain / offset and slopes of linear fits to inverse-probit data
plotfit(B,BA,BV,udt,uper,1);
plotfit(G,GA,GV,udt,uper,2);


%% Helper functions
function [x,y,ks] = getcdf(rt,t)
x	= sort((rt)); % sort rt from low to high
n	= numel(rt); % number of data points
y	= linspace(0,1,n); % a probability scale
ks	= ksdensity(rt,t,'function','cdf','bandwidth',20); % estimate the cumulative density function by means of Gun-Wodka

function [b,bA,bV] = plotinvdata(x,xA,xV,t,ulrich,gielen,colonius)
b	= plotprobit(x,[0 .7 0]);
bA	= plotprobit(xA,[0 0 .9]);
bV	= plotprobit(xV,[0.8 0 0]);


ks = pa_probit(gielen);
plot(-1./t,ks,'k-','LineWidth',2);
ks = pa_probit(ulrich);
plot(-1./t,ks,'k-');
ks = pa_probit(colonius);
plot(-1./t,ks,'k-');
drawnow

function [b,h] = plotprobit(x,col)

% rename
sel		= ~isnan(x) &x <1000 & x>100;
rt		= x(sel);
x		= -1./sort(rt); % inverse reaction time / promptness (ms-1)

% raw data
n		= numel(x); % number of data points
p		= (1:n)./(n+.01);
y		= pa_probit(p); % cumulative probability for every data point converted to probit scale

% quantiles
p		= [1 2 5 10:10:90 95 98 99]/100;
probit	= pa_probit(p);
xtick	= sort(-1./(150+[0 pa_oct2bw(50,-1:4)])); % some arbitrary xticks

% this should be a straight line
b.beta	= robustfit(x,y); % remove 'outlier' influence

% plot
plot(x,y,'g.','Color',col,'LineWidth',2);
hold on
% plot(-1./t,ksy,'k-','Color',col);
set(gca,'XTick',xtick,'XTickLabel',-1./xtick);
xlim([min(xtick) max(xtick)]);
set(gca,'YTick',probit,'YTickLabel',p*100);
ylim([pa_probit(0.1/100) pa_probit(99.9/100)]);
axis square;
box off
h		= pa_regline(b.beta,'k-');
set(h,'Color',col,'LineWidth',2);
xlabel('Response time re sound modulation onset (ms)');
ylabel('Cumulative probability');

function plotfit(B,BA,BV,udt,uper,typ)

for idx = 1:2
	%% Plot the median difference between race model and actual data
	% interpolation, to make figure look smooth and nice
	d		= squeeze(BA(idx,:,:));
	XI		= linspace(min(udt),max(udt),100);
	YI		= linspace(uper(2),uper(end),100);
	[XI,YI] = meshgrid(XI,YI);
	ZI		= interp2(udt,uper(2:end),d,XI,YI);
	
	figure(100+typ)
	subplot(2,3,1+(idx-1)*3)
	[~,h]	= contourf(XI,YI,ZI,50);
	hold on
	x		= udt;
	y		= uper(2:end);
	[x,y]	= meshgrid(x,y);
	plot(x,y,'ko','MarkerFaceColor','w');
	axis square;
	set(gca,'YDir','normal','XTick',udt,'YTick',ceil(uper(2:end)),'TickDir','out');
	colorbar;
	shading(gca, 'flat');
	set(h,'LineColor','none');
	xlabel('LED re Sound onset (ms)');
	ylabel('Modulation period (ms)');
	
	d		= squeeze(BV(idx,:,:));
	XI		= linspace(min(udt),max(udt),100);
	YI		= linspace(uper(2),uper(end),100);
	[XI,YI] = meshgrid(XI,YI);
	ZI		= interp2(udt,uper(2:end),d,XI,YI);
	
	subplot(2,3,2+(idx-1)*3)
	[~,h]	= contourf(XI,YI,ZI,50);
	hold on
	x		= udt;
	y		= uper(2:end);
	[x,y]	= meshgrid(x,y);
	plot(x,y,'ko','MarkerFaceColor','w');
	axis square;
	set(gca,'YDir','normal','XTick',udt,'YTick',ceil(uper(2:end)),'TickDir','out');
	colorbar;
	shading(gca, 'flat');
	set(h,'LineColor','none');
	xlabel('LED re Sound onset (ms)');
	ylabel('Modulation period (ms)');
	if idx==1
		title('LED Intensity = 40');
	else
		title('LED Intensity = 80');
	end
	
	d		= squeeze(B(idx,:,:));
	XI		= linspace(min(udt),max(udt),100);
	YI		= linspace(uper(2),uper(end),100);
	[XI,YI] = meshgrid(XI,YI);
	ZI		= interp2(udt,uper(2:end),d,XI,YI);
	
	subplot(2,3,3+(idx-1)*3)
	[~,h]	= contourf(XI,YI,ZI,50);
	hold on
	x		= udt;
	y		= uper(2:end);
	[x,y]	= meshgrid(x,y);
	plot(x,y,'ko','MarkerFaceColor','w');
	axis square;
	set(gca,'YDir','normal','XTick',udt,'YTick',ceil(uper(2:end)),'TickDir','out');
	colorbar;
	shading(gca, 'flat');
	set(h,'LineColor','none');
	xlabel('LED re Sound onset (ms)');
	ylabel('Modulation period (ms)');
end

if typ==1
for ii = 1:6
	subplot(2,3,ii)
	caxis([3.5 11])
end
else
	for ii = 1:6
		subplot(2,3,ii)
	caxis([1000 4000])

	end
end

% print('-dpng',['fig' num2str(100+typ)]);
