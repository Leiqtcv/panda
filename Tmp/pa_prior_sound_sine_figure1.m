function pa_prior_sound_sine_figure1

close all
clear all


% RG1, RG2, RGcomb, JR1, JR2, HH, RO, TH, MW, CK, BK, DM, LJ
fnames = {'JR-RG2-2012-02-22-0001';...
	'JR-RG-2012-03-08-0001';...
	'RG-JR2-2012-02-28-0001';...
	'RG-HH-2012-03-01-0001';...
% 	'RG-TH-2012-03-13-0001';...
	'RG-CK-2012-03-20-0001';...
	'RG-DM-2012-03-16-0001';...
	'RG-BK-2012-03-20-0001';...
	};
plotgain5(fnames);

fnames = {'JR-RG-2012-02-23-0001';...
	'TH-RG-2012-03-09-0001';...
	'RG-JR-2012-02-29-0001';...
	'RG-RO-2012-03-13-0001';...
	'RG-MW-2012-03-21-0001';...
	% 				  'RG-TH-2012-03-15-00001';...
	'RG-BK-2012-03-21-0001';...
% 	'RG-CK-2012-03-22-0001';...
	'RG-DM-2012-03-26-0001'};

plotgain4(fnames);

  fnames = {'JR-RG-2012-02-22-0001';'JR-RG-2012-03-07-0001';'RG-JR-2012-02-28-0001';...
                  'RG-JR-2012-03-13-0001';'RG-HH-2012-02-29-0001';'RG-RO-2012-03-08-0001';...
                  'RG-TH-2012-03-09-0001';'RG-MW-2012-03-13-0001';'RG-CK-2012-03-13-0001';...
                  'RG-BK-2012-03-13-0001';'RG-DM-2012-03-15-0001'};
plotgain6(fnames);

for ii = 1:3
	subplot(1,3,ii)
	pa_text(0.05,0.95,char(96+ii));
	ylim([0 1.2])
axis square;
xlabel('Trial');
ylabel('Response Gain');
box off;

	
end
%% Print
pa_datadir;
print('-depsc','-painter',mfilename);
return
%%
fnames = {'JR-RG-2012-02-23-0001';...
	'TH-RG-2012-03-09-0001';...
	'RG-JR-2012-02-29-0001';...
	'RG-RO-2012-03-13-0001';...
	'RG-MW-2012-03-21-0001';...
	% 				  'RG-TH-2012-03-15-00001';...
	'RG-BK-2012-03-21-0001';...
% 	'RG-CK-2012-03-22-0001';...
	'RG-DM-2012-03-26-0001'};

plotgain(fnames);

fnames = {'JR-RG2-2012-02-22-0001';...
	'JR-RG-2012-03-08-0001';...
	'RG-JR2-2012-02-28-0001';...
	'RG-HH-2012-03-01-0001';...
	'RG-TH-2012-03-13-0001';...
	'RG-CK-2012-03-20-0001';...
	'RG-DM-2012-03-16-0001';...
	'RG-BK-2012-03-20-0001';...
	};
plotgain2(fnames);

  fnames = {'JR-RG-2012-02-22-0001';'JR-RG-2012-03-07-0001';'RG-JR-2012-02-28-0001';...
                  'RG-JR-2012-03-13-0001';'RG-HH-2012-02-29-0001';'RG-RO-2012-03-08-0001';...
                  'RG-TH-2012-03-09-0001';'RG-MW-2012-03-13-0001';'RG-CK-2012-03-13-0001';...
                  'RG-BK-2012-03-13-0001';'RG-DM-2012-03-15-0001'};
plotgain3(fnames);


