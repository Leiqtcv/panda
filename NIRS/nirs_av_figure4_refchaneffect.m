function nirs_av_refchaneffect
% determine grand average
% signals are obtained from
% clear all
close all

sub1; drawnow; % single subject average
sub2; drawnow % all subjects average
sub3; drawnow % glm check
sub4; drawnow;

pa_datadir;
print('-depsc','-painters',mfilename);

function sub1
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

[~,Txt]	= xlsread('subj_analysis_v14112014-all.xlsx');
Txt		= Txt(2:end,:);
figure(666)
subplot(235)
xlim([-1 41]);
ylim([-1.0 1.4]);
patch([10 10 30 30],[-2 2 2 -2],[.9 .9 .9]);
hold on

ii = 1;
sel		= nmbr == unmbr(ii);
fnames	= {d(sel).name};
nfiles	= numel(fnames);

S		= [];
So		= [];
T		= [];
M		= [];
E		= [];
for jj = 1:nfiles
	load(fnames{jj});
	S	= [S;nirs.signal]; %#ok<*NODEF,*AGROW>
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
	end
end
S = pa_zscore(S);
So = pa_zscore(So);

%% Block average
clear N
N.event.sample	= E';
N.event.stim	= M;
N.Fs			= nirs.Fs;
N.fsdown		= nirs.fsdown;


nchan = size(S,2);
mod = {'A';'V';'AV'};
for chanIdx = 2
	for modIdx	= 1
		MU			= pa_nirs_blockavg(N,S(:,chanIdx),mod{modIdx});
		x			= 1:length(MU);
		x			= x/10;
		
		figure(666)
		subplot(235)
		plot(x,nanmean(MU),'-','LineWidth',2)
		hold on
	end
end
for chanIdx = 2
	for modIdx	= 3
		MUo			= pa_nirs_blockavg(N,So(:,chanIdx),mod{modIdx});
		x			= 1:length(MUo);
		x			= x/10;
		
		figure(666)
		subplot(235)
		
		plot(x,nanmean(MUo),'-','LineWidth',2)
		hold on
	end
end

%% Hemo
nirs	= N;

fs		= nirs.Fs;
fd		= nirs.fsdown;
R		= S(:,1);
on		= ceil([nirs.event.sample]*fd/fs);
off		= on(2:2:end);
on		= on(1:2:end);
stim	= nirs.event.stim;
ustim	= unique(stim);
nstim	= numel(ustim);
n		= numel(R);
HDR		= NaN(3,n);
for sIdx = 1:nstim
	sel		= strcmp(ustim(sIdx),stim(1:2:end)) | strcmp('AV',stim(1:2:end));
	ons		= on(sel);
	offs	= off(sel);
	N		= length(R);
	bl      = zeros(1, N);
	for kk	= 1:length(ons)
		bl(ons(kk):offs(kk)) = 1;
	end
	hemo		= pa_nirs_hdrfunction(1,bl);
	HDR(sIdx,:) = hemo';
end



%% GlM\

B = NaN(nchan,3);
for chanIdx = 1:nchan
	
	x			= HDR';
	y			= S(:,chanIdx);
	b		= glmfit(x,y,'normal');
	b			= b(2:end);
	if str2double(fnames{1}(5:7))>16 && str2double(fnames{1}(5:7))<38
		idx		= [3 2 1];
		b		= b(idx);
	end
	B(chanIdx,:) = b;
	
	
	
end
BETA(ii).b		= B';

