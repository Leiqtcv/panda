function pa_am_allcells_mtf

clc;
close all hidden;
clear all

% cd('E:\DATA\selected cells');
cd('E:\DATA\Cortex\AM');
d = dir('*.mat');
fnames = {d.name};
nfiles = length(d);
flag.spike	= false;
flag.rt		= true;

% joe18: inhibition
% joe6707c01b00: onset peak smaller in A
examplefiles = {'joe11311c02b00.mat','joe2105c01b00.mat','thor08411.mat'};
% flag.
%% Default
uMF			= pa_oct2bw(2,0:0.5:7);
Nbin		= 32;
col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);
%%
% nBin = 16;
tMTFP		= NaN(nfiles,15);
tMTFA500	= tMTFP;
tMTFA1000	= tMTFP;
rMTFP		= tMTFP;
rMTFA500	= tMTFP;
rMTFA1000	= tMTFP;
VSP			= tMTFP;
VSA500			= tMTFP;
VSA1000			= tMTFP;
TSP			= tMTFP;
TSA500			= tMTFP;
TSA1000			= tMTFP;
B		= NaN(nfiles,3);
N		= 0;
Base	= B; %baseline period regression
M		= B; % maximum onset peak
S		= B; % synchronization onset peak
P500 = tMTFP;
P1000 = tMTFP;
rtstruct = struct([]);
%% For every cell
for ii = 1:nfiles
	
	%% load data
	fname = fnames{ii};
	disp(fname)
	% 		if strcmpi(fname,'thor08411.mat');
	% 	if strcmpi(fname,'joe11311c02b00.mat');
	cd('E:\DATA\Cortex\AM');
	load(fname)
	
	%% separate active trials in spike
	% 	stim			= [spikeAMA.stimvalues];
	% 	dur				= stim(3,:);
	% 	sel				= dur==500;
	% 	spikeAMA500		= spikeAMA(sel);
	% 	spikeAMA1000	= spikeAMA(~sel);
	
	%% separate active trials in spike
	[spikeAMA1000,RT1000]	= seldur(SpikeAMA,behAM,1000);
	[spikeAMA500,RT500]	= seldur(SpikeAMA,behAM,500);
	spikeAMP = SpikeAMP;
	%% obtain MTFs
	[tMP,rMP,vsP,PhiP,~,rayleighP,periodSDFP,periodNP,tsP]					= getmtf(spikeAMP);
	[tMA500,rMA500,vsA500,PhiA500,~,rayleighA500,periodSDFA500,~,tsA500]			= getmtf(spikeAMA500);
	[tMA1000,rMA1000,vsA1000,PhiA1000,~,rayleighA1000,periodSDFA1000,~,tsA1000]	= getmtf(spikeAMA1000);
	rayleigh = [rayleighP; rayleighA500; rayleighA1000];
	ts = [tsP; tsA500; tsA1000];
	
