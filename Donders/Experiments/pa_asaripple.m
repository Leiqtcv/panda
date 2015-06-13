function varargout = pa_asaripple(varargin)
% PA_ASARIPPLE MATLAB code for pa_asaripple.fig
%      PA_ASARIPPLE, by itself, creates a new PA_ASARIPPLE or raises the existing
%      singleton*.
%
%      H = PA_ASARIPPLE returns the handle to a new PA_ASARIPPLE or the handle to
%      the existing singleton*.
%
%      PA_ASARIPPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PA_ASARIPPLE.M with the given input arguments.
%
%      PA_ASARIPPLE('Property','Value',...) creates a new PA_ASARIPPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pa_asaripple_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pa_asaripple_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pa_asaripple

% Last Modified by GUIDE v2.5 24-Oct-2012 10:44:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
	'gui_Singleton',  gui_Singleton, ...
	'gui_OpeningFcn', @pa_asaripple_OpeningFcn, ...
	'gui_OutputFcn',  @pa_asaripple_OutputFcn, ...
	'gui_LayoutFcn',  [] , ...
	'gui_Callback',   []);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before pa_asaripple is made visible.
function pa_asaripple_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pa_asaripple (see VARARGIN)

handles                                = main_variables(handles, varargin{:});

% Choose default command line output for pa_asaripple
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pa_asaripple wait for user response (see UIRESUME)
% uiwait(handles.pa_asaripple_fig);

function handles = main_variables(handles,varargin)

%% Variables
handles.Pname	=	'E:\DATA\';
handles.Subj	=	'MW-2012-10-24';

handles.Vel1	=	4;			% Ripple velocity [Hz]
handles.Dens1	=	2;			% Ripple density [cyc/oct]
handles.Mod1	=	1;			% Modulation depth (0-1)
handles.Dur1	=	1000;		% Duration [msec]

handles.Vel2	=	0:5:20;		% Ripple velocity [Hz]
handles.Dens2	=	-4:2:4;		% Ripple density [cyc/oct]
handles.Vel2	=	2;		% Ripple velocity [Hz]
handles.Dens2	=	-1;		% Ripple density [cyc/oct]

handles.Mod2	=	1;			% Modulation depth (0-1)
handles.Dur2	=	1000;		% Duration [msec]

handles.Delay	=	0;			% Delay S2 re S1 [msec]
handles.Amp		=	.4;			% AMplitude [0 1]
handles.Nrep	=	2;			% Number of repetitions

% Fs		=	48828.125;	% Sampling frequency [Hz], for TDT
handles.Fs		=	50000;	% Sampling frequency [Hz]

handles.Ndelay	=	round(handles.Delay * 10^-3 * handles.Fs);
handles.Dur2	=	handles.Dur2 - handles.Delay;

%% Setup the trial matrix
handles.stmMtx	=	makemtx(handles.Vel2,handles.Dens2,handles.Mod2,handles.Vel1,handles.Dens1,handles.Mod1,handles.Nrep);
handles.nTrl	=	length(handles.stmMtx);
handles.S		= struct([]);
handles.CurrentTrial = 1;
handles.display = true;

function Mtx = makemtx(Vel,Dens,Mod,cVel,cDens,cMod,Nrep)
% MTX = MAKEMTX(VEL,DENS,MD,CVEL,CDENS,CMD,NREP)
%
% Create stimulus matrix

%% Recombine Velocity, Density and Modulation Depth of mask
[X,Y,Z]	=	meshgrid(Vel,Dens,Mod);
X		=	X(:);
Y		=	Y(:);
Z		=	Z(:);
Mtx		=	[X,Y,Z];

%% Add catch trial
sel		=	cVel == Mtx(:,1) & cDens == Mtx(:,2) & cMod == Mtx(:,3);	%-- Make sure that you don't select Snd1 = Snd2 --%
M		=	Mtx(~sel,:);

