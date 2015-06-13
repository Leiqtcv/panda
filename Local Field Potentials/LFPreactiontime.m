function [muM,T] = LFPreactiontime(data,cfg)
% LFPTIMEFREQ(DATA)
%
% Plot time-frequency-graph of Local Field Potentials.
%
% 2010 Marc van Wanrooij
disp(['Start ' mfilename]);
tic
M = [];
F = [];
T = [];
for i = 1:length(data)
    [m,f,t] = gettimefreq(data(i).lfpfilt,data(i).samplefrequency,cfg.tstep);
    M(:,:,i) = m;
    %     if i ==1
    %         M = m;
    %         F = f;
    %         T = t;
    %     else
    %         M = M+m;
    %     end
    
end
F       = f;
T       = t;

%% React
ReactFlag   = 1;


maxRT		= max([data.reactiontime]);
indxmax		= find(t>maxRT,1);
MTX		= M;
M		= nanmean(M,3);
MTX1	= repmat(nanmean(M,2),[1,size(MTX,2),size(MTX,3)]);
MTX		= MTX-MTX1;
MTX2	= NaN([size(MTX,1),size(MTX,2)+indxmax,size(MTX,3)]);
if ReactFlag
for ii = 1:length(data)
	figure(1)
	clf
    RT      = [data(ii).reactiontime];
	dur		= data(ii).stimulus.values(3);
	indx = find(t>RT,1);
	indx1 = indx;
	indx = (indxmax-indx+1):(indxmax-indx+size(MTX,2));
    pcolor(indx,f,squeeze(MTX(:,:,ii)));
	MTX2(:,indx,ii) = MTX(:,:,ii);
	xlim([0 size(MTX,2)+indxmax]);
	verline(dur+300,'w-');
	title([RT indx1])
	shading flat
	drawnow
% 	pause
end
end
M		= MTX2;
M		= nanmean(M,3);

muM     = nanmean(M);
muM     = muM-nanmin(muM);
muM     = muM./nanmax(muM);

t = 1:size(M,2);
tstep = 5;
t  = 1000*t*tstep/data(1).samplefrequency-maxRT-300-1000;
if cfg.display
    pcolor(t,f,M)
    shading flat
    hold on
	verline(0,'k-');
%     plot(T,muM*100,'w-','LineWidth',2);
end
toc
disp(['End ' mfilename]);

function [MTX,Freq,t] = gettimefreq(x,Fs,step)
% [M,F,T] = GETTIMEFREQ(X,FS)
%
% Get time-frequency representation of signal X sampled at FS Hz.
%
% 2009 Marc van Wanrooij

%% Default
x       = x(:);
fmax	= 100;
nfft    = 2^12;
wnd		= 2^8; % 256
wnd		= round(Fs*wnd/1000); % samples
n		= length(x);
% step	= 5;
t		= (1:step:(n-wnd));
nt		= length(t);
Freq	= ((1:(nfft/2))-1)/nfft*Fs;
sel		= Freq<fmax;
Freq	= Freq(sel);
nFbin	= sum(sel);
nTbin	= nt;
M		= zeros(nFbin,nTbin);
w		= hanning(wnd+1);

%% Get Power
for i		= 1:nt
    indx	= t(i):t(i)+wnd;
    sig		= x(indx);
    sig		= w.*sig;
    [f,mx]	= getpower(sig,Fs,nfft);
    sel		= f<fmax;
    M(:,i)	= mx(sel);
end
t			= t/Fs+(wnd/2)/Fs;
t           = round(t*1000); % ms
MTX         = M;

function [f,mx]=getpower(x,Fs,nfft)
% [F,MX] = GETPOWER(X,FS,DISP)
%
% Get power spectrum MX of signal X, sampled at FS Hz.
% DISP - plot power spectrum
%


% Sampling frequency
if nargin<2
    Fs = 50000;
end
if nargin<3
    % Use next highest power of 2 greater than or equal to length(x) to calculate FFT.
    nfft			= 2^(nextpow2(length(x)));
end

% Time vector of 1 second
% Take fft, padding with zeros so that length(fftx) is equal to nfft
fftx			= fft(x,nfft);
% Calculate the numberof unique points
NumUniquePts	= ceil((nfft+1)/2);
% FFT is symmetric, throw away second half
fftx			= fftx(1:NumUniquePts);
% Take the magnitude of fft of x and scale the fft so that it is not a function of
% the length of x
mx				= abs(fftx)/length(x);
% Take the square of the magnitude of fft of x.
mx				= mx.^2;

% Since we dropped half the FFT, we multiply mx by 2 to keep the same energy.
% The DC component and Nyquist component, if it exists, are unique and should not
% be mulitplied by 2.
if rem(nfft, 2) % odd nfft excludes Nyquist point
    mx(2:end)	= mx(2:end)*2;
else
    mx(2:end -1) = mx(2:end -1)*2;
end
% This is an evenly spaced frequency vector with NumUniquePts points.
f		= (0:NumUniquePts-1)*Fs/nfft;


mx		= 20*log10(mx);
% sel		= isinf(mx);
% mx(sel) = min(mx(~sel));