function pp_resultsfigure5

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all
clc

% pa_datadir('RG-MW-2011-12-02')
fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
	'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
	'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
	'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
	'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
	'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
	'RG-MW-2011-09-27-0001';'RG-MW-2011-09-27-0002';'RG-MW-2011-09-27-0003';'RG-MW-2011-09-27-0004';...
	'RG-MW-2011-09-21-0001';'RG-MW-2011-09-21-0002';'RG-MW-2011-09-21-0003';'RG-MW-2011-09-21-0004';...
	};
conditions = [3 2 3 1,...
	3 2 1 3,...
	2 3 1 3,...
	2 3 1 3,...
	3 1 3 2,...
	1 3 3 2,...
	5 7 4 6,...
	10 8 11 9,...
	]; % 1 - 10 deg, 2 - 29 deg, 3 - 50 deg, 4 - 50 deg

% for
% nsets = length(fnames);
rng = [10 30 50 30 45 60 75 10 20 35 50];
% nrng = length(rng);
% Gain = NaN(nsets,nrng,2);
GainAz = NaN(numel(rng),1);
GainEl = GainAz;
GainElse = GainAz;
GainAzse = GainAz;
for ii = 1:numel(rng)
	sel = conditions==ii;
	sum(sel)
	fname = fnames(sel);
	nfiles = length(fname);
	SS = [];
	for jj = 1:nfiles
		file = fname{jj};
		pa_datadir(['Prior\' file(1:end-5)]);
		load(file); %load fnames(ii) = load('fnames(ii)');
		SupSac      = pa_supersac(Sac,Stim,2,1);
		SS          = [SS;SupSac];
	end
	sel = abs(SS(:,23))<=10 & abs(SS(:,24))<=10;
	if ismember(ii,4:7)
		sel = abs(SS(:,23))<=15 & abs(SS(:,24))<=15;
	end
	TarAz       = SS(sel,23);
	TarEl       = SS(sel,24);
	ResAz       = SS(sel,8);
	ResEl       = SS(sel,9);
	RT          = SS(sel,5);
	
	%     pa_loc(TarAz,ResAz);
	if ii<8
		sel = TarAz>0;
		b = regstats(ResAz(sel),TarAz(sel),'linear','beta');
		ResAz(sel) = ResAz(sel)-b.beta(1);
		sel = TarAz<0;
		b = regstats(ResAz(sel),TarAz(sel),'linear','beta');
		ResAz(sel) = ResAz(sel)-b.beta(1);
		
		b = regstats(ResAz,TarAz,'linear',{'beta','r','tstat'});
		GainAz(ii) = b.beta(2);
		GainAzse(ii) = b.tstat.se(2);
		%     else
		%           GainAz(ii) = b.beta(2);
		%     GainAzse(ii) = b.tstat.se(2);
	end
	
	b = regstats(ResEl,TarEl,'linear',{'beta','r','tstat'});
	GainEl(ii) = b.beta(2);
	GainElse(ii) = b.tstat.se(2);
	
	Prior(ii) = std(TarEl);
end
% mx = max(GainAz(1:3));
% GainAz(1:3) = GainAz(1:3)./mx;
% mx = max(GainAz(4:7));
% GainAz(4:7) = GainAz(4:7)./mx;
%
% mx = max(GainEl(1:3));
% GainEl(1:3) = GainEl(1:3)./mx;
% GainElse(1:3) = GainElse(1:3)./mx;
%
% mx = max(GainEl(4:7));
% GainEl(4:7) = GainEl(4:7)./mx;
% GainElse(4:7) = GainElse(4:7)./mx;
% mx = max(GainEl(8:11));
% GainEl(8:11) = GainEl(8:11)./mx;
% GainElse(8:11) = GainElse(8:11)./mx;

mx = max(GainEl);
GainEl = GainEl/mx;
[rng,indx] = sort(rng);
GainAz = GainAz(indx);
GainEl = GainEl(indx);
GainElse = GainElse(indx);
Prior = Prior(indx);


X = [0 rng];
Y = [0.4 GainEl'];
P = polyfit(X,Y,4);
XP = 1:80;
YP = polyval(P,XP);
% subplot(122)
rnd = +randn(size(rng));
rnd = zeros(size(rng));
rnd(1) = -1;
rnd(5) = -1;
rnd(8) = -1;
subplot(121)
errorbar(rng+rnd,GainEl,GainElse,'ko','MarkerFaceColor','w','LineWidth',2);
hold on
plot(rng+rnd,GainEl,'k:','MarkerFaceColor','w','LineWidth',2)
plot(XP,YP,'r-','LineWidth',2);
axis([0 80 0 1.7]);

axis square;
box off
xlabel('Range (deg)');
ylabel('Elevation gain');
x = 1:.1:50;
% Y = testfun(10,x);
% plot(x,Y,'r-','LineWidth',2);
beta		= nlinfit(Prior,GainEl',@testfun,30)
% beta = sqrt(beta)
Y = testfun(beta,x);

plot(x/0.58,Y,'b-','LineWidth',2);

Y = testfun(6.3,x);
plot(x/0.58,Y,'g-','LineWidth',2);

%% Prior fit
subplot(122)
plot(Prior,GainEl','ko','MarkerFaceColor','w')
hold on
x = 5:.1:50;
beta		= nlinfit(Prior,GainEl',@testfun,30^2)
% beta = sqrt(beta)
Y = testfun(beta,x);
plot(x,Y,'b-','LineWidth',2);
axis square;
xlim([4 20]);
function Y = testfun(beta,X)
P	= X;
G	= 1-beta.^2./P.^2;
Y	= G;

