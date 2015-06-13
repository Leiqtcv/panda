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
G500            = NaN(51,1);
G1000           = NaN(51,1);
GA              = NaN(51,1);
ERFF500         = NaN(51,1);
ERFF1000        = NaN(51,1);
ERFFA           = NaN(51,1);
Bias500         = NaN(51,1);
Bias1000        = NaN(51,1);
BiasA           = NaN(51,1);

methflag = 1;
indx1 = 4:6;
indx2 = 2:4;
% indx1	= 1:10;
% indx2	= 1:10;
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
		[D500,g500,b500] = getdiff(B,B500,indx1,indx2,methflag,dsp,fname);
% 				pause
		[D1000,g1000,b1000] = getdiff(B,B1000,indx1,indx2,methflag,dsp,fname);
% 				pause
		[DA,ga,ba] = getdiff(B500,B1000,indx1,indx2,methflag,dsp,fname);
% 				pause

G500(k)         = g500;
			G1000(k)        = g1000;
			GA(k)           = ga;
			Bias500(k)      = b500;
			Bias1000(k)     = b1000;
			BiasA(k)        = ba;
		
		%% ERFF
		[erff500,erff1000,erffA] = geterff(B,B500,B1000,indx1,indx2);
		ERFF500(k)      = erff500;
		ERFF1000(k)     = erff1000;
		ERFFA(k)        = erffA;
		
		%% RMS
		B           = B./rms(B(:));
		D500		= D500./rms(D500(:));
		D1000		= D1000./rms(D1000(:));
		DA			= DA./rms(DA(:));
		B500        = B500./rms(B500(:));
		
		X(k,:) = B(:);
		Y(k,:) = B500(:);
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



Pool_P          = Pool_P./k;
Pool_500        = Pool_500 ./k;
Pool_1000       = Pool_1000 ./k;
Pool_A          = Pool_A ./k;
Pool_A500       = Pool_A500 ./k;
Pool_A1000       = Pool_A1000 ./k;

close all;
figure(1);
cla;
mxscal = max(max(Pool_P));
subplot(221)
imagesc(Pool_P);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(222)
imagesc(Pool_500);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(223)
imagesc(Pool_1000);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(224)
imagesc(Pool_A);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

%%
figure(2);
cla;
mxscal = max(max(Pool_P));
subplot(221)
x		= data.time;
y		= data.frequency;
z		= Pool_P;
[~,m]   = max(max(z,[],1));
XI     = linspace(min(x),max(x),500);
YI     = linspace(min(y),max(y),500);
ZI     = interp2(x,y',z,XI,YI','*spline');
imagesc(XI,YI,ZI);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);


subplot(222)
z		= Pool_500;
[~,m]   = max(max(z,[],1));
XI     = linspace(min(x),max(x),500);
YI     = linspace(min(y),max(y),500);
ZI     = interp2(x,y',z,XI,YI','*spline');
imagesc(XI,YI,ZI);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(223)
z		= Pool_1000;
[~,m]   = max(max(z,[],1));
XI     = linspace(min(x),max(x),500);
YI     = linspace(min(y),max(y),500);
ZI     = interp2(x,y',z,XI,YI','*spline');
imagesc(XI,YI,ZI);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(224)
mxscal = max(max(Pool_A500));
z		= Pool_A;
[~,m]   = max(max(z,[],1));
XI     = linspace(min(x),max(x),500);
YI     = linspace(min(y),max(y),500);
ZI     = interp2(x,y',z,XI,YI','*spline');
imagesc(XI,YI,ZI);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

%% plot  Bias & gains
% sel = isnan(G500);
% G500 = G500(~sel);
% sel = isnan(G1000);
% G1000 = G1000(~sel);
% sel = isnan(GA);
% GA = GA(~sel);

figure(3);
x = -1:0.2:3;
subplot(331)
N = hist(G500,x);
h= bar(x,N,1);
set(h,'FaceColor',[.7 .7 .7]);
axis square;
xlim([-3 3]);
h = pa_verline(median(G500),'k-');  set(h,'LineWidth',2);
pa_verline(1,'k:');
title('G500');

subplot(332)
N = hist(G1000,x);
h= bar(x,N,1);
set(h,'FaceColor',[.7 .7 .7]);
axis square;
xlim([-3 3]);
h = pa_verline(median(G1000),'k-'); set(h,'LineWidth',2);
pa_verline(1,'k:');
title('G1000');

subplot(333)
N = hist(GA,x);
h= bar(x,N,1);
set(h,'FaceColor',[.7 .7 .7]);
axis square;
xlim([-3 3]);
h = pa_verline(median(GA),'k-'); set(h,'LineWidth',2);
pa_verline(1,'k:');
title('GA');

subplot(334)
N = hist(Bias500,x);
h= bar(x,N,1);
set(h,'FaceColor',[.7 .7 .7]);
axis square;
xlim([-3 3]);
h = pa_verline(nanmedian(Bias500),'k-');  set(h,'LineWidth',2);
pa_verline(0,'k:');
title('Bias500');