% 	if sum(rayleigh>13.8)>3 || sum(ts>0.6)>3% 13.8 = p=0.05
		% 			if all(rayleigh<13.8) % 13.8 = p=0.05
	if true
		
		%% Data
		tMTFP(ii,:)		= tMP;
		tMTFA500(ii,:)	= tMA500;
		tMTFA1000(ii,:) = tMA1000;
		
		rMTFP(ii,:)		= rMP;
		rMTFA500(ii,:)	= rMA500;
		rMTFA1000(ii,:) = rMA1000;
		
		VSP(ii,:)		= vsP;
		VSA500(ii,:)	= vsA500;
		VSA1000(ii,:)	= vsA1000;
		
		TSP(ii,:)		= tsP;
		TSA500(ii,:)	= tsA500;
		TSA1000(ii,:)	= tsA1000;
		
		N = N+1;
		
		RP(ii,:)		= rayleighP;
		RA500(ii,:)		= rayleighA500;
		RA1000(ii,:)	= rayleighA1000;
		%%
		% 		keyboard
		%% Reaction times
		if flag.rt
			figure(670)
			clf
			[mu500,mu1000] = plotrt(spikeAMA500,spikeAMA1000,RT500,RT1000,col);
			
			if any(strcmpi(fname,examplefiles));
				pa_datadir;
				print('-depsc','-painter',['rt' fname(1:end-4)]);
			end
			% to know which cell we have
			title(fname)
			
			P500(ii,:) = mu500;
			P1000(ii,:) = mu1000;
			
			figure(671)
			clf
			spike		= spikeAMA500;
			stim		= [spike.stimvalues];
			modFreq		= stim(5,:);
			uMF			= unique(modFreq);
			nMF			= numel(uMF);
			
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
			figure(667)
			clf
			subplot(231)
			spk_rasterplot(spikeAMP,500,'color',col(1,:));
			subplot(232)
			spk_rasterplot(spikeAMA500,500,'color',col(2,:));
			subplot(233)
			spk_rasterplot(spikeAMA1000,1000,'color',col(3,:));
			% 		return
			% for responses aligned to handlebar release
					subplot(235)
					spk_rasterplot(spikeAMA500,500,'color',col(2,:),'rt',RT500);
					subplot(236)
					spk_rasterplot(spikeAMA1000,1000,'color',col(3,:),'rt',RT1000);
			
			% And some example cells printing
				if any(strcmpi(fname,examplefiles));
				pa_datadir;
				print('-depsc','-painter',['raster' fname(1:end-4)]);
			end

			% to know which cell we have
			title(fname)
		end
		%% Spike-waveform
		figure(668)
		clf
		spk_wave(spikeAMP,spikeAMA500,spikeAMA1000,col);
		
		% And some example cells printing
			if any(strcmpi(fname,examplefiles));
				pa_datadir;
				print('-depsc','-painter',['spikewave' fname(1:end-4)]);
			end

		% to know which cell we have
		title(fname)
		
		
		%% Spike density
		figure(669)
		clf
		subplot(221)
		MSDF	= pa_spk_sdf(spikeAMP,'Fs',1000,'sigma',10);
		x		= 1:length(MSDF);
		x = x-300-500;
		sel = x<700;
		plot(x(sel),MSDF(sel),'k-','lineWidth',2,'Color',col(1,:));
		hold on
		
		MSDF	= pa_spk_sdf(spikeAMA500,'Fs',1000,'sigma',10);
		x		= 1:length(MSDF);
		x = x-300-500;
		sel = x<700;
		plot(x(sel),MSDF(sel),'k-','lineWidth',2,'Color',col(2,:));
		hold on
		
		MSDF	= pa_spk_sdf(spikeAMA1000,'Fs',1000,'sigma',10);
		x		= 1:length(MSDF);
		x		= x-300-1000;
		sel		= x>-500 & x<0;
		x = x(~sel);
		x = 1:length(x);
		x		= x-300-500;
		MSDF = MSDF(~sel);
		sel = x<700;
		plot(x(sel),MSDF(sel),'k-','lineWidth',2,'Color',col(3,:));
		
		axis square
		set(gca,'TickDir','out');
		box off
		xtr = 300+500+700;
		xtr = xtr*0.01;
		xlim([-300-500-xtr 700+xtr]);
		xlabel('Time (ms)');
		ylabel('Instantaneous firing rate (spikes/s)');
		pa_verline([-500 0],'k-');
		% 		return
		
		%% Get baseline response
		% with increase in active conditions quantified by linear
		% regression
		subplot(222)
		Base(ii,:) = plotbaseline(spikeAMP,spikeAMA500,spikeAMA1000,col);
		%%
		subplot(223)
		M(ii,:) = plotonset(spikeAMP,spikeAMA500,spikeAMA1000,col);
		
		%%
		subplot(224)
		S(ii,:) = synconset(spikeAMP,spikeAMA500,spikeAMA1000);
		
				if any(strcmpi(fname,examplefiles));
				pa_datadir;
				print('-depsc','-painter',['baseline' fname(1:end-4)]);
			end

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
		% keyboard
		%%
		% 		figure(1)
		% 		clf
		% 		subplot(131)
		% 		plotsdf(periodSDFP,xp,uMF,1);
		%
		% 		subplot(132)
		% 		plotsdf(periodSDFA500,xp,uMF,2);
		%
		% 		subplot(133)
		% 		plotsdf(periodSDFA1000,xp,uMF,3);
		
		%% MTFs
		figure(3)
		clf
		subplot(231)
		mtffigure(tMP,tMA500,tMA1000,rayleighP,rayleighA500,rayleighA1000,false)
		% 		ylim([-17 2]);
		
		subplot(232)
		mtffigure(rMP,rMA500,rMA1000,rayleighP,rayleighA500,rayleighA1000,false)
		% 		ylim([-17 2]);
		
		subplot(234)
		vsfigure(vsP,vsA500,vsA1000,rayleighP,rayleighA500,rayleighA1000,false)
		ylim([-0.1 1.1]);
		
		subplot(235)
		vsfigure(tsP.^2,tsA500.^2,tsA1000.^2,rayleighP,rayleighA500,rayleighA1000,false)
		ylim([-0.1 1.1]);
		
		
		subplot(236)
		p1 = unwrap(PhiP);
		p2 = unwrap(PhiA500);
		p3 = unwrap(PhiA1000);
		B(ii,:) = phifigure(p1,p2,p3,rayleighP,rayleighA500,rayleighA1000);
		drawnow
			if any(strcmpi(fname,examplefiles));
				pa_datadir;
				print('-depsc','-painter',['mtf' fname(1:end-4)]);
			end

		
		%%
		% 		keyboard
		%%
