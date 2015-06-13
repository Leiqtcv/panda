function tmp

close all
clear all
clc
% elderly_fig4_modelselection_earsize;
hold on

[g8,d8] = elderly;
[g7,d7]  = avdr;
[g6,d6]  = geta;
% [g5,d5] = avprior; % elevation
[g1,d1] = plug;
[g2,d2] = plug2;
[g3,d3] = mold;
% [g4,d4] = owl; % molds??

d			= [d1; d2; d3; d6; d7; d8];
g			= [g1; g2; g3; g6; g7; g8];

sel = isnan(g);
g = g(~sel);
d = d(~sel);

[d,indx]	= sort(d);
g			= g(indx);
g = g./nanmax(g);
a = datenum('11-24-1976');
y = d-a;
y = y/365;
plot(y,g,'ko','MarkerFaceColor','w','LineWidth',2);
hold on

% g2 = [0.5; g; 0.5];
% y2 = [15; y; 45];
g2 = [g];
y2 = [y];
% g2 = [0.5; g];
% y2 = [0; y];
x = min(y):.1:max(y); 
% plot(y2,g2,'ro','MarkerFaceColor','w','LineWidth',2);
P = polyfit(y2,g2,2);
Y = polyval(P,x);
plot(x,Y,'k-','LineWidth',2);
xlim([0.9*min(y) 1.1*max(y)]);
ylim([0 1.2])
% ylim([0 1.4]);
pa_horline(1);
drawnow
axis square;
xlabel('Age (yrs)');
ylabel('Localization gain');
drawnow

