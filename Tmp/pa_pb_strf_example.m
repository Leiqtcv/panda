function pa_pb_strf_example

%% Clearance & Closure
close all
clear all
clc


%% Data
cd('C:\DATA\Test'); % go to data-directory
% load('test.mat')
% whos
% spike = spikep;
% spike = rmfield(spike,'spikewave');
% save examplecell spike;
load('examplecell'); % load data

%% Raster plot
figure
pa_spk_rasterplot(spike);
hold on

%% Spike density
s = pa_spk_sdf(spike,'Fs',1000);
plot(s,'r-','LineWidth',2)
xlabel('Time (ms)');
ylabel('Spike density (Hz)');

%% STRF
shift = 0;
data = pa_spk_ripple2strf(spike,'shift',shift);
pa_spk_plotstrf(data,'freqax',shift);
pause(5)
shift = 1;
data = pa_spk_ripple2strf(spike,'shift',shift);
pa_spk_plotstrf(data,'freqax',shift);


function [MSDF,sdf] = pa_spk_sdf(spike,varargin)
% [MSDF,SDF] = PA_SPK_SDF(SPIKE)
%
% Obtain (mean) spike-density function (M)SDF by convolving trains of action
% potentials in SPIKE with a Gaussian, Possion of growth-decay function
% kernel.
%
% SPIKE should be a (sparse) MxN matrix of M trials and N samples,
% consisting of ones (spike) and zeros (no spikes). SPIKE can also be a
% structure containing spike timings in the field spiketime. MSDF will be 
% the average across trials, while SDF will also be a MxN matrix.
%
% PA_SDF(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'kernel'	- specify convolution kernel. Options are:
%			- 'gaussian' (default)
%			- 'poisson'
%			- 'EPSP' a combination of growth and decay funcions that
%			resemble a postsynaptic potential. Default growth and decay
%			time constant: 1 and 20 (chosen according to Thompson et al. 1996)
%
% And some kernel parameters might be requested:
%	'sigma'	- specify Gaussian kernel width. Default: 5 samples.
%	'Te'	and 'Td' - specify growth and decay time constants for EPSP
%						kernel. Default: 1 and 20.
%
% To obtain a firing rate instead of a density function, input a sampling
% frequency:
%	'Fs'	- sample frequency (Hz). This is used to determine firing rate.
%			By default Fs will be empty and only the spike density function
%			is determined.
%
% See also PA_SPK_RASTERPLOT
%
% More information: 
%		"Spikes - exploring the neural code", Rieke et al. 1999, figure	2.1
%		"Matlab for Neuroscientists", Wallisch et al. 2009,  section 15.5.2


% (c) 2011 Marc van Wanrooij
% E-mail: m.vanwanrooij@gmail.com

%% Initialization
if isstruct(spike) % if we have a structure containing spike timings
	spike = pa_spk_timing_struct2mat(spike);
end

if issparse(spike) % if we have a sparse matrix
	spike = full(spike); % make it full
end

%% Optional input
sigma         = pa_keyval('sigma',varargin);
if isempty(sigma)
	sigma			= 5;
end
Te         = pa_keyval('Te',varargin);
if isempty(Te)
	Te			= 1;
end
Td         = pa_keyval('Td',varargin);
if isempty(Td)
	Td			= 20;
end
kernel         = pa_keyval('kernel',varargin);
if isempty(kernel)
	kernel			= 'gaussian';
end
Fs         = pa_keyval('Fs',varargin);

[ntrials,nsamples]		= size(spike);
if ntrials>nsamples
	disp('More trials than samples');
	disp('Is this correct?');
end
switch kernel
	case 'gaussian'
		winsize		= sigma*5;
		t			= -winsize:winsize;
		window		= normpdf(t,0,sigma);
		winsize		= [winsize nsamples+winsize-1];
	case 'poisson'
		winsize		= [1 nsamples];
		t			= 1:150;
		window		= poisspdf(t,sigma);
	case 'EPSP'
		winsize		= [1 nsamples];
		t			= 0:Td*10;
		window		= (1-exp(-t/Te)).*(exp(-t/Td));
		window = window./sum(window);
	otherwise % also do 'gaussian'
		winsize		= sigma*5;
		window		= normpdf(-winsize:winsize,0,sigma);
		winsize = [winsize nsamples+winsize-1];
end


%% Convolute
sdf			= spike;
for ii = 1:ntrials
	convspike	= conv(spike(ii,:),window);
	convspike	= convspike(winsize(1):winsize(2));
	sdf(ii,:)	= convspike;
end

%% Obtain firing rate
if ~isempty(Fs) % if sampling frequency is given
	MSDF		= sum(sdf)/ntrials*Fs; % Firing Rate
	sdf			= sdf*Fs;
else % just average
	MSDF		= sum(sdf)/ntrials; % Probability
end

function data = pa_spk_ripple2strf(Spike,varargin)
% STRF = PA_SPK_RIPPLE2STRF(SPIKE)
%
% Determine STRF from SPIKE-structure (obtained by PA_SPK_READSRC). The
% STRF-structure contains the following fields:
% - magnitude
% - phase
% - density
% - velocity
% - norm
% - moddepth
% - shift
% - strf
% - time
% - frequency
%
% PA_SPK_RIPPLESTRF checks for the ripple parameters in SPIKE (velocity,
% density, depth) but nor for extraneous parameters such as duration of
% static part. This means that you have to divide the experiments in
% different SPIKE structures.
%
% PA_SPK_RIPPLE2STRF(...,'PARAM1',val1,'PARAM2',val2) specifies optional
% name/value pairs. Parameters are:
%	'shift'	- shift the spectro-temporal receptive field by X octaves.
%	Default: 0 (no shift
%	'fs'	- sample frequency of ripple stimuli. Default: 50000 (Hz)
%	'nfft'	- number of FFT points for stimulus generation. Default: 2^14
%	'nbin'
%
% See also PA_SPK_READSRC, PA_SPK_PLOTSTRF

% 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com


%% Initialization
fs        = pa_keyval('fs',varargin);  % sample frequency of ripple stimulus
if isempty(fs)
	fs				= 50000;
end
nfft        = pa_keyval('nfft',varargin); % number of FFT points for stimulus generation
if isempty(nfft)
	nfft			= 2^14;
end
Nbin        = pa_keyval('nbin',varargin); % number of FFT points for stimulus generation
if isempty(Nbin)
	Nbin			= 2^5;
end
starttime        = pa_keyval('start',varargin); % Remove first X ms from analysis
if isempty(starttime)
	starttime		= 100; % ms
end
endtime        = pa_keyval('end',varargin); % End at X ms for analysis
if isempty(endtime)
	endtime		= 1000; % ms
end
df				= fs/nfft/2;	% frequency binning in ripple spectrum
x				= linspace(1/Nbin,1,Nbin);

hfshift        = pa_keyval('shift',varargin); % Do we need to shift the STRF by 1 octave
if isempty(hfshift)
	hfshift			= 0;
end

%% Obtain firing rate during different periods
A	= [Spike.spiketime];
A	= A-300; % Remove the default 300 ms silent period
t	= [Spike.trial];
Dstat		= NaN(size(Spike));
Drand		= Dstat;
Velocity	= NaN(size(Spike));
Density		= Dstat;
MD			= Dstat;
for ii = 1:length(Spike)
	Dstat(ii)		= Spike(ii).stimvalues(3);
	Drand(ii)		= Spike(ii).stimvalues(4);
	Velocity(ii)	= Spike(ii).stimvalues(5);
	Density(ii)		= Spike(ii).stimvalues(6);
	MD(ii)			= Spike(ii).stimvalues(7);
end
Dstat		= Dstat(t);
A			= A-Dstat;
% Some rounding, or else Matlab will not recognize certain values correctly
% due to rounding precision
Velocity	= round(Velocity*1000)/1000;
Density		= round(Density*1000)/1000;
MD			= round(MD);
vel			= Velocity;
dens		= Density;
moddepth	= MD;
% Set Velocity, Density and Depth in correct order
Velocity	= Velocity(t);
Density		= Density(t);
MD			= MD(t);
% And get unique values
uV			= unique(Velocity);
uD			= unique(Density);
uM			= unique(MD);

%% Get STRF
M	= squeeze(NaN([numel(uV) numel(uD) numel(uM)]));
P	= M;
Nrm = M;
for ii = 1:numel(uV)
	for jj = 1:numel(uD)
		for kk = 1:numel(uM)
			selv	= Velocity==uV(ii);
			seld	= Density==uD(jj);
			selm	= MD==uM(kk);
			sela	= A>=0 & A<unique(Drand); % Select for velocity and density
			sel		= selv & seld & selm & sela;
			Nrep	= sum(vel==uV(ii) & dens==uD(jj) & moddepth == uM(kk));
			if sum(sel)
				%% Bin
				SpikeTimes	= A(sel);
				w			= round(uV(ii)/df)*df;
				period		= 1000/w;
Nspikes		= getbins(SpikeTimes,Nbin,x,period,starttime,endtime,Nrep);
				
				%% Fourier analysis - Take first component
				X			= fft(Nspikes,Nbin)/Nbin;
				M(ii,jj,kk)		= abs(X(2));
				P(ii,jj,kk)		= angle(X(2));
				binnum		= Nbin;
				nFFT		= 1+binnum/2;
				Nrm(ii,jj,kk)	= abs(X(2))/sqrt(sum(abs(X(2:nFFT)).^2));
			end
		end
	end
end
data	= struct([]);
for ii = 1:numel(uM)
	Mag		= squeeze(M(:,:,ii));
	Phase	=  squeeze(P(:,:,ii));
	Norm	= squeeze(Nrm(:,:,ii));
	
	NO		= numel(uD);
	NW		= numel(uV);
	Whi		= max(uV);
	Wlo		= min(uV);
	Wstep	= (Whi-Wlo)/(NW-1);
	Ohi		= max(uD);
	Olo		= min(uD);
	Ostep	= (Ohi-Olo)/(NO-1);
	tms		= (0:NW*2-1)/(NW*2)/Wstep*1000;  % 10 points in strf (changed 1-'01)
	xoct	= (1:NO-1)/(NO-1)/Ostep;
	
	if ~any(isnan(Mag))
		%% STRF
		C		= Mag.*exp(1i*Phase);
		strf	= compstrf(C);
	else
		% Find fixed density and velocity
		indxFixD = find(sum(isnan(Mag))==0);
		indxFixV = find(sum(isnan(Mag'))==0);
		data(ii).fixeddensity	= uD(indxFixD);
		data(ii).fixedvelocity	= uV(indxFixV);
		
		% first determine parameters for fixed density O Omega
		Mfd		= Mag(:,indxFixD);
		Pfd		= Phase(:,indxFixD);
		
		% then determine parameters for fixed velocity w omega
		Mfv		= Mag(indxFixV,:);
		Pfv		= Phase(indxFixV,:);
		% 		% index for two crosspoints
		Pcross	= Phase(indxFixV,indxFixD); % phases at cross points
		Across	= Mag(indxFixD,indxFixD); % amplitudes at cross points
		Mt		= Mfd*Mfv;
		Pt		= Pfd*Pfv;
		
		data(ii).magextra	= Mt;
		data(ii).phasextra	= Pt;
		
		Cplx	= Mt.*exp(1i*Pt);
		CplxQ12	= Cplx*exp(-1i*Pcross)/Across;
		
		% total complex transfer function and strf
		strf = compstrf(CplxQ12);
	end
	if hfshift~=0
		kshift	= hfshift/(xoct(2)-xoct(1));
		m		= size(strf,1);
		indx	= [kshift+1:m 1:kshift];
		strf	= strf(indx,:);
	end
	%% Save data
	data(ii).strf		= strf;
	data(ii).frequency	= xoct;
	data(ii).time		= tms;
	data(ii).magnitude	= Mag;
	data(ii).phase		= Phase;
	data(ii).norm		= Norm;
	data(ii).moddepth	= uM(ii);
	data(ii).density	= uD;
	data(ii).velocity	= uV;
	data(ii).shift		= hfshift;
end

function Nspikes = getbins(SpikeTimes,Nbin,x,period,starttime,endtime,Nrep)
% GETBINS
% Bin the spike responses

%% Remove Onset Transient
% Remove all periods that have spikes in the first 100 ms
N				= ceil(starttime/period); % Number of periods
% The next part could be made better
% sel				= SpikeTimes>starttime & SpikeTimes<=N*period;
% SPKAfterOnset		= SpikeTimes(sel);

sel				= SpikeTimes>N*period;
SpikeTimes		= SpikeTimes(sel); % remove all spikes that fall within the "onset transient"

%% Use only periods that fall completely within 1000 ms
N			= floor(endtime/period);
NbinafterNperiods = round(Nbin*(endtime/period-N));
sel			= SpikeTimes>N*period;
SPKAfterNperiods	= SpikeTimes(sel);
sel			= SpikeTimes<=N*period;
SpikeTimes	= SpikeTimes(sel);

%% Make period histograms
% Express Spike Times as lying between 0 and 1 period
SpikeTimes	= mod(SpikeTimes,period);
SpikeTimes	= SpikeTimes/period;
Nspikes		= hist(SpikeTimes,x); % Bin spiketimes in Nbin bins
Nspikes		= Nbin*1000*Nspikes/Nrep/period; % Convert to firing rate


if ~isempty(SPKAfterNperiods)
	SPKAfterNperiods				= mod(SPKAfterNperiods,period);
	SPKAfterNperiods				= SPKAfterNperiods/period;
	NspikesAfterNperiods	= hist(SPKAfterNperiods,x); % Bin spiketimes in Nbin bins
	NspikesAfterNperiods	= Nbin*1000*NspikesAfterNperiods/Nrep/period; % Convert to firing rate
	Nspikes					= Nspikes+NspikesAfterNperiods;
end

% 		if ~isempty(SPKAfterOnset)
% 			SPKAfterOnset				= mod(SPKAfterOnset,period);
% 			SPKAfterOnset				= SPKAfterOnset/period;
% 			NspikesAfterOnset	= hist(SPKAfterOnset,x); % Bin spiketimes in Nbin bins
% 			NspikesAfterOnset	= Nbin*1000*NspikesAfterOnset/Nrep/period; % Convert to firing rate
% 			Nspikes					= Nspikes+NspikesAfterOnset;
% 		end

%% Normalize for N periods
Nperiods = repmat(N,1,Nbin); % N full periods
Nperiods(1:NbinafterNperiods) = Nperiods(1:NbinafterNperiods)+1; % Normalize for partial period after N full periods
Nspikes = Nspikes./Nperiods;

function strf = compstrf(cplxq12,nw,no)
%  STRF = COMPSTRF(CPLXQ12,NW,NO)
%
% Obtain spectrotemporal receptive field STRF from the complex transfer
% function for quadrants 1 and 2 CPLXQ12, for w>0, entire omega range.

% Huib Versnel, version 26-7-'00
if nargin < 3
	no=1;
end;
if nargin < 2
	nw=1;
end;
s				= size(cplxq12,2);
stat			= zeros(1,s);
cplxq34			= conj(fliplr(flipud(cplxq12)));
cplxtotal		= [cplxq34;stat;cplxq12];
cplxtot1		= conj(fliplr(flipud(fftshift(cplxtotal(2:end,2:end)))));
cplxstrf		= ifft2(cplxtot1*(nw*no));	%inverse Fourier transform
strf			= real(fliplr(cplxstrf).');


function pa_spk_plotstrf(data,varargin)
% PA_SPK_PLOTSTRF(STRF)
%
% Plot Spectro-Temporal Receptive Field in structure STRF, ontained by
% PA_SPK_RIPPLESTRF. This structure contains the following fields:
% - magnitude
% - phase
% - density
% - velocity
% - norm
% - strf
% Additional fields (depending on experiment) are:
% - magextra
% - phasextra
%
%
% See also PA_SPK_RIPPLE2STRF

% 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Data-structure contains N elements, one for each Modulation Depth
% presented.
n	= length(data);
freqax        = pa_keyval('freqax',varargin);  % sample frequency of ripple stimulus
if isempty(freqax)
	freqax				= false;
end
%% Graphics
% Plot magnitude and phase plots
for ii = 1:n
	figure(150+ii)
	m		= data(ii).magnitude;
	p		= data(ii).phase;
	nrm		= data(ii).norm;
	uD		= data(ii).density;
	uV		= data(ii).velocity;
	plotMP(m,p,nrm,uD,uV);
end

% Sometimes only a subsection of ripples were presented, with a fixed
% density and velocity, instead of an entire quadrant.
if isfield(data,'magextra')
	for ii = 1:n
		figure(100+ii)
		m		= data(ii).magextra;
		p		= data(ii).phasextra;
		nrm		= data(ii).norm;
		uD		= data(ii).density;
		uV		= data(ii).velocity;
		plotMP(m,p,nrm,uD,uV);
	end
end



%% STRF
	nsb = ceil(sqrt(n)); %number of subplots
for ii = 1:n
	figure(200)
	subplot(nsb,nsb,ii)
	x		= data(ii).time;
	y		= data(ii).frequency;
	z		= data(ii).strf;
	whos x y z
	[~,m] = max(max(z,[],1));
	
	mxscal = max(abs(z(:)));
	XI = linspace(min(x),max(x),500);
	YI = linspace(min(y),max(y),500);
	ZI = interp2(x,y',z,XI,YI','*spline');
	
	subplot(121)
	imagesc(x,y,z);
	colorbar;
	axis square
	caxis([-mxscal,mxscal]);
	ylabel('Frequency (octaves)');
	xlabel('time (ms)');
	title('STRF');
	set(gca,'YDir','normal','TickDir','out');
	pa_verline(x(m));
	xlim([0 100])
	if ~islogical(freqax) || freqax
		yoct = get(gca,'YTick');
		yfreq = round(pa_oct2bw(250,yoct+freqax));
		set(gca,'YTick',yoct,'YTickLabel',yfreq);
		ylabel('Frequency (Hz)');

	end
	
	subplot(122)
	imagesc(XI,YI,ZI);
	shading flat;
	colorbar;
	axis square
	caxis([-mxscal,mxscal]);
	ylabel('tonotopy (octaves)');
	xlabel('time (ms)');
	title('STRF');
	set(gca,'YDir','normal','TickDir','out');
	pa_verline(x(m));
	xlim([0 100])
	if ~islogical(freqax) || freqax
		yoct = get(gca,'YTick');
		yfreq = round(pa_oct2bw(250,yoct+freqax));
		set(gca,'YTick',yoct,'YTickLabel',yfreq);
		ylabel('Frequency (Hz)');
	end
end

function plotMP(M,P,Nrm,x,y)
% Magnitude plot
subplot(131)
z		= M;
imagesc(x,y,z);
colorbar;
ylabel('ripple velocity (Hz)');
axis square
set(gca,'YDir','normal','TickDir','out');
set(gca,'YTick',y,'XTick',x);
title('Magnitude (Hz)');


% Phase plot
subplot(132)
z		= P;
imagesc(x,y,z);
caxis([-pi pi])
colorbar;
xlabel('ripple density (cycles/s)');
axis square
set(gca,'YDir','normal','TickDir','out');
set(gca,'YTick',[],'XTick',x);
title('Phase');

% Norm plot
subplot(133)
z		= Nrm;
imagesc(x,y,z);
caxis([0 1])
colorbar;
axis square
set(gca,'YDir','normal','TickDir','out');
set(gca,'YTick',[],'XTick',x);
title('Norm factor');


function h = pa_spk_rasterplot(T,varargin)
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

%% Plotting
if isstruct(T) % if we have a structure containing spike timings
	Ntrials = length(T);
	hold on;
	for ii = 1:Ntrials
		t = T(ii).spiketime;
		t = t/Fs*1000; % spike times in (ms)
		for jj = 1:length(t)
			line([t(jj) t(jj)],[ii-1 ii],'Color',col);
		end
	end
	% Ticks and labels
	ylim([0 Ntrials]);
	set(gca,'TickDir','out');
	xlabel('Time (ms)');
	ylabel('Trial #');
	% It is inconvenient to get a line handle for EVERY spike, therefore we just
	% give the handle of the current axis
	h = gca;
else % if we have just on- and offsets
	% plot spikes
	trials		= ceil(T/Ltrial);	% get trial number for each spike time
	time		= mod(T,Ltrial);	% get time in trial
	time(~time) = Ltrial;			% Time 0 is actually last sample in trial
	numspikes	= length(T);
	x			= NaN(3*numspikes,1);
	y			= NaN(3*numspikes,1);
	
	% Trials
	y(1:3:3*numspikes)		= (trials-1);
	y(2:3:3*numspikes)		= y(1:3:3*numspikes)+1;
	
	% Time scale
	x(1:3:3*numspikes)		= time*1000/Fs; % in ms
	x(2:3:3*numspikes)		= time*1000/Fs;
	
	h = plot(x,y,'Color',col);
	xlim([1 Ltrial*1000/Fs]);
	ylim([0 Ntrials]);
	
	% Ticks and labels
	set(gca,'TickDir','out');
	xlabel('Time re Onset (ms)');
	ylabel('Trial #');
end

function F = pa_oct2bw(F1,oct)
% F2 = PA_OCT2BW(F1,OCT)
%
% Determine frequency F2 that lies OCT octaves from frequency F1
%

% (c) 2011-05-06 Marc van Wanrooij
F = F1 .* 2.^oct;

function [val, remaining] = pa_keyval(key, varargin)

% PA_KEYVAL returns the value that corresponds to the requested key in a
% key-value pair list of variable input arguments
%
% Use as
%   [val] = pa_keyval(key, varargin)
%
% See also VARARGIN

% Undocumented option
%   [val] = pa_keyval(key, varargin, default)

% Copyright (C) 2005-2007, Robert Oostenveld
%
% This file was part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details. It is now used for PandA, see
% http://www.mbfys.ru.nl/~marcw/Spike/doku.php
%
%    PandA is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    PandA is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with PandA. If not, see <http://www.gnu.org/licenses/>.
%

% what to return if the key is not found
emptyval = [];

if nargin==3 && iscell(varargin{1})
  emptyval = varargin{2};
  varargin = varargin{1};
end

if nargin==2 && iscell(varargin{1})
  varargin = varargin{1};
end

if mod(length(varargin),2)
  error('optional input arguments should come in key-value pairs, i.e. there should be an even number');
end

% the 1st, 3rd, etc. contain the keys, the 2nd, 4th, etc. contain the values
keys = varargin(1:2:end);
vals = varargin(2:2:end);

% the following may be faster than cellfun(@ischar, keys)
valid = false(size(keys));
for i=1:numel(keys)
  valid(i) = ischar(keys{i});
end

if ~all(valid)
  error('optional input arguments should come in key-value pairs, the optional input argument %d is invalid (should be a string)', i);
end

hit = find(strcmpi(key, keys));
if isempty(hit)
  % the requested key was not found
  val = emptyval;
elseif length(hit)==1  
  % the requested key was found
  val = vals{hit};
else
  error('multiple input arguments with the same name');
end

if nargout>1
  % return the remaining input arguments with the key-value pair removed
  keys(hit) = [];
  vals(hit) = [];
  remaining = cat(1, keys(:)', vals(:)');
  remaining = remaining(:)';
end
