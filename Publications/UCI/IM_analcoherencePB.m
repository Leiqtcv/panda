close all hidden;
clear all hidden;

PB = [0 1/3 2/3 1 4/3 5/3 2];
nPB = numel(PB);
load RedBlue
indx = round(linspace(1,64,nPB));
col = col(indx,:);
for ii = 1:nPB
Tcues	= true; % Masker timing: true: asynchronous; false: synchronous
Fcues	= 1; %  1: random frequencies; 2: constant frequencies across pulses
TrFr = IM_coherenceanalysis(Tcues,Fcues,PB(ii));

Tcues	= false; % Masker timing: true: asynchronous; false: synchronous
Fcues	= 2; %  1: random frequencies; 2: constant frequencies across pulses
TcFc = IM_coherenceanalysis(Tcues,Fcues,PB(ii));

Tcues	= true; % Masker timing: true: asynchronous; false: synchronous
Fcues	= 2; %  1: random frequencies; 2: constant frequencies across pulses
TrFc = IM_coherenceanalysis(Tcues,Fcues,PB(ii));

Tcues	= false; % Masker timing: true: asynchronous; false: synchronous
Fcues	= 1; %  1: random frequencies; 2: constant frequencies across pulses
TcFr = IM_coherenceanalysis(Tcues,Fcues,PB(ii));

figure(42)
subplot(121)

y = 100-[TrFr TrFc TcFr TcFc];
% n = size(y,1)
% for ii = 1:n
% y(ii,:) = (y(ii,:)-min(y(ii,:)))./(max(y(ii,:))-min(y(ii,:))).^2.5+5;
% end
x = 1:4;
plot(x,y,'ro-','LineWidth',2,'MarkerFaceColor',col(ii,:),'Color',col(ii,:));

hold on

plot(x,y,'ko','LineWidth',2,'MarkerFaceColor',col(ii,:));
% axis square;
drawnow
end
xlim([0 5]);
% ylim([-10 80]);
box off
xlabel('Masker type');
ylabel('Fusion');
% pa_horline([0 57],'k--');
set(gca,'XTick',1:4,'XTickLabel',{'TrFr','TrFc','TcFr','TcFc'});
title('Coherence model');
axis square

pa_datadir;

print('-depsc','-painter',mfilename);


return
%% Initialization
Fshigh			= 48828; % Sampling rate (Hz)
Fs				= 1000;
Fn				= Fshigh/2; % Sampling rate (Hz)

dur				= 2; % duration impulse response (s)
n				= round(dur*Fs); % # samples impulse response
t				= (1:n)/Fs;  % time vector impulse response (s)
ChannelBW		= (1/4:1/4:2)/2;
oct				= -4:1/3:3;
FreqChannels	= pa_oct2bw(1600,oct);
% FreqChannels	= [100:500:12100];

nBW				= numel(ChannelBW);
nChan			= numel(FreqChannels);

dispFlag = true;
%% Stimuli
Par.MaskRand	= true; % Masker timing: true: asynchronous; false: synchronous
Par.Paradigm	= 1; %  1: random frequencies; 2: constant frequencies across pulses
Par.ProtectBand	= 2; % Protected Band (in 2013: 0:1/3:2)
Par.NMaskLow	= 2; % Number of masker tones below target
Par.NMaskHigh	= 2; % number of masker tones above target
Par.MaskRng		= 2; % Range (octave) from which maskers can be drawn
Par.NPulse		= 10; % Number of pulses
Par.SigFreq		= 1600; % target frequency

[M,S]			= pa_geninfomask(Par);

