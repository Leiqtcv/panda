clear all
close all

cd('E:\DATA\Set-up\Headphones');
Fs		= 48828.125; % Freq (Hz)
HiCut	= 18000;
LoCut	= 500;
Nyq		= Fs/2;

% [min(s) max(s) min(s) + max(s)]

% [CSpec,Impulse]= GolayAnal(ADCBuff,AGol,BGol);
% S	= CSpec .* SpeakerDrxVec;    % correct for speaker directionality, then save complex spectrum of the original system


Freqs	= pa_oct2bw(100,0:1/3:7+1/3);
nFreq	= numel(Freqs);
dur		= 1000;
int		= pa_oct2bw(0.01,-5:4);
nInt	= numel(int);
n		= 0;
Freq	= NaN(230,1);
Amp		= Freq;
for ii = 1:nFreq
	for jj = 1:nInt
		n = n+1;
		Freq(n) = Freqs(ii);
		Amp(n) = int(jj);
	end
end

hrtf = pa_readhrtf('BoseQC2-links.hrtf');
% hrtf = pa_readhrtf('BoseQC2-rechts.hrtf');
% hrtf = pa_readhrtf('SenhPXC350-links.hrtf');
% hrtf = pa_readhrtf('TDH39-links.hrtf');
% hrtf = pa_readhrtf('TDH39-rechts.hrtf');
F = NaN(230,1);
A = F;
F2 = F;
A2 = F;
for ii = 1:230
	x		= squeeze(hrtf(:,:,ii));
	x = x-mean(x);
	
	[f,Mag] = pa_getpower(x',Fs);
	subplot(211)
	plot(x(1:5000))
	title(ii)
	
% 	nfft			= 2^(nextpow2(length(x)));
% 	% Take fft, padding with zeros so that length(fftx) is equal to nfft
% 	fftx			= fft(x,nfft);
% 	% Calculate the numberof unique points
% 	NumUniquePts	= ceil((nfft+1)/2);
% 	% FFT is symmetric, throw away second half
% 	fftx			= fftx(1:NumUniquePts);
% 	Mag		= abs(fftx)/length(x);
% 	Mag = Mag*2;
% 	Mag = 20*log10(Mag);
	% 	f		= (0:NumUniquePts-1)*Fs/nfft;
	%
	subplot(212)
	semilogx(f,Mag,'ko-','MarkerFaceColor','w')
	ylim([-40 20]);
	set(gca,'XTick',Freqs,'XTickLabel',round(Freqs));
	pa_verline(Freq(ii));
	
% 	pause
	[mx,indx] = max(Mag);
	
	% 	[~,indx] = min(abs(f-Freq(ii)));
	F(ii) = f(indx);
	A(ii) = Mag(indx);
	
	if 2*indx<=length(f)
	F2(ii) = f(2*indx);
	A2(ii) = Mag(2*indx);
	pa_verline(F2(ii),'r-');
	F2(ii)
	end
		drawnow
% 		pause

end

%%
figure
uAmp = unique(Amp);
nAmp = numel(uAmp);
col = jet(nAmp);
for ii = 1:nAmp
	sel = Amp==uAmp(ii) & A>-20 & ~isnan(A);
	x = F(sel);
	y = A(sel);
	semilogx(x,y,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',col(ii,:));
	hold on
end
% W = pa_aweight(x);
% HL = pa_dba2dbhl(W,x,1);
% semilogx(x,W+20,'k-')
% semilogx(x,HL+10,'r-')
% semilogx(x,HL+W+20,'g-')

set(gca,'XTick',Freqs,'XTickLabel',round(Freqs),'XScale','log');
pa_horline(20);
xlabel('Frequency (Hz)');
ylabel('Power (dB)');

figure
uAmp = unique(Amp);
nAmp = numel(uAmp);
col = jet(nAmp);
for ii = 1:nAmp
	sel = Amp==uAmp(ii) & A>-20 & ~isnan(A);
	x = F(sel);
	y = A(sel)-A2(sel);
	semilogx(x,y,'ko-','MarkerFaceColor','w','LineWidth',2,'Color',col(ii,:));
	hold on
end
% W = pa_aweight(x);
% HL = pa_dba2dbhl(W,x,1)
% semilogx(x,W+20,'k-')
% semilogx(x,HL+10,'r-')
% semilogx(x,HL+W+20,'g-')

set(gca,'XTick',Freqs,'XTickLabel',round(Freqs),'XScale','log');
pa_horline(20);
xlabel('Frequency (Hz)');
ylabel('\Delta Power (dB)');


return
nfft			= 2^(nextpow2(length(x)));
% Take fft, padding with zeros so that length(fftx) is equal to nfft
S			= fft(x,nfft);
S = abs(S);
% % Calculate the numberof unique points
% NumUniquePts	= ceil((nfft+1)/2);
% % FFT is symmetric, throw away second half
% fftx			= fftx(1:NumUniquePts);
%
% % Take the magnitude of fft of x and scale the fft so that it is not a function of
% % the length of x
% dat		= abs(fftx);
%
%
% hrtf	= pa_gensweep;
% x		= squeeze(hrtf(1380:21000,:,1));
%
% nfft			= 2^(nextpow2(length(x)));
% % Take fft, padding with zeros so that length(fftx) is equal to nfft
% fftx			= fft(x,nfft);
% % Calculate the numberof unique points
% NumUniquePts	= ceil((nfft+1)/2);
% % FFT is symmetric, throw away second half
% fftx			= fftx(1:NumUniquePts);
% f		= (0:NumUniquePts-1)*Fs/nfft;
%
% % Take the magnitude of fft of x and scale the fft so that it is not a function of
% % the length of x
% mx		= abs(fftx);
%
% mx = dat./mx;
%
% plot(f,mx);
% for ii = 1:436
% h = squeeze(hrtf(:,:,ii));
% whos h
% plot(h)
% title(ii)
% drawnow
% pause
% end
% Spec,Freq,Tijd] = sweep2spec(Sweep,Wav,chan,NFFT,NSweep,Fs,GraphFlag)

% return
%
% Spec = mx;
%% Initialization
FIROrder = 850;
HannSize = FIROrder-1; %% size of hanning window
if ~rem(HannSize,2),    % Gotta be odd
	HannSize = HannSize-1;
end
HalfHann	= floor(HannSize/2);
HannWindow	= hanning(HannSize)';

%% Spectrum
Impulse		= real(ifft(S)); % impulse response

figure
plot(Impulse)
%%
nI			= length(Impulse);
[~, indx]	= max(Impulse);
AugImp		= [Impulse Impulse];
if indx<ceil(HannSize/2),
	indx		= indx + nI;
end
CutImp		= AugImp((indx-HalfHann):(indx+HalfHann));
CutImp		= CutImp.*HannWindow; % apply Hanning window
Spec		= fft(CutImp); % get complex spectrum
invSpec		= 1./Spec; % inverse spectrum
Mag			= abs(invSpec(1:(HalfHann+1))); % magnitude
RelFreq		= (0:HalfHann)/(HalfHann); % frequencies


indxLo			= find(RelFreq<LoCut/Nyq);
indxLo			= indxLo(end);
indxHi			= find(RelFreq>HiCut/Nyq);
indxHi			= indxHi(1);
t			= indxLo-(0:indxLo-1);
t			= t/indxLo;
Mag(1:indxLo)	= Mag(1:indxLo).*(1+cos(pi*t))/2;
t			= (indxHi:length(Mag)) - indxHi;
t			= t/max(t);
Mag(indxHi:end) = Mag(indxHi);
Mag(indxHi:end) = Mag(indxHi:end).*(1+cos(pi*t))/2;

Freq = RelFreq*Fs/2;

figure
semilogx(Freq,Mag,'ko-','MarkerFaceColor','w')
FIRBuff = fir2(FIROrder, RelFreq, Mag);

FIRBuff = 10*FIRBuff/sum(abs(FIRBuff)); % normalize by sum of abs FIRBuff
%   and multiply by 10 to get reasonable gain