% 								pause
		
	end
	% 			end
end

% keyboard

%%
clc
close all
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
	whos prc
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
%%
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

%%
figure(100)
subplot(131)
mtffigure(tMTFP,tMTFA500,tMTFA1000,RP,RA500,RA1000)
% ylim([-8 2])


subplot(132)
mtffigure(rMTFP,rMTFA500,rMTFA1000,RP,RA500,RA1000)
% ylim([-3 4])

subplot(133)
vsfigure(VSP,VSA500,VSA1000,N,nfiles,'vector strength')


pa_datadir;
print('-depsc','-painter',mfilename);

%%
% close all
col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

figure(200)
subplot(222)
hold on
x = uMF;
y = nanmean(rMTFA500-rMTFP);
plot(x,y,'kv-','MarkerFaceColor',col(2,:),'Color',col(2,:),'MarkerSize',3);
x = uMF;
y = nanmean(rMTFA1000-rMTFP);
plot(x,y,'k^-','MarkerFaceColor',col(3,:),'Color',col(3,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','XScale','log');
xlabel('rMTF_{idle} (spikes/s)')
ylabel('rMTF_{acting_{0.5}} (spikes/s)')

subplot(221)
hold on
x = uMF;
y = nanmean(tMTFA500-tMTFP);
% keyboard
[~,p,~,stats] = ttest(x,y);
str1 = ['Idle - Acting_{0.5}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'kv-','MarkerFaceColor',col(2,:),'Color',col(2,:),'MarkerSize',3);
x = mean(tMTFP,2);
x = uMF;
y = nanmean(tMTFA1000-tMTFP);
[~,p,~,stats] = ttest(x,y);
str2 = ['Idle - Acting_{1.0}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'k-^','MarkerFaceColor',col(3,:),'Color',col(3,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','Xscale','log');
pa_horline(0,'k:');
% % axis([-10 50 -10 50]);
% % pa_unityline('k:');
% ylabel('Firing rate (dB)');
% xlabel('tMTF_{idle} (spikes/s)')
% ylabel('tMTF_{acting_{0.5}} (spikes/s)')
% pa_text(0.1,0.9,str1);
% pa_text(0.1,0.8,str2);

subplot(223)
hold on
x = max(VSP,[],2);
y = max(VSA500,[],2);
[~,p,~,stats] = ttest(x,y);
str1 = ['Idle - Acting_{0.5}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'kv','MarkerFaceColor',col(2,:),'MarkerSize',3);
x = max(VSP,[],2);
y = max(VSA1000,[],2);
[~,p,~,stats] = ttest(x,y);
str2 = ['Idle - Acting_{1.0}: t_{df=' num2str(stats.df) '}=' num2str(stats.tstat,2) ', p=' num2str(p,2)];
plot(x,y,'k^','MarkerFaceColor',col(3,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','XTick',0:0.2:1,'YTick',0:0.2:1);
axis([-0.1 1.1 -0.1 1.1]);
pa_unityline('k:');
ylabel('Firing rate (dB)');
xlabel('VS_{idle}')
ylabel('VS_{acting_{0.5}}')
pa_text(0.1,0.9,str1);
pa_text(0.1,0.8,str2);

D = -1000*B/(2*pi);
subplot(224)
plot(D(:,1),D(:,2),'kv','MarkerFaceColor',col(2,:),'MarkerSize',3);
hold on
plot(D(:,1),D(:,3),'k^','MarkerFaceColor',col(3,:),'MarkerSize',3);
% plot(D(:,2),D(:,3),'ko','MarkerFaceColor',col(1,:),'MarkerSize',3);
axis square
box off
set(gca,'TickDir','out','XTick',0:10:40,'YTick',0:10:40);
axis([-10 40 -10 40]);
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
xlabel('Characteristic delay_{idle}')
ylabel('Characteristic delay_{acting_{0.5}}')

%%
% keyboard

pa_datadir;
print('-depsc','-painter',[mfilename 'comparison']);

%%
close all
clc



figure(801)


sel = ~isnan(tMTFP(:,1));
a = tMTFP(sel,:);
sel = ~isnan(tMTFA500(:,1));
b = tMTFA500(sel,:);
sel = ~isnan(tMTFA1000(:,1));
c = tMTFA1000(sel,:);

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
C = C./max(C(:))*64;
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
subimage(C,c);

axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

% marginal histograms
figure(811)
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

C = zeros(nMF,nMF);
for ii = 1:nMF
	for jj = 1:nMF
		sel = bfa==ii & bfc==jj;
		C(ii,jj) = sum(sel);
	end
end
C = C./max(C(:))*64;
coln = 3;
c = pa_statcolor(64,[],[],[],'def',6);
switch coln
	case 1
		c = c(:,[2 1 3]);
	case 3
		c = c(:,[2 3 1]);
	case 2
end
figure(801)
subplot(122)
subimage(C,c);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

figure(821)
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
% pa_unityline('k-');

%%
figure(802)

sel = ~isnan(rMTFP(:,1));
a = rMTFP(sel,:);
sel = ~isnan(rMTFA500(:,1));
b = rMTFA500(sel,:);
sel = ~isnan(rMTFA1000(:,1));
c = rMTFA1000(sel,:);

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
cl = pa_statcolor(64,[],[],[],'def',6);
subplot(121)
imagesc(C);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

C = zeros(nMF,nMF);
for ii = 1:nMF
	for jj = 1:nMF
		sel = bfa==ii & bfc==jj;
		C(ii,jj) = sum(sel);
	end
end
cl = pa_statcolor(64,[],[],[],'def',6);
subplot(122)
imagesc(C);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

%
figure(803)
sel = ~isnan(VSP(:,1)) &  ~isnan(VSA500(:,1)) & ~isnan(VSA1000(:,1)) ;
a = VSP(sel,:);
b = VSA500(sel,:);
c = VSA1000(sel,:);

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
cl = pa_statcolor(64,[],[],[],'def',6);
subplot(121)
imagesc(C);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

C = zeros(nMF,nMF);
for ii = 1:nMF
	for jj = 1:nMF
		sel = bfa==ii & bfc==jj;
		C(ii,jj) = sum(sel);
	end
end
cl = pa_statcolor(64,[],[],[],'def',6);
subplot(122)
imagesc(C);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

%
figure(804)
sel = ~isnan(TSP(:,1)) &  ~isnan(TSA500(:,1)) & ~isnan(TSA1000(:,1)) ;
a = TSP(sel,:);
b = TSA500(sel,:);
c = TSA1000(sel,:);

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
cl = pa_statcolor(64,[],[],[],'def',6);
subplot(121)
imagesc(C);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

C = zeros(nMF,nMF);
for ii = 1:nMF
	for jj = 1:nMF
		sel = bfa==ii & bfc==jj;
		C(ii,jj) = sum(sel);
	end
end
cl = pa_statcolor(64,[],[],[],'def',6);
subplot(122)
imagesc(C);
axis square;
colormap(cl)
set(gca,'XTick',1:2:15,'XTickLabel',round(uMF(1:2:end)),'YTick',1:2:15,'YTickLabel',round(uMF(1:2:end)),...
	'TickDir','out');
pa_unityline('k-');

%%
keyboard

function [tM,rM,VS,Phi,uMF,rayleigh,periodSDF,periodN,TS] = getmtf(spike)
% Get temporal and rate codes / vector strength and firing rate
stim		= [spike.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
nMF			= numel(uMF);
VS			= NaN(nMF,1);
d			= 0.700;
Nbin		= 32;
ncomp		= 1;
xperiod		= linspace(0,1,Nbin);
tM			= NaN(nMF,1);
rM			= tM;
Phi			= tM;
sigma		= 5;
winsize		= sigma*5;
t			= -winsize:winsize;
window		= normpdf(t,0,sigma);
x			= -1:0.01:100;
periodSDF	= NaN(nMF,length(x));
periodN		= NaN(nMF,Nbin);
TS = VS;
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
for ii		= 1:nMF
	sel		= modFreq==uMF(ii);
	spk		= spike(sel);
	dur		= spk(1).stimvalues(3)/1000;
	spk1	= [spk.spiketime]/1000; % spike times in s
	sel		= spk1>0.300+dur & spk1<d+0.3+dur;
	spk1	= spk1(sel)-0.300-dur;
	spk1	= spk1*uMF(ii);
	[N,xp]	= hist(spk1,x);
	convN	= conv(N,window);
	N		= convN(1:end-winsize*2);
	N		= N/max(N);
	
	%% Period
	sel		= modFreq==uMF(ii);
	ntrials = sum(sel);
	nperiod = floor(d/(1/uMF(ii)));
	maxtime = nperiod*(1/uMF(ii));
	P = [];
	for jj = 1:ntrials
		spktime		= spk(jj).spiketime/1000;
		sel			= spktime>0.300+dur & spktime<d+0.3+dur; % 700 ms modulation duration
		spktime		= spktime(sel)-0.300-dur;
		sel			= spktime<=maxtime;
		spktime		= spktime(sel);
		spktime		= spktime*uMF(ii);
		period		= mod(spktime,1);
		P			= [P period]; %#ok<AGROW>
	end
	Nspikes		= hist(P,xperiod);
	Nspikes		= Nbin*Nspikes/ntrials/(1/uMF(ii))/nperiod; % Convert to firing rate
	X			= fft(Nspikes,Nbin)/Nbin;
	tM(ii)		= abs(X(ncomp+1));
	Phi(ii)		= angle(X(ncomp+1));
	rM(ii)		= abs(X(ncomp+0));
	VS(ii)		= tM(ii)./rM(ii);
	periodSDF(ii,:)		= N;
	periodN(ii,:) = Nspikes;
	
	%% Trial similarity
	nhalf	= floor(ntrials/2);
	R = NaN(1,10);
	for Idx = 1:10;
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
		R(Idx) = r;
	end
	
	TS(ii) = nanmean(R);
	
	
end
rayleigh = (tM./rM).^2*2.*rM;

function mtffigure(Y1,Y2,Y3,R1,R2,R3,muflag)
if nargin<7
	muflag = true;
end
col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= pa_oct2bw(2,0:0.5:7);
n		= length(uMF);
uMFi	= pa_oct2bw(2,linspace(0,7,n*10));
hold on

if muflag
	Y		= nanmean(Y1);
else
	Y = Y1';
	R = R1;
end
if muflag
	plot(uMF,Y,'ko','MarkerFaceColor',col(1,:),'MarkerSize',4);
else
	plot(uMF,Y,'k-','Color',col(1,:));
	sel = R>13.8;
	plot(uMF(sel),Y(sel),'ko','MarkerFaceColor',col(1,:),'MarkerSize',6);
	plot(uMF(~sel),Y(~sel),'ko','MarkerFaceColor',col(1,:),'MarkerSize',2);
end
BW	= pa_freq2bw(2,uMF);
if muflag
	P	= polyfit(BW,Y,5);
	BWi = pa_freq2bw(2,uMFi);
	Yi	= polyval(P,BWi);
	plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(1,:));
end

if muflag
	Y		= nanmean(Y2);
else
	Y = Y2';
	R = R2;
end
if muflag
	plot(uMF,Y,'ko','MarkerFaceColor',col(2,:),'MarkerSize',4);
else
	plot(uMF,Y,'k-','Color',col(2,:));
	sel = R>13.8;
	plot(uMF(sel),Y(sel),'ko','MarkerFaceColor',col(2,:),'MarkerSize',6);
	plot(uMF(~sel),Y(~sel),'ko','MarkerFaceColor',col(2,:),'MarkerSize',2);
end
BW	= pa_freq2bw(2,uMF);
if muflag
	P	= polyfit(BW,Y,5);
	BWi = pa_freq2bw(2,uMFi);
	Yi	= polyval(P,BWi);
	plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(2,:));
end

if muflag
	Y		= nanmean(Y3);
else
	Y = Y3';
	R = R3;
end
if muflag
	plot(uMF,Y,'ko','MarkerFaceColor',col(3,:),'MarkerSize',4);
else
	plot(uMF,Y,'k-','Color',col(3,:));
	sel = R>13.8;
	plot(uMF(sel),Y(sel),'k^','MarkerFaceColor',col(3,:),'MarkerSize',6);
	plot(uMF(~sel),Y(~sel),'ko','MarkerFaceColor',col(3,:),'MarkerSize',2);
end
BW	= pa_freq2bw(2,uMF);
if muflag
	P	= polyfit(BW,Y,5);
	BWi = pa_freq2bw(2,uMFi);
	Yi	= polyval(P,BWi);
	plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(3,:));
end


axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ax = axis;
axis([ax(1) ax(2) 0 ax(4)]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

function vsfigure(Y1,Y2,Y3,R1,R2,R3,muflag)
if nargin<7
	muflag = true;
end
col = pa_statcolor(3,[],[],[],'def',1);
col = col([2 1 3],:);

uMF		= pa_oct2bw(2,0:0.5:7);
n		= length(uMF);
uMFi	= pa_oct2bw(2,linspace(0,7,n*10));
hold on

if muflag
	Y		= nanmean(Y1);
else
	Y = Y1';
	R = R1;
end
if muflag
	h1 = plot(uMF,Y,'ko','MarkerFaceColor',col(1,:),'MarkerSize',4);
else
	plot(uMF,Y,'k-','Color',col(1,:));
	sel = R>13.8;
	h1 = plot(uMF(sel),Y(sel),'ko','MarkerFaceColor',col(1,:),'MarkerSize',6);
	plot(uMF(~sel),Y(~sel),'ko','MarkerFaceColor',col(1,:),'MarkerSize',2);
end
BW	= pa_freq2bw(2,uMF);
if muflag
	P	= polyfit(BW,Y,5);
	BWi = pa_freq2bw(2,uMFi);
	Yi	= polyval(P,BWi);
	plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(1,:));
end

if muflag
	Y		= nanmean(Y2);
else
	Y = Y2';
	R = R2;
end
if muflag
	h2 = plot(uMF,Y,'ko','MarkerFaceColor',col(2,:),'MarkerSize',4);
else
	plot(uMF,Y,'k-','Color',col(2,:));
	sel = R>13.8;
	h2 = plot(uMF(sel),Y(sel),'kv','MarkerFaceColor',col(2,:),'MarkerSize',6);
	plot(uMF(~sel),Y(~sel),'kv','MarkerFaceColor',col(2,:),'MarkerSize',2);
end
BW	= pa_freq2bw(2,uMF);
if muflag
	P	= polyfit(BW,Y,5);
	BWi = pa_freq2bw(2,uMFi);
	Yi	= polyval(P,BWi);
	plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(1,:));
end

if muflag
	Y		= nanmean(Y3);
else
	Y = Y3';
	R = R3;
end
if muflag
	h3 = plot(uMF,Y,'ko','MarkerFaceColor',col(3,:),'MarkerSize',4);
else
	plot(uMF,Y,'k-','Color',col(3,:));
	sel = R>13.8;
	h3 = plot(uMF(sel),Y(sel),'k^','MarkerFaceColor',col(3,:),'MarkerSize',6);
	plot(uMF(~sel),Y(~sel),'k^','MarkerFaceColor',col(3,:),'MarkerSize',2);
end
BW	= pa_freq2bw(2,uMF);
if muflag
	P	= polyfit(BW,Y,5);
	BWi = pa_freq2bw(2,uMFi);
	Yi	= polyval(P,BWi);
	plot(uMFi,Yi,'k-','LineWidth',2,'Color',col(1,:));
end

axis square
box off
set(gca,'TickDir','out','Xscale','log');
xlim([1 256*2]);
ylim([-0.1 1.1]);
uMF = pa_oct2bw(2,0:0.5:7);
set(gca,'XTick',uMF(1:4:end),'XTickLabel',round(uMF(1:4:end)));

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

function plotsdf(SDF,xp,uMF,coln)

xp = mod(xp,1);
xp = round(xp*100)/100;

% whos xp SDF
% col = colormap
col = pa_statcolor(63,[],[],[],'def',6);
coln
switch coln
	case 1
		col = col(:,[2 1 3]);
	case 3
		col = col(:,[2 3 1]);
	case 2
end
colormap(col);

% return
[X,ia,ib] = unique(xp);
% 	P =
n = size(SDF,1);
P = NaN(n,length(X));
for ii = 1:n
	y = SDF(ii,:);
	
	Y = accumarray(ib',y',[],@nansum);
	Y = (Y-nanmin(Y))./(nanmax(Y)-nanmin(Y));
	
	% 	plot(X,0.25*Y+0.3*ii,'k-','Color',col);
	
	% hp		= patch([xp(1) xp xp(end)],[0.3*ii 0.25*SDF(ii,:)+0.3*ii 0.3*ii],col);
	% 	set(hp,'FaceColor',col);
	% 	hold on
	% 	xlim([0 9]);
	P(ii,:) = Y;
end
y = pa_freq2bw(2,uMF);
yi = linspace(min(y),max(y),50);
xi = linspace(min(X),max(X),50);
whos X xi y yi P
[xi,yi]=meshgrid(xi,yi);
Z = interp2(X,y,P,xi,yi);
% imagesc(Z)
subimage(xi(1,:),yi(:,1),Z*63,col);
hold on

axis square;
box off
set(gca,'Ydir','normal','TickDir','out');

colorbar;

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

function B = plotbaseline(spikeAMP,spikeAMA500,spikeAMA1000,col)

t = [spikeAMP.spiketime];
ntrials = numel(spikeAMP);
sel = t>100 & t<300; % start, exclduing response to handle bar
tstart = t(sel);
x = 110:20:290;
N = hist(tstart,x);
N = N/20*1000/ntrials;
b = regstats(N,x,'linear','beta');
plot([-200 0],[100 300]*b.beta(2)+b.beta(1),'k-','Color',col(1,:),'LineWidth',2)
hold on
plot(x-300,N,'ko','MarkerFaceColor',col(1,:))
B(1) = b.beta(2);

t = [spikeAMA500.spiketime];
ntrials = numel(spikeAMA500);
sel = t>100 & t<300; % start, exclduing response to handle bar
tstart = t(sel);
x = 110:20:290;
N = hist(tstart,x);
N = N/20*1000/ntrials;
b = regstats(N,x,'linear','beta');
plot([-200 0],[100 300]*b.beta(2)+b.beta(1),'k-','Color',col(2,:),'LineWidth',2)
hold on
plot(x-300,N,'kv','MarkerFaceColor',col(2,:))
B(2) = b.beta(2);

t = [spikeAMA1000.spiketime];
ntrials = numel(spikeAMA1000);
sel = t>100 & t<300; % start, exclduing response to handle bar
tstart = t(sel);
x = 110:20:290;
N = hist(tstart,x);
N = N/20*1000/ntrials;
b = regstats(N,x,'linear','beta');
plot([-200 0],[100 300]*b.beta(2)+b.beta(1),'k-','Color',col(3,:),'LineWidth',2)
hold on
plot(x-300,N,'k^','MarkerFaceColor',col(3,:))
B(3) = b.beta(2);

xlim([-200-0.1*200  0+0.1*200]);
ax = axis;
ylim([0 ax(4)]);
axis square;
box off;
set(gca,'TickDir','out','XTick',-200:100:0);
xlabel('Time (ms)');
ylabel('Firing rate (spikes/s)');

function M = plotonset(spikeAMP,spikeAMA500,spikeAMA1000,col)

t = [spikeAMP.spiketime];
ntrials = numel(spikeAMP);
sel = t>300 & t<400; % start, exclduing response to handle bar
t = t(sel);
x = 305:10:395;
N = hist(t,x);
N = N/10*1000/ntrials;
hold on
plot(x-300,N,'ko-','MarkerFaceColor',col(1,:),'Color',col(1,:),'MarkerEdgeColor','k')
M(1) = max(N);

t = [spikeAMA500.spiketime];
ntrials = numel(spikeAMA500);
sel = t>300 & t<400; % start, exclduing response to handle bar
t = t(sel);
x = 305:10:395;
N = hist(t,x);
N = N/10*1000/ntrials;
hold on
plot(x-300,N,'kv-','MarkerFaceColor',col(2,:),'Color',col(2,:),'MarkerEdgeColor','k')
M(2) = max(N);

t = [spikeAMA1000.spiketime];
ntrials = numel(spikeAMA1000);
sel = t>300 & t<400; % start, exclduing response to handle bar
t = t(sel);
x = 305:10:395;
N = hist(t,x);
N = N/10*1000/ntrials;
hold on
plot(x-300,N,'k^-','MarkerFaceColor',col(3,:),'Color',col(3,:),'MarkerEdgeColor','k')
M(3) = max(N);

xlim([0-0.1*100  100+0.1*100]);
ax = axis;
ylim([0 ax(4)]);
axis square;
box off;
set(gca,'TickDir','out','XTick',0:20:100);
xlabel('Time (ms)');
ylabel('Firing rate (spikes/s)');

function S = synconset(spikeAMP,spikeAMA500,spikeAMA1000)

t	= [spikeAMP.spiketime];
sel = t>310 & t<340; % start, exclduing response to handle bar
t	= t(sel)-310;
t	= t/30;
nspikes = numel(t);
S(1)		= (1/nspikes)*sqrt( sum(cos(t)).^2+sum(sin(t)).^2);


t	= [spikeAMA500.spiketime];
sel = t>310 & t<340; % start, exclduing response to handle bar
t	= t(sel)-310;
t	= t/30;
nspikes = numel(t);
S(2)		= (1/nspikes)*sqrt( sum(cos(t)).^2+sum(sin(t)).^2);

t	= [spikeAMA1000.spiketime];
sel = t>310 & t<340; % start, exclduing response to handle bar
t	= t(sel)-310;
t	= t/30;
nspikes = numel(t);
S(3)		= (1/nspikes)*sqrt( sum(cos(t)).^2+sum(sin(t)).^2);

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