subplot(335)
N = hist(Bias1000,x);
h= bar(x,N,1);
set(h,'FaceColor',[.7 .7 .7]);
axis square;
xlim([-3 3]);
h = pa_verline(nanmedian(Bias1000),'k-'); set(h,'LineWidth',2);
pa_verline(0,'k:');
title('Bias1000');

subplot(336)
N = hist(BiasA,x);
h= bar(x,N,1);
set(h,'FaceColor',[.7 .7 .7]);
axis square;
xlim([-3 3]);
h = pa_verline(nanmedian(BiasA),'k-'); set(h,'LineWidth',2);
pa_verline(0,'k:');
title('BiasA');

%%
figure(4)
subplot(221)
x = [ERFF500 ERFF1000 ERFFA];
boxplot(x);
pa_horline(0);
title('ERFF');

subplot(222)
x = [G500 G1000 GA];
boxplot(x);
pa_horline(1);
title('GAIN');

subplot(223)
x = [Bias500 Bias1000 BiasA];
boxplot(x);
pa_horline(0);
title('Bias');




% figure
% x = X(:);
% y = Y(:);
% plot(x,y,'.');
% hold on
% pa_unityline
% 
% xi = -8:1:8;
% yi = pa_weightedmean(x,y,.5,xi);
% plot(xi,yi,'r-')
% axis square
% lsline

figure;
cla;
mxscal = max(max(Pool_P));
subplot(131)
imagesc(Pool_P);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(132)
imagesc(Pool_A500);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

subplot(133)
imagesc(Pool_A1000);
shading flat;
colorbar;
axis square;
caxis([-mxscal,mxscal]);

figure;
plot(G500,ERFF500,'k.');
hold on
plot(G1000,ERFF1000,'r.');
plot(GA,ERFFA,'b.');


axis square;
xlabel('Gain');
ylabel('Sensitivity contrast');
% lsline;
pa_horline;
pa_verline(1);
keyboard
function [D,g,b] = getdiff(STRFx,STRFy,indx1,indx2,methflag,dsp,fname)
y = STRFy(indx1,indx2);
x = STRFx(indx1,indx2);
y = y(:);
x = x(:);
% sel = x<0;
% x(sel) = -x(sel);
% y(sel) = -y(sel);


switch methflag
	case 1
% 		sel = x>(mean(x)+std(x));
		sel = x<1000;
		% Method 1
		stats     = regstats(y(sel),x(sel));
		g      = stats.beta(2);
		b      =  stats.beta(1);
		strf   = (STRFy-b)./g;
		p = stats.fstat.pval;
		% 				strf500 = stats.r;
		
	case 2
		% Method 2
		stats     = regstats(x,y);
		g      = stats.beta(2);
		b      = stats.beta(1);
		strf	= g*STRFy+b;
		p		= stats.fstat.pval;
		
	case 3
		% method 3
		g		= y\x;
		b      = 0;
		strf	 = g*STRFy;
		p		= 0;
	case 4
		% 				B			= B./rms(B(:));
		% 				B500		= B500./rms(B500(:));
		% 				B1000		= B1000./rms(B1000(:));
		% 				Strf500		= B500-B;
		% 				Strf1000	= B1000-B;
		% 				StrfA		= B1000-B500;
		% 				p = 0;
		
		case 5
% 		sel = x>(mean(x)+std(x));
		sel = x<1000;
		% Method 1
		stats = polyfit(x(sel),y(sel),2);
		stats
		g      = stats.beta(2);
		b      =  stats.beta(1);
		strf   = (STRFy-b)./g;
		p = stats.fstat.pval;
		% 				strf500 = stats.r;
		
		
end
% 		if methflag ~= 4
D   = strf - STRFx;
% 		end

if dsp
	y2 = strf(indx1,indx2); y2 = y2(:);
	subplot(321)
	cla;
	plot(x,y,'k.');
	hold on
	plot(x,y2,'r.');
	mx = max(abs([x; y]));
	xi = linspace(-mx,mx,10);
% yi = pa_weightedmean(x,y,mx/10,xi);
% plot(xi,yi,'b-','LineWidth',2)

	
	axis([-mx mx -mx mx])
% 	axis square;
	pa_unityline;
	lsline;
	title([g p])
	
	subplot(325)
	cla
	plot(STRFx(5,:),'k-');
	hold on
	plot(STRFy(5,:),'r-');
	tst = round(max(STRFx(5,:))-min(STRFx(5,:)));
	tst2 = round(max(STRFy(5,:))-min(STRFy(5,:)));
	title([tst tst2])
	
	subplot(323)
	imagesc(STRFx);
	mx = max(abs(STRFx(:)));
	caxis([-mx mx]);
	
	subplot(324)
	imagesc(STRFy);
	caxis([-mx mx]);
	
	subplot(326)
	title(fname)
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