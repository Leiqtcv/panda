% function nirs_av_grandaverage
% determine grand average
% signals are obtained from
% clear all
close all
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('nirs0*.mat');

[m,~]	= size(d);
nmbr	= NaN(m,1);
for ii	= 1:m
	fname		= d(ii).name;
	nmbr(ii)	= str2double(fname(5:7));
	
end
unmbr			= unique(nmbr);
nnmbr			= numel(unmbr);
[~,Txt]	= xlsread('subj_analysis_v14112014-all.xlsx');
Txt				= Txt(2:end,:);
OXYA = [];
OXYV = [];
OXYAV = [];

DOXYA = [];
DOXYV = [];
DOXYAV = [];
for ii = 1:(nnmbr-5)
	try
		sel		= nmbr == unmbr(ii);
		fnames	= {d(sel).name};
		nfiles	= numel(fnames);
		disp(ii)
		disp(fnames)
		S		= [];
		So = [];
		T		= [];
		M		= [];
		E		= [];
		for jj = 1:nfiles
			load(fnames{jj})
			S	= [S;nirs.signal]; %#ok<*AGROW>
			So	= [So;nirs.deepchan]; %#ok<*AGROW>
			% 		S	= [S;pa_zscore(nirs.signal)]; %#ok<*AGROW>
			% 		So	= [So;pa_zscore(nirs.deepchan)]; %#ok<*AGROW>
			%% add timings, continuous
			if ~isempty(E)
				e = T(end)*nirs.Fs;
				t = T(end);
				T = [T;nirs.time+t];
				E = [E [nirs.event.sample]+e];
			else
				T = [T;nirs.time];
				E = [E [nirs.event.sample]];
			end
			fname	= fnames{jj};
			fname	= fname(5:end-4);
			sel		= strcmpi(fname,Txt(:,1));
			
			%% Check for interleaved blocks
			modal	= Txt(sel,5);
			if strncmp(modal,'Random',5);
				M = [M {nirs.event.stim}];
			elseif strncmp(modal,'Audiovisual',11);
				a = {nirs.event.stim};
				for kk = 1:size(a,2)
					a {kk} = 'AV';
				end
				M = [M a];
			elseif strncmp(modal,'Auditory',8);
				a = {nirs.event.stim};
				for kk = 1:size(a,2)
					a {kk} = 'A';
				end
				M = [M a];
			elseif strncmp(modal,'Visual',6);
				a = {nirs.event.stim};
				for kk = 1:size(a,2)
					a {kk} = 'V';
				end
				M = [M a];
			else
				M = [M {nirs.event.stim}];
			end
		end
		S = pa_zscore(S);
% 		S = pa_zscore(So);
		
		
		%% Block average
		clear N
		N.event.sample	= E';
		N.event.stim	= M;
		N.Fs			= nirs.Fs;
		N.fsdown		= nirs.fsdown;
		
		figure(1)
		clf
		nchan = size(S,2);
		mod = {'A';'V';'AV'};
		k = 0;
		muA = NaN(nchan,406);
				muV = NaN(nchan,406);

						muAV = NaN(nchan,406);

		for chanIdx = 1:nchan
			k = k+1;
			for modIdx	= 1:3
				mu			= pa_nirs_blockavg(N,S(:,chanIdx),mod{modIdx});
				x			= 1:length(mu);
				x			= x/10;
				switch modIdx
					case 1
				muA(k,:) = nanmean(mu);
					case 2
				muV(k,:) = nanmean(mu);
					case 3
				muAV(k,:) = nanmean(mu);
				end
				
				figure(1)
				plot(x,mu)
				hold on
				
			end
		end
		oxy = muA(2:2:end,:);
		OXYA = [OXYA;oxy];
		oxy = muV(2:2:end,:);
		OXYV = [OXYV;oxy];
		oxy = muAV(2:2:end,:);
		OXYAV = [OXYAV;oxy];
		
		doxy = muA(1:2:end,:);
		DOXYA = [DOXYA;doxy];
		doxy = muV(1:2:end,:);
		DOXYV = [DOXYV;doxy];
		doxy = muAV(1:2:end,:);
		DOXYAV = [DOXYAV;doxy];

		drawnow
	end