if dispFlag
	nsamples = length(M);
	
	figure(666)
	
	tM	=	(0:nsamples-1)/Fshigh;
	subplot(211)
	plot(tM,M,'k-')
	hold on
	plot(tM,S+2,'r-')
	xlim([tM(1) tM(end)])
	xlabel('Time (s)')
	ylabel('Amplitude (a.u.)')
	
	col = colormap('hot');
	% 	col = 1-col;
	snd = M;
	nsamples	= length(snd);
	td			= nsamples/Fshigh*1000;
	dt			= 12.5;
	nseg		= td/dt;
	segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
	noverlap	= round(0.6*segsamples); % 1/3 overlap
	window		= segsamples+noverlap; % window size
	nfft		= 1000;
	
	subplot(223)
	[~,F,T,P] = spectrogram(snd,window,noverlap,nfft,Fshigh);
	surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
	axis tight
	view(0,90);
	axis square;
	set(gca,'YTick',[0.1 0.5 1 2 4 8 16]*1000);
	set(gca,'YTickLabel',[0.1 0.5 1 2 4 8 16]);
	set(gca,'YScale','log');
	set(gca,'TickDir','out')
	ylim([100 20000]);
	xlabel('Time (s)');
	caxis([-80 -20]);
	pa_horline(pa_oct2bw(1600,[-Par.ProtectBand Par.ProtectBand]),'r-');
	pa_horline(pa_oct2bw(1600,[-Par.ProtectBand-Par.MaskRng Par.ProtectBand+Par.MaskRng]),'r:');
	title('Masker Alone');
	
	snd = M+S;
	
	subplot(224)
	[~,F,T,P] = spectrogram(snd,window,noverlap,nfft,Fshigh);
	surf(T,F,10*log10(abs(P)+eps),'EdgeColor','none');
	axis tight
	view(0,90);
	axis square;
	set(gca,'YTick',[0.1 0.25 0.5 1 2 4 8 16]*1000);
	set(gca,'YTickLabel',[0.1 0.25 0.5 1 2 4 8 16]);
	set(gca,'YScale','log');
	set(gca,'TickDir','out')
	ylim([100 20000]);
	xlabel('Time (s)');
	caxis([-80 -20]);
	pa_horline(pa_oct2bw(1600,[-Par.ProtectBand Par.ProtectBand]),'r-');
	pa_horline(pa_oct2bw(1600,[-Par.ProtectBand-Par.MaskRng Par.ProtectBand+Par.MaskRng]),'r:');
	title('Signal & Masker');
	colormap(col);
	
end
M				= M+S;
nM				= numel(M);

%% Frequency Channels
if dispFlag
	figure
	subplot(121)
	col = summer(nChan);
	plot(tM,M,'k-');
	hold on
	
end

MaskEnv		= NaN(nChan,nM);
Mre			= NaN(nChan,round(nM*Fs/Fshigh)+1);
for ii = 1:nChan
	Fc				= pa_oct2bw(FreqChannels(ii),[-1/6 1/6]);
	m				= pa_bandpass(M, Fc, Fn, 100);
	MaskEnv(ii,:)	= abs(hilbert(m));
	Mre(ii,:)		= resample(MaskEnv(ii,:),Fs,Fshigh);
	
	if dispFlag
		plot(tM,MaskEnv(ii,:)+ii,'Color',col(ii,:))
		
	end
end

if dispFlag
	axis square;
	xlabel('Time (s)');
	
	subplot(122)
	nsamples	= length(Mre);
	tm			= (1:nsamples)/Fs; % resampled
	imagesc(tm,oct,MaskEnv);
	axis square;
	set(gca,'YDir','normal');
	set(gca,'YTick',oct,'YTickLabel',round(FreqChannels));
	colormap hot;
end


%% Temporal filters
w		= [2 4 8 16 32]; % Characteristic frequency (Hz)
nw		= numel(w);
theta	= 0:1/3*pi:2*pi; % Characteristic phase (rad)
ntheta	= numel(theta);

H	= NaN(nw*ntheta,n);
G	= H;
k	= 0;
col = hot(nw*ntheta+5);
nM	= length(M);
nS	= length(S);
RM	= NaN(nw*ntheta,length(M));
RS	= NaN(nw*ntheta,length(S));

figure(667)
subplot(221)

