function rm_tonotopic
close all
clear all
clc;

joe;
thor;

function joe
f32 = 'C:\all Data\JoeData\';
xcl = 'C:\all Data\';
cd(xcl);
[NUMERIC,TXT] = xlsread('Joe-data.xlsx');
TXT		= TXT(2:end,:);
sel		= strcmpi(TXT(:,3),'tonerough');
NUMERIC = NUMERIC(2:end,:);
x		= NUMERIC(sel,5);
y		= NUMERIC(sel,6);
z		= NUMERIC(sel,1);
cd(f32)
files	= TXT(sel,1);
colormap jet
c	= colormap;
ls	= log10(logspace(log10(200),log10(12000),64));
k = 0;
M = NaN(length(files),4);
for ii =110:length(files)
	fname = files{ii};
	if length(fname)>13
		DatFile = fname(1:6);
	elseif length(fname)==13
		DatFile= fname(1:5);
	end
	dname = [f32 DatFile,'experiment'];
	cd(dname);
	
	fname = pa_fcheckext(fname,'.f32');
	
	if exist(fname,'file')
		if ii>1
			figure(101)
			clf
		end
		
		
% 		try
			ToneChar = rm_tonechar(fname,'display',1)
			pause
			df = abs(ls-log10(ToneChar.charFrequency));
			[~,indx] = min(df);
			
			figure(666)
			plot(x(ii)+0.4*rand(1),y(ii)+0.4*rand(1),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
			hold on;
			k = k+1;
			M(k,1) = x(ii);
			M(k,2) = y(ii);
			M(k,3) = z(ii);
			M(k,4) = ToneChar.charFrequency;
			
			if ~isempty(ToneChar.threshold)
			T(k) = ToneChar.threshold;
			L(k) = ToneChar.onsetLatency;
			end
% 		end
		
		
	else
		disp('Uh-oh');
		disp(fname);
	end
end

sel		= isnan(M(:,1));
M		= M(~sel,:);
plotvor(M);
thresh = [nanmean(T) nanstd(T)]
lat = [nanmean(L) nanstd(L)]


function thor
f32 = 'C:\all Data\ThorData\';
f32rm = 'C:\all Data\Data\';
xcl = 'C:\all Data\';
cd(xcl);
[NUMERIC,TXT]=xlsread('thor-data.xlsx');
TXT		= TXT(2:end,:);
sel		= strcmpi(TXT(:,3),'tonerough');
NUMERIC = NUMERIC(2:end,:);
x		= NUMERIC(sel,5);
y		= NUMERIC(sel,6);
z		= NUMERIC(sel,1);
cd(f32)
files	= TXT(sel,1);
colormap jet
c	= colormap;
ls	= log10(logspace(log10(200),log10(12000),64));
k = 0;
M = NaN(length(files),4);
T = NaN(length(files),1);
L = T;
for ii = 1:length(files)
	fname = files{ii};
	if length(fname)<15
		cd(f32)
		cd(fname(1:7))
	else
		cd(f32rm)
		cd(fname(1:end-5))
	end

	
	fname = pa_fcheckext(fname,'.f32');
	
	if exist(fname,'file')
		if ii>1
			figure(101)
			clf
		end
		
% 		try
		ToneChar = pa_tonechar(fname,'display',1,'sd',2)
								pause
		
if ~isnan(ToneChar.charFrequency)
		df = abs(ls-log10(ToneChar.charFrequency));
		[~,indx] = min(df);
		
		figure(666)
		plot(x(ii)+0.4*rand(1),y(ii)+0.4*rand(1),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
		hold on;
end

		k = k+1;
		M(k,1) = x(ii);
		M(k,2) = y(ii);
		M(k,3) = z(ii);
		M(k,4) = ToneChar.charFrequency;

			T(k) = ToneChar.threshold;
			L(k) = ToneChar.onsetLatency;
% 		end
	else
		disp('Uh-oh');
		disp(fname);
	end
end

sel		= isnan(M(:,1));
M		= M(~sel,:);
plotvor2(M);
thresh = [nanmean(T) nanstd(T)]
lat = [nanmean(L) nanstd(L)]
keyboard
function plotvor(M)
%%
sel = ~isnan(M(:,1)) & ~isnan(M(:,2)) & ~isnan(M(:,4));
M	= M(sel,:);

x	= M(:,1);
y	= M(:,2);
bf	= M(:,4);

xy		= [x y];
uxy		= unique(xy,'rows');
n		= length(uxy);
muBF	= NaN(n,1);
N = muBF;
colormap jet
c	= colormap;
ls	= log10(logspace(log10(200),log10(12000),64));
for ii = 1:n
	sel = x == uxy(ii,1) & y == uxy(ii,2);
	muBF(ii)	= nanmean(bf(sel));
	N(ii) = sum(sel);
	
	tmp = sort(bf(sel));
	ntmp = sum(sel);
	for jj = 1:ntmp
	figure(102)
	df = abs(ls-log10(tmp(jj)));
		[~,indx] = min(df);
	plot(uxy(ii,1),uxy(ii,1),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
	hold on
	end
	
end
axis square;
xlabel('Anterior-posterior');
ylabel('Medial-lateral');

y		= uxy(:,2);
x		= uxy(:,1);
y2		= (-6:0.5:-1)';
x2		= repmat(1.5,size(y2));
bf2		= repmat(100,size(y2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy = [x y];

y		= uxy(:,2);
x		= uxy(:,1);
y2		= (-6:0.5:-1)';
x2		= repmat(9,size(y2));
bf2		= repmat(100,size(y2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy		= [x y];

y		= uxy(:,2);
x		= uxy(:,1);
x2		= (2:0.5:9)';
y2		= repmat(-6.5,size(x2));
bf2		= repmat(100,size(x2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy		= [x y];


y		= uxy(:,2);
x		= uxy(:,1);
x2		= (2:0.5:9)';
y2		= repmat(-0.5,size(x2));
bf2		= repmat(100,size(x2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy		= [x y];

[uxy,indx]	= sortrows(uxy,[1,2]);
muBF		= muBF(indx);
[v,c] = voronoin(uxy);
figure(103)
subplot(121)
for j = 1:length(c)
	if all(c{j}~=1)   % If at least one of the indices is 1,then it is an open region and we can't patch that.
		hold on
		patch(v(c{j},1),v(c{j},2),log2(muBF(j))); % use color i.
	end
end
hold on
axis square;
caxis([9 13]);
h = colorbar;
set(h,'YTick',9:13,'YTickLabel',2.^(9:13));
xlim([2 8.5]);
xlabel('Anterior-posterior');
ylabel('Lateral-medial');
%%

function plotvor2(M)
%%
sel = ~isnan(M(:,1)) & ~isnan(M(:,2)) &~isnan(M(:,4));
M	= M(sel,:);

x	= M(:,1);
y	= M(:,2);
bf	= M(:,4);

xy		= [x y];
uxy		= unique(xy,'rows');
n		= length(uxy);
muBF	= NaN(n,1);
N		= muBF;
colormap jet
c	= colormap;
ls	= log10(logspace(log10(200),log10(12000),64));

for ii = 1:n
	sel = x == uxy(ii,1) & y == uxy(ii,2);
	muBF(ii)	= nanmean(bf(sel));
	N(ii) = sum(sel);
	
		tmp = sort(bf(sel));
	ntmp = sum(sel);
	for jj = 1:ntmp
	figure(102)
	df = abs(ls-log10(tmp(jj)));
		[~,indx] = min(df);
	plot(uxy(ii,1)+0.1*(jj-ntmp/2),uxy(ii,2),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
	hold on
	end
end


y		= uxy(:,2);
x		= uxy(:,1);
y2		= (-6:0.5:0)';
x2		= repmat(-3,size(y2));
bf2		= repmat(100,size(y2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy = [x y];

y		= uxy(:,2);
x		= uxy(:,1);
y2		= (-6:0.5:0)';
x2		= repmat(7,size(y2));
bf2		= repmat(100,size(y2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy		= [x y];

y		= uxy(:,2);
x		= uxy(:,1);
x2		= (-2:0.5:7)';
y2		= repmat(-6,size(x2));
bf2		= repmat(100,size(x2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy		= [x y];


y		= uxy(:,2);
x		= uxy(:,1);
x2		= (-2:0.5:7)';
y2		= repmat(2,size(x2));
bf2		= repmat(100,size(x2));
x		= [x; x2];
y		= [y; y2];
muBF	= [muBF; bf2];
uxy		= [x y];

[uxy,indx]	= sortrows(uxy,[1,2]);
muBF		= muBF(indx);
[v,c] = voronoin(uxy);
figure(103)
subplot(122)
for j = 1:length(c)
	if all(c{j}~=1)   % If at least one of the indices is 1,then it is an open region and we can't patch that.
		hold on
		patch(v(c{j},1),v(c{j},2),log2(muBF(j))); % use color i.
	end
end
hold on
% plot(uxy(:,1),uxy(:,2),'o');

axis square;
caxis([7 13])
h = colorbar;
set(h,'YTick',7:13,'YTickLabel',2.^(7:13));
xlabel('Anterior-posterior');
ylabel('Lateral-medial');