end


%%
close all
figure(666)
subplot(221)
oxy = OXYV;
mu = nanmean(oxy);
n = size(oxy,1);
sd = std(oxy)./sqrt(n);
t = 1:length(mu);
t = t/10;
patch([10 10 30 30],[-2 2 2 -2],[.9 .9 .9]);
hold on
pa_errorpatch(t,mu,sd,[0 0 .9])
hold on
oxy = OXYA;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.8 0 0]);

oxy = OXYAV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[0 .7 0]);


oxy = OXYA+OXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.7 .7 .7]);


axis square;
box off
set(gca,'TickDir','out','XTick',0:10:40,'XTickLabel',-10:10:30,'YTick',0:.2:1.4);
xlim([0 40]);
ylim([-0.2 1.6])
xlabel('Time re stimulus onset (s)');
ylabel('\DeltaHbO_2');
title('Normal-hearing, left & right AC (N=38))');

subplot(223)
oxy = DOXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
t = 1:length(mu);
t = t/10;
patch([10 10 30 30],[-2 2 2 -2],[.9 .9 .9]);
hold on
pa_errorpatch(t,mu,sd,[0 0 .9])
hold on
oxy = DOXYA;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.8 0 0]);

oxy = DOXYAV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[0 .7 0]);

oxy = DOXYA+DOXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.7 .7 .7]);


axis square;
box off
set(gca,'TickDir','out','XTick',0:10:40,'XTickLabel',-10:10:30,'YTick',-1.2:.2:0);
xlim([0 40]);
ylim([-1.4 0.2])
xlabel('Time re stimulus onset (s)');
ylabel('\DeltaHbR');


% pa_errorpatch(t,mu,sd,'r')

% plot(nanmean(OXYA))
% plot(nanmean(OXYAV))

%% COCHLEAR
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('nirs0*.mat');

[m,~]	= size(d);
nmbr	= NaN(m,1);
for ii	= 1:m
	fname		= d(ii).name;
	nmbr(ii)	= str2double(fname(5:7));
	
end
unmbr			= unique(nmbr);
nnmbr			= numel(unmbr);
[~,Txt]	= xlsread('subj_analysis_v14112014-all.xlsx');
Txt				= Txt(2:end,:);
OXYA = [];
OXYV = [];
OXYAV = [];

