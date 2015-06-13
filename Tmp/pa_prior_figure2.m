function pa_prior_figure2

close all
clear all

%% Subjects
% Some data-sets do not work: removed them them
fnames = {'JR-RG2-2012-02-22-0001';...
	'JR-RG-2012-03-08-0001';...
	'RG-JR2-2012-02-28-0001';...
	'RG-HH-2012-03-01-0001';...
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
	'RG-BK-2012-03-21-0001';...
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
	
	rng = 7;
	cntr = 1:rng:max(X);
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x	= Y(sel,:);
		y	= Z(sel,:);
		
		%% Correct for high gain for low range
		% Visual check, needs to be automized and checked!
		sel		= abs(x)<15;
		y(sel)	= y(sel)/1.3;
		
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	
	GG(ii,:) = G; %#ok<*AGROW>
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
	
	rng = 15;
	cntr = 1:rng:max(X);
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);

		%% Correct for high gain for low range
		% Visual check, needs to be automized and checked!		
		sel = abs(x)<15;
		y(sel) = y(sel)/1.3;
		
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	

	
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
	
	rng = 5;
	cntr = 1:rng:max(X);
	G = NaN(size(cntr));
	S = G;
	P = G;
	for jj = 1:length(cntr)
		sel = X<=cntr(jj)+rng/2 & X>cntr(jj)-rng/2;
		x = Y(sel,:);
		y = Z(sel,:);
		%% Correct for high gain for low range
		% Visual check, needs to be automized and checked!
		sel		= abs(x)<15;
		y(sel)	= y(sel)/1.3;
		
		b = regstats(y,x,'linear',{'beta','r'});
		G(jj) = b.beta(2);
		S(jj) = std(b.r);
		P(jj) = std(x);
	end
	

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