for ii = 1:nw
	for jj = 1:ntheta
		k		= k+1;
		wct		= w(ii)*t;
		g		= wct.^2.*exp(-3.5*wct).*sin(2*pi*wct);
		
		h1	= w(ii)*g*cos(theta(jj));
		gh	= hilbert(g);
		h2	= w(ii)*gh*sin(theta(jj));
		h	= h1+h2;
		H(k,:) = h;
		G(k,:) = g;
		
		plot(t,g,'Color',col(k,:));
		hold on
	end
end
axis square;
xlabel('Time (s)');
ylabel('Amplitude');
title('Gamma functions');

subplot(222)
colormap hot;
imagesc(G)
shading flat
axis square;
xlabel('Time (s)');
ylabel('Gamma functions \omega_c x \theta_c');
set(gca,'YDir','normal');

subplot(223)
imagesc(abs(H))
shading flat
axis square;
xlabel('Time (s)');
ylabel('Temporal filter \omega_c x \theta_c');
set(gca,'YDir','normal');


%% Coherence analysis
disp('---- Coherence ----');

R = NaN(nChan,k,length(Mre));
A = NaN(nChan*k,length(Mre));
npsi = ntheta*nw;
cnt = 0;
col = summer(npsi*nChan);
for ii = 1:nChan
	for jj = 1:npsi
		[ii jj]
		a = conv(Mre(ii,:),H(jj,:));
		R(ii,jj,:) = a(1:length(Mre));
		A(cnt+1,:) = abs(a(1:length(Mre)));
		cnt = cnt+1;
		
		
		% 		plot(Mre(ii,:),'k-');
		% 		hold on
		% 		plot(H
		% 		pause
	end
end

%%
subplot(224)
r = abs(squeeze(R(5,:,:)));
imagesc(A);
set(gca,'YDir','normal');
colormap hot
xlabel('Time (ms)');
ylabel('Channel x \Psi');
axis square;
%%
cnt = 0;
% close all
figure(99)
C = NaN(nChan,nChan);
for ii = 1:nChan
	ri = squeeze(R(ii,:,:))';
	
% 	subplot(221)
% 	imagesc(abs(ri)')
% 	title(ii);
% 			axis square;
% 		set(gca,'YDir','normal');
		
	for jj = 1:nChan
		cnt = cnt+1;
		rj = squeeze(R(jj,:,:))';
		
		%
		% 		c = NaN(k,1);
		% 		for kk = 1:k
		% 			c(kk) = ri(kk,:)*rj(kk,:)';
		% 		end
		% 		C(ii,jj) = abs(nansum(c));
		
		
		m			= abs(ri'*rj);
		C(ii,jj)	= sum(m(:));
		
% 		subplot(222)
% 		imagesc(abs(rj)')
% 		title(jj);
% 		
% 		axis square;
% 		set(gca,'YDir','normal');
% 		
% 		subplot(223)
% 		plot(abs(ri),abs(rj),'k.');
% 		axis([0 15 0 15]);
% 		axis square;
% 		set(gca,'YDir','normal');
% 		subplot(224)
% 		
% 		imagesc(m);
% 		caxis([0 15000])
% % 				caxis([0 400])
% 
% 		title(size(m))
% 		axis square;
% 		set(gca,'YDir','normal');
% 		pa_unityline('w-');
% 		
% 		drawnow
		
	end
end

%%
figure;
subplot(121)
pcolor(oct,oct,C);
% pcolor(C);

shading flat
set(gca,'YDir','normal');
% set(gca,'XScale','log');
% return
% set(gca,'YTick',oct,'YTickLabel',round(FreqChannels));
% set(gca,'XTick',oct,'XTickLabel',round(FreqChannels));
axis square;
h = pa_unityline;
set(h,'Color','w');
% colormap hot;

[u,s,v] = svd(C);
s = diag(s,0);
s = s./sum(s);
subplot(122)
bar(s)

l = s(2)/s(1);
title(l);

%%
% figure
%
% 		RM(k,:) = a(1:nM);
% 		RS(k,:) = a(1:nS);
% 		plot(t,real(h),'k-','Color',col(k,:));
% 		hold on
% 		ylim([-2 2]);



% R = sum(abs(R));
% whos R
% figure
% plot(R)

% figure
% imagesc(sum(R'))
% shading flat