figure(666)
subplot(235)
set(gca,'XTick',0:10:40,'XTickLabel',-10:10:30,'YTick',-1.2:0.4:1.2,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('Time re stimulus onset (s)','FontSize',12);
ylabel('[\Delta HbO_2] (\sigma)','FontSize',12);
axis square;
box off
h = pa_text(0.1,0.9,'D');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
% text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
title('Normal-hearing subject 1, Auditory','FontSize',12);

function sub2
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
	sel		= nmbr == unmbr(ii);
	fnames	= {d(sel).name};
	nfiles	= numel(fnames);
	disp(ii)
	disp(fnames)
	S		= [];
	So		= [];
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
	
	nchan	= size(S,2);
	mod		= {'A';'V';'AV'};
	k		= 0;
	muA		= NaN(nchan,406);
	muV		= NaN(nchan,406);
	muAV	= NaN(nchan,406);
	for chanIdx = 1:nchan
		k		= k+1;
		for modIdx	= 1:3
			mu			= pa_nirs_blockavg(N,S(:,chanIdx),mod{modIdx});
			switch modIdx
				case 1
					if length(mu)==406
						muA(k,:) = nanmean(mu);
					else
						muA(k,:) = [nanmean(mu) 0];
					end
				case 2
					if length(mu)==406
						muV(k,:) = nanmean(mu);
					else % subject 5 contains stim duration of 204 instead of 205
						muV(k,:) = [nanmean(mu) 0];
					end
				case 3
					if length(mu)==406
						muAV(k,:) = nanmean(mu);
					else
						muAV(k,:) = [nanmean(mu) 0];
					end
			end
			
		end
	end
	oxy		= muA(2:2:end,:);
	OXYA	= [OXYA;oxy];
	oxy		= muV(2:2:end,:);
	OXYV	= [OXYV;oxy];
	oxy		= muAV(2:2:end,:);
	OXYAV	= [OXYAV;oxy];
	
	doxy	= muA(1:2:end,:);
	DOXYA	= [DOXYA;doxy];
	doxy	= muV(1:2:end,:);
	DOXYV	= [DOXYV;doxy];
	doxy	= muAV(1:2:end,:);
	DOXYAV	= [DOXYAV;doxy];
	
end

figure(666)
subplot(236)
oxy		= OXYV;
mu		= nanmean(oxy);
n		= size(oxy,1);
sd		= std(oxy)./sqrt(n);
t		= 1:length(mu);
t		= t/10;
patch([10 10 30 30],[-2 2 2 -2],[.9 .9 .9]);
hold on
pa_errorpatch(t,mu,sd,[0 0 .9]);
hold on
h = pa_text(0.1,0.9,'E');
set(h,'FontSize',15,'FontWeight','bold');
%% ref?
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('nirs0*.mat');

[m,~]	= size(d);
nmbr	= NaN(m,1);
for ii	= 1:m
	fname		= d(ii).name;
	nmbr(ii)	= str2double(fname(5:7));
	
end
unmbr		= unique(nmbr);
nnmbr		= numel(unmbr);
[~,Txt]		= xlsread('subj_analysis_v14112014-all.xlsx');
Txt			= Txt(2:end,:);
OXYA		= [];
OXYV		= [];
OXYAV		= [];
DOXYA		= [];
DOXYV		= [];
DOXYAV		= [];
for ii = 1:(nnmbr-5)
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
	S = pa_zscore(So);
	
	
	%% Block average
	clear N
	N.event.sample	= E';
	N.event.stim	= M;
	N.Fs			= nirs.Fs;
	N.fsdown		= nirs.fsdown;
	
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
			switch modIdx
				case 1
					if length(mu)==406
						muA(k,:) = nanmean(mu);
					else
						muA(k,:) = [nanmean(mu) 0];
					end
				case 2
					if length(mu)==406
						muV(k,:) = nanmean(mu);
					else % subject 5 contains stim duration of 204 instead of 205
						muV(k,:) = [nanmean(mu) 0];
					end
				case 3
					if length(mu)==406
						muAV(k,:) = nanmean(mu);
					else
						muAV(k,:) = [nanmean(mu) 0];
					end
			end
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
	
end

figure(666)
subplot(236)
oxy = OXYV;
mu = nanmean(oxy);
n = size(oxy,1);
sd = std(oxy)./sqrt(n);
t = 1:length(mu);
t = t/10;
hold on
pa_errorpatch(t,mu,sd,[.7 0 0]);
hold on
axis square;
box off
set(gca,'TickDir','out','XTick',0:10:40,'XTickLabel',-10:10:30,'YTick',-1.2:.4:1.2);
set(gca,'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlim([0 40]);
ylim([-1.0 1.4])
xlabel('Time re stimulus onset (s)');
ylabel('[\DeltaHbO_2] (\sigma)');
str = sprintf('All normal-hearing (N=%i), auditory trial',n);
title(str,'FontSize',12);


%%
pa_datadir;
print('-depsc','-painters',mfilename);

function sub3
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files

load('allglmbetas');


n	= [BETA.n];
b0	= [BETA.b0];
b1	= [BETA.b1];
n	= n(:,1:end-10);
b0	= b0(:,1:end-10);
b1	= b1(:,1:end-10);
figure(666)
subplot(234)
hold on
n		= logical(n);
idx		= 2:2:length(b1);
idx		= idx(n(2:2:length(b1)));
plot(b0(1,idx),b1(1,idx),'ko','MarkerFaceColor',[0 0 0.9]);
idx		= 2:2:length(b1);
idx		= idx(~n(2:2:length(b1)));
plot(b0(1,idx),b1(1,idx),'ko','MarkerFaceColor',[0.7 0 0]);
plot(b0(1,2),b1(1,2),'kp','MarkerFaceColor',[.7 .7 1],'MarkerSize',20);

xlim([-1 2]);
ylim([-1 2]);
axis square
box off
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');


set(gca,'XTick',-0.5:0.5:1.5,'YTick',-0.5:0.5:1.5,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-qualityxlim([0 40]);

xlabel('\beta_A before RCS');
ylabel('\beta_A after RCS');
str = sprintf('%i out of %i',sum(n(2:2:length(b1))),numel(n(2:2:length(b1))));
title(str,'FontSize',12);

h = pa_text(0.1,0.9,'C');
set(h,'FontSize',15,'FontWeight','bold');

function sub4
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

[~,Txt]	= xlsread('subj_analysis_v14112014-all.xlsx');
Txt		= Txt(2:end,:);
sel		= nmbr == unmbr(1);
fnames	= {d(sel).name};
nfiles	= numel(fnames);

S		= [];
So		= [];
Ro		= [];
T		= [];
M		= [];
E		= [];
for jj = 1:nfiles
	load(fnames{jj});
	S	= [S;nirs.signal]; %#ok<*NODEF,*AGROW>
	So	= [So;nirs.deepchan]; %#ok<*AGROW>
	Ro	= [Ro;nirs.shallowchan]; %#ok<*AGROW>
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
	end
end
hidx = 2;
selnan		= isnan(S);
So(selnan)	= NaN;
Ro(selnan)	= NaN;
S			= pa_zscore(S);
So			= pa_zscore(So);
Ro			= pa_zscore(Ro);
x = 1:length(S);
x = x/10;

on		= ceil(E*nirs.fsdown/nirs.Fs);
off		= on(2:2:end);
on		= on(1:2:end);
for kk = 1:numel(on)
	sel = x>on(kk)/10 & x<off(kk)/10;
	subplot(221)
	y = So(sel,hidx);
	y = y-y(1);
	plot(x(sel)-on(1)/10,y,'r-')
	hold on
	y = Ro(sel,hidx);
	y = y-y(1);
	plot(x(sel)-on(1)/10,y,'k-')
	y = S(sel,hidx);
	y = y-y(1);
	plot(x(sel)-on(1)/10,y,'b-')
end

% axis square
box off
xlim([on(1)/10-10 off(12)/10+10]-on(1)/10)
ylim([-4 4])
pa_horline(0,'k-');

xlabel('Time re first stimulus onset (s)','FontSize',12)
ylabel('[\Delta HbO_2] (\sigma)','FontSize',12)
% str = ['[\Delta HbO_2]_{deep} = ' num2str(b.beta(2),'%0.2f') '[\Delta HbO_2]_{reference}'];
% text(0,3,str,'HorizontalAlignment','center');

set(gca,'XTick',0:100:1000,'YTick',-3:3,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
legend('Deep before RCS','Shallow/Reference','Signal after RCS');
title('Normal-hearing subject 1, first block (12 trials, interleaved)');

subplot(233)
plot(Ro(1:100:end,hidx),So(1:100:end,hidx),'k.','Color',[.7 .7 .7])
box off
axis square;
axis([-4 4 -4 4]);
lsline;

b = regstats(So(:,hidx),Ro(:,hidx),'linear');
h = pa_regline(b.beta,'k-');
set(h,'LineWidth',2);
pa_unityline;
xlabel('Shallow/reference [\Delta HbO_2] (\sigma)','FontSize',12)
ylabel('Deep [\Delta HbO_2] (\sigma)','FontSize',12)
str = ['[\Delta HbO_2]_{deep} = ' num2str(b.beta(2),'%0.2f') '[\Delta HbO_2]_{reference}'];
text(0,3,str,'HorizontalAlignment','center');

set(gca,'XTick',-3:3,'YTick',-3:3,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
title('Normal-hearing subject 1, entire session');

h = pa_text(0.1,0.9,'B');
set(h,'FontSize',15,'FontWeight','bold');

subplot(221)
on		= ceil(E*nirs.fsdown/nirs.Fs);
off		= on(2:2:end);
on		= on(1:2:end);

for kk = 1:numel(on)
	x = [on(kk) off(kk)]/10-on(1)/10;
	y = [0 0];
	e = [5 5];
	pa_errorpatch(x,y,e,[.7 .7 .7]);
end
box off

h = pa_text(0.1,0.9,'A');
set(h,'FontSize',15,'FontWeight','bold');
