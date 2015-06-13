function pa_am_hamenkaas
% PA_AM_HAMENKAAS
%
% Do AM everything

%% Initialization
% clean, clear, and close
clc;
close all hidden;
clear all
% files
cd('E:\DATA\Cortex\AM'); % change this directory to your data-set
d			= dir('*.mat');
fnames		= {d.name};
nfiles		= length(d);
% flags
flag.spike	= false;
flag.rt		= true;
% example files: which should be shown and saved
% joe18: inhibition
% joe6707c01b00: onset peak smaller in A
examplefiles = {'joe11311c02b00.mat','joe2105c01b00.mat','thor08406.mat','Thor-2009-10-07-0004.mat','comp'};
% Default
uMF			= pa_oct2bw(2,0:0.5:7);
Nbin		= 32;
col			= pa_statcolor(3,[],[],[],'def',1);
col			= col([2 1 3],:);

%%

tMTFP		= NaN(nfiles,15); tMTFA500	= tMTFP; tMTFA1000	= tMTFP;
rMTFP		= tMTFP; rMTFA500	= tMTFP; rMTFA1000	= tMTFP;
VSP			= tMTFP; VSA500		= tMTFP; VSA1000		= tMTFP;
TSP			= tMTFP; TSA500		= tMTFP; TSA1000		= tMTFP;
P500		= tMTFP; P1000		= tMTFP;
B			= NaN(nfiles,2);
Base		= B; %baseline period regression
M			= B; % maximum onset peak
S			= B; % synchronization onset peak
N			= 0;
rtstruct	= struct([]);
Pcomp = struct([]); A500comp = struct([]);A1000comp= struct([]);
RT500comp = []; RT1000comp = [];
%% For every cell
for ii = 1:nfiles
	
	%% load data
	fname = fnames{ii};
	disp(fname)
	cd('E:\DATA\Cortex\AM');
	load(fname)
	
	%% separate active trials in spike
	[spikeAMA1000,RT1000]	= seldur(SpikeAMA,behAM,1000);
	[spikeAMA500,RT500]		= seldur(SpikeAMA,behAM,500);
	spikeAMP				= SpikeAMP;
	
	%% obtain MTFs
	[tMP,rMP,vsP,tsP,PhiP,~,rayleighP,periodNP,neuronP]					= getmtf(spikeAMP);
	[tMA500,rMA500,vsA500,tsA500,PhiA500,~,rayleighA500,~,neuron500]		= getmtf(spikeAMA500,RT500);
	[tMA1000,rMA1000,vsA1000,tsA1000,PhiA1000,~,rayleighA1000,~,neuron1000]	= getmtf(spikeAMA1000,RT1000);
	rayleigh = [rayleighP; rayleighA500; rayleighA1000];
	ts = [tsP; tsA500; tsA1000];
	% 	if sum(rayleigh>13.8)>1 || sum(ts>0.6)>1% 13.8 = p=0.05
	if true
		
		%% Data
		tMTFP(ii,:)		= tMP;		tMTFA500(ii,:)	= tMA500;		tMTFA1000(ii,:) = tMA1000;
		rMTFP(ii,:)		= rMP;		rMTFA500(ii,:)	= rMA500;		rMTFA1000(ii,:) = rMA1000;
		VSP(ii,:)		= vsP;		VSA500(ii,:)	= vsA500;		VSA1000(ii,:)	= vsA1000;
		TSP(ii,:)		= tsP;		TSA500(ii,:)	= tsA500;		TSA1000(ii,:)	= tsA1000;
		N = N+1;
		
		%% Similarity index
		
		m1 = neuronP.tMTF;	m2 = neuron500.tMTF;	m3 = neuron1000.tMTF;
		SI(ii).t12 = 1-norm(m1-m2)/(norm(m1)+norm(m2)); SI(ii).t13 = 1-norm(m1-m3)/(norm(m1)+norm(m3)); SI(ii).t23 = 1-norm(m1-m3)/(norm(m2)+norm(m3));
		
		m1 = neuronP.rMTF;	m2 = neuron500.rMTF;	m3 = neuron1000.rMTF;
		SI(ii).r12 = 1-norm(m1-m2)/(norm(m1)+norm(m2)); SI(ii).r13 = 1-norm(m1-m3)/(norm(m1)+norm(m3)); SI(ii).r23 = 1-norm(m1-m3)/(norm(m2)+norm(m3));
		
		m1 = neuronP.tsMTF;	m2 = neuron500.tsMTF;	m3 = neuron1000.tsMTF;
		SI(ii).ts12 = 1-norm(m1-m2)/(norm(m1)+norm(m2)); SI(ii).ts13 = 1-norm(m1-m3)/(norm(m1)+norm(m3)); SI(ii).ts23 = 1-norm(m1-m3)/(norm(m2)+norm(m3));
		
		m1 = neuronP.vsMTF;	m2 = neuron500.vsMTF;	m3 = neuron1000.vsMTF;
		SI(ii).vs12 = 1-norm(m1-m2)/(norm(m1)+norm(m2)); SI(ii).vs13 = 1-norm(m1-m3)/(norm(m1)+norm(m3)); SI(ii).vs23 = 1-norm(m1-m3)/(norm(m2)+norm(m3));
		
	
		NP(ii)		= neuronP;
		N500(ii)	= neuron500;
		N1000(ii)	= neuron1000;
		%% Reaction times
		if flag.rt
			figure(670); clf
			[mu500,mu1000] = plotrt(spikeAMA500,spikeAMA1000,RT500,RT1000,col);
			prnt(fname,examplefiles,'rt');
			title(fname);% to know which cell we have
			
			P500(ii,:)	= mu500;
			P1000(ii,:) = mu1000;
			spike		= spikeAMA500;
			stim		= [spike.stimvalues];
			modFreq		= stim(5,:);
			uMF			= unique(modFreq);
			
			rtstruct(ii).RT500 = RT500;
			rtstruct(ii).RT1000 = RT1000;
			spike		= spikeAMA500;
			stim		= [spike.stimvalues];
			modFreq		= stim(5,:);
			rtstruct(ii).MF500 = modFreq;
			spike		= spikeAMA1000;
			stim		= [spike.stimvalues];
			modFreq		= stim(5,:);
			rtstruct(ii).MF1000 = modFreq;
		end
		
		%% Spike raster plot
		if flag.spike
			figure(667); clf
			subplot(131)
			spk_rasterplot(spikeAMP,500,'color',col(1,:));
			subplot(132)
			spk_rasterplot(spikeAMA500,500,'color',col(2,:));
			subplot(133)
			spk_rasterplot(spikeAMA1000,1000,'color',col(3,:));
			prnt(fname,examplefiles,'raster'); % And some example cells printing
			title(fname); % to know which cell we have
		end
		%% Spike-waveform
		figure(668);		clf
		spk_wave(spikeAMP,spikeAMA500,spikeAMA1000,col);
		prnt(fname,examplefiles,'spikewave'); % And some example cells printing
		title(fname); % to know which cell we have
		
		
		%% Spike density
		% 		close all
		figure(201)
		clf
		plotsdf(neuronP,neuron500,neuron1000);
		prnt(fname,examplefiles,'base'); % And some example cells printing
		title(fname); % to know which cell we have
		
		
		% for later group analysis
		%% Spike density function
		spike = [spikeAMA500,spikeAMA1000];
sdf	= pa_spk_sdf(spike,'Fs',1000);

