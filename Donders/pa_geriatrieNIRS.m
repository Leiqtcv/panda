function tmp

clear all hidden;
clc;
close all hidden;

dorigin = 'E:\DATA\Test\Data pilot gezonde ouderen\Data\Data PortaLite\Data Excel';
cd(dorigin);
d = dir;

dnames = {d.name};
dnames = dnames(3:end-1);
nsub = length(dnames);
Mlopen = NaN(nsub,1);
Mstroop = Mlopen;
Mtellen = Mlopen;
Mcijfer = Mlopen;
for ii = 1:nsub
	cd(dorigin);
	dname = dnames{ii};
	cd(dname)
	d = dir([dname '*.xl*']);
	fnames = {d.name};
	nfiles = length(fnames);
	for jj = 1:nfiles
		fname = fnames{jj};
		
		
		% 		close all;
		% 		plotdata(data);
		
		% 		pause(.1);
		
		f = fname(7:end-4)
		switch f
			case 'lopen'
				disp('Lopen')
				data = getdata(fname);
				data = anadata(data);
				
				Mlopen(ii) = data.median;
			case 'lopen met stroop'
				disp('lopen met stroop')
				data = getdata(fname);
				data = anadata(data);
				
				Mstroop(ii) = data.median;
			case 'lopen met terugtellen'
				disp('lopen met terugtellen')
				data = getdata(fname);
				data = anadata(data);
				
				Mtellen(ii) = data.median;
			case 'lopen met cijferreeksen'
				disp('lopen met cijferreeksen')
				data = getdata(fname);
				data = anadata(data);
				
				Mcijfer(ii) = data.median;
				
		end
		
		% 		ismember(fname(7:end),'lopen')
		% 		ismember(fname(7:end),'lopen')
		% 		return
	end
	
end
n = [sum(~isnan(Mlopen(:,1))) sum(~isnan(Mstroop(:,1))) sum(~isnan(Mcijfer(:,1))) sum(~isnan(Mtellen(:,1)))];
mu = [nanmean(Mlopen(:,1)) nanmean(Mstroop(:,1)) nanmean(Mcijfer(:,1)) nanmean(Mtellen(:,1))];
sd = [nanstd(Mlopen(:,1)) nanstd(Mstroop(:,1)) nanstd(Mcijfer(:,1)) nanstd(Mtellen(:,1))];
se = sd./sqrt(n);
close all
figure
errorbar(1:4,mu,se,'k.','LineWidth',2)
hold on
bar(1:4,mu)
set(gca,'Xtick',1:4,'XTickLabel',{'Lopen';'Stroop';'Cijfer';'Tellen'});
axis square
box off

sel = ~isnan(Mstroop);
X = Mlopen(sel,1);
Y = Mstroop(sel,1);
[H,P,CI,stats] = ttest(X,Y,0.05);
P

sel = ~isnan(Mcijfer);
X = Mlopen(sel,1);
Y = Mcijfer(sel,1);
[H,P,CI,stats] = ttest(X,Y,0.05);
P

sel = ~isnan(Mtellen);
X = Mlopen(sel,1);
Y = Mtellen(sel,1);
[H,P,CI,stats] = ttest(X,Y,0.05);
P

% % anovan
% keyboard
% return
function data = getdata(fname)
%% Instellen
subjects = 1;% the total number of subjects from whom the data has to be loaded
Fcl = 0.3; % cut-off frequency of the lowpas filter
task_duration = 60; % duration of the task in seconds
end_mean_calculation = task_duration+60;

%% Uploading
data = struct('marker',{[]},'Samples',{[]},'Fs',{[]}, 'Time',{[]}, ...
	'mean_HbDiff918',{[]}, 'mean_HbDiff919',{[]}, 'mean_HbDiff918_filt',{[]}, ...
	'mean_HbDiff919_filt',{[]}, ...
	'mean_signaal_HbDiff918_filt',{[]}, 'mean_signaal_HbDiff919_filt',{[]}, ...
	'time_mean_HbDiff918_filt',{[]}, 'time_mean_HbDiff919_filt',{[]}, ...
	'median_taskend918_filt',{[]}, 'median_taskend919_filt',{[]});
[Data,txt,raw] = xlsread(fname,1,'A74:AD18000');

marker=[];tekstmarker=[]; start=0;
for i2 = 2:length(raw)
	a=num2str(raw{i2,30});
	if strcmp(a,'NaN')
	else
		if strcmp(a(1),'B')
			start =1;
		end
		if start ==1;
			marker=[marker;i2];
			if length(a)<4
				a=['xx' a];
			end
			if length(a)<5
				a=['x' a];
			end
			tekstmarker=[tekstmarker;a];
		end
	end
end

Samples             = Data(:,1);
T1_HbDiff918        = Data(:,7);
T2_HbDiff918        = Data(:,11);
T3_HbDiff918        = Data(:,15);
mean_HbDiff918      = (T1_HbDiff918+T2_HbDiff918+T3_HbDiff918)/3;
T1_HbDiff919        = Data(:,21);
T2_HbDiff919        = Data(:,25);
T3_HbDiff919        = Data(:,29);
mean_HbDiff919      = (T1_HbDiff919+T2_HbDiff919+T3_HbDiff919)/3;

Fs = xlsread(fname,'B5:B5'); % sample frequency
Time = ((0:length(Samples)-1)/Fs)';

data = struct('marker',{marker},'Samples',{Samples},'Fs',{Fs}, 'Time',{Time}, ...
	'mean_HbDiff918',{mean_HbDiff918}, 'mean_HbDiff919',{mean_HbDiff919}, ...
	'mean_HbDiff918_filt',{[]}, 'mean_HbDiff919_filt',{[]}, ...
	'mean_signaal_HbDiff918_filt',{[]}, 'mean_signaal_HbDiff919_filt',{[]}, ...
	'time_mean_HbDiff918_filt',{[]}, 'time_mean_HbDiff919_filt',{[]}, ...
	'median_taskend918_filt',{[]}, 'median_taskend919_filt',{[]});

function plotdata(data)

T = data.Time;
HbChan1 = data.mean_HbDiff918;
HbChan1 = pa_lowpass(HbChan1,1,data.Fs/2,50);
% keyboard
subplot(221)
plot(T,HbChan1);
pa_verline(data.marker/data.Fs,'r-')

subplot(222)
pa_getpower(HbChan1,data.Fs,'display',1);
x = pa_oct2bw(0.1,0:1:10);
set(gca,'XTick',x)

mu = data.mean;
t = (1:length(mu))/data.Fs;
subplot(223)
plot(t,mu,'k-');
pa_verline(60,'r-');

function data = anadata(data)
T = data.Time;
HbChan1 = data.mean_HbDiff918;
HbChan1 = pa_lowpass(HbChan1,1,data.Fs/2,50);
marker = data.marker;

%% Calculcate mean for each person of 918 filt
tnumber=0;total=0;task_total_O2Hb918=0;rest_total_O2Hb918=0;diff_total_O2Hb918=0;
end_mean_calculation = 120;
for i3 =1:2:length(marker)-1
	grafiek = HbChan1(marker(i3):marker(i3)+end_mean_calculation*data.Fs);
	correctie = median (HbChan1((marker(i3)-1*data.Fs):(marker(i3)+1*data.Fs)));
	grafiek_cor = grafiek-correctie;
	total=total+grafiek_cor;
	tnumber=tnumber+1;
end
data.mean = total/tnumber;
data.median(1) = median(data.mean(50*data.Fs:60*data.Fs));
