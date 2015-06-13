function STRF_dif
close all
clear all
clc

%% reading and loading the files

cd('E:\DATA\Cortex\Test\goodcells');

thorfiles = dir('thor*');
joefiles  = dir('joe*');


files		= [thorfiles' joefiles'];
load('STD_OK_CELLS');
k               = 0;

Pool_P          = zeros(10,10);
Pool_500        = zeros(10,10);
Pool_1000       = zeros(10,10);
Pool_A          = zeros(10,10);
Pool_A500       = zeros(10,10);
Pool_A1000       = zeros(10,10);
n = 50;
G500            = NaN(n,1);
G1000           = NaN(n,1);
GA              = NaN(n,1);
G5002            = NaN(n,1);
G10002           = NaN(n,1);
GA2              = NaN(n,1);
ERFF500         = NaN(n,1);
ERFF1000        = NaN(n,1);
ERFFA           = NaN(n,1);
Bias500         = NaN(n,1);
Bias1000        = NaN(n,1);
BiasA           = NaN(n,1);

methflag = 2;
indx1 = 4:6;
indx2 = 2:4;
indx1	= 1:10;
indx2	= 1:10;
% indx1 = 5;
% indx2 = 1:10;
dsp		= 0;

for j =1:length(L)
	if L(j)   == 1 && j~=92
		fname = files(j).name;
		disp(fname);
		
		%% Spike structures
		load(fname);
		k			= k+1;
		P			= spikep;
		A500		= S500;
		A1000		= S1000;
		
		%% STRFs
		data		= pa_spk_ripple2strf(P);
		data500		= pa_spk_ripple2strf(A500);
		data1000	= pa_spk_ripple2strf(A1000);
		
		%% Shift
		[B, kshift]         = rm_spk_strfshiftmax(data.strf);
		B500                = rm_spkA_strfshiftmax(data500.strf,kshift);
		B1000               = rm_spkA_strfshiftmax(data1000.strf,kshift);
		
		%% RMS
		% 		B           = B./rms(B(:));
		% 		B500        = B500./rms(B500(:));
		% 		B1000        = B1000./rms(B1000(:));
		%
		%% regression
		if dsp
			figure(666)
			clf;
		end
		[D500,g500,b500,g5002,b5002] = getdiff(B,B500,indx1,indx2,methflag,dsp,fname);
		% 				pause
		[D1000,g1000,b1000,g10002,b10002] = getdiff(B,B1000,indx1,indx2,methflag,dsp,fname);
		% 				pause
		[DA,ga,ba,ga2,ba2] = getdiff(B500,B1000,indx1,indx2,methflag,dsp,fname);
		% 				pause
		
		G500(k)         = g500;
		G1000(k)        = g1000;
		GA(k)           = ga;
		Bias500(k)      = b500;
		Bias1000(k)     = b1000;
		BiasA(k)        = ba;
		G5002(k)         = g5002;
		G10002(k)        = g10002;
		GA2(k)           = ga2;
		Bias5002(k)      = b5002;
		Bias10002(k)     = b10002;
		BiasA2(k)        = ba2;
		
		%% RMS
		B           = B./rms(B(:));
		D500		= D500./rms(D500(:));
		D1000		= D1000./rms(D1000(:));
		DA			= DA./rms(DA(:));
		B500        = B500./rms(B500(:));
		
	%% ERFF
		[erff500,erff1000,erffA] = geterff(B,B500,B1000,indx1,indx2);
		ERFF500(k)      = erff500;
		ERFF1000(k)     = erff1000;
		ERFFA(k)        = erffA;
		
		%% SUM
		Pool_P          = Pool_P + B;
		Pool_500        = Pool_500 + D500;
		Pool_1000       = Pool_1000 + D1000;
		Pool_A          = Pool_A + DA;
		Pool_A500       = Pool_A500 + B500;
		Pool_A1000       = Pool_A1000 + B1000;
		
	end
end
% keyboard

figure;
h1 = plot(G500,G5002,'ko','Color',[.7 .7 .7],'MarkerFaceColor',[.7 .7 .7]);
hold on
h2 = plot(G1000,G10002,'ko','Color',[.7 .7 .7],'MarkerFaceColor',[.7 .7 .7]);
h3 = plot(GA,GA2,'ko','Color',[.7 .7 .7],'MarkerFaceColor',[.7 .7 .7]);
axis square;
axis([-1 3 -1 3]);
pa_horline(1);
pa_verline(1);
x = -3:0.1:3;
y = 1./x;
h4 = plot(x,y,'k-','LineWidth',2);
xlabel('Gain Active = a*Passive');
ylabel('Gain Passive = a*Active');
legend([h1,h2,h3,h4],{'P-A500','P-A1000','A500-A1000','Ideal y = 1/x'});