DOXYA = [];
DOXYV = [];
DOXYAV = [];
for ii = (nnmbr-4):nnmbr
	try
		sel		= nmbr == unmbr(ii);
		fnames	= {d(sel).name};
		nfiles	= numel(fnames);
		disp(ii)
		disp(fnames)
		S		= [];
		So = [];
		T		= [];
		M		= [];
		E		= [];
		for jj = 1:nfiles
			load(fnames{jj})
			S	= [S;nirs.signal]; %#ok<*AGROW>
			So	= [So;nirs.deepchan]; %#ok<*AGROW>
			% 		S	= [S;pa_zscore(nirs.signal)]; %#ok<*AGROW>
			% 		So	= [So;pa_zscore(nirs.deepchan)]; %#ok<*AGROW>
			%% add timings, continuous
			if ~isempty(E)
				e = T(end)*nirs.Fs;
				t = T(end);
				T = [T;nirs.time+t];
				E = [E [nirs.event.sample]+e];
			else
				T = [T;nirs.time];
				E = [E [nirs.event.sample]];
			end
			fname	= fnames{jj};
			fname	= fname(5:end-4);
			sel		= strcmpi(fname,Txt(:,1));
			
			%% Check for interleaved blocks
			modal	= Txt(sel,5);
			if strncmp(modal,'Random',5);
				M = [M {nirs.event.stim}];
			elseif strncmp(modal,'Audiovisual',11);
				a = {nirs.event.stim};
				for kk = 1:size(a,2)
					a {kk} = 'AV';
				end
				M = [M a];
			elseif strncmp(modal,'Auditory',8);
				a = {nirs.event.stim};
				for kk = 1:size(a,2)
					a {kk} = 'A';
				end
				M = [M a];
			elseif strncmp(modal,'Visual',6);
				a = {nirs.event.stim};
				for kk = 1:size(a,2)
					a {kk} = 'V';
				end
				M = [M a];
			else
				M = [M {nirs.event.stim}];
			end
		end
		S = pa_zscore(S);
		% 	So = pa_zscore(So);
		
		
		%% Block average
		clear N
		N.event.sample	= E';
		N.event.stim	= M;
		N.Fs			= nirs.Fs;
		N.fsdown		= nirs.fsdown;
		
		figure(1)
		clf
		nchan = size(S,2);
		mod = {'A';'V';'AV'};
		k = 0;
		muA = NaN(nchan,406);
				muV = NaN(nchan,406);

						muAV = NaN(nchan,406);

		for chanIdx = 1:nchan
			k = k+1;
			for modIdx	= 1:3
				mu			= pa_nirs_blockavg(N,S(:,chanIdx),mod{modIdx});
				x			= 1:length(mu);
				x			= x/10;
				switch modIdx
					case 1
				muA(k,:) = nanmean(mu);
					case 2
				muV(k,:) = nanmean(mu);
					case 3
				muAV(k,:) = nanmean(mu);
				end
				
				figure(1)
				plot(x,mu)
				hold on
				
			end
		end
		oxy = muA(2:2:end,:);
		OXYA = [OXYA;oxy];
		oxy = muV(2:2:end,:);
		OXYV = [OXYV;oxy];
		oxy = muAV(2:2:end,:);
		OXYAV = [OXYAV;oxy];
		
		doxy = muA(1:2:end,:);
		DOXYA = [DOXYA;doxy];
		doxy = muV(1:2:end,:);
		DOXYV = [DOXYV;doxy];
		doxy = muAV(1:2:end,:);
		DOXYAV = [DOXYAV;doxy];

		drawnow
	end
end


%%
figure(666)
subplot(222)
oxy = OXYA;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
t = 1:length(mu);
t = t/10;
patch([10 10 30 30],[-2 2 2 -2],[.9 .9 .9]);
hold on
pa_errorpatch(t,mu,sd,[0 0 .9])
hold on
oxy = OXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.8 0 0]);

oxy = OXYAV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[0 .7 0]);



oxy = OXYA+OXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.7 .7 .7]);


axis square;
box off
set(gca,'TickDir','out','XTick',0:10:40,'XTickLabel',-10:10:30,'YTick',0:.2:1.4);
xlim([0 40]);
ylim([-0.2 1.6])
xlabel('Time re stimulus onset (s)');
ylabel('\DeltaHbO_2');
title('Postingually deaf CI users (N=5)');

subplot(224)
oxy = DOXYA;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
t = 1:length(mu);
t = t/10;
patch([10 10 30 30],[-2 2 2 -2],[.9 .9 .9]);
hold on
pa_errorpatch(t,mu,sd,[0 0 .9])
hold on
oxy = DOXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.8 0 0]);

oxy = DOXYAV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[0 .7 0]);


oxy = DOXYA+DOXYV;
mu = nanmean(oxy);
n = size(oxy,1);
s = bsxfun(@minus,oxy,nanmean(oxy,2));
sd = std(s)./sqrt(n);
pa_errorpatch(t,mu,sd,[.7 .7 .7]);


axis square;
box off
set(gca,'TickDir','out','XTick',0:10:40,'XTickLabel',-10:10:30,'YTick',-1.2:.2:0);
xlim([0 40]);
ylim([-1.4 0.2])
xlabel('Time re stimulus onset (s)');
ylabel('\DeltaHbR');

for ii = 1:4
	subplot(2,2,ii)
	pa_horline(0,'k-');
end
% pa_errorpatch(t,mu,sd,'r')

% plot(nanmean(OXYA))
% plot(nanmean(OXYAV))


%% 
pa_datadir;
print('-depsc','-painters',mfilename);
