function y = genstim(type,Dur,Filter,Env,zeropad,Fs,FLAG_Play);

% function Y = GENSTIM(<TYPE>,<DUR>,<FILTER>,<ENV>,<ZEROPAD>,<FS>,<PLAYFLAG>)
%
%   This function can generate different types of stimuli.
%
%   TYPE:
%       'GWN' - Gaussian white noise (DEFAULT)
%       'Tone...' - tone of ... Hz
%           e.g. 'Tone440' gerates 440Hz tone.
%       'LP' - low pass noise
%       'HP' - high pass noise
%
%   DUR: duration (ms)
%       DEFAULT - 150
%
%   FILTER: frequency filter (Hz)
%       numel = 1 - high pass filter @ FILTER
%           e.g. [200] (DEFAULT)
%       numel = 2 - band pass filter between FILTER(1) and FILTER(2)
%           e.g. [200 20000]
%
%   ENV: envelope (ms)
%       Duration of onset and (not together) offset ramp.
%       DEFAULT - 5
% 
%   ZEROPAD: zero trialing duration (ms)
%       Extra duration of silence at start of stimulus.
%       DEFAULT - 20
%
%   FS: sample rate
%       DEFAULT - 48828.125
%
%   PLAYFLAG: flag to indicate that the generated stimulus is played after
%             generating
%           e.g. [1] (DEFAULT)

%% input stuff

POS_type=[{'GWN'};{'TONE'};{'LP'};{'HP'}];

if nargin<7
    FLAG_Play = 1;
elseif ischar(FLAG_Play)
    warning('GENSTIM:input','input variable PLAYFLAG is incorrect: use default')
    FLAG_Play = 1;
end

if nargin<6
    Fs = 48828.125;
elseif ischar(Fs)
    warning('GENSTIM:input','input variable FS is incorrect: use default')
    Fs = 48828.125;
end

if nargin<5
    zeropad = 20;
elseif ischar(Fs)
    warning('GENSTIM:input','input variable FS is incorrect: use default')
    zeropad = 20;
end

if nargin<4
    Env = 5;
elseif ischar(Env)
    warning('GENSTIM:input','input variable ENV is incorrect: use default')
    Env = 5;
end

if nargin<3
    if nargin>0 % type is known
        if strcmpi(type,'lp')
            Filter = 3000; FiltMethod = 'LP';
        elseif strcmpi(type,'hp')
            Filter = 3000; FiltMethod = 'HP';
        else
            Filter = 200; FiltMethod = 'HP';
        end
    else
        Filter = 200; FiltMethod = 'HP';
    end
elseif ischar(Filter)
    warning('GENSTIM:input','input variable FILTER is incorrect: use default')
    Filter = 200; FiltMethod = 'HP';
elseif numel(Filter) == 2
    if Filter(1)>Filter(2)
        error('GENSTIM:input','input variable FILTER is incorrect: FILTER(1)>FILTER(2)')
    end
elseif isempty(Filter)
    FiltMethod = 'not!';
else
    FiltMethod = 'HP';
end

if nargin<2
    Dur = 150;
elseif ischar(Dur)
    warning('GENSTIM:input','input variable DUR is incorrect: use default')
    Dur = 150;
end


if nargin<1
    type = 'GWN';
elseif ~ismember(lower(type(1:min([length(type) 4]))),lower(POS_type))
    warning('GENSTIM:input','input variable TYPE is incorrect: use default')
    type = 'GWN';
elseif length(type)>4
    Freq = str2double(type(5:end));
    type = upper(type(1:4));
elseif length(type)==2
    type = upper(type);
    FiltMethod = type;
else
    type = upper(type);
end

%% filter method
if ~exist('FiltMethod')==1
    if numel(Filter) == 2
        FiltMethod = 'BP';
    else
        FiltMethod = 'HP';
    end
end

%% generate source
switch type
    case 'GWN'
        y0 = gennoise(round(Dur/1000*Fs),round(Env/1000*Fs));
    case 'TONE'
        y0 = genwave(round(Dur/1000*Fs),Freq,round(Env/1000*Fs),Fs);
    case 'LP'
        y0 = gennoise(round(Dur/1000*Fs),round(Env/1000*Fs));
    case 'HP'
        y0 = gennoise(round(Dur/1000*Fs),round(Env/1000*Fs));
end

%% filter
switch FiltMethod
    case 'HP'
        y0 = highpassnoise(y0, Filter, Fs/2, 500);
    case 'LP'
        y0 = lowpassnoise(y0, Filter, Fs/2, 500);
    case 'BP'
        y0 = bandpassnoise(y0, Filter, Fs/2, 500);
    otherwise
        warning('GENSTIM:filter','This Stimulus is not filtered')
end

%% silence
y = [zeros(1,round(zeropad/1000*Fs)) y0];


%% Optional Graphics & sound
if FLAG_Play
    figure
    home;
    disp(['>> ' upper(mfilename) ' <<']);
    subplot(211)
    plot(y)
    title([type ' Stimulus of ' num2str(Dur) 'ms. with envelope ' num2str(Env) 'ms. and ' num2str(zeropad) 'ms. silence.'])
    xlabel('Sample number')
    ylabel('Amplitude (a.u.)');
    Nfft = 1024;
    Nnyq = Nfft/2;
    s = fft(y0,Nfft);
    s = abs(s);
    s = s(1:Nnyq);
    f = (0:(Nnyq-1))/(Nnyq)*Fs/2;
    subplot(212)
    loglog(f,s);
    title([FiltMethod '-filtered @ cut-off(s) <' num2str(Filter) '>'])
    set(gca,'Xtick',[1 2 4 6 12 24]*1000,'XtickLabel',[1 2 4 6 12 24]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (a.u.)');
    ap = audioplayer(y,Fs,16);
    playblocking(ap);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stm = gennoise (N, NEnvelope)

%% Create Signal
RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock)));
sig             = randn (N,1);

%% Envelope to remove click
stm             = envelope (sig, NEnvelope);

%% Reshape
stm             = stm(:)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stm = genwave(N, Freq, NEnvelope, Fs)

%% Create and Modify Signal
sig             = cumsum(ones(1,N))-1;
sig             = sig/Fs;
sig             = sin(2*pi*Freq*sig);

%% Envelope to remove click
stm             = envelope (sig(:), NEnvelope);

%% Reshape
stm             = stm(:)';