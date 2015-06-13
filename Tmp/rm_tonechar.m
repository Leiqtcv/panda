function ToneChar = rm_tonechar(fname,varargin)
% PA_TONECHAR(FNAME,METH,DSP)
%
% Characterize tone response characteristics of auditory neurons.
%
% Characteristics are as defined by Recanzone, Guard and Chan, 2000, and
% include:
%
% - Frequency response are
% - spontaneous rate
% - driven response
% - characteristic frequency


% (c) 2012 Marc van Wanrooij

%% Initialization
dsp = pa_keyval('display',varargin);
if isempty(dsp)
	dsp = 1;
end
sd = pa_keyval('sd',varargin);
if isempty(sd)
	sd =3;
end
% if nargin<2
% 	meth = 2;
% end

%% Load f32-data set
dat			= spikematf(fname,1);
swlen		= dat.sweeplength; % sweep duration / recording duration (ms)
toneonset	= 300; % Hard-coded. Where can this be found in stimulus file?
charDur		= 50; % time (ms) during stimulus presentation, used for
% characterization. Ideally, this should equal sound duration. However, for
% onset response cells (as opposed to sustained response cells), this might
% skew the characterization.
preDur		= 300;

%% Obtain firing rate
N			= NaN(1,length(dat)); % number of spikes
Frequency	= N; % frequency
soundLevel	= N; % sound level (dB)
soundDur	= N; % sound duration (ms)
B			= N;
firingRate	= N; % Firing Rate during first 50 ms (spikes/s)
stimRept	= N; % number of repeats
A			= [];
spike		= struct([]);
for ii = 1:length(dat)
	Frequency(ii)	= dat(ii).stim(1);
	soundLevel(ii)	= dat(ii).stim(2);
	soundDur(ii)	= dat(ii).stim(3);
	
	b				= full(mean(dat(ii).sweeps));
	a				= full([dat(ii).sweeps]);
	A				= [A;a]; %#ok<AGROW>
	t				= 1:length(b);
	
	sel				= t>=toneonset & t<toneonset+charDur;
	N(ii)			= sum(b(sel)); % number of spikes
	stimRept(ii)	= size(a,1);
	B(ii)			= sum(b(~sel));
	firingRate(ii)	= N(ii)/charDur*1000; % Firing Rate during first 50 ms (spikes/s)
	b				= a(:,sel);
	spike(ii).Onset	= b';
	spike(ii).Frequency = repmat( dat(ii).stim(1),1,size(b,1));
end
uFrequency		= unique(Frequency);
nFrequency		= numel(uFrequency);
uLevel			= unique(soundLevel);
nLevel			= numel(uLevel);
rept			= unique(stimRept);
if numel(rept)>1
	rept = mean(rept);
	disp('Number of repeats vary');
end

%% Spike density
SDF = pa_spk_sdf(A);

%% Some visual check
if dsp
	figure(101)
	subplot(211)
	pa_spk_dotplot(A,'markersize',5);
	pa_verline([300 450],'r-');
	pa_horline(cumsum(rept*nLevel*ones(nFrequency,1)),'r-');
	
	AF	= [spike.Frequency];
	x	= 1:length(AF);
	set(gca,'YTick',x(1:rept*nLevel:end),'YTickLabel',round(AF(1:rept*nLevel:end)));
	plot(rept*nLevel*nFrequency*SDF/max(SDF),'r-','LineWidth',2);
end

%% Spontaneous activity
% Measured in 50 ms before stimulus onset
t				= 1:size(A,2); % time (ms)
sel				= t>toneonset-preDur & t<toneonset; % prestimulus period
sponAct			= sum(A(:,sel),2)/preDur*1000; % spontaneuous rate (spikes/s) per trial
muSponAct		= mean(sponAct); % mean over trials
sdSponAct		= std(sponAct); % sd over trials
% keyboard
%% Driven response
% average of all presentations of each stimulus that was greater than mean
% and 2 SDs of the spontaneous activity
minDrivenAct	= muSponAct+sd*sdSponAct; %(spikes/s)
drivenResponse	= firingRate > minDrivenAct; % is there a driven response?
drivenLevel		= soundLevel(drivenResponse); % what sound levels drive a response?
drivenFrequency	= Frequency(drivenResponse); % what sound levels drive a response?

%% Check whether the lowest driven level also induces responses at higher levels
udF = unique(drivenFrequency);
checkLF = NaN(numel(udF),2);
for ii = 1:numel(udF)
	sel = drivenFrequency==udF(ii);
	mn = min(drivenLevel(sel));
	if	mn<70
		if sum(sel)==1
			checkLF(ii,1) = mn;
			checkLF(ii,2) = udF(ii);
		end
	end
end
sel = isnan(checkLF(:,1));
checkLF = checkLF(~sel,:);

if ~isempty(checkLF)
	sel1 = ismember(drivenLevel,checkLF(:,1));
	sel2 = ismember(drivenFrequency,checkLF(:,2));
	sel = sel1&sel2;
	drivenLevel = drivenLevel(~sel);
