function nirs_av_timings
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
Tm = [];
B = [];
I = [];
OFF = [];
ON = [];
	Stim = NaN(nnmbr,36);
StimAV = Stim;
StimV = Stim;
for ii = 1:nnmbr
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
		load(fnames{jj});
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
	
	s = [nirs.event.sample];
	on = s(1:2:end);
	off = s(2:2:end);
	ON = [ON on];
	OFF = [OFF off];
	t = (off-on)/nirs.Fs;
	Tm = [Tm t];
	
	brk = on(2:end)-off(1:end-1);
	B = [B brk/nirs.Fs];
	
	idx = repmat(ii,size(brk));
	I = [I idx];
	
	stim = {nirs.event.stim};
	sel = strcmp('A',stim);
	sel = sel(1:2:end);
	n = numel(sel);
	Stim(ii,1:n) = sel;

	stim = {nirs.event.stim};
	sel = strcmp('A',stim);
	sel = sel(1:2:end);
	n = numel(sel);
	Stim(ii,1:n) = sel;

	stim = {nirs.event.stim};
	sel = strcmp('AV',stim);
	sel = sel(1:2:end);
	n = numel(sel);
	StimAV(ii,1:n) = sel;

		stim = {nirs.event.stim};
	sel = strcmp('V',stim);
	sel = sel(1:2:end);
	n = numel(sel);
	StimV(ii,1:n) = sel;
end

%%
close all
figure;
subplot(121)
A = round(nanmean(Stim)*nnmbr)/nnmbr;
V = round(nanmean(StimV)*nnmbr)/nnmbr;
AV = round(nanmean(StimAV)*nnmbr)/nnmbr;
stairs(A,'b');
hold on
stairs(V+1,'r');
stairs(AV+2,'g');
stairs(A+V+AV+2,'k');
% bar([A; V; AV],1)
axis square;
box off
xlim([0 37]);
ylim([0 4]);
pa_horline([0 1 2 3],'k-');
pa_horline([1/3 1+1/3 2+1/3 3],'k:');
xlabel('Segment order number');
ylabel('Probability of segment modality');
set(gca,'XTick',[0 12 24 36]+1,'XTickLabel',[0 12 24 36],...
	'YTick',[0 1/3 1 1+1/3 2 2+1/3],'YTickLabel',{'0';'1/3';'0';'1/3';'0';'1/3'});
% pa_verline([0 12 24 36]+1);
pa_errorpatch([12 24]+1,[-1 -1],[10 10]);
box off
subplot(122)
x = 0:1:500;
sel = B<100;
N = hist(B(sel),x); hold on;
N = N./sum(N);
XI = 0:500;
[F,XI]=ksdensity(B(sel),XI,'function','pdf');
[H,p] = kstest(B(sel))
stairs(x,N,'k-','Color',[.7 .7 .7])
hold on
% plot(XI,F,'k-','LineWidth',2);
axis square;
box off
xlim([10 70])

x = 25:49;
N = ones(size(x))./numel(x);
x2 = [0:24 50:80];
N2 = zeros(size(x2));
x = [x x2];
N = [N N2];
[x,s] = sort(x);
N = N(s);
stairs(x,N,'k-','LineWidth',2);
xlabel('Duration baseline periods (s)');
ylabel('Probability');
sel = B>100;
nanmean(B(sel))/60
nanmean(B(sel))-4*60

pa_datadir;
print('-depsc','-painters',mfilename);