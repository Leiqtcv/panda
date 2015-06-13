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
Mlopen918 = NaN(nsub,1);
Mstroop918 = Mlopen918;
Mtellen918 = Mlopen918;
Mcijfer918 = Mlopen918;
Mlopen919 = NaN(nsub,1);
Mstroop919 = Mlopen919;
Mtellen919 = Mlopen919;
Mcijfer919 = Mlopen919;
for ii = 1:nsub
	cd(dorigin);
	dname = dnames{ii};
	cd(dname)
	d = dir([dname '*.xl*']);
	fnames = {d.name};
	nfiles = length(fnames);
	for jj = 1:nfiles
		fname = fnames{jj};
		f = fname(7:end-4);
		switch f
			case 'lopen'
				disp('lopen')
				data = getdata(fname);
				data = anadata(data);
				Mlopen918(ii) = data.median918;
				Mlopen919(ii) = data.median919;
			case 'lopen met stroop'
				disp('lopen met stroop')
				data = getdata(fname);
				data = anadata(data);
				Mstroop918(ii) = data.median918;
				Mstroop919(ii) = data.median919;
			case 'lopen met terugtellen'
				disp('lopen met terugtellen')
				data = getdata(fname);
				data = anadata(data);
				Mtellen918(ii) = data.median918;
				Mtellen919(ii) = data.median919;
			case 'lopen met cijferreeksen'
				disp('lopen met cijferreeksen')
				data = getdata(fname);
				data = anadata(data);
				Mcijfer918(ii) = data.median918;
				Mcijfer919(ii) = data.median919;
		end
	end
end

n = [sum(~isnan(Mlopen918)) sum(~isnan(Mstroop918)) sum(~isnan(Mcijfer918)) sum(~isnan(Mtellen918))]
mu = [nanmean(Mlopen918) nanmean(Mstroop918) nanmean(Mcijfer918) nanmean(Mtellen918)]
sd = [nanstd(Mlopen918) nanstd(Mstroop918) nanstd(Mcijfer918) nanstd(Mtellen918)]
se = sd./sqrt(n)
close all
figure(918)
errorbar(1:4,mu,se,'k.','LineWidth',2)
hold on
bar(1:4,mu)
set(gca,'Xtick',1:4,'XTickLabel',{'Lopen';'Stroop';'Cijfer';'Tellen'});
axis square
box off
hold off

sel = ~isnan(Mstroop918);
X = Mlopen918(sel);
Y = Mstroop918(sel);
[H,P,CI,stats] = ttest(X,Y,0.05);
P
CI

sel = ~isnan(Mcijfer918);
X = Mlopen918(sel);
Y = Mcijfer918(sel);
[H,P,CI,stats] = ttest(X,Y,0.05);
P
CI

sel = ~isnan(Mtellen918);
X = Mlopen918(sel);
Y = Mtellen918(sel);
[H,P,CI,stats] = ttest(X,Y,0.05);
P
CI

n = [sum(~isnan(Mlopen919)) sum(~isnan(Mstroop919)) sum(~isnan(Mcijfer919)) sum(~isnan(Mtellen919))]
mu = [nanmean(Mlopen919) nanmean(Mstroop919) nanmean(Mcijfer919) nanmean(Mtellen919)]
sd = [nanstd(Mlopen919) nanstd(Mstroop919) nanstd(Mcijfer919) nanstd(Mtellen919)]
se = sd./sqrt(n)
close all
figure(919)
errorbar(1:4,mu,se,'k.','LineWidth',2)
hold on
bar(1:4,mu)
set(gca,'Xtick',1:4,'XTickLabel',{'Lopen';'Stroop';'Cijfer';'Tellen'});
axis square
box off
hold off

sel = ~isnan(Mstroop919);
X = Mlopen919(sel,1);
Y = Mstroop919(sel,1);
[H,P,CI,stats] = ttest(X,Y,0.05);
P
CI

sel = ~isnan(Mcijfer919);
X = Mlopen919(sel,1);
Y = Mcijfer919(sel,1);
[H,P,CI,stats] = ttest(X,Y,0.05);
P
CI

sel = ~isnan(Mtellen919);
X = Mlopen919(sel,1);
Y = Mtellen919(sel,1);
[H,P,CI,stats] = ttest(X,Y,0.05);
P
CI

function data = getdata(fname) % Uploading
data = struct('marker',{[]},'Samples',{[]},'Fs',{[]}, 'Time',{[]}, ...
	'mean_HbDiff918',{[]}, 'mean_HbDiff919',{[]}, ...
	'mean_HbDiff918_filt',{[]}, 'mean_HbDiff919_filt',{[]}, ...
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

function data = anadata(data) % Calculcate mean for each person of 918 AND 919 filt
HbChan918 = data.mean_HbDiff918;
HbChan918 = pa_lowpass(HbChan918,1,data.Fs/2,50);
HbChan919 = data.mean_HbDiff919;
HbChan919 = pa_lowpass(HbChan919,1,data.Fs/2,50);
end_mean_calculation = 120;
tnumber=0;total918=0;total919=0;
for i3 =1:2:length(data.marker)-1
	grafiek918 = HbChan918(data.marker(i3):data.marker(i3)+end_mean_calculation*data.Fs);
	grafiek919 = HbChan919(data.marker(i3):data.marker(i3)+end_mean_calculation*data.Fs);
	correctie918 = mean (HbChan918((data.marker(i3)-1*data.Fs):(data.marker(i3)+1*data.Fs)));
	correctie919 = mean (HbChan919((data.marker(i3)-1*data.Fs):(data.marker(i3)+1*data.Fs)));
	grafiek918_cor = grafiek918-correctie918;
	grafiek919_cor = grafiek919-correctie919;
	total918=total918+grafiek918_cor;
	total919=total919+grafiek919_cor;
	tnumber=tnumber+1;
end
data.mean918 = total918/tnumber;
data.mean919 = total919/tnumber;
data.median918 = median(data.mean918(50*data.Fs:60*data.Fs));
data.median919 = median(data.mean919(50*data.Fs:60*data.Fs));

