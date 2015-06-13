function Akaike_analysis_onsetAligned
% AKAIKE_ANALYSIS
%

% 2013

%% Cleansing
clc;
close all;
clear all;

%% Data stored @

cd('E:\DATA\Cortex\top-down paper data'); % Change this to suit your needs
thorfiles   = dir('thor*');
joefiles    = dir('joe*');
files       = [thorfiles' joefiles'];
dspFlag     = true;
dspFlag     = false;

%% Initialization

sigma		= 70;
dur			= 1000;

analyze(files,sigma);

function analyze(files,sigma)
ncells		= length(files);
sgnindx 	= 900:1300; % this is the index, from 500 ms before reaction, to 100 ms after reaction
LL500       = NaN(ncells,4);
LL1000      = NaN(ncells,4);
LLprep      = NaN(ncells,1);
M500        = NaN(ncells,numel(sgnindx));

M1000       = NaN(ncells,numel(sgnindx));
Nspikes500  = NaN(ncells,1);
Nspikes1000 = NaN(ncells,1);
Ntrials500  = NaN(ncells,1);
Ntrials1000 = NaN(ncells,1);
isiflag = false;
for ii				 = 1:ncells
	%% Load
	
	fname			 = files(ii).name;
	disp(fname);
	load(fname);
	
	%     spikeA = spikeA;
	%     spikeP = spikeP;
	%     beh    = beh;
	
	spikeA = spikeAMA;
	spikeP = spikeAMP;
	beh    = behAM;
	
	% 	keep spikeA spikeP beh
	%% Select data (reaction time and spike trains) based on duration of static sound
	[S1000,RT1000]	= seldur(spikeA,beh,1000);
	[S500,RT500]	= seldur(spikeA,beh,500);
	SP				= rmfield(spikeP,{'spikewave';'timestamp';'stimparams';'trialorder';'trial';'aborted'});
	clear spikeA beh behAM spikeAMA spikeAMP spikeP
	
	%% Analyze
	% We will subtract the passive response from the active condition
	% this will presumably remove the acoustic component (if not, we will
	% see some acoustic modulations left). We will do this for every trial
	% in the active condition with the firing rate from the passive
	% condition averaged. For reasons, that will be explained below, we
	% do this removal with heavily smoothed spike density functions.
	[par500,par1000,parP,isripple]						= getparams(S500,S1000,SP); % the acoustic parameters
	
	uMF = unique(par500);
	nMF = numel(uMF);
	for mfIdx = 1:nMF
		sel = par500==uMF(mfIdx);
		sdf = pa_spk_sdf(S500(sel));
		sdf = sdf(800:1300);

		selp = parP==uMF(mfIdx);
		sdfp = pa_spk_sdf(SP(selp));
		whos sdfp
		if length(sdfp)<1300
		sdfp = sdfp(800:length(sdfp));
		else
		sdfp = sdfp(800:1300);
		end
		figure(1)
		clf
		subplot(211)
		pa_spk_rasterplot(S500(sel));
		xlim([800 1300])
		title(fname)
		subplot(211)
		t = 1:501;
		plot(t+800,0.5*sum(sel)*sdf/max(sdf))
		
		subplot(212)
		plot(sdf,'LineWidth',2)
		hold on
		plot(sdfp,'r-','LineWidth',2);
		xlim([0 500]);
		
		x = 1:500;
		y = sin(2*pi*uMF(mfIdx)*x/1000)*mean(sdf)*2;
		y(y<0) = 0;
		plot(x,y,'k-','Color',[.7 .7 .7]);
		title(uMF(mfIdx));
		drawnow
		pause
		
	end
end


function 	[par500,par1000,parP,isripple] = getparams(S500,S1000,SP)

stim	= [S500.stimvalues]; % active500 parameters
if size(stim,1)==7
	indx = [5 6]; % for ripples
	isripple = true;
elseif size(stim,1)==6
	indx = 5; % for AM
	isripple = false;
end
par500	= round(stim(indx,:)*1000)/1000;
stim	= [S1000.stimvalues]; % active1000 trial parameters
par1000	= round(stim(indx,:)*1000)/1000;
stim	= [SP.stimvalues]; % passive trial parameters
parP	= round(stim(indx,:)*1000)/1000;


function [Spike,RT] = seldur(spike,beh,dur)
stim			= [spike.stimvalues];
durstat			= stim(3,:);
sel				= durstat == dur;
Spike			= spike(sel);
Spike			= rmfield(Spike,{'spikewave';'timestamp';'stimparams';'trialorder';'trial';'aborted'});

sel				= beh(4,:)==dur; %#ok<*NODEF>
rt				= beh(2,:);
RT				= rt(sel); % Check this
mn              = min(length(Spike),length(RT));
Spike			= Spike(1:mn);
RT				= RT(:,1:mn);

