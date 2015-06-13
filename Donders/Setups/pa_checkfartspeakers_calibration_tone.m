function pa_checkfartspeakers_calibration_tone
% PA_BOSE_QC2_CALIBRATION2
%
% Determine calibration parameters of the Bose Quiet Comfort 2 headphones.
%
% See also AUDIOGRAM, PA_PLOT_BOSE_QC2_CALIBRATION

% 2013 Marc van Wanrooij
% Calibration performed by Michiel Dirkx, Maarten van de Kraan

close all
% grphFlag = false;

%% Files
fname	=  'E:\DATA\Set-up\Soundcal\fartspeakers-1-2013-02-11.hrtf';
d		= fname;
cal1 = getcal(d);
plotcal(cal1);

fname	=  'E:\DATA\Set-up\Soundcal\fartspeakers-2-2013-02-11.hrtf';
d		= fname;
cal2 = getcal(d);
plotcal(cal2);

%%
keyboard
f = [cal1.frequency; cal2.frequency];
s = [cal1.amplitude; cal2.amplitude];
whos f s
figure
plot(f,s);

function plotcal(cal)
Snd		= cal.amplitude;
Loc		= cal.stimlocation;
uLoc	= unique(Loc);
nLoc	= numel(uLoc);
Amp		= cal.stimamplitude;
uAmp = unique(Amp);
nAmp = numel(uAmp);
F = cal.frequency;
%% Visualization
col = summer(nAmp);

Freq = NaN(nLoc,nAmp);
S = Freq;
for ii = 1:nLoc
	for jj = 1:nAmp
		sel = Amp==uAmp(jj) & Loc == uLoc(ii);
% 		Freq(ii,jj,:) = 
		subplot(5,6,ii)
		
		x = F(sel);
		y = Snd(sel);
		semilogx(x,y,'k-','LineWidth',2,'Color',col(jj,:));
		hold on
		f = pa_oct2bw(1000,-2:2:6);
		set(gca,'XTick',f,'XTickLabel',f);
		title(ii)
		ylim([-80 10])
		xlim([100 20000])
		xlabel('Frequency (Hz)');
		ylabel('power (dB re V)');
	end
end


function cal = getcal(d)
%% Some experimental/setup details
% this should be stored in the data-file
% unfortunately, it is not
% These parameters have been used when obtaining data stored in
% 'BoseQC2-links.hrtf'.
Fs		= 48828.125; % Freq (Hz)
Freqs	= pa_oct2bw(100,1/2:1/2:7); % pure tones of these frequencies were presented.
nFreq	= numel(Freqs);
int		= 30:10:70; % and the sounds were stored in wav-filed at different amplitudes
nInt	= numel(int);
n		= 0;
Freq	= NaN(207,1); % 230 combinations of frequencies and amplitudes were tested
Amp		= Freq;
for ii = 1:nFreq
	for jj = 1:nInt
		n = n+1;
		Freq(n) = Freqs(ii);
		Amp(n) = int(jj);
	end
end

%% Analysis
[hrtf,m] = pa_readhrtf(d); % read the data
sel = m(:,2)==1; % STRANGE, SHOULD BE 2 ACCORDING TO PA_READCSV!
Snd = m(sel,11);
nSnds = length(Snd);
Loc = m(sel,7);
Amp = m(sel,10);

%%
n = nFreq*nInt*29;
n = round(n/2);
F	= NaN(n,1);
A	= F;
F2	= F;
A2	= F;
cal = struct([]);
for ii = 1:nSnds
	x			= hrtf(ii).hrtf;
	x			= x(2000:end-2000);
	x			= x-mean(x);
	[f,Mag]		= pa_getpower(x',Fs); % determine the power-spectrum of the current trial/tone
	
	[~,indx]	= max(Mag); % frequency index of highest-amplitude signal
	F(ii)		= f(indx);
	A(ii) = Mag(indx);
	if 2*indx<=length(f) % determine harmonic
		F2(ii) = f(2*indx);
		A2(ii) = Mag(2*indx);
	end
	
	
end
cal(1).frequency = F;
cal(1).amplitude = A;
cal(1).stimidentity	= Snd;
cal(1).stimamplitude	= Amp;
cal(1).stimlocation	= Loc;







function [dat,mlog,exp,chan] = pa_readhrtf(hrtffile)
% HRTF = PA_READHRTF(HRTFFILE)
%
% Read hrtf-file and extract Time Series data in HRTF
% HRTF is a (k x m x n)-matrix, where
%   k = number of samples
%   m = number of trials/locations
%   n = number of microphones/channels
%
% See also READCSV, READDAT

% Copyright 2008
% Marc van Wanrooij

%% Initialization
% Check Inputs
if nargin <1
	hrtffile        = '';
end
% Check Files
hrtffile            = pa_fcheckext(hrtffile,'.hrtf');
hrtffile            = pa_fcheckexist(hrtffile,'.hrtf');
csvfile             = pa_fcheckext(hrtffile,'.csv');

%% Read CSV-file
[exp,chan,mlog]     = pa_readcsv(csvfile);
% to determine number of trials
% nrepeats			= exp(3);
% ntrials             = exp(4);
% and number of channels

sel                 = ismember(mlog(:,5),6); % 6 and 7 are Inp1 and Inp2
ntrials				= sum(sel);

nsample				= mlog(sel,9);

% mlog
%% Read HRTF-file
fid             = fopen(hrtffile,'r');
% First determine number of samples
% fseek(fid,0,'eof');
% nbytes          = ftell(fid);
% nsample         = nbytes./(nchan*ntrials*nbytesperfloat);
% nsample = floor(nsample);
% rem(nsample,1)
% Get HRTF data
% frewind(fid)
if ispc
	hrtf         = fread(fid,inf,'float');
else %MAC
	hrtf         = fread(fid,inf,'float','l');
end
% And close
fclose(fid);

dat = struct([]);
cnt = 0;
for ii = 1:ntrials
	indx			= (1:nsample(ii))+cnt;
	cnt				= cnt+nsample(ii);
	dat(ii).hrtf	= hrtf(indx);
end

