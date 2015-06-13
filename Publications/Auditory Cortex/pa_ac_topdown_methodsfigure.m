function pa_ac_topdown_methodsfigure

clc;
close all hidden;
clear all

cd('E:\DATA\Cortex\top-down paper data');
% fnames = {'joe11311c02b00.mat';...
% 	'joe14512c01b00';...
% 	'joe14711c01b00';...
% 	'thor08411';...
% 	'thor09110';...
% 	};

fname = 'joe14711c01b00'; % worse
fname = 'joe14512c01b00'; % Better rate & magnitude
% fname = 'joe11311c02b00.mat'; % worse timing, better rate & magnitude
% fname = 'thor09110'; % worse
fname = 'thor08411'; % worse
fname ='thor07206.mat'
% fname = 'joe12002c02b00';

% fname = 'joe17417c02b00';
% fname = 'joe5405c01b00';
% fname = 'joe15312c01b00';

% fname = 'joe16015c01b00'; % worse timing, higher/worse rate, equal magnitude BEST CELL



% fname = 'joe14512c01b00'; % Better rate & magnitude nice at mf(5) for passive and active

load(fname)
stim		= [spikeAMP.stimvalues];
modFreq		= stim(5,:);
uMF			= unique(modFreq);
uMF
mf			= uMF(3);
% mf			= uMF(3);

sigma	= 5;
sigma70 = 70;
% indx			= [spikeAMA.trialorder];
% spikeAMA		= spikeAMA(indx);
stim			= [spikeAMA.stimvalues];
mn				= min([length(spikeAMA) length(behAM)]);
stim			= stim(:,1:mn);
dur				= stim(3,:);
selmf				= dur==500;
spikeAMA500		= spikeAMA(selmf);
spikeAMA1000	= spikeAMA(~selmf);
behAMA500		= behAM(:,selmf); %#ok<*NASGU,*NODEF>
behAMA1000		= behAM(:,~selmf);

% behAMA500(4,:)
% return
%% Passive
[~,sdf]		= pa_spk_sdf(spikeAMP,'sigma',sigma,'Fs',1000);
[~,sdf70]	= pa_spk_sdf(spikeAMP,'sigma',sigma70,'Fs',1000);
stim		= [spikeAMP.stimvalues];
modFreq		= stim(5,:);
selmf			= modFreq==mf;
muP			= mean(sdf(selmf,:));
muP70		= mean(sdf70(selmf,:));
t			= 0:length(muP)-1;
t			= t-300-500;

sb = 1:2;
n = numel(sb);
for ii = 1:n
	subplot(3,2,sb(ii))
	hold on
	hp		= patch([t(1) t t(end)],[0 muP 0],'k');
	set(hp,'FaceColor',[.7 .7 .7],'EdgeColor','none');
	
% 	s = 25*(sin(2*pi*mf*t/1000+pi)+1);
% 	plot(t,s,'k--');
end

sb = 3:4;
n = numel(sb);
for ii = 1:n
	subplot(3,2,sb(ii))
	hold on
	hp		= patch([t(1) t t(end)],[0 muP70 0],'k');
	set(hp,'FaceColor',[.7 .7 .7],'EdgeColor','none');
end

%% Active
[~,sdf]		= pa_spk_sdf(spikeAMA500,'sigma',sigma,'Fs',1000);
[~,sdf70]	= pa_spk_sdf(spikeAMA500,'sigma',sigma70,'Fs',1000);
sdf70		= sdf70(:,1:length(muP70));
sdf			= sdf(:,1:length(muP));

stim		= [spikeAMA500.stimvalues];
modFreq		= stim(5,:);
selmf			= modFreq==mf;
mu500		= mean(sdf(selmf,:));
mu50070		= mean(sdf70(selmf,:));
t			= 0:length(sdf)-1;
t			= t-300-500;

C			= bsxfun(@minus,sdf70,muP70);
subplot(321)
plot(t,mu500,'k-','LineWidth',2);

subplot(323)
n		= sum(selmf);
col		= gray(n+2);
y		= sdf70(selmf,:);
for ii = 1:n
plot(t,y(ii,:),'--','Color',col(ii+1,:),'LineWidth',1);
end
plot(t,mu50070,'k-','LineWidth',2);