function plotgain3(fnames)
for ii = 1:length(fnames)
	fname = fnames{ii};
	pa_datadir(['\Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	X           = SupSac(:,1);
	Y           = SupSac(:,24);
	Z           = SupSac(:,9);
	n = length(Y);
	rng = 10;
	cntr = 1:rng:n;
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	figure(5)
	subplot(3,4,ii)
	plot(cntr,G,'ko-','MarkerFaceColor','w')
	hold on
	ylim([0 1.5]);
	sigma       = 5;
	
	% function [Gain,Mu] = getdynamics(X,Y,Z,sigma)
	
	XI              = X;
	[Gain,se,xi]    = pa_weightedregress(X,Y,Z,sigma*2,XI);
	n       = 400; %
	x       = 1:n;
	freq	= 0.01;
	sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
	sd      = sd/max(sd);
	
	mx              = max(X);
	
	figure(5)
	subplot(3,4,ii)
	plot(x,sd,'r','LineWidth',2);
	hold on
	pa_errorpatch(xi,Gain,se);
	xlim([1 mx])
	
	title ('Elevation')
	GG(ii,:) = G;
	SS(ii,:) = S;
	PP(ii,:) = P;
end

G2 = GG;
muG = mean(GG);
sdG = std(GG)/sqrt(size(GG,1))/10;

muS = mean(SS);
muP = mean(PP);

whos muG sdG
figure(666)
subplot(133)
errorbar(cntr+rng/2,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(x,sd,'r','LineWidth',2);

PredG = 1-muS.^2./(muP).^2; % Better fit than std = block
plot(cntr+rng/2,PredG,'ko-','Color',[.7 .7 .7],'MarkerFaceColor','w');
xlim([0 n]);
ylim([0 1.5])
axis square;
xlabel('Trial');
ylabel('Response Gain');
box off;

function plotgain2(fnames)
for ii = 1:length(fnames)
	fname = fnames{ii};
	pa_datadir(['\Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	X           = SupSac(:,1);
	Y           = SupSac(:,24);
	Z           = SupSac(:,9);
	n = length(Y);
	rng = 15;
	cntr = 1:rng:n;
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	figure(4)
	subplot(3,3,ii)
	plot(cntr,G,'ko-','MarkerFaceColor','w')
	hold on
	ylim([0 1.5]);
	sigma       = 5;
	
	% function [Gain,Mu] = getdynamics(X,Y,Z,sigma)
	
	XI              = X;
	[Gain,se,xi]    = pa_weightedregress(X,Y,Z,sigma*2,XI);
	n       = 400; %
	x       = 1:n;
	freq	= 0.005;
	sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
	sd      = sd/max(sd);
	
	mx              = max(X);
	
	figure(4)
	subplot(3,3,ii)
	plot(x,sd,'r','LineWidth',2);
	hold on
	pa_errorpatch(xi,Gain,se);
	xlim([1 mx])
	
	title ('Elevation')
	GG(ii,:) = G;
	SS(ii,:) = S;
	PP(ii,:) = P;
end

G2 = GG;
muG = mean(GG);
sdG = std(GG)/sqrt(size(GG,1))/10;

muS = mean(SS);
muP = mean(PP);

whos muG sdG
figure(666)
subplot(132)
errorbar(cntr+rng/2,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(x,sd,'r','LineWidth',2);

PredG = 1-muS.^2./(muP).^2; % Better fit than std = block
plot(cntr+rng/2,PredG,'ko-','Color',[.7 .7 .7],'MarkerFaceColor','w');
xlim([0 n]);
ylim([0 1.5])
axis square;
xlabel('Trial');
ylabel('Response Gain');
box off;

function plotgain(fnames)
for ii = 1:length(fnames)
	fname = fnames{ii};
	pa_datadir(['\Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	X           = SupSac(:,1);
	Y           = SupSac(:,24);
	Z           = SupSac(:,9);
	n = length(Y);
	rng = 25;
	cntr = 1:rng:n;
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	figure(3)
	subplot(3,3,ii)
	plot(cntr,G,'ko-','MarkerFaceColor','w')
	hold on
	ylim([0 1.5]);
	sigma       = 5;
	
	% function [Gain,Mu] = getdynamics(X,Y,Z,sigma)
	
	XI              = X;
	[Gain,se,xi]    = pa_weightedregress(X,Y,Z,sigma*2,XI);
	n       = 400; %
	x       = 1:n;
	freq	= 0.002;
	sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
	sd      = sd/max(sd);
	
	mx              = max(X);
	
	figure(3)
	subplot(3,3,ii)
	plot(x,sd,'r','LineWidth',2);
	hold on
	pa_errorpatch(xi,Gain,se);
	xlim([1 mx])
	
	title ('Elevation')
	GG(ii,:) = G;
	SS(ii,:) = S;
	PP(ii,:) = P;
end

muG = mean(GG);
sdG = std(GG)/sqrt(size(GG,1))/10;

muS = mean(SS);
muP = mean(PP);

whos muG sdG
figure(666)
subplot(131)
errorbar(cntr+rng/2,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(x,sd,'r','LineWidth',2);

PredG = 1-muS.^2./(muP).^2; % Better fit than std = block
plot(cntr+rng/2,PredG,'ko-','Color',[.7 .7 .7],'MarkerFaceColor','w');
xlim([0 n]);
axis square;
xlabel('Trial');
ylabel('Response Gain');
box off;

function plotgain5(fnames)
for ii = 1:length(fnames)
	fname = fnames{ii};
	pa_datadir(['\Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	X       = SupSac(:,1);
	Y       = SupSac(:,24);
	Z       = SupSac(:,9);
	freq	= 0.005;
	X		= mod(X,1/(2*freq));

	n = length(Y);
	rng = 7;
	cntr = 1:rng:max(X);
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		sel = abs(x)<15;
		y(sel) = y(sel)/1.3;
		
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end

	n       = 400; %
	x       = 1:n;
	sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
	sd      = sd/max(sd);
	

	GG(ii,:) = G;
	SS(ii,:) = S;
	PP(ii,:) = P;
end


muG		= mean(GG);
sdG		= std(GG)/sqrt(size(GG,1));
muS		= mean(SS);
muP		= mean(PP);
PredG	= 1-muS.^2./(muP).^2; % Better fit than std = block

figure(667)
subplot(132)
plot(cntr+rng/2,PredG,'ko-','Color',[.7 .7 .7],'MarkerFaceColor','w');
hold on
errorbar(cntr+rng/2,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
xlim([min(cntr+rng/2)-5 max(cntr+rng/2)+5]); 


function plotgain4(fnames)
for ii = 1:length(fnames)
	fname = fnames{ii};
	pa_datadir(['\Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	X       = SupSac(:,1);
	Y       = SupSac(:,24);
	Z       = SupSac(:,9);
	freq	= 0.002;
	X		= mod(X,1/(2*freq));

	n = length(Y);
	rng = 15;
	cntr = 1:rng:max(X);
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		sel = abs(x)<15;
		y(sel) = y(sel)/1.3;
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	
	% function [Gain,Mu] = getdynamics(X,Y,Z,sigma)
	
	n       = 400; %
	x       = 1:n;
	sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
	sd      = sd/max(sd);
	
	GG(ii,:) = G;
	SS(ii,:) = S;
	PP(ii,:) = P;
end

muG		= mean(GG);
sdG		= std(GG)/sqrt(size(GG,1));
muS		= mean(SS);
muP		= mean(PP);
PredG	= 1-muS.^2./(muP).^2; % Better fit than std = block

figure(667)
subplot(131)
plot(cntr+rng/2,PredG,'ko-','Color',[.7 .7 .7],'MarkerFaceColor','w');
hold on
errorbar(cntr+rng/2,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
xlim([min(cntr+rng/2)-5 max(cntr+rng/2)+5]); 


function plotgain6(fnames)
for ii = 1:length(fnames)
	fname = fnames{ii};
	pa_datadir(['\Prior\' fname(1:end-5)]);
	load(fname); %load fnames(ii) = load('fnames(ii)');
	SupSac      = pa_supersac(Sac,Stim,2,1);
	
	X       = SupSac(:,1);
	Y       = SupSac(:,24);
	Z       = SupSac(:,9);
	freq	= 0.01;
	X		= mod(X,1/(2*freq));

	n = length(Y);
	rng = 5;
	cntr = 1:rng:max(X);
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		sel = abs(x)<15;
		y(sel) = y(sel)/1.3;
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	
	% function [Gain,Mu] = getdynamics(X,Y,Z,sigma)
	
	n       = 400; %
	x       = 1:n;
	sd		= 40*sin(2*pi*freq*x+0.5*pi).^2+5;
	sd      = sd/max(sd);
	
	GG(ii,:) = G;
	SS(ii,:) = S;
	PP(ii,:) = P;
end

muG		= mean(GG);
sdG		= std(GG)/sqrt(size(GG,1));
muS		= mean(SS);
muP		= mean(PP);
PredG	= 1-muS.^2./(muP).^2; % Better fit than std = block

figure(667)
subplot(133)
plot(cntr+rng/2,PredG,'ko-','Color',[.7 .7 .7],'MarkerFaceColor','w');
hold on
errorbar(cntr+rng/2,muG,sdG,'ko-','MarkerFaceColor','w','LineWidth',2);
xlim([min(cntr+rng/2)-5 max(cntr+rng/2)+5]); 