% baseline increase during Active
x			= 200:300;
sdf			= sdf(x);
b			= regstats(sdf,x,'linear','beta');


		B(ii,1) = neuronP.basebeta(2);
		B(ii,2) = b.beta(2);
		
		M(ii,1) = neuronP.peak.max;
		M(ii,2) = neuron500.peak.max;
		M(ii,3) = neuron1000.peak.max;
		
		S(ii,1) = neuronP.peak.sync;
		S(ii,2) = neuron500.peak.sync;
		S(ii,3) = neuron1000.peak.sync;
		
		Brt(ii,1) = neuron500.rtbeta(2);
		Brt(ii,2) = neuron1000.rtbeta(2);
		%%
		% 				keyboard
		%% Period histogram
		figure(666)
		clf
		nMF = numel(uMF);
		periodN = periodNP;
		x = 1:Nbin;
		x = x/Nbin;
		mx = max(periodN(:));
		for mfIdx = 1:nMF
			N = periodN(mfIdx,:);
			
			subplot(3,5,mfIdx)
			h = bar(x,N,1);
			hold on
			
			y = rMP(mfIdx)+tMP(mfIdx)*cos(2*pi*x+PhiP(mfIdx));
			plot(x,y,'k-')
			
			plot(x,N,'k.');
			
			set(h,'FaceColor',[.7 .7 .7],'EdgeColor','none');
			xlim([min(x) max(x)])
			set(gca,'XTick',[],'YTick',[]);
			axis square
			ylim([0 mx*1.1]);
			pa_text(0.1,0.9,num2str(tMP(mfIdx),3));
			pa_text(0.1,0.8,num2str(rMP(mfIdx),3));
			pa_text(0.1,0.7,num2str(1000*PhiP(mfIdx)/(2*pi)/uMF(mfIdx),3));
		end
		title(fname)
		if any(strcmpi(fname,examplefiles));
			pa_datadir;
			print('-depsc','-painter',['periodhist' fname(1:end-4)]);
		end
		
		%%
		
		
		%% MTFs
		figure(101)
		clf
		subplot(121)
		mtffigure(neuronP,neuron500,neuron1000,SI(ii),'tMTF')
		subplot(122)
		mtffigure(neuronP,neuron500,neuron1000,SI(ii),'rMTF')
		prnt(fname,examplefiles,'tMTF');
		
		figure(102)
		clf
		subplot(121)
		vsfigure(neuronP,neuron500,neuron1000,SI(ii),'vsMTF')
		ylim([-0.1 1.1]);
		subplot(122)
		tsfigure(neuronP,neuron500,neuron1000,SI(ii),'tsMTF')
		ylim([-0.1 1.1]);
		prnt(fname,examplefiles,'tsMTF');
		
		figure(103)
		clf
		subplot(121)
		p1 = unwrap(PhiP);
		p2 = unwrap(PhiA500);
		p3 = unwrap(PhiA1000);
		phifigure(p1,p2,p3,rayleighP,rayleighA500,rayleighA1000);
		
		%% Show now
		drawnow
		% 				keyboard
		% 		pause
		
		% Pcomp = [Pcomp,spikeAMP];
		% A500comp = [A500comp,spikeAMA500];
		% A1000comp= [A1000comp,spikeAMA1000];
		% RT500comp = [RT500comp,RT500];
		% RT1000comp = [RT1000comp,RT1000];
		
	end
end

%%
% keyboard

%%
clc
% close all
flag.rt = true;
if flag.rt
	
	figure(700)
	
	
	RT = [rtstruct.RT500];
	modFreq		=  [rtstruct.MF500];
	c = 2;
	sel = RT<1000 & RT>-100;
	RT = RT(sel);
	modFreq = modFreq(sel);
	numel(RT)
	uMF			= unique(modFreq);
	nMF			= numel(uMF);
	prc = NaN(nMF,3);
	for mfIdx = 1:nMF
		sel = modFreq == uMF(mfIdx);
		tmp = prctile(RT(sel),[25 50 75]);
		prc(mfIdx,:) = tmp;
	end
	subplot(121)
	
	X = 1./uMF;
	Y = prc(:,2);
	plot(uMF,Y,'kv','markerFaceColor',col(c,:));
	hold on
	sel = uMF<700 & uMF>.3;
	b = regstats(Y(sel),X(sel),'linear','beta');
	y = b.beta(1)+b.beta(2).*X;
	plot(uMF,b.beta(1)+b.beta(2).*X,'k-','Color',col(c,:));
	b = regstats(prc(sel,1),X(sel),'linear','beta');
	l = b.beta(1)+b.beta(2).*X;
	plot(uMF,b.beta(1)+b.beta(2).*X,'k-','Color',col(c,:));
	b = regstats(prc(sel,3),X(sel),'linear','beta');
	u = b.beta(1)+b.beta(2).*X;
	plot(uMF,b.beta(1)+b.beta(2).*X,'k-','Color',col(c,:));
	E = [l; u];
	pa_errorpatch(uMF,y,E,col(c,:));
	
	
	RT = [rtstruct.RT1000];
	modFreq		=  [rtstruct.MF1000];
	c = 3;
	sel = RT<1000 & RT>-100;
	RT = RT(sel);
	modFreq = modFreq(sel);
	numel(RT)
	
	uMF			= unique(modFreq);
	nMF			= numel(uMF);
	prc = NaN(nMF,3);
	for mfIdx = 1:nMF
		sel = modFreq == uMF(mfIdx);
		tmp = prctile(RT(sel),[25 50 75]);
		prc(mfIdx,:) = tmp;
	end
	subplot(121)
	X = 1./uMF;
	Y = prc(:,2);
	plot(uMF,Y,'k^','markerFaceColor',col(c,:));
	hold on
	sel = uMF<700 & uMF>.3;
	b = regstats(Y(sel),X(sel),'linear','beta');
	y = b.beta(1)+b.beta(2).*X;
	plot(uMF,b.beta(1)+b.beta(2).*X,'k-','Color',col(c,:));
	b = regstats(prc(sel,1),X(sel),'linear','beta');
	l = b.beta(1)+b.beta(2).*X;
	plot(uMF,b.beta(1)+b.beta(2).*X,'k-','Color',col(c,:));
	b = regstats(prc(sel,3),X(sel),'linear','beta');
	u = b.beta(1)+b.beta(2).*X;
	plot(uMF,b.beta(1)+b.beta(2).*X,'k-','Color',col(c,:));
	E = [l; u];
	pa_errorpatch(uMF,y,E,col(c,:));
	
	axis square
	box off
	ylim([0 600]);
	set(gca,'TickDir','out','Xscale','log');
	xlim([1 256*2]);
	uMF = pa_oct2bw(2,0:0.5:7);
	set(gca,'XTick',uMF(1:2:end),'XTickLabel',round(uMF(1:2:end)),'YTick',100:100:500);
	ylabel('Latency (ms)');
	xlabel('Modulation frequency (Hz)');
	
	%
	RT		= [rtstruct.RT500];
	modFreq	= [rtstruct.MF500];
	c = 2;
	sel = RT<1000 & RT>-100;
	RT = RT(sel);
	modFreq = modFreq(sel);
	numel(RT)
	uMF			= unique(modFreq);
	nMF			= numel(uMF);
	p = 10:10:90;
	np = numel(p);
	prc = NaN(nMF,np);
	for mfIdx = 1:nMF
		sel = modFreq == uMF(mfIdx);
		tmp = prctile(RT(sel),p);
		prc(mfIdx,:) = tmp;
	end
	L1 = NaN(np,1);
	St = L1;
	L0 = L1;
	subplot(122)
	hold on
	for Idx = 1:np
		b = regstats(prc(:,Idx),1./uMF,'linear',{'beta','tstat','fstat'});
		L1(Idx) = b.beta(2);
		St(Idx) = b.tstat.pval(2)<0.05;
		% 		S(Idx) = b.fstat.pval<0.05;
		L0(Idx) = median(prc(:,Idx));
		L0(Idx) = b.beta(1);
		
		text(L0(Idx),L1(Idx)/1000+0.02,num2str(p(Idx)),'HorizontalAlignment','center');
	end
	sel = logical(St);
	plot(L0,L1/1000,'k-','MarkerFaceColor',col(c,:),'Color',col(c,:),'MarkerEdgeColor','k')
	hold on
	plot(L0(sel),L1(sel)/1000,'kv-','MarkerFaceColor',col(c,:),'Color',col(c,:),'MarkerEdgeColor','k')
	
	
	%
	RT		= [rtstruct.RT1000];
	modFreq	= [rtstruct.MF1000];
	c = 3;
	sel = RT<1000 & RT>-100;
	RT = RT(sel);
	modFreq = modFreq(sel);
	numel(RT)
	uMF			= unique(modFreq);
	nMF			= numel(uMF);
	p = 10:10:90;
	np = numel(p);
	prc = NaN(nMF,np);
	for mfIdx = 1:nMF
		sel = modFreq == uMF(mfIdx);
		tmp = prctile(RT(sel),p);
		prc(mfIdx,:) = tmp;
	end
	L1 = NaN(np,1);
	St = L1;
	L0 = L1;
	for Idx = 1:np
		b = regstats(prc(:,Idx),1./uMF,'linear',{'beta','tstat','fstat'});
		
		L1(Idx) = b.beta(2);
		St(Idx) = b.tstat.pval(2)<0.05;
		% 		S(Idx) = b.fstat.pval<0.05;
		L0(Idx) = median(prc(:,Idx));
		L0(Idx) = b.beta(1);
		
		text(L0(Idx),L1(Idx)/1000-0.02,num2str(p(Idx)),'HorizontalAlignment','center');
	end
	sel = logical(St);
	subplot(122)
	plot(L0,L1/1000,'k-','MarkerFaceColor',col(c,:),'Color',col(c,:),'MarkerEdgeColor','k')
	hold on
	plot(L0(sel),L1(sel)/1000,'k^-','MarkerFaceColor',col(c,:),'Color',col(c,:),'MarkerEdgeColor','k')
	
	set(gca,'TickDir','out');
	xlim([-10 510]);
	ylim([-0.1 0.4]);
	set(gca,'YTick',0:0.1:0.3,'XTick',0:100:500);
	xlabel('Median latency (ms)');
	ylabel('Period dependence');
	box off
	axis square