dsel = 100;
hold on;
x = -1:.01:5;
y = 1./x;
n = numel(G500);
for ii = 1:n
	dx = G500(ii)-x;
	dy = G5002(ii)-y;
	d = sqrt(dx.^2+dy.^2);
	D(ii) = min(d);
end
% x = abs(1./G5002-G500');
sel500 = D<dsel;
h1 = plot(G500(sel500),G5002(sel500),'ko','MarkerFaceColor','k','Color','k');
hold on
x = -1:.01:5;
y = 1./x;
n = numel(G1000);
for ii = 1:n
	dx = G1000(ii)-x;
	dy = G10002(ii)-y;
	d = sqrt(dx.^2+dy.^2);
	D(ii) = min(d);
end
sel1000 = D<dsel;
h2 = plot(G1000(sel1000),G10002(sel1000),'ko','MarkerFaceColor','k','Color','k');
x = -1:.01:5;
y = 1./x;
n = numel(GA);
for ii = 1:n
	dx = GA(ii)-x;
	dy = GA2(ii)-y;
	d = sqrt(dx.^2+dy.^2);
	D(ii) = min(d);
end
selA = D<dsel;

h3 = plot(GA(selA),GA2(selA),'ko','MarkerFaceColor','k','Color','k');
axis square;
axis([-1 3 -1 3]);
pa_horline(1);
pa_verline(1);
x = -3:0.1:3;
y = 1./x;
% h4 = plot(x,-y,'r-','LineWidth',2);
xlabel('Gain Active = a*Passive');
ylabel('Gain Passive = a*Active');


figure;
subplot(131)
boxplot(G500(sel500),'notch','on');
axis square;
ylim([0 2.5]);
pa_horline(1);
str = [num2str(sum(sel500)) ' of 51 cells'];
title(str);

subplot(132)
boxplot(G1000(sel1000),'notch','on');
axis square;
ylim([0 2.5]);
pa_horline(1);
str = [num2str(sum(sel1000)) ' of 51 cells'];
title(str);

subplot(133)
boxplot(GA(selA),'notch','on');
axis square;
ylim([0 2.5]);
pa_horline(1);
str = [num2str(sum(selA)) ' of 51 cells'];
title(str);


figure;
plot(G500(sel500),ERFF500(sel500),'k.');
hold on
plot(G1000(sel1000),ERFF1000(sel1000),'r.');
plot(GA(selA),ERFFA(selA),'b.');


axis square;
xlabel('Gain');
ylabel('Sensitivity contrast');
% lsline;
pa_horline;
pa_verline(1);

figure(1)
pa_datadir;
print('-depsc','gainrev');

figure(2)
pa_datadir;
print('-depsc','gainhist');

figure(3)
pa_datadir;
print('-depsc','gainerff');

function [D,g,b,g2,b2] = getdiff(STRFx,STRFy,indx1,indx2,methflag,dsp,fname)
y = STRFy(indx1,indx2);
x = STRFx(indx1,indx2);
y = y(:);
x = x(:);
% sel = x<0;
% x(sel) = -x(sel);
% y(sel) = -y(sel);


% 		sel = x>(mean(x)+std(x));
sel = x<1000;
% Method 1
stats     = regstats(y(sel),x(sel));
g      = stats.beta(2);
b      =  stats.beta(1);
strf   = (STRFy-b)./g;
p = stats.fstat.pval;
% 				strf500 = stats.r;

% Method 2
stats     = regstats(x,y);
g2      = stats.beta(2);
b2      = stats.beta(1);
strf2	= g*STRFy+b;
p		= stats.fstat.pval;

D   = strf - STRFx;

if dsp
	y2 = strf(indx1,indx2); y2 = y2(:);
	subplot(121)
	cla;
	plot(x,y,'k.');
	hold on
	% 	plot(x,y2,'r.');
	mx = max(abs([x; y]));
	axis([-mx mx -mx mx])
	pa_unityline;
	lsline;
	title([g p])
	axis square;
	
	subplot(122)
	cla;
	plot(y,x,'k.');
	hold on
	mx = max(abs([x; y]));
	axis([-mx mx -mx mx])
	pa_unityline;
	lsline;
	title([g p])
	axis square;
	pause;
end

function [erff500,erff1000,erffA] = geterff(STRFx,STRFy,STRFz,indx1,indx2)
x		= STRFx(indx1,indx2); x = x(:);
mn		= min(x);
mx		= max(x);
xdif	= mx-mn;
x		= STRFy(indx1,indx2); x = x(:);
mn		= min(x);
mx		= max(x);
ydif = mx-mn;
x		= STRFz(indx1,indx2); x = x(:);
mn		= min(x);
mx		= max(x);
zdif = mx-mn;

erff500		= (ydif-xdif)/(ydif+xdif);
erff1000	= (zdif-xdif)/(zdif+xdif);
erffA		= (zdif-ydif)/(zdif+ydif);

% erff500		= (ydif-xdif);
% erff1000	= (zdif-xdif);
% erffA		= (zdif-ydif);