%% Sort RT
rt		= behAMA500(2,selmf);
subplot(323)
% h		= pa_verline(rt);
% for ii = 1:n
% 	h		= pa_verline(rt(ii));
% 	selrt = t==rt(ii);
% % 	sum(selrt)
% plot(t(selrt),y(ii,selrt),'ko','MarkerFaceColor',col(ii+1,:),'LineWidth',1);
% 
% set(h,'Color',col(ii+1,:),'LineWidth',2);
% end

subplot(321)
% h		= pa_verline(rt);
C		= C(selmf,:)';
D500	= mean(C,2);


n = size(C,2);
for ii = 1:n
	C(:,ii) = circshift(C(:,ii),rt(ii));
end
D500 = mean(C,2);

n	= sum(selmf);
col = gray(n+2);
for ii = 1:n
	subplot(325)
	hold on
	plot(t-800,C(:,ii),'--','Color',col(ii+1,:),'LineWidth',1);
end
plot(t-800,D500,'k-','LineWidth',2)
pa_horline(0,'k-');
xlim([-600 100]);

subplot(3,2,1)
title({fname;['Modulation frequency: ' num2str(mf) ' Hz'];['Kernel width: ' num2str(sigma) ' ms']});
xlabel('time re modulation onset (ms)');
ylabel('Firing rate (Hz)');
% ylim([0 200]);
set(gca,'YTick',0:50:200,'XTick',0:200:400);

subplot(3,2,3)
title('Kernel width = 70 ms');
xlabel('time re modulation onset (ms)');
ylabel('Firing rate (Hz)');
% ylim([0 200]);
set(gca,'YTick',0:50:200,'XTick',0:200:400);

subplot(3,2,5)
title('Kernel width = 70 ms');
xlabel('time re reaction (ms)');
ylabel('Difference in firing rate (Hz)');
ylim([-50 150]);
set(gca,'YTick',-50:50:150,'XTick',-40:200:0);

sb = [1 3 5];
for ii = 1:numel(sb)
	subplot(3,2,sb(ii))
	if ii<3
		xlim([-100 500]);
					axis square

	else
		xlim([-500 100]);
			axis square

	end
	box off
	pa_text(0.05,0.9,char(64+ii));
	pa_verline(0,'k:');
end
% return
%% ACTIVE1000
[~,sdf]		= pa_spk_sdf(spikeAMA1000,'sigma',sigma,'Fs',1000);
[~,sdf70]	= pa_spk_sdf(spikeAMA1000,'sigma',sigma70,'Fs',1000);
sdf70		= sdf70(:,1:length(muP70));
sdf			= sdf(:,1:length(muP));

stim		= [spikeAMA1000.stimvalues];
modFreq		= stim(5,:);
sel			= modFreq==mf;
mu500		= mean(sdf(sel,:));
mu50070		= mean(sdf70(sel,:));
t			= 0:length(sdf)-1;
t			= t-300-500;

C			= bsxfun(@minus,sdf70,muP70);
subplot(322)
plot(t,mu500,'b-','LineWidth',2);

subplot(324)
n		= sum(sel);
col		= cool(n+2);
y		= sdf70(sel,:);
for ii = 1:n
plot(t,y(ii,:),'--','Color',col(ii+1,:));
end
plot(t,mu50070,'b-','LineWidth',2);


%% Sort RT
rt		= behAMA1000(2,sel);
subplot(324)
h		= pa_verline(rt);
subplot(322)
h		= pa_verline(rt);
C		= C(sel,:)';
D500	= mean(C,2);


n = size(C,2);
for ii = 1:n
	C(:,ii) = circshift(C(:,ii),rt(ii));
end
D500 = mean(C,2);

n	= sum(sel);
col = cool(n+2);
for ii = 1:n
	subplot(326)
	hold on
	plot(t-800,C(:,ii),':','Color',col(ii+1,:));
end
plot(t-800,D500,'b-','LineWidth',2)
pa_horline(0,'k-');
xlim([-600 100]);

sb = [2 4 6];
for ii = 1:numel(sb)
	subplot(3,2,sb(ii))
	if ii<3
		xlim([-100 500]);
	else
		xlim([-500 100]);
			axis square

	end
	box off
	pa_text(0.05,0.9,char(96+ii+1));
	pa_verline(0,'k:');
	title(mf);
end


pa_datadir;
print('-depsc','-painter',mfilename);