C		=	[M ones(size(M,1),1)]; % catch trials = 4th row = 1
M		=	[Mtx zeros(size(Mtx,1),1)]; % signal trials, 4th row = 0
Mtx		=	[M; C];

%% Replicate by N number of repetitions
Mtx		=	repmat(Mtx,Nrep,1);

%% Randomize
len		=	length(Mtx);
idx		=	randperm(len);
Mtx		=	Mtx(idx,:);


function handles = main_runexp(hObject,handles)

S = handles.S;
ii = handles.CurrentTrial;
S(ii).maskvelocity		= handles.stmMtx(ii,1);
S(ii).maskdensity		= handles.stmMtx(ii,2);
S(ii).maskmodulation	= handles.stmMtx(ii,3);
S(ii).zeros				= handles.stmMtx(ii,4); %?
S(ii).sgnvelocity		= handles.Vel1;
S(ii).sgndensity		= handles.Dens1;
S(ii).sgnmodulation		= handles.Mod1;
S(ii).delay				= handles.Delay;
S(ii).amplitude			= handles.Amp;
S(ii).sgnduration		= handles.Dur1;
S(ii).samplefreq		= handles.Fs;
S(ii).trial				= ii;
handles.S				= S;
guidata(hObject, handles);

%% Work through the trial list
snd1	=	pa_genripple(handles.Vel1,handles.Dens1,handles.Mod1*100,handles.Dur1,0,'Fs',handles.Fs);
snd2	=	pa_genripple(handles.stmMtx(ii,1),handles.stmMtx(ii,2),handles.stmMtx(ii,3)*100,handles.Dur2,0,'Fs',handles.Fs);
snd2	=	[zeros(1,handles.Ndelay) snd2];

%% Normalization
snd1	=	handles.Amp * snd1 / max(abs(snd1));
snd2	=	handles.Amp * snd2 / max(abs(snd2));
if( handles.stmMtx(ii,4) == 1 )
	snd	=	snd2 + snd2;
else
	snd	=	snd1 + snd2;
end
snd		=	handles.Amp * snd / max(abs(snd));

%%
if handles.display
	axes(handles.signal_spectrogram);
	nsamples	= length(snd1);
	t			= nsamples/handles.Fs*1000;
	dt			= 5;
	nseg		= t/dt;
	segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
	noverlap	= round(0.6*segsamples); % 1/3 overlap
	window		= segsamples+noverlap; % window size
	nfft		= 1000;
	spectrogram(snd1,window,noverlap,nfft,handles.Fs,'yaxis');
	ylim([500 16000]);
	% colorbar
	cax = caxis;
	caxis([0.7*cax(1) 1.1*cax(2)])
	set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
	set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
	set(gca,'YScale','log');
	drawnow
end

%%
if handles.display
	
	axes(handles.mask_spectrogram);
	nsamples	= length(snd);
	t			= nsamples/handles.Fs*1000;
	dt			= 5;
	nseg		= t/dt;
	segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
	noverlap	= round(0.6*segsamples); % 1/3 overlap
	window		= segsamples+noverlap; % window size
	nfft		= 1000;
	spectrogram(snd,window,noverlap,nfft,handles.Fs,'yaxis');
	ylim([500 16000]);
	% colorbar
	cax = caxis;
	caxis([0.7*cax(1) 1.1*cax(2)])
	set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
	set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
	set(gca,'YScale','log');
	drawnow
end

%%

if( isunix )
	sound(snd1,Fs);
	sound(snd,Fs);
else
	p1 = audioplayer(snd1,handles.Fs); %#ok<*TNMLP>
	p2 = audioplayer(snd,handles.Fs);
	playblocking(p1);
	playblocking(p2);
end

axes(handles.behavior_figure); %#ok<*NASGU>
cla;

if isfield(S,'response') && handles.display
	Resp = [S.response];
	plot(Resp,'ko-','LineWidth',2,'MarkerFaceColor','w');
end

