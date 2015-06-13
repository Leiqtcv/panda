%% Initialization
close all
clear all

%% Load data
cd('E:\DATA\Studenten\Nynke\NN-01-2014-05-01');
fname	= 'NN-01-2014-05-01-0001.hv';
[H,V]	= pa_loadraw(fname,2,22000); % calibrated response data
[e,c,l] = pa_readcsv(fname); % stimulus information

%% Sounds
ntrials		= size(H,2);

sel		= l(:,5) == 2; % column 5 = modality stim, 3 = snd1
sndid1	= l(sel,11);
sel		= l(:,5) == 3; % column 5 = modality stim, 3 = snd2
sndid2	= l(sel,11);

% snd_dir		= 'E:\DATA\Studenten\Nynke\Zwuis moving sounds';
snd_dir		= 'E:\DATA\Studenten\Nynke\zwuis no scaling 19960ms'; % input argument, check default, check computer
ff			= 0.05; % hardcoding - bad, should use stimulus creation parameters
T0			= 1/ff; % fundamental period
harm		= round([2, 3, 7, 11, 19]*ff*20)/20;
nharm		= numel(harm);
amp			= 20; % Component amplitude, some more hardcoding - bad!!!!
calfactor	= 250; % Also badly hardcoded - should use static localization responses for calibration

Fsmedusa	= 1017; % head response sample rate
Fsrp2		= 48828; % sound generation sample rate

%% Analysis
gr	= NaN(nharm,ntrials);
gs	= gr;
G	= gr;
dP	= gr;
for idx=1:ntrials
	%% Sound wave envelope
	% To do: incorporate the stimulus envelope from creation
	% Not use noisy wav-file
	cd(snd_dir);
	wavname1	= ['snd' num2str(sndid1(idx))];
	wavname2	= ['snd' num2str(sndid2(idx))];
	snd1		= wavread(wavname1);
	snd2		= wavread(wavname2);
	env1		= smooth(abs(hilbert(snd1)),500);
	env2		= smooth(abs(hilbert(snd2)),500);
	S			= env2-env1;
	S			= calfactor*S;
	
	%% Visualization
	tH = (1:size(H,1))/Fsmedusa;
	tS = (1:length(snd1))/Fsrp2;
	
	figure(idx)
	subplot(311)
	hold on
	h1 = plot(tS,S,'k-');
	h2 = plot(tH,H(:,idx),'r-','LineWidth',2);
	box off
	set(gca,'TickDir','out');
	xlabel('Time (s)');
	xlim([0 22]);
	ylabel('Position (deg)');
	legend('Sound','Response');
	title('zwuis')
	
	%% Stimulus
	% should make function for stimulus AND response spectrum
	X = S;
	X = X-mean(X); % remove DC
	A = fft(X,Fsrp2*T0);
	A = A(1:length(A)/2+1);
	A = 1/length(X).*A;
	A(2:end-1) = 2*A(2:end-1);
	F = 0:Fsrp2/(2*length(A)):Fsrp2/2;
	F = F(1:length(A));
	F = round(F*T0)/T0;
	
	P = angle(A);
	A = abs(A);
	Stim.F = F;
	Stim.A = A;
	Stim.P = P;
	
	subplot(323)
	h = stem(F,A,'k-');
	hold on
	set(get(h,'Baseline'),'Visible','off')
	set(h,'Marker','none');
	ylim([0 amp*1.1]);
	pa_verline(amp,'k:');
	
	subplot(324)
	h = stem(F,P,'k-');
	hold on
	xlim([0 2]);
	set(h,'Marker','none');
	
	%% Response
	X		= H(:,idx);
	X		= X-mean(X);
	A		= fft(X,Fsmedusa*T0);
	A = A(1:length(A)/2+1);
	A = 1/length(X).*A;
	A(2:end-1) = 2*A(2:end-1);
	F = 0:Fsmedusa/(2*length(A)):Fsmedusa/2;
	F = F(1:length(A));
	F = round(F*T0)/T0;
	P = angle(A);
	A = abs(A);
	
	Resp.F =F;
	Resp.A = A;
	Resp.P = P;
	subplot(323)
	h = plot(F,A,'ro','LineWidth',2,'MarkerFaceColor','w');
	
	hold on
	xlim([0 2]);
	ylim([0 amp*1.1]);
	pa_verline(amp,'k:');
	box off
	set(gca,'TickDir','out');
	xlabel('Frequency (Hz)');
	ylabel('Amplitude (deg)');
	
	subplot(324)
	plot(F,P,'ro','LineWidth',2,'MarkerFaceColor','w');
	hold on
	xlim([0 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('Frequency (Hz)');
	ylabel('Phase (rad)');
	
	%%
	for hrmIdx = 1:nharm
		selr = Resp.F == harm(hrmIdx);
		sels = Stim.F == harm(hrmIdx);
		sum(selr)
		sum(sels)
		gr(hrmIdx,idx) = Resp.A(selr);
		gs(hrmIdx,idx) = Stim.A(sels);
		G(hrmIdx,idx) = Resp.A(selr)./Stim.A(sels);
		
		dP(hrmIdx,idx) = Resp.P(selr)-Stim.P(sels);
	end
	
	subplot(325)
	plot(harm,G(:,idx),'ko-','MarkerFaceColor','w');
	box off
	xlim([0 2]);
	xlabel('Frequency (Hz)');
	ylabel('Gain');
	
	subplot(326)
	plot(harm,unwrap(dP(:,idx)),'ko-','MarkerFaceColor','w');
	hold on
	xlim([0 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('Frequency (Hz)');
	ylabel('Phase (rad)');
end
dP = bsxfun(@minus,dP,dP(1,:));
dP = unwrap(dP)/pi/2;

pa_datadir
print('-depsc','-painter','onetransfer');

figure
subplot(121)
plot(harm,G,'k-','Color',[.7 .7 .7]);
hold on
errorbar(harm,mean(G,2),std(G,[],2),'k-','MarkerFaceColor','w');
plot(harm,mean(G,2),'ko','MarkerFaceColor','w');
box off
xlim([0 1.1]);
ylim([0 1.5]);
xlabel('Frequency (Hz)');
ylabel('Gain');
axis square;

subplot(122)
plot(harm,dP,'k-','Color',[.7 .7 .7]);
hold on
errorbar(harm,mean(dP,2),std(dP,[],2),'k-','MarkerFaceColor','w');
plot(harm,mean(dP,2),'ko','MarkerFaceColor','w');
box off
xlim([0 1.1]);
ylim([-1 0.2])
xlabel('Frequency (Hz)');
ylabel('Phase difference (cycles)');
axis square;


Y = dP(:);
X = repmat(harm,ntrials,1)';
X = X(:);
b = regstats(Y,X,'linear','beta');
pa_regline(b.beta,'r-');
str = [' Delay = ' num2str(round(b.beta(2)*1000)) ' ms'];
title(str)

pa_datadir
print('-depsc','-painter','alltransfer');