end
pa_datadir;
print('-depsc','-painter','RT');

%% Baseline
figure(300)
clf
subplot(221)
plot(Base(:,1),Base(:,2),'kv','MarkerFaceColor',col(2,:));
hold on
plot(Base(:,1),Base(:,3),'k^','MarkerFaceColor',col(3,:));
axis square;
box off
xlim([-0.2 0.8]);
ylim([-0.2 0.8]);
set(gca,'TickDir','out','XTick',0:0.2:0.6,'YTick',0:0.2:0.6);
pa_unityline('k:');
xlabel('\beta_{baseline, passive} ([spikes/s]/ms)');
ylabel('\beta_{baseline, active} ([spikes/s]/ms)');
pa_text(0.1,0.9,char(65));
[~,p,~,stats] = ttest(Base(:,1),Base(:,2));
str = ['t_{P-A500, df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,3)];
pa_text(0.5,0.9,str);
[~,p,~,stats] = ttest(Base(:,1),Base(:,3));
str = ['t_{P-A1000, df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,3)];
pa_text(0.5,0.8,str);

subplot(222)
plot(M(:,1),M(:,2),'kv','MarkerFaceColor',col(2,:));
hold on
plot(M(:,1),M(:,3),'k^','MarkerFaceColor',col(3,:));
axis square;
box off
xlim([-50 750]);
ylim([-50 750]);
set(gca,'TickDir','out','XTick',0:100:700,'YTick',0:100:700);
pa_unityline('k:');
xlabel('Onset_{passive} firing rate (spikes/s)');
ylabel('Onset_{active} firing rate (spikes/s)');
pa_text(0.1,0.9,char(66));
[~,p,~,stats] = ttest(M(:,1),M(:,2));
str = ['t_{P-A500, df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,3)];
pa_text(0.5,0.9,str);
[~,p,~,stats] = ttest(M(:,1),M(:,3));
str = ['t_{P-A1000, df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,3)];
pa_text(0.5,0.8,str);

subplot(223)
sel = ~isnan(Base(:,1)) & (M(:,3)-M(:,1))>-250;

plot(Base(sel,2)-Base(sel,1),M(sel,2)-M(sel,1),'kv','MarkerFaceColor',col(2,:));
hold on
plot(Base(sel,3)-Base(sel,1),M(sel,3)-M(sel,1),'k^','MarkerFaceColor',col(3,:));
axis square;
box off
xlim([-0.2 0.8]);
ylim([-300 100]);
[r,p] = corrcoef(Base(sel,2)-Base(sel,1),M(sel,2)-M(sel,1));
str = ['R^2_{P-A500, df=' num2str(stats.df) '}=' num2str(r(2)^2,2) ', p=' num2str(p(2),3)];
pa_text(0.5,0.9,str);
[r,p] = corrcoef(Base(sel,3)-Base(sel,1),M(sel,3)-M(sel,1));
str = ['R^2_{P-A1000, df=' num2str(stats.df) '}=' num2str(r(2)^2,2) ', p=' num2str(p(2),3)];
pa_text(0.5,0.8,str);
set(gca,'TickDir','out','XTick',0:0.2:0.6,'YTick',-250:50:50);
xlabel('\Delta \beta_{baseline}');
ylabel('\Delta onset peak (spikes/s)');
pa_text(0.1,0.9,char(67));

subplot(224)
plot(S(:,1),S(:,2),'kv','MarkerFaceColor',col(2,:));
hold on
plot(S(:,1),S(:,3),'k^','MarkerFaceColor',col(3,:));
axis square;
box off
set(gca,'TickDir','out');
pa_unityline('k:');
xlabel('Onset synchronisation_{passive}');
ylabel('Onset synchronisation_{active}');
[~,p,~,stats] = ttest(S(:,1),S(:,2));
str = ['t_{P-A500, df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,3)];
pa_text(0.2,0.9,str);
[~,p,~,stats] = ttest(S(:,1),S(:,3));
str = ['t_{P-A1000, df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,3)];
pa_text(0.2,0.8,str);
pa_text(0.1,0.9,char(68));




%%
close all
clc

confmatrix(tMTFP,tMTFA500,tMTFA1000,800,uMF,nMF,'tMTF');

confmatrix(rMTFP,rMTFA500,rMTFA1000,900,uMF,nMF,'rMTF');

confmatrix(TSP,TSA500,TSA1000,1100,uMF,nMF,'tsMTF');

confmatrix(VSP,VSA500,VSA1000,1000,uMF,nMF,'vsMTF');


%% Composite MTFs
close all
figure(201)
clf
compositemtf(NP,N500,N1000,uMF,nMF,'tsMTF',col)

figure(202)
clf
compositemtf(NP,N500,N1000,uMF,nMF,'tMTF',col)

figure(203)
clf
compositemtf(NP,N500,N1000,uMF,nMF,'vsMTF',col)

figure(204)
clf
compositemtf(NP,N500,N1000,uMF,nMF,'rMTF',col)

%% Composite
% keyboard




function [tMTF,rMTF,vsMTF,tsMTF,Phi,uMF,rayleigh,periodN,neuron] = getmtf(spike,RT)
% GETMTF(SPIKE)
%
% Determine modulation transfer functions:
% - first harmonic, magnitude, tMTF
% - average firing rate, DC, rMTF
% - vector strength, vsMTF
% - trial similarity, tsMTF
%
% with corresponding standard deviation, rayleigh statistic, significance, similarity index
% according to "Malone et al 2013 spectral contents affects"
%
% Also determine:
% - best modulation frequency bMF for all four MTFs
% - spike density function SDF (smoothed Gaussian kernel)
% - spontaneous firing rate, with linear rising slope determined from SDF
% - maximum peak, detemined from SDF
% - sound-evoked firing rate (last 400 ms in unmodulated sound interval)
% - bar-release aligned firing rate.
if nargin<2
	RT = [];
end

% Get temporal and rate codes / vector strength and firing rate
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
vsMTF		= NaN(nMF,1); vsMTFsd		= vsMTF; vsMTF2		= vsMTF; q = vsMTF;
tMTF		= vsMTF; tMTFsd		= vsMTF; tMTFp		= vsMTF;
rMTF		= vsMTF; rMTF2		= vsMTF;rMTF2se		= vsMTF; tsMTF		= vsMTF;
tsMTFsd		= vsMTF; Phi			= vsMTF; R			= struct([]);

d			= 0.700;
Nbin		= 32;
ncomp		= 1;
xperiod		= linspace(0,1,Nbin);
periodN		= NaN(nMF,Nbin);

dur			= spike(1).stimvalues(3); % duration umnodulated interval (500 or 1000 ms)

%% Spike density function
neuron.sdf	= pa_spk_sdf(spike,'Fs',1000);

% baseline increase during Active
x			= 200:300;
sdf			= neuron.sdf(x);
b			= regstats(sdf,x,'linear','beta');
neuron.basebeta = b.beta;

% peak due to sound onset
x = 301:401;
sdf = neuron.sdf(x);
[mx,indx] = max(sdf);
neuron.peak.max = mx;
neuron.peak.t = x(indx)-300; % ms re sound onset

% sync during peak
t	= [spike.spiketime];
sel = t>310 & t<340; % start, exclduing response to handle bar
t	= t(sel)-310;
t	= t/30;
nspikes = numel(t);
neuron.peak.sync		= (1/nspikes)*sqrt( sum(cos(t)).^2+sum(sin(t)).^2);

% aligned to bar release
if ~isempty(RT)
	spikert = spike;
	for ii = 1:numel(spikert)
		t  = spikert(ii).spiketime - RT(ii) + 300 -300-dur;
		sel = t>0 & t<500;
		spikert(ii).spiketime = t(sel);
	end
	neuron.sdfrt	= pa_spk_sdf(spikert,'Fs',1000);
	x			= 201:300;
	sdf			= neuron.sdfrt(x);
	b			= regstats(sdf,x,'linear','beta');
	neuron.rtbeta = b.beta;
end

%% Firing rates
ntrials = length(spike);
spontFR = NaN(ntrials,1);
seFR	= spontFR;
meFR	= spontFR;
for ii = 1:ntrials
	t			= spike(ii).spiketime; % spike timings in ms
	sel			= t<=300; % first 300 ms = no sound
	spontFR(ii) = sum(sel)/300*1000; % spontaneous firing rate (spikes/s)
	
	sel			= t>400 & t<300+dur; % unmodulated sound interval, minus first 100 ms to exclude onset peak
	seFR(ii)	= sum(sel)/(dur-100)*1000; % sound-evoked steady-state firing rate
	
	sel			= t>300+dur & t<300+dur+d; % modulated sound interval
	meFR(ii)	= sum(sel)/(dur-100)*1000; % modulation-evoked firing rate
end
neuron.spontFR	= mean(spontFR);
neuron.seFR		= mean(seFR);
neuron.meFR		= mean(meFR);

%% Baseline
% ntrials = numel(spike);
% fr		= NaN(ntrials,1);
% for jj = 1:ntrials
% 	spktime		= spike(jj).spiketime/1000;
% 	sel			= spktime>0.400 & spktime<0.4+0.4;
% 	spktime		= spktime(sel);
% 	nspikes		= numel(spktime);
% 	fr(jj)		= nspikes/400*1000;
% end
% FR = mean(fr);

%% Modulation
dur = dur/1000; % static duration in s
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	ntrials = sum(sel);
	nperiod = floor(d/(1/uMF(ii)));
	maxtime = nperiod*(1/uMF(ii));
	P = [];
	rate = NaN(ntrials,1);
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.300+dur & spktime<d+0.3+dur; % 700 ms modulation duration
		spktime		= spktime(sel)-0.300-dur;
		sel			= spktime<=maxtime;
		rate(jj)	= sum(sel)./maxtime; % average trial firing rate
		spktime		= spktime(sel);
		spktime		= spktime*uMF(ii);
		period		= mod(spktime,1);
		P			= [P period]; %#ok<AGROW>
	end
	Nspikes		= hist(P,xperiod);
	Nspikes		= Nbin*Nspikes/ntrials/(1/uMF(ii))/nperiod; % Convert to firing rate
	X			= fft(Nspikes,Nbin)/Nbin;
	tMTF(ii)	= abs(X(ncomp+1));
	q(ii)		= abs(X(ncomp+1))./sum(abs(X((ncomp+1):end)));
	Phi(ii)		= angle(X(ncomp+1));
	rMTF(ii)	= abs(X(ncomp+0));
	vsMTF(ii)	= tMTF(ii)./rMTF(ii);
	
	vsMTF2(ii)		= vectorstrength(P);
	rMTF2(ii)		= mean(rate);
	rMTF2se(ii)		= std(rate)./sqrt(ntrials);
	periodN(ii,:)	= Nspikes;
	R(ii).rate		= rate;
	
	%% Bootstrapping
	nbs = 100;
	bs = NaN(nbs,1);
	bsVS = NaN(nbs,1);
	for Idx = 1:100
		P = [];
		indx = pa_rndval(1,ntrials,[ntrials,1]);
		bsspk = spk(indx);
		for jj = 1:ntrials
			spktime		= bsspk(jj).spiketime/1000;
			sel			= spktime>0.300+dur & spktime<d+0.3+dur; % 700 ms modulation duration
			spktime		= spktime(sel)-0.300-dur;
			sel			= spktime<=maxtime;
			rate(jj)	= sum(sel)./maxtime; % average trial firing rate
			spktime		= spktime(sel);
			spktime		= spktime*uMF(ii);
			period		= mod(spktime,1);
			P			= [P period]; %#ok<AGROW>
		end
		Nspikesbs		= hist(P,xperiod);
		Nspikesbs		= Nbin*Nspikesbs/ntrials/(1/uMF(ii))/nperiod; % Convert to firing rate
		X			= fft(Nspikesbs,Nbin)/Nbin;
		bs(Idx)	= abs(X(ncomp+1));
		tmp	= abs(X(ncomp+0));
		% 	vsMTF(ii)	= tMTF(ii)./rMTF(ii);
		
		bsVS(Idx)		=bs(Idx)./tmp;
		
	end
	tMTFsd(ii) = std(bs)./sqrt(ntrials);
	[~,tMTFp(ii)] = ttest(bs);
	vsMTFsd(ii) = std(bsVS)./sqrt(ntrials);
	%% Trial similarity
	nhalf	= floor(ntrials/2);
	TS = NaN(1,10);
	for Idx = 1:100;
		rindx	= randperm(ntrials);
		
		P		= [];
		for jj = 1:nhalf
			indx = rindx(jj);
			spktime		= spk(indx).spiketime/1000;
			sel			= spktime>0.300+dur & spktime<d+0.3+dur; % 700 ms modulation duration
			spktime		= spktime(sel)-0.300-dur;
			sel			= spktime<=maxtime;
			spktime		= spktime(sel);
			spktime		= spktime*uMF(ii);
			period		= mod(spktime,1);
			P			= [P period]; %#ok<AGROW>
		end
		Ns1		= hist(P,xperiod);
		Ns1		= Nbin*Ns1/nhalf/(1/uMF(ii))/nperiod; % Convert to firing rate
		
		P		= [];
		for jj = (nhalf+1):(nhalf*2)
			indx = rindx(jj);
			spktime		= spk(indx).spiketime/1000;
			sel			= spktime>0.300+dur & spktime<d+0.3+dur; % 700 ms modulation duration
			spktime		= spktime(sel)-0.300-dur;
			sel			= spktime<=maxtime;
			spktime		= spktime(sel);
			spktime		= spktime*uMF(ii);
			period		= mod(spktime,1);
			P			= [P period]; %#ok<AGROW>
		end
		Ns2		= hist(P,xperiod);
		Ns2		= Nbin*Ns2/nhalf/(1/uMF(ii))/nperiod; % Convert to firing rate
		
		r = corrcoef(Ns1,Ns2);
		r = r(2);
		TS(Idx) = r;
	end
	tsMTF(ii) = nanmean(TS);
	tsMTFsd(ii) = nanstd(TS)./sqrt(nhalf);
end
rayleigh = (tMTF./rMTF).^2*2.*rMTF;

neuron.tMTF		= tMTF;
neuron.tMTFsd	= tMTFsd;
neuron.q		= q;
% neuron.tMTFp	= tMTFp;
% neuron.tMTFp	= (rayleigh<13.8);
% neuron.tMTFp	= tMTF<0.08; % according to uniform spike train simulation, p < 0.001
neuron.tMTFp	= q<0.12; % according to uniform spike train simulation, p < 0.001

neuron.rayleigh = rayleigh;
neuron.rMTF		= rMTF;
neuron.rMTF2	= rMTF2;
neuron.rMTF2se	= rMTF2se;

neuron.vsMTF	= vsMTF;
neuron.vsMTFp	= (rayleigh<13.8);  % according to Mardia and Jupp 2000, p < 0.001
neuron.vsMTFsd	= vsMTFsd;
neuron.vsMTF2	= vsMTF2;
neuron.tsMTF	= tsMTF;
neuron.tsMTFsd	= tsMTFsd;
neuron.tsMTFp	= tsMTF<0.4; % according to Malone et al 2013,  p < 0.001
neuron.tsMTFp	= tsMTF<0.8; % according to uniform spike train simulation, p < 0.001
neuron.MF		= uMF;


%% BMF and significance
% for rBMFs, the best should be different from worst according to WIlcoxon
% ranked sum test
[~,bindx]			= max(rMTF);
[~,windx]			= min(rMTF);
neuron.rBMF.value	= uMF(bindx);
p					= ranksum(R(bindx).rate,R(windx).rate);
neuron.rBMF.p		= p;

p	= NaN(nMF,1);
sd	= NaN(nMF,1);
for ii = 1:nMF
	p(ii)	= ranksum(R(ii).rate,seFR);
	r		= [R(ii).rate];
	sd(ii)	= std(r)./sqrt(numel(r));
end
neuron.rMTFp = p;
neuron.rMTFsd = sd;

function mtffigure(neuron1,neuron2,neuron3,SI,sf)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= neuron1.MF;
hold on

Y = neuron1.(sf);
E = neuron1.([sf 'sd']);
R = neuron1.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(1,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'ko','MarkerFaceColor',col(1,:));

Y = neuron2.(sf);
E = neuron2.([sf 'sd']);
R = neuron2.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(2,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'kv','MarkerFaceColor',col(2,:));

Y = neuron3.(sf);
E = neuron3.([sf 'sd']);
R = neuron3.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(3,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'k^','MarkerFaceColor',col(3,:));

axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ax = axis;
axis([ax(1) ax(2) 0 ax(4)]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

str = [sf(1) '12'];
pa_text(0.1,0.9,num2str(SI.(str)));
str = [sf(1) '13'];
pa_text(0.1,0.8,num2str(SI.(str)));
str = [sf(1) '23'];
pa_text(0.1,0.7,num2str(SI.(str)));

function tsfigure(neuron1,neuron2,neuron3,SI,sf)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= neuron1.MF;
hold on

Y = neuron1.(sf);
E = neuron1.([sf 'sd']);
R = neuron1.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(1,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'ko','MarkerFaceColor',col(1,:));

Y = neuron2.(sf);
E = neuron2.([sf 'sd']);
R = neuron2.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(2,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'kv','MarkerFaceColor',col(2,:));

Y = neuron3.(sf);
E = neuron3.([sf 'sd']);
R = neuron3.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(3,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'k^','MarkerFaceColor',col(3,:));

axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ax = axis;
axis([ax(1) ax(2) 0 ax(4)]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

str = [sf(1:2) '12'];
pa_text(0.1,0.9,num2str(SI.(str)));
str = [sf(1:2) '13'];
pa_text(0.1,0.8,num2str(SI.(str)));
str = [sf(1:2) '23'];
pa_text(0.1,0.7,num2str(SI.(str)));

function vsfigure(neuron1,neuron2,neuron3,SI,sf)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= neuron1.MF;
hold on

Y = neuron1.(sf);
E = neuron1.([sf 'sd']);
R = neuron1.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(1,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'ko','MarkerFaceColor',col(1,:));

Y = neuron2.(sf);
E = neuron2.([sf 'sd']);
R = neuron2.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(2,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'kv','MarkerFaceColor',col(2,:));

Y = neuron3.(sf);
E = neuron3.([sf 'sd']);
R = neuron3.([sf 'p']);
errorbar(uMF,Y,E,'k-','Color',col(3,:));
sel = R<=0.001;
plot(uMF(sel),Y(sel),'k^','MarkerFaceColor',col(3,:));

axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ax = axis;
axis([ax(1) ax(2) 0 ax(4)]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

str = [sf(1:2) '12'];
pa_text(0.1,0.9,num2str(SI.(str)));
str = [sf(1:2) '13'];
pa_text(0.1,0.8,num2str(SI.(str)));
str = [sf(1:2) '23'];
pa_text(0.1,0.7,num2str(SI.(str)));

function B = phifigure(Y1,Y2,Y3,R1,R2,R3)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= pa_oct2bw(2,0:0.5:7);
n		= length(uMF);
hold on


Y = Y1';
R = R1;
x=uMF;
selx = x<65 & x>2;
selr = R>13.8;
b = regstats(Y(selx),x(selx),'linear');
y = b.beta(1)+b.beta(2)*x;
b = robustfit(x(selx),Y(selx));
y = b(1)+b(2)*x;
plot(uMF(selx),y(selx)/(2*pi),'k-','Color',col(1,:));
h1 = plot(x(selr),Y(selr)/(2*pi),'ko','MarkerFaceColor',col(1,:),'MarkerSize',6);
plot(x(~selr),Y(~selr)/(2*pi),'ko','MarkerFaceColor',col(1,:),'MarkerSize',2);
B(1) = b(2);



Y = Y2';
R = R2;
selr = R>13.8;
b = regstats(Y(selx),x(selx),'linear');
y = b.beta(1)+b.beta(2)*x;
b = robustfit(x(selx),Y(selx));
y = b(1)+b(2)*x;
plot(uMF(selx),y(selx)/(2*pi),'k-','Color',col(2,:));
h2 = plot(x(selr),Y(selr)/(2*pi),'ko','MarkerFaceColor',col(2,:),'MarkerSize',6);
plot(x(~selr),Y(~selr)/(2*pi),'ko','MarkerFaceColor',col(2,:),'MarkerSize',2);
B(2) = b(2);

Y = Y3';
R = R3;
selr = R>13.8;

b = regstats(Y(selx),x(selx),'linear');
y = b.beta(1)+b.beta(2)*x;
b = robustfit(x(selx),Y(selx));
y = b(1)+b(2)*x;
plot(uMF(selx),y(selx)/(2*pi),'k-','Color',col(3,:));
h3 = plot(x(selr),Y(selr)/(2*pi),'ko','MarkerFaceColor',col(3,:),'MarkerSize',6);
plot(x(~selr),Y(~selr)/(2*pi),'ko','MarkerFaceColor',col(3,:),'MarkerSize',2);
B(3) = b(2);


axis square
box off
set(gca,'TickDir','out','XScale','log');
xlim([1 256*2]);
ylim([-3 2]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

function h = spk_rasterplot(T,dur,varargin)
% PA_SPK_RASTERPLOT(T)
%
% Display raster plot of spikes in structure T. T should contain spike
% timings for every trial in the field spiketime.
%
% Alternatively, T can be a MxN length vector, with M t
%at times T (in samples) for NTRIAL trials,
% each of length TRIALLENGTH samples, sampling rate = 1kHz. SpikeT are
% hashed by the trial length.
%
% PA_SPK_RASTERPLOT(T,NTRIAL,TRIALLENGTH,FS)
% Plots the rasters using sampling rate of FS (Hz)
%
% H = PA_SPK_RASTERPLOT(T,NTRIAL,TRIALLENGTH,FS)
% Get handle of rasterplot figure
%
% PA_GETPOWER(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'color'	- specify colour of graph. Colour choices are the same as for
%	PLOT (default: k - black).
%
%  Example:
%		Ntrials = 50;
%		Ltrial  = 1000;
%		nspikes = 1000;
%		T       = pa_spk_genspiketimes(nspikes,Ntrials*Ltrial);
%       h       = pa_spk_rasterplot(T,'Ntrials',Ntrials,'Ltrial',Ltrial);
%
% More information:
%		"Spikes - exploring the neural code", Rieke et al. 1999, figure	2.1
%		"Matlab for Neuroscientists", Wallisch et al. 2009,  section 13.3.1

% 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

%% Initialization
Ntrials         = pa_keyval('Ntrials',varargin);
if isempty(Ntrials)
	Ntrials		= 1;
end
Ltrial         = pa_keyval('Ltrial',varargin);
if isempty(Ltrial)
	Ltrial		= round(length(T)/Ntrials);
end
Fs         = pa_keyval('Fs',varargin);
if isempty(Fs)
	Fs			= 1000; % (Hz)
end

%% Plot variables
col         = pa_keyval('color',varargin);
if isempty(col)
	col			= 'k';
end

%% Plot variables
rt         = pa_keyval('rt',varargin);

Ntrials = length(T);
MF = NaN(Ntrials,1);
for ii = 1:Ntrials
	MF(ii) = T(ii).stimvalues(5);
end
[sMF,indx]	= sort(MF);
[usMF,ia]	= unique(sMF,'stable');
T			= T(indx);
if isempty(rt)
	rt = zeros(Ntrials,1);
end

rt			= rt(indx);
mu = nanmean(rt);
hold on;
for ii = 1:Ntrials
	t = T(ii).spiketime;
	t = t/Fs*1000; % spike times in (ms)
	t = t-dur-300;
	if mu~=0
		t = t-rt(ii);
	end
	% 		sel = t>0 & t<700;
	% 		t = t(sel);
	sel = t<700;
	t = t(sel);
	for jj = 1:length(t)
		line([t(jj) t(jj)],[ii-1 ii],'Color',col);
	end
end
% Ticks and labels
ylim([-0.01*Ntrials Ntrials+0.01*Ntrials]);
% 	xlim([-10 710]);
xtr = 300+dur+700;
xtr = xtr*0.01;
xlim([-300-dur-xtr 700+xtr]);

set(gca,'TickDir','out','YTick',ia(1:2:end)-1,'YTicklabel',round(usMF(1:2:end)),'XTick',[-1000 -500 0:250:500]);
xlabel('Time (ms)');
ylabel('Modulation frequency (Hz)');
axis square;
pa_verline([-dur 0],'k-');
pa_horline(ia-1,'k-');
% It is inconvenient to get a line handle for EVERY spike, therefore we just
% give the handle of the current axis
h = gca;

function [Spike,RT] = seldur(spike,beh,dur)
stim			= [spike.stimvalues];

durstat			= stim(3,:);
sel				= durstat == dur;
Spike			= spike(sel);
Spike			= rmfield(Spike,{'timestamp';'stimparams';'trialorder';'trial';'aborted'});

sel				= beh(4,:)==dur; %#ok<*NODEF>
rt				= beh(2,:);
RT				= rt(sel); % Check this

mn              = min(length(Spike),length(RT));
Spike			= Spike(1:mn);
RT				= RT(:,1:mn);

function spk_wave(T1,T2,T3,col)

T = T1;
c = col(1,:);
a = [T.spikewave];
mu = mean(a,2);
mus = smooth(mu);
x = 1:length(mu);
plot(x,mus,'k-','Color',c,'LineWidth',2);
hold on
mu1 = mu;

T = T2;
c = col(2,:);
a = [T.spikewave];
mu = mean(a,2);
b = regstats(mu1,mu,'linear','beta');
mu = b.beta(2).*mu+b.beta(1);
mus = smooth(mu);
x = 1:length(mu);
plot(x,mus,'k-','Color',c,'LineWidth',2);
hold on

T = T3;

c = col(3,:);
a = [T.spikewave];
mu = mean(a,2);
b = regstats(mu1,mu,'linear','beta');
mu = b.beta(2).*mu+b.beta(1);
mus = smooth(mu);
x = 1:length(mu);
plot(x,mus,'k-','Color',c,'LineWidth',2);
hold on

axis square;
box off
set(gca,'TickDir','out');

function [mu500,mu1000] = plotrt(spikeAMA500,spikeAMA1000,RT500,RT1000,col)

spike		= spikeAMA500;
RT			= RT500;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
MU = NaN(nMF,1);
SD = NaN(nMF,1);
whos RT spikeAMA500
for trial = 1:nMF
	sel = modFreq==uMF(trial) & RT>100 & RT<700;
	if sum(sel)
		rt = RT(sel);
		rtinv = 1000./rt;
		MU(trial) = nanmean(rtinv);
		SD(trial) = nanstd(rtinv)./sqrt(sum(sel));
	end
end
errorbar(uMF,MU,SD,'k-','Color',col(2,:))
hold on
plot(uMF,MU,'ko','MarkerFaceColor',col(2,:))
mu500 = MU;

spike		= spikeAMA1000;
RT			= RT1000;
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
MU = NaN(nMF,1);
SD = NaN(nMF,1);
for trial = 1:nMF
	sel = modFreq==uMF(trial) & RT>100 & RT<700;
	rt = RT(sel);
	rtinv = 1000./rt;
	MU(trial) = nanmean(rtinv);
	SD(trial) = nanstd(rtinv)./sqrt(sum(sel));
end

errorbar(uMF,MU,SD,'k-','Color',col(3,:))
hold on
plot(uMF,MU,'ko','MarkerFaceColor',col(3,:))
mu1000 = MU;
axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ax = axis;
axis([ax(1) ax(2) 0 ax(4)]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

function reciprobit(rt,col)
% PA_HOW2RECIPROBIT

% 2013 Marc van Wanrooij
% e: marcvanwanrooij@neural-code.com


%% Inverse reaction time
rtinv	= 1./rt; % inverse reaction time / promptness (ms-1)
x = -1./sort((rt)); % multiply by -1 to mirror abscissa
n = numel(rtinv); % number of data points
y = pa_probit((1:n)./n); % cumulative probability for every data point converted to probit scale
sel = isfinite(y);
x = x(sel);
y = y(sel);
% whos x y
% close all
% plot(x,rt,'.');
%
% %%

% plot(x,y,'k.','Color',col);
hold on;


% quantiles
p		= [1 2 5 10:10:90 95 98 99]/100;
probit	= pa_probit(p);
q		= quantile(rt,p);
q		= -1./q;
xtick	= sort(-1./(250+[0 pa_oct2bw(50,-1:4)])); % some arbitrary xticks
plot(q,probit,'ko-','Color',col,'MarkerFaceColor',col,'LineWidth',1);
hold on
set(gca,'XTick',xtick,'XTickLabel',-1./xtick);
xlim([min(xtick) max(xtick)]);
set(gca,'YTick',probit,'YTickLabel',p*100);
ylim([pa_probit(0.1/100) pa_probit(99.9/100)]);
axis square;
box off
xlabel('Reaction time (ms)');
ylabel('Cumulative probability');
title('Probit ordinate');


% this should be a straight line
theta = 0;

function VS = vectorstrength(T)
N = numel(T);
VS = sqrt( sum(cos(2*pi*T)).^2+sum(sin(2*pi*T)).^2 ) / N;

function prnt(fname,examplefiles,exname)
if any(strcmpi(fname,examplefiles));
	pa_datadir;
	print('-depsc','-painter',[exname fname(1:end-4)]);
end

function plotsdf(neuronP,neuron500,neuron1000)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);
x = 20:300;

sdf = neuronP.sdf(x);
beta = neuronP.basebeta;
subplot(131)
plot(x-300,sdf,'Color',col(1,:))
hold on
plot(x-300,beta(1)+beta(2).*x,'k-','Color',col(1,:),'LineWidth',2);

sdf = neuron500.sdf(x);
beta = neuron500.basebeta;
subplot(131)
plot(x-300,sdf,'Color',col(2,:))
hold on
plot(x-300,beta(1)+beta(2).*x,'k-','Color',col(2,:),'LineWidth',2);

sdf = neuron1000.sdf(x);
beta = neuron1000.basebeta;
subplot(131)
plot(x-300,sdf,'Color',col(3,:))
hold on
plot(x-300,beta(1)+beta(2).*x,'k-','Color',col(3,:),'LineWidth',2);
axis square;
box off
xlim([-10 320]-300);
ax = axis;
ylim([0 ax(4)]);
axis square;
box off;
set(gca,'TickDir','out','XTick',-300:100:0);
xlabel('Time (ms)');
ylabel('Firing rate (spikes/s)');

x = 301:401;

sdf = neuronP.sdf(x);
mx = neuronP.peak.max;
t = neuronP.peak.t;
subplot(132)
plot(x-300,sdf,'Color',col(1,:))
hold on
plot(t,mx,'ko','MarkerFaceColor',col(1,:))

sdf = neuron500.sdf(x);
mx = neuron500.peak.max;
t = neuron1000.peak.t;
subplot(132)
plot(x-300,sdf,'Color',col(2,:))
hold on
plot(t,mx,'ko','MarkerFaceColor',col(2,:))

sdf = neuron1000.sdf(x);
mx = neuron1000.peak.max;
t = neuron1000.peak.t;
subplot(132)
plot(x-300,sdf,'Color',col(3,:))
hold on
plot(t,mx,'ko','MarkerFaceColor',col(3,:))

axis square;
box off
xlim([-10 110]);
ax = axis;
ylim([0 ax(4)]);
axis square;
box off;
set(gca,'TickDir','out','XTick',0:50:100);
xlabel('Time (ms)');
ylabel('Firing rate (spikes/s)');

%

sdf = neuron500.sdfrt;
x = 1:length(sdf);
idx = 100:300;
sdf = sdf(idx);
x = x(idx);
subplot(133)
plot(x-300,sdf,'Color',col(2,:))
hold on

beta = neuron500.rtbeta;
x = 200:300;
hold on
plot(x-300,beta(1)+beta(2).*x,'k-','Color',col(2,:),'LineWidth',2);

sdf = neuron1000.sdfrt;
x = 1:length(sdf);
idx = 100:300;
sdf = sdf(idx);
x = x(idx);
subplot(133)
plot(x-300,sdf,'Color',col(3,:))
hold on
beta = neuron1000.rtbeta;
x = 200:300;
hold on
plot(x-300,beta(1)+beta(2).*x,'k-','Color',col(3,:),'LineWidth',2);

axis square;
box off
xlim([-210 10]);
ax = axis;
ylim([0 ax(4)]);
axis square;
box off;
set(gca,'TickDir','out','XTick',-200:100:0);
xlabel('Time (ms)');
ylabel('Firing rate (spikes/s)');

function confmatrix(MTF1,MTF2,MTF3,fg,uMF,nMF,txt)

col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

figure(fg+1)
sel = ~isnan(MTF1(:,1)) & ~isnan(MTF2(:,1)) & ~isnan(MTF3(:,1));
a = MTF1(sel,:);
b = MTF2(sel,:);
c = MTF3(sel,:);

[~,bfa] = max(a,[],2);
[~,bfb] = max(b,[],2);
[~,bfc] = max(c,[],2);

C = zeros(nMF,nMF);
for ii = 1:nMF
	for jj = 1:nMF
		sel = bfa==ii & bfb==jj;
		C(ii,jj) = sum(sel);
	end
end
coln = 2;
c = pa_statcolor(64,[],[],[],'def',6);
switch coln
	case 1
		c = c(:,[2 1 3]);
	case 3
		c = c(:,[2 3 1]);
	case 2
end
subplot(121)
subimage(C./max(C(:))*64,c);

axis square;
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

% marginal histograms
figure(fg+11)
subplot(121)
h = bar(sum(C));
set(h,'FaceColor',col(2,:));
axis square;
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'TickDir','out');
xlim([0.5 15.5]);

subplot(122)
h = bar(sum(C,2));
set(h,'FaceColor',col(1,:));
axis square;
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'TickDir','out');
xlim([0.5 15.5]);
pa_datadir;
print('-depsc','-painter',[txt mfilename 'b'])
C = zeros(nMF,nMF);
for ii = 1:nMF
	for jj = 1:nMF
		sel = bfa==ii & bfc==jj;
		C(ii,jj) = sum(sel);
	end
end
coln = 3;
c = pa_statcolor(64,[],[],[],'def',6);
switch coln
	case 1
		c = c(:,[2 1 3]);
	case 3
		c = c(:,[2 3 1]);
	case 2
end
figure(fg+1)
subplot(122)
subimage(C./max(C(:))*64,c);
axis square;
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

pa_datadir;
print('-depsc','-painter',[txt mfilename 'a'])

figure(fg+21)
subplot(121)
h = bar(sum(C));
set(h,'FaceColor',col(3,:));
axis square;
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'TickDir','out');
xlim([0.5 15.5]);

subplot(122)
h = bar(sum(C,2));
set(h,'FaceColor',col(1,:));
axis square;
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'TickDir','out');
xlim([0.5 15.5]);

pa_datadir;
print('-depsc','-painter',[txt mfilename 'c'])

function compositemtf(NP,N500,N1000,uMF,nMF,str,col)
subplot(121)

n = numel(NP);
yp = NaN(n,nMF);
y500 = yp;
y1000 = yp;
ypns = NaN(n,nMF);
y500ns = yp;
y1000ns = yp;
for ii = 1:n;
	if any(NP(ii).([str 'p'])<0.001 | N500(ii).([str 'p'])<0.001 | N1000(ii).([str 'p'])<0.001);
% 	if any(NP(ii).([str 'p'])<0.001 | N500(ii).([str 'p'])<0.001 | N1000(ii).([str 'p'])<0.001);
% 		mx = nanmax([NP(ii).(str); N500(ii).(str); N1000(ii).(str)]);
		mx = nanmax(NP(ii).(str));
		switch str
			case {'tMTF','rMTF'}
		yp(ii,:) = 20*log10(NP(ii).(str)/mx);
		y500(ii,:) = 20*log10(N500(ii).(str)/mx);
		y1000(ii,:) = 20*log10(N1000(ii).(str)/mx);
			case {'tsMTF','vsMTF'}
		yp(ii,:) = NP(ii).(str);
		y500(ii,:) = N500(ii).(str);
		y1000(ii,:) = N1000(ii).(str);
		end		
	else
		mx = nanmax(NP(ii).(str));
		switch str
			case {'tMTF','rMTF'}
		ypns(ii,:) = 20*log10(NP(ii).(str)/mx);
		y500ns(ii,:) = 20*log10(N500(ii).(str)/mx);
		y1000ns(ii,:) = 20*log10(N1000(ii).(str)/mx);
			case {'tsMTF','vsMTF'}
		ypns(ii,:) = NP(ii).(str);
		y500ns(ii,:) = N500(ii).(str);
		y1000ns(ii,:) = N1000(ii).(str);
		end		
	end
end
yp(isinf(yp))		= NaN;
y500(isinf(y500))	= NaN;
y1000(isinf(y1000))	= NaN;
ncells				= sum(~isnan(yp(:,1)));

p1 = NaN(nMF,1);
p2 = NaN(nMF,1);
for ii = 1:nMF
	sel = isnan(yp(:,ii)) | isnan(y500(:,ii));
	p1(ii) = signrank(yp(~sel,ii),y500(~sel,ii));
	sel = isnan(yp(:,ii)) | isnan(y1000(:,ii));
	p2(ii) = signrank(yp(~sel,ii),y1000(~sel,ii));
end
sel1 = p1<0.05;
sel2 = p2<0.05;
subplot(121)
mu = nanmean(yp); se = nanstd(yp)./sqrt(ncells);
errorbar(uMF,mu,se,'k-','Color',col(1,:),'MarkerFaceColor',col(1,:),'MarkerEdgeColor','k')
hold on
mu = nanmean(y500); se = nanstd(y500)./sqrt(ncells);
errorbar(uMF,mu,se,'k-','Color',col(2,:),'MarkerFaceColor',col(2,:),'MarkerEdgeColor','k')
plot(uMF(sel1),mu(sel1),'kv','Color',col(2,:),'MarkerFaceColor',col(2,:),'MarkerEdgeColor','k')
mu = nanmean(y1000); se = nanstd(y1000)./sqrt(ncells);
errorbar(uMF,mu,se,'k-','Color',col(3,:),'MarkerFaceColor',col(3,:),'MarkerEdgeColor','k')
plot(uMF(sel2),mu(sel2),'k^','Color',col(3,:),'MarkerFaceColor',col(3,:),'MarkerEdgeColor','k')
axis square
box off
if strcmp(str,'rMTF')
set(gca,'XScale','log','Xtick',uMF(1:4:end),'XtickLabel',uMF(1:4:end),'YTick',-5:0,'TickDir','out');
ylim([-6 1]);
elseif strcmp(str,'tMTF')
set(gca,'XScale','log','Xtick',uMF(1:4:end),'XtickLabel',uMF(1:4:end),'YTick',-15:5:0,'TickDir','out');
ylim([-16 1]);
else
set(gca,'XScale','log','Xtick',uMF(1:4:end),'XtickLabel',uMF(1:4:end),'YTick',0:0.2:1,'TickDir','out');
ylim([-0.1 1.1]);
end
xlim([1 256*2])
pa_text(0.1,0.9,['N = ' num2str(ncells)]);

yp = ypns;
y500 = y500ns;
y1000= y1000ns;
yp(isinf(yp))		= NaN;
y500(isinf(y500))	= NaN;
y1000(isinf(y1000))	= NaN;
ncells				= sum(~isnan(yp(:,1)));

p1 = NaN(nMF,1);
p2 = NaN(nMF,1);
for ii = 1:nMF
	sel = isnan(yp(:,ii)) | isnan(y500(:,ii));
	p1(ii) = signrank(yp(~sel,ii),y500(~sel,ii));
	sel = isnan(yp(:,ii)) | isnan(y1000(:,ii));
	p2(ii) = signrank(yp(~sel,ii),y1000(~sel,ii));
end
sel1 = p1<0.05;
sel2 = p2<0.05;
subplot(122)
mu = nanmean(yp); se = nanstd(yp)./sqrt(ncells);
errorbar(uMF,mu,se,'k-','Color',col(1,:),'MarkerFaceColor',col(1,:),'MarkerEdgeColor','k')
hold on
mu = nanmean(y500); se = nanstd(y500)./sqrt(ncells);
errorbar(uMF,mu,se,'k-','Color',col(2,:),'MarkerFaceColor',col(2,:),'MarkerEdgeColor','k')
plot(uMF(sel1),mu(sel1),'kv','Color',col(2,:),'MarkerFaceColor',col(2,:),'MarkerEdgeColor','k')
mu = nanmean(y1000); se = nanstd(y1000)./sqrt(ncells);
errorbar(uMF,mu,se,'k-','Color',col(3,:),'MarkerFaceColor',col(3,:),'MarkerEdgeColor','k')
plot(uMF(sel2),mu(sel2),'k^','Color',col(3,:),'MarkerFaceColor',col(3,:),'MarkerEdgeColor','k')
axis square
box off
if strcmp(str,'rMTF')
set(gca,'XScale','log','Xtick',uMF(1:4:end),'XtickLabel',uMF(1:4:end),'YTick',-5:0,'TickDir','out');
ylim([-6 1]);
elseif strcmp(str,'tMTF')
set(gca,'XScale','log','Xtick',uMF(1:4:end),'XtickLabel',uMF(1:4:end),'YTick',-15:5:0,'TickDir','out');
ylim([-16 1]);
else
set(gca,'XScale','log','Xtick',uMF(1:4:end),'XtickLabel',uMF(1:4:end),'YTick',0:0.2:1,'TickDir','out');
ylim([-0.1 1.1]);
end
xlim([1 256*2])
pa_text(0.1,0.9,['N = ' num2str(ncells)]);


pa_datadir;
print('-depsc','-painter',[mfilename 'composite' str]);