% --- Outputs from this function are returned to the command line.
function varargout = pa_asaripple_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_yes.
function btn_yes_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to btn_yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.S(handles.CurrentTrial).response			= 1;
S = handles.S; %#ok<*NASGU>

%% Save after each trial
str = [handles.Pname handles.Subj '-' date];
save(str,'S');
handles.CurrentTrial = handles.CurrentTrial+1;

%% Run new
if handles.CurrentTrial<=handles.nTrl
handles = main_runexp(hObject,handles);
% Update handles structure
guidata(hObject, handles);

else
	close(handles.pa_asaripple_fig)
end


% --- Executes on button press in btn_no.
function btn_no_Callback(hObject, eventdata, handles)
% hObject    handle to btn_no (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.S(handles.CurrentTrial).response			= 0;
S = handles.S; %#ok<*NASGU>

%% Save after each trial
str = [handles.Pname handles.Subj '-' date];
save(str,'S');
handles.CurrentTrial = handles.CurrentTrial+1;

%% Run new
if handles.CurrentTrial<=handles.nTrl
handles = main_runexp(hObject,handles);
% Update handles structure
guidata(hObject, handles);

else
	close(handles.pa_asaripple_fig)
end
% --- Executes on button press in btn_start.
function btn_start_Callback(hObject, eventdata, handles)
% hObject    handle to btn_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = main_runexp(hObject,handles);

% --- Executes on key press with focus on pa_asaripple_fig and none of its controls.
function pa_asaripple_fig_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pa_asaripple_fig (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on key press over pa_sacdet with no controls selected.

h                                      = get(handles.pa_asaripple_fig);
CC                                     = h.CurrentCharacter;
if strcmpi(CC,'1')
	btn_yes_Callback(hObject, eventdata, handles);
elseif strcmpi(CC,'0')
	btn_no_Callback(hObject, eventdata, handles);
end


% --- Executes on key press with focus on btn_start and none of its controls.
function btn_start_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to btn_start (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

h                                      = get(handles.pa_asaripple_fig);
CC                                     = h.CurrentCharacter;
if strcmpi(CC,'1')
	btn_yes_Callback(hObject, eventdata, handles);
elseif strcmpi(CC,'0')
	btn_no_Callback(hObject, eventdata, handles);
end

function [snd,Fs] = pa_genripple(vel,dens,md,durrip,durstat,varargin)
% [SND,FS] = PA_GENRIPPLE(VEL,DENS,MOD,DURDYN,DURSTAT)
%
% Generate a ripple stimulus with velocity (amplitude-modulation) VEL (Hz),
% density (frequency-modulation) DENS (cyc/oct), and a modulation depth MOD
% (0-1). Duration of the ripple stimulus is DURSTAT+DURRIP (ms), with the first
% DURSTAT ms no modulation occurring.
%
% These stimuli are parametrized naturalistic, speech-like sounds, whose
% envelope changes in time and frequency. Useful to determine
% spectro-temporal receptive fields.  Many scientists use speech as
% stimuli (in neuroimaging and psychofysical experiments), but as they are
% not parametrized, they are basically just using random stimulation (with
% random sentences).  Moving ripples are a complete set of orthonormal
% basis functions for the spectrogram.
%
% See also PA_GENGWN, PA_WRITEWAV

% 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com
%
% Acknowledgements:
% Original script from Huib Versnel and Rob van der Willigen
% Original fft-script from NLS tools (Powen Ru)

%% Initialization
if nargin<1
	vel = 4; % (Hz)
end
if nargin<2
	dens = 0; % (cyc/oct)
end
if nargin<3
	md = 100; % Percentage (0-100%)
end
if nargin<4
	durrip = 1000; %msec
end
if nargin<5
	durstat = 500; %msec
end

%% Optional arguments
dspFlag       = pa_keyval('display',varargin);
if isempty(dspFlag)
	dspFlag	= 0;
end
sv         = pa_keyval('save',varargin);
if isempty(sv)
	sv	= 'n';
end
plee       = pa_keyval('play',varargin);
if isempty(plee)
	plee	= 'n';
end
Fs         = pa_keyval('freq',varargin);
if isempty(Fs)
	Fs		= 48828.125; % Freq (Hz)
end
meth        = pa_keyval('method',varargin);
if isempty(meth)
	meth			= 'fft';
	% meth = 'fft' works slightly faster
	
end
if strcmp(meth,'fft') % fft method is not defined for negative densities
	if dens<0
		dens	= -dens;
		vel		= -vel;
	end
end
md			= md/100; % Gain (0-1)

%% According to Depireux et al. (2001)
nFreq	= 128;
FreqNr	= 0:1:nFreq-1;
F0		= 250;
df		= 1/20;
Freq	= F0 * 2.^(FreqNr*df);
Oct		= FreqNr/20;                   % octaves above the ground frequency
Phi		= pi - 2*pi*rand(1,nFreq); % random phase
Phi(1)	= pi/2; % set first to 0.5*pi

%% Sounds
switch meth
	case 'time'
		rip		= genrip(vel,dens,md,durrip,Fs,nFreq,Freq,Oct,Phi);
	case 'fft'
		rip = genripfft(vel,dens,md,durrip,Fs,df);
end
if durstat>0 % if required, construct a static part of the noise, and prepend
	stat	= genstat(durstat,Fs,nFreq,Freq,Phi);
	% Normalize ripple power to static power
	nStat		= numel(stat);
	rms_stat	= norm(stat/sqrt(nStat));
	rms_rip		= norm(rip/sqrt(numel(rip)));
	ratio		= rms_stat/rms_rip;
	snd			= [stat ratio*rip];
else
	nStat	= 0;
	snd		= rip;
end



%% Normalization
% Because max amplitude should not exceed 1
% So set max amplitude ~= 0.8 (44/55)
snd			= snd/55; % in 3 sets of 500 trials, mx was 3 x 44+-1


%% Graphics
if dspFlag
	plotspec(snd,Fs,nStat,Freq,durstat);
end

%% Play
if strcmpi(plee,'y');
	snd = pa_envelope(snd',round(10*Fs/1000));
	p	= audioplayer(snd,Fs);
	playblocking(p);
end

%% Save
if strcmpi(sv,'y');
	wavfname = ['V' num2str(vel) 'D' num2str(dens) '.wav'];
	pa_writewav(snd,wavfname);
end

function plotspec(snd,Fs,nStat,Freq,durstat)
close all;
t = (1:length(snd))/Fs*1000;
subplot(221)
plot(t,snd,'k-')
ylabel('Amplitude (au)');
ylabel('Time (ms)');
xlim([min(t) max(t)]);
hold on

subplot(224)
pa_getpower(snd(nStat+1:end),Fs,'orientation','y');
set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
ylim([min(Freq) max(Freq)])
ax = axis;
xlim(0.6*ax([1 2]));
set(gca,'YScale','log');

subplot(223)
nsamples	= length(snd);
t			= nsamples/Fs*1000;
dt			= 12.5;
nseg		= t/dt;
segsamples	= round(nsamples/nseg); % 12.5 ms * 50 kHz = 625 samples
noverlap	= round(0.6*segsamples); % 1/3 overlap
window		= segsamples+noverlap; % window size
nfft		= 1000;
spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');

% colorbar
cax = caxis;
caxis([0.7*cax(1) 1.1*cax(2)])
ylim([min(Freq) max(Freq)])
set(gca,'YTick',[0.5 1 2 4 8 16]*1000);
set(gca,'YTickLabel',[0.5 1 2 4 8 16]);
set(gca,'YScale','log');
drawnow

% figure
subplot(221)
[~,~,t,p] = spectrogram(snd,window,noverlap,nfft,Fs,'yaxis');
p = 10*log10(p);
p = smooth(sum(p,1),3);
p = p-min(p);
p = p/max(p);
hold on
plot(t*1000,p,'r-' );
pa_verline(durstat);

function snd = genstat(durstat,Fs,nFreq,Freq,Phi)
nTime	= round( (durstat/1000)*Fs ); % # Samples for Static Noise
time	= ((1:nTime)-1)/Fs; % Time (sec)


%% Modulate carrier, with static and dynamic part
snd		= 0;
for ii = 1:nFreq
	stat	= 1.*sin(2*pi* Freq(ii) .* time + Phi(ii));
	snd		= snd+stat;
end

function [snd,A] = genrip(vel,dens,md,durrip,Fs,nFreq,Freq,Oct,Phi)
nTime   = round( (durrip/1000)*Fs ); % # Samples for Rippled Noise
time	= ((1:nTime)-1)/Fs; % Time (sec)

%% Generating the ripple
% Create amplitude modulations completely dynamic without static
T			= 2*pi*vel*time;
F			= 2*pi*dens*Oct;
[T,F]		= meshgrid(T,F);
A			= 1+md*sin(T+F);
A			= A';

%% Modulate carrier
snd		= 0; % 'initialization'
for ii = 1:nFreq
	rip		= A(:,ii)'.*sin(2*pi*Freq(ii) .* time + Phi(ii));
	snd		= snd+rip;
end

function [snd,A] = genripfft(vel,dens,md,durrip,Fs,df)
% Generate ripple in frequency domain

%%
Ph		= 0-pi/2;

%% excitation condition
durrip	= durrip/1000;	% ripple duration (s)
f0		= 250;	% lowest freq
BW		= 6.4;	% bandwidth, # of octaves
Fs		= round(Fs*2)/2; % should be even number
maxRVel	= max(abs(vel(:)),1/durrip);

%% Time axis
tStep		= 1/(4*maxRVel);
tEnvSize	= round((durrip/tStep)/2)*2; % guarantee even number for fft components
tEnv		= (0:tEnvSize-1)*tStep;

%% Frequency axis
oct			= (0:round(BW/df*2)/2-1)*df;
fr			= pa_oct2bw(f0,oct)';
fEnv		= log2(fr./f0);
fEnvSize	= length(fr);	% # of component

%% Compute the envelope profile
ripPhase	= Ph+pi/2;
fPhase		= 2*pi*dens*fEnv + ripPhase;
tPhase		= 2*pi*vel*tEnv;
A			= md*(sin(fPhase)*cos(tPhase)+cos(fPhase)*sin(tPhase));
A			= 1+A; % shift so background = 1 & profile is envelope

%% freq-domain AM
nTime		= durrip*Fs; % signal time (samples)

%% roll-off and phase relation
th			= 2*pi*rand(fEnvSize,1); % component phase, theta
S			= zeros(1, nTime); % memory allocation
tEnvSize2	= tEnvSize/2;
for ii = 1:fEnvSize
	f_ind				= round(fr(ii)*durrip);
	S_tmpA				= fftshift(fft(A(ii,:)))*exp(1i*th(ii))/tEnvSize*nTime/2;
	
	pad0left		= f_ind - tEnvSize2 - 1;
	pad0right		= nTime/2 - f_ind - tEnvSize2;
	if ((pad0left > 0) && (pad0right > 0) )
		S_tmpB = [zeros(1,pad0left),S_tmpA,zeros(1,pad0right)];
	elseif ((pad0left <= 0) && (pad0right > 0) )
		S_tmpB = [S_tmpA(1 - pad0left:end),zeros(1,pad0right)];
	elseif ((pad0left > 0) && (pad0right <= 0) )
		S_tmpB = [zeros(1,pad0left),S_tmpA(1:end+pad0right)];
	end
	S_tmpC	= [0, S_tmpB, 0, fliplr(conj(S_tmpB))];
	S		= S + S_tmpC; % don't really have to do it all--know from padzeros which ones to do...
end
snd = real(ifft(S));
