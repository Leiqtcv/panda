%% Initialization
close all
clear all

%% Load data
cd('E:\DATA\Studenten\Nynke\NN-02-2014-04-29');
fname = 'NN-02-2014-04-29-0001.hv';
[H,V] = pa_loadraw(fname,2,22000);

%% wav names and figure handles
ntrials = size(H,2);
fignum = 1:2:(2*ntrials-1); % handles for figures and sounds
fignum(2,:) = fignum(1,:)+1;

wavnames = {'snd107.wav','snd109.wav','snd103.wav','snd105.wav','snd101.wav';
	'snd108.wav','snd110.wav','snd104.wav','snd106.wav','snd102.wav'};
f_soundmov = [0.5,0.1,0.9,0.3,0.7];

%%
for i=1:ntrials
% for i = 1
	%% Sound waves
	cd('E:\DATA\Studenten\Nynke\Zwuis moving sounds');
	
	wavname1 = wavnames{1,i};
	wavname2 = wavnames{2,i};
	
	snd1 = wavread(wavname1);
	snd2 = wavread(wavname2);
	env1 = smooth(abs(hilbert(snd1)),500);
	env2 = smooth(abs(hilbert(snd2)),500);
	
	S = env2-env1;
	
	%% Visualization
	tH = (1:size(H,1))/1017;
	tS = (1:length(snd1))/48828.125;
	%     figure(fignum(1,i))
	%     plot(H(:,i),'-');
	%     plottitle = sprintf('sound movement frequency %g Hz',f_soundmov(i));
	%     title(plottitle)
	
	figure(fignum(2,i))
	subplot(311)
	%     plot(tS,90*snd2,'k-')
	hold on
	h1 = plot(tS,120*S,'k-');
	%     h2 = plot(tH,H(:,i)-mean(H(:,i)),'k-');
	h2 = plot(tH,H(:,i),'r-','LineWidth',2);
	box off
	set(gca,'TickDir','out');
	xlabel('Time (s)');
	xlim([0 22]);
	ylabel('Position (deg)');
	legend('Sound','Response');
	%         plottitle = sprintf('sound movement frequency %g Hz',f_soundmov(i));
	%     title(plottitle)
	title('zwuis')
	
		%% Stimulus
	%     X = 90*S;
	%     % X = decimate(S,48828.125/1017);
	%     [F,A,P] = pa_getpower(X,48828.125);
	%     subplot(323)
	%     plot(F,A,'k-');
	%     xlim([0.1 5]);
		X = 360*S;
	X = detrend(X);
	%     [F,A,P] = pa_getpower(X);
	A = fft(X,500000);
	A = A(1:length(A)/2+1);
	A = 1/length(X).*A;
	A(2:end-1) = 2*A(2:end-1);
	Fs = 50000;
	F = 0:Fs/(2*length(A)):Fs/2;
	F = F(1:length(A));
	P = angle(A);
	A = abs(A);
		Stim.F = floor(F*10)/10;
	Stim.A = A;
	Stim.P = P;

	subplot(323)
	h = stem(F,A,'k-');
	hold on
	set(get(h,'Baseline'),'Visible','off')
	set(h,'Marker','none');
	
	subplot(324)
	plot(F,P,'k-');
	hold on
	xlim([0.1 5]);
	% subplot(313)
	%% Response
	X = H(:,i);
	X = detrend(X);
	%     [F,A,P] = pa_getpower(X);
	A = fft(X,10000);
	A = A(1:length(A)/2+1);
	A = 1/length(X).*A;
	A(2:end-1) = 2*A(2:end-1);
	Fs = 1000;
	F = 0:Fs/(2*length(A)):Fs/2;
	F = F(1:length(A));
	P = angle(A);
	A = abs(A);
	
	Resp.F = floor(F*10)/10;
	Resp.A = A;
	Resp.P = P;
	subplot(323)
% 	h = stem(F,A,'r-','LineWidth',2);
	h = plot(F,A,'ro','LineWidth',2,'MarkerFaceColor','w');

	hold on
	xlim([0.1 2]);
	box off
	set(gca,'TickDir','out');
	xlabel('Frequency (Hz)');
	ylabel('Amplitude (deg)');
% 	pa_verline([2, 3, 7, 11, 19]*0.1,'k:');
% 	set(get(h,'Baseline'),'Visible','off')
% 	set(h,'Marker','o','MarkerFaceColor','w');
	
	subplot(324)
	plot(F,P,'r-');
	hold on
	xlim([0.1 5]);
	box off
	set(gca,'TickDir','out');
	xlabel('Frequency (Hz)');
	ylabel('Phase (rad)');
	% PH = P;
	
	%% 
	harm = floor([2, 3, 7, 11, 19]*0.1*10)/10;
	nharm = numel(harm);
	for idx = 1:nharm
	selr = Resp.F == harm(idx);
	sels = Stim.F == harm(idx);
	G(idx,i) = Resp.A(selr)./Stim.A(sels);
	end

	subplot(325)
	plot(harm,G(:,i),'ko-','MarkerFaceColor','w');
	box off
		xlim([0.1 2]);
			xlabel('Frequency (Hz)');
	ylabel('Gain');


end


	figure
	plot(harm,G,'k-','Color',[.7 .7 .7]);
	hold on
	errorbar(harm,mean(G,2),std(G,[],2),'k-','MarkerFaceColor','w');
	plot(harm,mean(G,2),'ko','MarkerFaceColor','w');
	box off
		xlim([0.1 2]);
			xlabel('Frequency (Hz)');
	ylabel('Gain');