function [g,d] = elderly
%% Refining data-set
dnames	= {'MW-2010-07-16'};
nexp	= length(dnames);
% nexp = 2;
g = NaN(nexp,1);
d = g;
for ii = 1:nexp
	pa_datadir(['MW\' dnames{ii}]);
	
	s		= dir('*.mat');
	SupSac = [];
		nfiles = length(s);

	for jj = 1:nfiles
		fname	= s(jj).name;
		if ~any(findstr(fname,'-'));
			
			load(fname);
			SS		= pa_supersac(Sac,Stim);
			SupSac	= [SupSac;SS];
		end
	end
	whos SupSac
	freq	= SupSac(:,30);
	unique(freq)
	selbb	= ismember(freq,520);
	selhp	= ismember(freq,921:940);
	sellp	= ismember(freq,[505 507 511]);
	freq(selbb) = 0;
	freq(selhp) = 2;
	freq(sellp) = 1;
	
	int		= SupSac(:,29);
	unique(int)
	TarAz	= SupSac(:,23);
	ResAz	= SupSac(:,8);
	TarEl	= SupSac(:,24);
	ResEl	= SupSac(:,9);
	react	= SupSac(:,5);
	
	sac.target.azimuth		= TarAz;
	sac.target.elevation	= TarEl;
	sac.target.level		= int; % dB(A)
	sac.response.azimuth	= ResAz;
	sac.response.elevation	= ResEl;
	sac.response.latency	= react;
	save(dnames{ii},'sac');
	
	sel		= freq == 0;
	if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g(ii) = stats.beta(2);
	dat = dnames{ii};
	dat = dat(4:end);
	d(ii) = datenum(dat);
	end
	
end
% pa_plotloc([TarAz(sel) ResAz(sel) TarEl(sel) ResEl(sel)]);
% 
% figure
% plot(ResAz(sel),ResEl(sel),'.');

function [g,d] = avprior
%% Refining data-set
dnames	= {'MW-2009-08-05';'MW-2009-10-02'};
nexp	= length(dnames);
% nexp = 2;
g = NaN(nexp,1);
d = g;
for ii = 1:nexp
	pa_datadir(['MW\' dnames{ii}]);
	
	s		= dir('*.mat');
	SupSac = [];
		nfiles = length(s);

	for jj = 1:nfiles
		fname	= s(jj).name;
		if ~any(findstr(fname,'-'));
			
			load(fname);
			SS		= pa_supersac(Sac,Stim);
			SupSac	= [SupSac;SS];
		end
	end
	freq	= SupSac(:,30);
	unique(freq)
	selbb	= ismember(freq,101);
	selhp	= ismember(freq,921:940);
	sellp	= ismember(freq,941:960);
	freq(selbb) = 0;
	freq(selhp) = 2;
	freq(sellp) = 1;
	
	int		= SupSac(:,29);
	unique(int)
	TarAz	= SupSac(:,23);
	ResAz	= SupSac(:,8);
	TarEl	= SupSac(:,24);
	ResEl	= SupSac(:,9);
	react	= SupSac(:,5);
	
	sac.target.azimuth		= TarAz;
	sac.target.elevation	= TarEl;
	sac.target.level		= int; % dB(A)
	sac.response.azimuth	= ResAz;
	sac.response.elevation	= ResEl;
	sac.response.latency	= react;
	save(dnames{ii},'sac');
	
	sel		= freq == 0;
	if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g(ii) = stats.beta(2);
	dat = dnames{ii};
	dat = dat(4:end);
	d(ii) = datenum(dat);
	end
	
end
pa_plotloc([TarAz(sel) ResAz(sel) TarEl(sel) ResEl(sel)]);

figure
plot(ResAz(sel),ResEl(sel),'.');

function [g,d] = owl
%% Refining data-set
dnames	= {'MW-2010-01-18'};
nexp	= length(dnames);
% nexp = 2;
g = NaN(nexp,1);
d = g;
for ii = 1:nexp
	pa_datadir(['MW\' dnames{ii}]);
	
	s		= dir('*.mat');
	SupSac = [];
		nfiles = length(s);

	for jj = 1:nfiles
		fname	= s(jj).name;
		if ~any(findstr(fname,'-'));
			
			load(fname);
			SS		= pa_supersac(Sac,Stim);
			SupSac	= [SupSac;SS];
		end
	end
	freq	= SupSac(:,30);
	selbb	= ismember(freq,901:920);
	selhp	= ismember(freq,921:940);
	sellp	= ismember(freq,941:960);
	freq(selbb) = 0;
	freq(selhp) = 2;
	freq(sellp) = 1;
	
	int		= SupSac(:,29)-4;
	TarAz	= SupSac(:,23);
	ResAz	= SupSac(:,8);
	TarEl	= SupSac(:,24);
	ResEl	= SupSac(:,9);
	react	= SupSac(:,5);
	
	sac.target.azimuth		= TarAz;
	sac.target.elevation	= TarEl;
	sac.target.level		= int; % dB(A)
	sac.response.azimuth	= ResAz;
	sac.response.elevation	= ResEl;
	sac.response.latency	= react;
	save(dnames{ii},'sac');
	
	sel		= freq == 0;
	if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g(ii) = stats.beta(2);
	dat = dnames{ii};
	dat = dat(4:end);
	d(ii) = datenum(dat);
	end
	
end

function [g,d] = plug2
%% Refining data-set
dnames	= {'MW-2003-03-14';'MW-2004-12-06';'MW-2004-12-10'};
nexp	= length(dnames);
% nexp = 2;
g = NaN(nexp,1);
d = g;
for ii = 1:nexp
	pa_datadir(['MW\' dnames{ii}]);
	
	s		= dir('*.mat');
	
	if numel(s)>1
		s = s(2);
	end
	fname	= s.name;
	load(fname);
	SupSac = supersac(Sac,Stim);
	freq	= SupSac(:,26);
	unique(freq)
	int		= SupSac(:,25)+98;
	unique(int)
	TarAz	= SupSac(:,23);
	ResAz	= SupSac(:,8);
	TarEl	= SupSac(:,24);
	ResEl	= SupSac(:,9);
	react	= SupSac(:,5);
	
	sac.target.azimuth		= TarAz;
	sac.target.elevation	= TarEl;
	sac.target.level		= int; % dB(A)
	sac.response.azimuth	= ResAz;
	sac.response.elevation	= ResEl;
	sac.response.latency	= react;
	save(dnames{ii},'sac');
	
	sel		= freq == 0;
	if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g(ii) = stats.beta(2);
	dat = dnames{ii};
	dat = dat(4:end);
	d(ii) = datenum(dat);
	end
	
end


function [g,d] = plug
%% Refining data-set
dnames	= {'MW-2000-07-31';'MW-2000-08-08';'MW-2000-08-15';'MW-2000-08-22';...
	'MW-2000-08-28';'MW-2000-08-29';'MW-2000-09-25';'MW-2000-09-26',...
	};
% dnames	= {'MW-2000-08-28'};

nexp	= length(dnames);
% nexp = 2;
g = NaN(nexp,1);
d = g;
for ii = 1:nexp
	pa_datadir(['MW\' dnames{ii}]);
	s		= dir('*.mat');
	nfiles = length(s);
	SupSac = [];
	
	for jj = 1:nfiles
		fname	= s(jj).name;
		if ~any(findstr(fname,'-'));
			
			load(fname);
			SS		= supersac(Sac,Stim);
			SupSac	= [SupSac;SS];
		end
	end
	sel = SupSac(:,8)<5 & SupSac(:,8)>-2 & SupSac(:,9)<10 & SupSac(:,9)>-10;
	sel = ~sel;
	SupSac = SupSac(sel,:);
	freq	= SupSac(:,26);
	unique(freq)
	selbb = ismember(freq,1:3);
	selhp = ismember(freq,[4:6 45:5:75]);
	sellp = ismember(freq,7:9);
	freq(selbb) = 0;
	freq(selhp) = 2;
	freq(sellp) = 1;
	int			= SupSac(:,26);
	sellow		= ismember(int,[1 4 7]);
	selmed		= ismember(int,[2 5 8]);
	selhigh		= ismember(int,[3 6 9]);
	int(sellow)	= 40;
	int(selmed) = 50;
	int(selhigh)= 60;
	TarAz	= SupSac(:,23);
	ResAz	= SupSac(:,8);
	TarEl	= SupSac(:,24);
	ResEl	= SupSac(:,9);
	react	= SupSac(:,5);
	
	sac.target.azimuth		= TarAz;
	sac.target.elevation	= TarEl;
	sac.target.level		= int; % dB(A)
	sac.response.azimuth	= ResAz;
	sac.response.elevation	= ResEl;
	sac.response.latency	= react;
	save(dnames{ii},'sac');
	
	sel		= freq == 0;
	if sum(sel)
	x		= TarAz(sel);
	y		= ResAz(sel);
	stats	= regstats(y,x,'linear','beta');
	g(ii)	= stats.beta(2);
	dat		= dnames{ii};
	dat		= dat(4:end);
	d(ii)	= datenum(dat);
	end
end

function [g,d] = mold
%% Refining data-set
dnames	= {'MW-2001-11-26';'MW-2002-01-15';'MW-2004-01-05'};
nexp	= length(dnames);
% nexp = 2;
g = NaN(nexp,1);
d = g;
for ii = 1:nexp
	pa_datadir(['MW\' dnames{ii}]);
	
	s		= dir('*.mat');
	if numel(s)>1
		s = s(2);
	end
	fname	= s.name;
	load(fname);
	SupSac = supersac(Sac,Stim);
	freq	= SupSac(:,26);
	int		= SupSac(:,25)+98;
	TarAz	= SupSac(:,23);
	ResAz	= SupSac(:,8);
	TarEl	= SupSac(:,24);
	ResEl	= SupSac(:,9);
	react	= SupSac(:,5);
	
	sac.target.azimuth		= TarAz;
	sac.target.elevation	= TarEl;
	sac.target.level		= int; % dB(A)
	sac.response.azimuth	= ResAz;
	sac.response.elevation	= ResEl;
	sac.response.latency	= react;
	save(dnames{ii},'sac');
	
	sel		= freq == 0;
	if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g(ii) = stats.beta(2);
	dat = dnames{ii};
	dat = dat(4:end);
	d(ii) = datenum(dat);
	end
end


function elderly_fig4_modelselection_earsize


%% Age-related effects on sound localization
P			= others;
Pothers		= P;

%% Our data
stim = [520];
ddir = 'C:\DATA\Test\Elderly\';
cd(ddir);
[N,T] = xlsread('Mappen.xlsx');

Subjects	= T(:,1);
n			= size(T,1);
Subjects	= Subjects(2:n);
age			= N(1:n-1,8);


tonefreq = [125 250 500 1000 2000 4000 8000 9000 10000 11200 12500];
indx = [1:7 9:11];
audio		= N(1:n-1,20:41);
audio(isnan(audio)) = nanmin(audio(:));
audio1 = audio(:,1:2:end);
audio2 = audio(:,2:2:end);
audio = -(audio1+audio2)/2;
audio = audio(:,indx);
tonefreq = tonefreq(indx);

%% Selection criteria
sel			= age<100;
Subjects	= Subjects(sel);
age			= age(sel);
audio		= audio(sel,:);

%% Do gain-analysis
nSubjects	= length(Subjects); % all
% nSubjects	= length(Subjects)-2; %exclude MA and MW
audio = audio(1:nSubjects,:);

Subjects	= char(Subjects);
G = [];
Gs = [];
S = [];
RT = [];
SD = [];
RMS = [];
for jj = 1:nSubjects
	%% Localization-data
	cd(ddir)
	sdir = Subjects(jj,1:end-5);
	cd(sdir);
	load(Subjects(jj,:));
	SupSac	= pa_supersac(Sac,Stim);
	sel		= ismember(SupSac(:,30),stim);
	snd20	= SupSac(sel,:);
	[stats,gs,sd,sdsd,rt] = datagraph(snd20);
	G		= [G;stats.beta(2)]; %#ok<*AGROW>
	Gs		= [Gs;gs];
	S		= [S;sd];
	SD		= [SD;sdsd];
	RT		= [RT;rt];
	
	%% Audiogram
	rms = getsnd(tonefreq,audio(jj,:));
	RMS = [RMS;rms];
end

%% Niet netjes: hardcoded gain-selection
% sel = G>0.4;
% G	= G(sel);
% Gs	= Gs(sel);
% S	= S(sel);
% RMS = RMS(sel);
% SD	= SD(sel);
% RT	= RT(sel);
% age = age(sel);

%% kids
ddir = 'C:\DATA\Test\Elderly\Kids';
cd(ddir)
[N,T] = xlsread('Mappenkids.xlsx');
Subjects = T(:,1);
n			= size(T,1);
Subjects = Subjects(2:n);


tonefreq = [125 250 500 1000 2000 4000 8000 9000 10000 11200 12500];
indx = [1:7 9:11];
audio		= N(1:n-1,20:33);
audio		= [audio zeros(n-1,8)];
audio(isnan(audio)) = nanmin(audio(:));
audio1 = audio(:,1:2:end);
audio2 = audio(:,2:2:end);
audio = -(audio1+audio2)/2;
audio = audio(:,indx);
tonefreq = tonefreq(indx);


nSubjects = length(Subjects);
Subjects = char(Subjects);
agekids			= N(:,8);
age = [age;agekids];
for jj = 1:nSubjects
	cd(ddir)
	sdir = Subjects(jj,1:end-5);
	cd(sdir);
	load(Subjects(jj,:));
	SupSac = pa_supersac(Sac,Stim);
	
	sel		= ismember(SupSac(:,30),stim);
	snd20	= SupSac(sel,:);
	[stats,gs,sd,sdsd,rt] = datagraph(snd20);
	G = [G;stats.beta(2)];
	Gs = [Gs;gs];
	S = [S;sd];
	RT = [RT;rt];
	SD = [SD;sdsd];

	%% Audiogram
	rms = getsnd(tonefreq,audio(jj,:));
	RMS = [RMS;rms];
end

%% Normalize gain over subjects
G			= G./max(G);

% %% Optimize
% % options		= statset('Robust','on');
% options = statset([]);
% n = length(G);
% 
% X = [S RMS];
% Y = G;
% beta0	= [27 -45 -25];
% [beta,r]	= nlinfit(X,Y,@pa_model1fun,beta0,options); % Acoustic Response
% K		= 3+2;
% RSS		= sum(r.^2);
% AIC1	= pa_AIC(RSS,n,K);
% 
% X = RMS;
% Y = G;
% beta0	= [-45 -25];
% [~,r]	= nlinfit(X,Y,@pa_model2fun,beta0,options); % Acoustic
% K		= 2+2;
% RSS		= sum(r.^2);
% AIC2	= pa_AIC(RSS,n,K);
% 
% X = S;
% Y = G;
% beta0	= 27;
% [~,r]	= nlinfit(X,Y,@pa_model3fun,beta0,options); % Response
% K		= 1+2;
% RSS		= sum(r.^2);
% AIC3	= pa_AIC(RSS,n,K);
% 
% 
% Xage	= polyval(Pothers,age);
% RSS		= sum((G-Xage).^2);
% K		= 2;
% AIC4	= pa_AIC(RSS,n,K);

% pa_datadir;
% save age_others Pothers
% X = [S RMS age];
% Y = G;
% beta0	= [27 -45 -25];
% [~,r] = nlinfit(X,Y,@pa_model5fun,beta0,options); % Acoustic Response Age
% K		= 3+2;
% RSS		= sum(r.^2);
% AIC5	= pa_AIC(RSS,n,K);
% 
% 
% disp('----------------------');
% AIC = [AIC1 AIC2 AIC3 AIC4 AIC5]
% Di	= AIC - min(AIC)
% e	= exp(-0.5*Di);
% wi	= e./sum(e)
% disp('----------------------');

%% Model selection



% %% MLR
% Xage		= polyval(P,age);
% Gprior		= 1-S.^2/beta(1)^2;
% 
% % keyboard
% 
% sel = RMS<beta(2);
% RMS(sel) = beta(2);
% sel = RMS>beta(3);
% RMS(sel) = beta(3);
% RMS = (RMS-min(RMS))./(max(RMS)-min(RMS));
% 
% Gint = Gprior.*RMS;
% Gint = (Gint-min(Gint))./(max(Gint)-min(Gint));
% 
% % Y = 1 - X.^2/beta.^2;
% X = [Xage Gprior.*RMS];
% Y = G;
% X = zscore(X);
% Y = zscore(Y);
% stats = regstats(Y,X,'linear',{'beta','rsquare','tstat'});
% stats.beta
% stats.tstat.pval
% stats.rsquare
% % keyboard
% 
% X = [Gprior RMS];
% Y = G;
% stats = regstats(Y,X,'linear',{'yhat'});

%% correct end
[~,indx]	= max(age);
age			= [age; 90; 100];
G			= [G; G(indx);  G(indx)];
Gs			= [Gs; Gs(indx);  Gs(indx)];
% Gprior		= [Gprior; Gprior(indx);  Gprior(indx)];
% RMS			= [RMS; RMS(indx); RMS(indx)];
% Gpred = stats.yhat;
% Gpred		= [Gpred; Gpred(indx);  Gpred(indx)];
% Gint		= [Gint; Gint(indx);  Gint(indx)];

%%
figure(1)
h = errorbar(age,G,Gs,'ro','MarkerFaceColor','w');
% plot(age,G,'ro','MarkerFaceColor','w');
hold on
% % plot(age,Gpred,'bo','MarkerFaceColor','w');
% % plot(age,RMS,'go','MarkerFaceColor','w');
% x = 0:100; 
% Y = polyval(Pothers,x);
% plot(x,Y,'k-','LineWidth',2);
% x = 0:10:100;
% Y = polyval(Pothers,x);
% h2 = plot(x,Y,'k^','LineWidth',2,'MarkerFaceColor','w');
% 
% x = 0:100; 
% P = polyfit(age,Gprior,3);
% Y1 = polyval(P,x);
% plot(x,Y1,'k-','LineWidth',2);
% x = 0:10:100;
% Y = polyval(P,x);
% h3 = plot(x,Y,'ko','LineWidth',2,'MarkerFaceColor','w');
% 
% x = 0:100; 
% P = polyfit(age,RMS,3);
% Y2 = polyval(P,x);
% plot(x,Y2,'k-','LineWidth',2);
% x = 0:10:100;
% Y = polyval(P,x);
% h4 = plot(x,Y,'ks','LineWidth',2,'MarkerFaceColor','w');
% % h11 = plot(x,Y1.*Y2,'k-','LineWidth',2,'Color',[.5 .5 .5]);
% 
% x = 0:100; 
% P = polyfit(age,G,3);
% Y = polyval(P,x);
% h1 = plot(x,Y,'r-','LineWidth',3);
% ylim([0 1.1]);
% xlim([0 85]);
% xlabel('Age (yrs)');
% ylabel('Gain');
% axis square;
% legend([h;h1;h2;h3;h4],{'Data';'Polyfit';'Aging';'Response';'Acoustic'},'Location','S');

pa_datadir;
print('-depsc',mfilename);

function [stats,Gs,sd,sdsd,rt] = datagraph(SND20)
nboot = 100;
RT		= SND20(:,5);
sel		= RT>100 & RT<600;
SND20	= SND20(sel,:);
X		= SND20(:,24);
Y		= SND20(:,9);
RT		= SND20(:,5);
rt = median(RT);
stats	= regstats(Y,X,'linear',{'beta','r','tstat','rsquare'});
sd		= std(stats.r);
Gs		= stats.tstat.se(2);
sdsd	= std(bootstrp(nboot, @getsd ,Y,X));

function sd = getsd(Y,X)
stats	= regstats(Y,X,'linear',{'r'});
sd		= std(stats.r);

function P = others
%% Dobreva Figure 5, BB0.1-20
age = [(19+41)/2 (45+66)/2 (70+81)/2 (19+41)/2 (45+66)/2 (70+81)/2];
gain = [0.8 0.65 0.65 0.95 0.57 0.43];
gain = gain/max(gain);
[age,indx] = sort(age);
gain			= gain(indx);
% h1 = plot(age,gain,'ko-','MarkerFaceColor','w','LineWidth',1);
hold on

A = age;
G = gain;
figure(1);
%% Besing Table 1
% age = [((11.3+11.8)+(6.11+7.2)+(11.10+12.0)+(11.10+12.0)+(12+12))/2 ];
age = [10.4 23.6 10.4 23.6];
gain = [45.75 59.66 50.61 65.62];
gain = gain/max(gain);

[age,indx] = sort(age);
gain			= gain(indx);
% h2 = plot(age,gain,'ks-','MarkerFaceColor','w','LineWidth',1);
A = [A age];
G = [G gain];

% % with otitis
ageom = [10 10];
gainom = [25.03 26.32];
gainom = gainom/65.62;
% plot(ageom,gainom,'ks','MarkerFaceColor',[.7 .7 .7],'LineWidth',1);

%% Van Deun Figure 6
age = [4 5 6 8 9 26];
gain = 100-[40 10 20 30 10 5];
gain = gain/max(gain(:));
[age,indx] = sort(age);
gain			= gain(indx);
% h3 = plot(age,gain','k^-','MarkerFaceColor','w','LineWidth',1);
A = [A age];
G = [G gain];

%% Grieco-Calub figure 1
age = 5.5;
gain = 1;
% h4 = plot(age,gain','k>-','MarkerFaceColor','w','LineWidth',1);
A = [A age];
G = [G gain];


%% Abel 2000 Table III
age = [15 25 35 45 55 65 75];
gain = [57 55 55 55 51 50 42;...
	79 76 62 66 67 66 56;...
	99 100 99 98 94 95 88;...
	56 55 55 54 53 49 48;...
	74 70 60 65 63 64 55;...
	90 93 91 92 85 82 76;...
	43 46 45 41 41 36 33;...
	60 61 60 53 50 50 51;...
	85 89 92 84 84 84 78;...
	50 51 52 45 45 39 34;...
	72 69 65 58 58 57 52;...
	92 94 97 92 91 89 85;...
	49 53 54 47 46 44 36;...
	72 70 66 61 61 62 50;...
	93 96 97 94 91 89 84;...
	46 51 53 47 49 44 39;...
	67 65 65 56 60 57 53;...
	90 92 95 91 87 86 80;...
	];
gain = median(gain);
gain = gain/max(gain(:));
[age,indx] = sort(age);
gain			= gain(indx);
% h5 = plot(age,gain','kd-','MarkerFaceColor','w','LineWidth',1);
A = [A age];
G = [G gain];


%% Litovsky2010 Figuur 2
age = [22 5.14];
gain = [(1.2+1.8+3+3.1+3.2+3.5+3.6+5.3+5.5+6.3)/10 (4+5+5.1+5.7+7.4+8+8.3+9.1)/8];
gain = 10-gain;
gain = gain/max(gain(:));
[age,indx] = sort(age);
gain			= gain(indx);
% h6 = plot(age,gain','k<-','MarkerFaceColor','w','LineWidth',1);
A = [A age];
G = [G gain];

[~,indx] = max(A);
A = [A 90 100];
G = [G G(indx) G(indx)];
P = polyfit(A,G,3);



function  RMS = getsnd(F2,HL)
% Generate Gaussian White Noise Stimulus by defining a flat Magnitude
% spectrum and a random phase.
%
%
% See also PA_GENGWN, PA_WRITEWAV
%

% 2007 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

Fh          = 3000;
Fn          = 48828.125/2; % TDT Nyquist sampling frequency (Hz)
% Fc			= min([Fc Fn]);
Fc = 11000;
order       = 500; % samples
NEnvelope   = 250; % samples
N           = 1*Fn*2; % samples

Fs = Fn*2;

%% Create and Modify Signal
NFFT	= 2^(nextpow2(N));
%% Magnitude
M		= repmat(100,NFFT/2,1);
M		= [M;fliplr(M)];

%% A-weighting
F		= (0:length(M)-1)*Fs/NFFT;
F		= F';
Nom		= 12200^2*F.^4;
Den		= (F.^2+20.6^2).*sqrt((F.^2+107.7^2).*(F.^2+737.9^2)).*(F.^2+12200^2);
R		= Nom./Den;


% P	= polyfit(F2,HL,2);
% HLe = polyval(P,F);
HL = [HL -100];
F2 = [F2 20000];
HLe = interp1(F2,HL,F,'cubic','extrap');


HLe = 10.^(HLe/20);

%% DTF

%% Weight
M		= M.*R.*HLe;

%% Phase
P		= (rand(NFFT/2,1)-0.5)*2*pi;
P		= [P;fliplr(P)];
R		= M.*cos(P);
I		= M.*sin(P);
S		= complex(R,I);
stm		= ifft(S,'symmetric');
% Low-pass filter
stm             = pa_lowpass(stm, Fc, Fn, order);
% High-pass filter
stm             = pa_highpass(stm, Fh, Fn, order);

% Envelope to remove click
if NEnvelope>0
	stm			= pa_envelope (stm, NEnvelope);
end
%Reshape
stm				= stm(:)';

RMS = round(20*log10(pa_rms(stm)));


function Y = pa_model1fun(beta,X)
% Acoustic Response
% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

Y1 = 1 - X(:,1).^2/beta(1).^2;
sel = X(:,2)<beta(2);
X(sel,2) = beta(2);
sel = X(:,2)>beta(3);
X(sel,2) = beta(3);
Y2 = (X(:,2)-min(X(:,2)))./(max(X(:,2))-min(X(:,2)));
Y = Y1.*Y2;

function Y = pa_model2fun(beta,X)
% Acoustic
% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

sel = X<beta(1);
X(sel) = beta(1);
sel = X>beta(2);
X(sel) = beta(2);
Y = (X-min(X))./(max(X)-min(X));


function Y = pa_model3fun(beta,X)
% Response
% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com
Y = 1 - X.^2/beta.^2;

function Y = pa_model5fun(beta,X)
% Acoustic Response
% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@neural-code.com

Y1			= 1 - X(:,1).^2/beta(1).^2;
sel			= X(:,2)<beta(2);
X(sel,2)	= beta(2);
sel			= X(:,2)>beta(3);
X(sel,2)	= beta(3);
Y2			= (X(:,2)-min(X(:,2)))./(max(X(:,2))-min(X(:,2)));

pa_datadir;
load age_others;
% Pothers		= beta(4:7);
Y3			= polyval(Pothers,X(:,3));
% save age_others Pothers

Y			= Y1.*Y2.*Y3;

function AIC = pa_AIC(RSS,n,K)
AIC = n*log(RSS/n)+2*K+(2*K*(K+1))/(n-K-1);

function SupSac=supersac(Sac,Stim)

% SUPSAC=SUPERSAC(SAC,STIM)
%
% adds to the Sac matrix  - target amplitude (21)
%                         - target direction (22)
%                         - target azimuth   (23)
%                         - target elevation (24)
%                         - Stim intensity   (25)
%                         - stim attribute   (26)
%                         - stim duration   (27)
% See also INDEX
%
%  02-05-01 Marcus

% Make use of intensities
% Stim       =  att2int(Stim);
nrtargets       = (size(Stim,2)-2)/8;
for i           =   1:size(Sac,1)
    trialNr     = Sac(i,1);
    
    if nrtargets>2
        Sac(i,21) = Stim(trialNr,13);   % target amplitude
        Sac(i,22) = Stim(trialNr,14);   % target direction
        Sac(i,23) = Stim(trialNr,15);   % target azimuth
        Sac(i,24) = Stim(trialNr,16);   % target elevation
        Sac(i,25) = Stim(trialNr,19);   % Intensity
        Sac(i,26) = Stim(trialNr,20);   % Attribute
        Sac(i,27) = Sac(i,3)*2-Stim(trialNr,17);   % SRT re Target 1
    end
    if nrtargets>3
        Sac(i,28) = Stim(trialNr,22);   % target amplitude
        Sac(i,29) = Stim(trialNr,23);   % target direction
        Sac(i,30) = Stim(trialNr,24);   % target azimuth
        Sac(i,31) = Stim(trialNr,25);   % target elevation
        Sac(i,32) = Stim(trialNr,28);   % Intensity
        Sac(i,33) = Stim(trialNr,29);   % Attribute
        Sac(i,34) = Sac(i,3)*2-Stim(trialNr,25);   % SRT re Target 2
    end
end
SupSac          = Sac;

function [Dat,Subj] = getavdr_aud_nobg
% Get Data Matrix from Auditory Trials with no bkg in AVDR-experiments

%% Data Analysis
% file_path         = fullfile(matlabroot,'work','Data','Audiovisual Disparity Integration');
file_path         = 'C:\DATA\Audiovisual\Audiovisual Disparity Integration';

Dat                 = NaN(2000,27);
files               = [...
    'mw1001';'mw1201';'mw1301';...
    ];
nfiles              = size(files,1);
prevl               = 0;
Subj                = Dat(:,1);
for k               = 1:nfiles
    fname           = files(k,:);
    matfile         = pa_fcheckext(fname,'.mat');
    dname           = fullfile(file_path,['data_' upper(fname(1:2))]);
    cd(dname);
    
    load(matfile);
    Dattmp          = supersac(Sac,Stim);
    indx            = (1:size(Dattmp,1))+prevl;
    prevl           = indx(end);
    Dat(indx,:)     = Dattmp;

    s               = fname(1:2);
    if strcmpi(s,'mw')
        s = 1;
    elseif strcmpi(s,'jg')
        s = 2;
    elseif strcmpi(s,'jo')
        s = 3;
    elseif strcmpi(s,'ab')
        s = 4;
    elseif strcmpi(s,'jv')
        s = 5;
    end
    Subj(indx)      = s*ones(size(indx'));
end
Dat                 = Dat(1:prevl,:);
Subj                = Subj(1:prevl);

%% Remake Trial Number
indx                = find(Dat(2:end,1)-Dat(1:end-1,1)<0);
incr                =    Dat(indx,1);
for i               = 1:length(indx)
    Dat(indx(i)+1:end,1) =  Dat(indx(i)+1:end,1)+incr(i);
end

Dat(:,2) = zeros(size(Dat,1),1);
Ntrial = max(Dat(:,1));
for i       = 1:Ntrial,
  ts        = (Dat(:,1)==i) & Dat(:,27)-1200>0;
  if sum(ts)>0,
    Dat(ts,2) = (1:sum(ts))';              % 2 saccade number in trial
  end;
end;

function [g,d]  = geta
id			= 11:22;
[Dat,S]     = getav_bg;
[Dat,S]     = avdr_selprim(Dat,S);
sel         = ismember(Dat(:,26),id) & ismember(Dat(:,25),2);
A			= Dat(sel,:);
S			= S(sel,:);
sel			= ismember(S,1);
SupSac		= A(sel,:);

freq		= SupSac(:,26);
selbb		= ismember(freq,11:22);
selhp		= ismember(freq,2);
sellp		= ismember(freq,1);
freq(selbb) = 0;
freq(selhp) = 2;
freq(sellp) = 1;
int			= SupSac(:,26);
sel6		= ismember(int,11+(0:3)*4);
sel12		= ismember(int,12+(0:3)*4);
sel18		= ismember(int,13+(0:3)*4);
sel21		= ismember(int,14+(0:3)*4);
int(sel6)	= -6;
int(sel12)	= -12;
int(sel18)	= -18;
int(sel21)	= -21;

TarAz	= SupSac(:,23);
ResAz	= SupSac(:,8);
TarEl	= SupSac(:,24);
ResEl	= SupSac(:,9);
react	= SupSac(:,5);

sac.target.azimuth		= TarAz;
sac.target.elevation	= TarEl;
sac.target.level		= int; % dB(A)
sac.response.azimuth	= ResAz;
sac.response.elevation	= ResEl;
sac.response.latency	= react;
dnames					= 'MW-2000-01-01';
pa_datadir(['MW\' dnames]);
save(dnames,'sac');

sel		= freq == 0;
if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g = stats.beta(2);
	dat = dnames;
	dat = dat(4:end);
	d = datenum(dat);
end

% pa_plotloc([TarAz(sel) ResAz(sel) TarEl(sel) ResEl(sel)]);
% 
% figure
% plot(ResAz(sel),ResEl(sel),'.');


function [g,d] = avdr
baselat     = -1200;
idlat       = -50;
audlat      = baselat+idlat; % klopt dit, eerst stond er 1250

[Dat,S]     = getavdr_aud_nobg;
Dat         = avdr_selsub(Dat,S,1);
Dat         = avdr_selprim(Dat);
L1          = Dat(:,27)+audlat;
id          = [50 51 52 53]; % these are the ids for the NO_BG stimulus
sel         = ismember(Dat(:,26),id);
SupSac      = Dat(sel,:);
SupSac(:,5) = L1(sel);
% whos Lno
% snr         = [6 12 18 21];
% for i       = 1:length(id)
%     sel     = ismember(Dat(:,26),id(i)); %#ok<NASGU>
%     str     = ['Lno' num2str(snr(i)) ' = L1(sel);'];
%     eval(str);
% end
% SupSac		= Lno;

freq		= SupSac(:,26);
unique(freq)
selbb		= ismember(freq,50:53);
selhp		= ismember(freq,2);
sellp		= ismember(freq,1);
freq(selbb) = 0;
freq(selhp) = 2;
freq(sellp) = 1;
int			= SupSac(:,26);
unique(int)
sel6		= ismember(int,50);
sel12		= ismember(int,51);
sel18		= ismember(int,52);
sel21		= ismember(int,53);
int(sel6)	= 60-6;
int(sel12)	= 60-12;
int(sel18)	= 60-18;
int(sel21)	= 60-21;

TarAz	= SupSac(:,23);
ResAz	= SupSac(:,8);
TarEl	= SupSac(:,24);
ResEl	= SupSac(:,9);
react	= SupSac(:,5);

sac.target.azimuth		= TarAz;
sac.target.elevation	= TarEl;
sac.target.level		= int; % dB(A)
sac.response.azimuth	= ResAz;
sac.response.elevation	= ResEl;
sac.response.latency	= react;
dnames					= 'MW-2001-12-30';
pa_datadir(['MW\' dnames]);
save(dnames,'sac');

sel		= freq == 0;
if sum(sel)
	x = TarEl(sel);
	y = ResEl(sel);
	stats = regstats(y,x,'linear','beta');
	g = stats.beta(2);
	dat = dnames;
	dat = dat(4:end);
	d = datenum(dat);
end

% pa_plotloc([TarAz(sel) ResAz(sel) TarEl(sel) ResEl(sel)]);
% 
% figure
% plot(ResAz(sel),ResEl(sel),'.');