end
% ismember
% checkLF

if dsp
	figure(101)
	subplot(211)
	str = {fname;['Spon A = ' num2str(round(muSponAct)) ' spikes/s'];['Driven A = ' num2str(round(minDrivenAct)) ' spikes/s']};
	title(str)
end

%% Threshold
threshold		= min(drivenLevel); % lowest intensity that drives a response

%% Characteristic Frequency
% the frequency that produced a driven response at the lowest intensity
indx			= find(drivenLevel == threshold);
charFrequency	= Frequency(drivenResponse);
charFiringRate	= firingRate(drivenResponse);
charFrequency	= charFrequency(indx);
charFiringRate	= charFiringRate(indx);
sel				= ismember(uFrequency,charFrequency);
if sum(diff(sel)<0)>1 % multiple non-adjacent driven frequencies
	[~,indx]		= max(charFiringRate);
	charFrequency	= charFrequency(indx);
else
	charFrequency	= sum(charFrequency.*charFiringRate)/sum(charFiringRate); % linearly averaged characteristic firing rate
end

%% Latency
[~,indx]				= min(abs(uFrequency-charFrequency));
closeCharFrequency		= uFrequency(indx); % the frequency actually tested closest to CF
indx					= indx-2:indx+2; % choose 5 frequencies nearest to CF
indx(indx<1)			= 1; % if extreme frequency, limit the 5 nearest frequencies
indx(indx>nFrequency)	= nFrequency;
nCharFrequency			= numel(indx);
latFrequency			= uFrequency(indx);

n				= numel(latFrequency);
A				= [];
F				= [];
for ii = 1:n
	sel = Frequency==latFrequency(ii);
	tmp = [spike(sel).Onset];
	A	= [A tmp]; %#ok<AGROW>
	tmp = [spike(sel).Frequency];
	F	= [F tmp]; %#ok<AGROW>
end
charSDF = pa_spk_sdf(A');

if dsp
	figure(101)
	subplot(223)
	pa_spk_dotplot((A'),'markersize',5);
	pa_verline(50,'r-');
	pa_horline(cumsum(rept*nLevel*ones(nCharFrequency,1)),'r-');
	plot(rept*nLevel*nCharFrequency*charSDF/max(charSDF),'r-','LineWidth',2);
	
	x = 1:length(F);
	set(gca,'YTick',x(1:rept*nLevel:end),'YTickLabel',round(F(1:rept*nLevel:end)));
	
	stairs(rept*nLevel*nCharFrequency*sum(A,2)./max(sum(A,2))/2,'r-')
end

A	= mean(A,2)*1000; % number of spikes per millisecond
A	= reshape(A,2,length(A)/2);
A	= sum(A)/2;
minDrivenAct	= muSponAct+2*sdSponAct; %(spikes/s)

b	= A>minDrivenAct;

c				= b+[0 b(1:end-1)]+[0 0 b(1:end-2)];
onsetLatency	= 2*(find(c==3,1)-2); % onset latency ms
if isempty(onsetLatency)
	onsetLatency = NaN;
end


if isempty(threshold)
	threshold = NaN;
end
ToneChar.onsetLatency	= onsetLatency;
ToneChar.charFrequency	= charFrequency;
ToneChar.muSponAct		= muSponAct;
ToneChar.minDrivenAct	= minDrivenAct;
ToneChar.threshold		= threshold;

%% Tuning bandwidth
% keyboard

x = reshape(Frequency,nLevel,nFrequency);
% x =
y = reshape(soundLevel,nLevel,nFrequency);
z = reshape(firingRate,nLevel,nFrequency);

XI = pa_oct2bw(250,0:0.1:6);
YI = 10:10:70;
[XI,YI] = meshgrid(XI,YI);
ZI = interp2(x,y,z,XI,YI,'*spline');

sel = YI == threshold+10;
y = YI(sel);
z = ZI(sel);
x = XI(sel);


indx1	= find(z>minDrivenAct,1,'first');
indx2	= find(z>minDrivenAct,1,'last');
Q10		= pa_freq2bw(x(indx1),x(indx2)); % oct

ToneChar.Q10 = Q10;


if dsp
	figure(101)
	subplot(223)
	pa_verline(onsetLatency,'r--');
	str = {['CF = ' num2str(round(charFrequency)) ' Hz'];['Onset Latency = ' num2str(round(onsetLatency)) ' (ms)']};
	title(str)
	
	figure(101)
	subplot(211)
	h = pa_verline(300+onsetLatency,'r--');
	set(h,'LineWidth',2);
	
	F = [spike.Frequency];
	indx = find(F==closeCharFrequency);
	pa_horline(indx,'r:');
	
	subplot(224)
	h = semilogx(x,z,'k-'); set(h,'LineWidth',2);
	pa_horline(minDrivenAct,'r-');
	pa_verline(charFrequency,'r-');
	str = {['Q10 = ' num2str(Q10,2)]};
	title(str)
end