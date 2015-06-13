function pa_bose_qc2_calibration(dname,fname,varargin)
% PA_BOSE_QC2_CALIBRATION2
%
% Determine calibration parameters of the Bose Quiet Comfort 2 headphones.
%
% See also AUDIOGRAM, PA_PLOT_BOSE_QC2_CALIBRATION

% 2013 Marc van Wanrooij
% Calibration performed by Michiel Dirkx, Maarten van de Kraan

%% Files
fname =  'BoseQC2-links.hrtf';
% fname = 'BoseQC2-rechts.hrtf';
% fname = 'SenhPXC350-links.hrtf';
% fname = 'TDH39-links.hrtf';
% fname = 'TDH39-rechts.hrtf';
d = which(fname);

%% Some experimental/setup details
% this should be stored in the data-file
% unfortunately, it is not
% These parameters have been used when obtaining data stored in
% 'BoseQC2-links.hrtf'.
Fs		= 48828.125; % Freq (Hz)
Freqs	= pa_oct2bw(100,0:1/3:7+1/3); % pure tones of these frequencies were presented. 
nFreq	= numel(Freqs);
int		= pa_oct2bw(0.01,-5:4); % and the sounds were stored in wav-filed at different amplitudes
nInt	= numel(int);
n		= 0;
Freq	= NaN(230,1); % 230 combinations of frequencies and amplitudes were tested
Amp		= Freq;
for ii = 1:nFreq
	for jj = 1:nInt
		n = n+1;
		Freq(n) = Freqs(ii);
		Amp(n) = int(jj);
	end
end

%% Analysis
hrtf = pa_readhrtf(d); % read the data

F	= NaN(230,1);
A	= F;
F2	= F;
A2	= F;
for ii = 1:230 % there are 230 trials
	x		= squeeze(hrtf(:,:,ii));
	x		= x-mean(x);
	[f,Mag] = pa_getpower(x',Fs); % determine the power-spectrum of the current trial/tone
	
	[~,indx] = max(Mag); % frequency index of highest-amplitude signal
	F(ii) = f(indx);
	A(ii) = Mag(indx);
	
	if 2*indx<=length(f) % determine harmonic
		F2(ii) = f(2*indx);
		A2(ii) = Mag(2*indx);
	end

	subplot(211)
	plot(x(1:5000))
	title(ii)
	
	subplot(212)
	semilogx(f,Mag,'ko-','MarkerFaceColor','w')
	ylim([-40 20]);
	set(gca,'XTick',Freqs,'XTickLabel',round(Freqs));
	pa_verline(Freq(ii));
		pa_verline(F2(ii),'r-');
			drawnow
	pause(.1)
end

%% Visualization
close all
figure
subplot(211)
hold on
uAmp = unique(Amp);
nAmp = numel(uAmp);
col = jet(nAmp);

H = [];
for ii = 1:nAmp
	sel = Amp==uAmp(ii) & A>-20 & ~isnan(A);
	x = F(sel);
	y = A(sel);
	if sum(sel)
	h = semilogx(x,y,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',col(ii,:));
	H = [H h];
	end
end
% W = pa_aweight(x);
% HL = pa_dba2dbhl(W,x,1);
% semilogx(x,W+20,'k-')
% semilogx(x,HL+10,'r-')
% semilogx(x,HL+W+20,'g-')

legend(H,num2str(log2(uAmp/0.01)));
set(gca,'XTick',Freqs,'XTickLabel',round(Freqs),'XScale','log');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
ylim([-30 30]);
pa_horline([0 20]);

subplot(212)
uAmp = unique(Amp);
nAmp = numel(uAmp);
col = jet(nAmp);
for ii = 1:nAmp
	sel = Amp==uAmp(ii) & A>-20 & ~isnan(A);
	x = F(sel);
	y = A2(sel);
	semilogx(x,y,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',col(ii,:));
	hold on
end
title('First first-order harmonic');
set(gca,'XTick',Freqs,'XTickLabel',round(Freqs),'XScale','log');
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
ylim([-120 30]);
pa_horline([0 20]);

