function pa_prior_sound_block_figure1

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all


subjects	= {'MW';'LJ';'HH';'RO';'RG'};
nsubjects	= length(subjects);
gain		= NaN(5,3);
s = NaN(nsubjects,3);
s2 = s;
gain2 = gain;
for ii = 1:nsubjects
	subject = subjects{ii};
	figure
	[B,B2]	= getgain(subject);
	g		= [B.beta];
	g2		= [B2.beta];
	for jj = 1:3
		s(ii,jj)		= std(B(jj).r);
		s2(ii,jj)		= std(B2(jj).r);
	end
	
	gain(ii,:) = g(2,:);
	gain2(ii,:) = g2(2,:);
end

musd	= median(s);
musd2	= median(s2);

mu		= mean(gain);
mx		= max(mu); % Normalize for maximum gain: is this correct/allowed?
mu		= mu/mx;
sd		= std(gain)/sqrt(5); % sd = standard error!
musd	= 0.58*musd/mx; % Correct for boxcar vs gaussian: is this correct/allowed?

mu2		= mean(gain2);
mx2		= max(mu2);
mu2		= mu2/mx2;
sd2		= std(gain2)/sqrt(5);
musd2	= 0.58*musd2/mx;

rng		= [10 30 50];
figure
subplot(122)
PredG = 1-musd.^2./(rng*0.58).^2; % Better fit than std = block
plot(rng+.5,PredG,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',[.7 .7 .7]);
hold on
errorbar(rng,mu,sd,'ko-','MarkerFaceColor','w','LineWidth',2,'MarkerSize',10);

subplot(121)
PredG2 = 1-musd2.^2./(rng*0.58).^2; % Better fit than std = block
plot(rng+.5,PredG2,'rs-','LineWidth',2,'MarkerFaceColor','w','Color',[.7 .7 .7]);
hold on
errorbar(rng,mu2,sd2,'ks-','MarkerFaceColor','w','LineWidth',2,'MarkerSize',10);

subplot(122)
for ii = 1:2
	subplot(1,2,ii)
	ylim([0.5 1.2]);
	hold on
	axis([0 60 0.6 1.1]);
	axis square;
	box off
	xlabel('Experimental \Sigma (deg)');
	ylabel('Response gain');
	set(gca,'YTick',0.7:0.1:1,'XTick',10:10:50);
	pa_horline(1);
	if ii==1
		title('Azimuth');
	else
		title('Elevation');
	end
end
pa_datadir;
print('-depsc','-painter',mfilename);

function [B,B2] = getgain(subject)

switch subject
	case 'MW'
		fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
			'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
			'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
			'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
			'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
			'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
			};
		conditions = [3 2 3 1,...
			3 2 1 3,...
			2 3 1 3,...
			2 3 1 3,...
			3 1 3 2,...
			1 3 3 2
			];
	case  'LJ'
		fnames = {    'RG-LJ-2011-12-14-0001';'RG-LJ-2011-12-14-0002';'RG-LJ-2011-12-14-0003';'RG-LJ-2011-12-14-0004';...
			'RG-LJ-2011-12-14-0005';'RG-LJ-2011-12-14-0006';'RG-LJ-2011-12-14-0007';'RG-LJ-2011-12-14-0008';...
			'RG-LJ-2011-12-21-0001';'RG-LJ-2011-12-21-0002';'RG-LJ-2011-12-21-0003';'RG-LJ-2011-12-21-0004';...
			'RG-LJ-2011-12-21-0005';'RG-LJ-2011-12-21-0006';'RG-LJ-2011-12-21-0007';'RG-LJ-2011-12-21-0008';...
			'RG-LJ-2012-01-10-0001';'RG-LJ-2012-01-10-0002';'RG-LJ-2012-01-10-0003';'RG-LJ-2012-01-10-0004';...
			'RG-LJ-2012-01-10-0005';'RG-LJ-2012-01-10-0006';'RG-LJ-2012-01-10-0007';'RG-LJ-2012-01-10-0008';...
			'RG-LJ-2012-01-17-0001';'RG-LJ-2012-01-17-0002';'RG-LJ-2012-01-17-0003';'RG-LJ-2012-01-17-0004';...
			};
		conditions = [
			2 3 1 3,...
			1 2 3 3,...
			3 1 3 2 ...
			3 2 1 3 ...
			2 3 1 3 ...
			3 3 1 2 ...
			3 2 3 1 ...
			];
	case 'RO'
		fnames = {
			'RG-RO-2011-12-12-0001';'RG-RO-2011-12-12-0002';'RG-RO-2011-12-12-0003';'RG-RO-2011-12-12-0004';...
			'RG-RO-2011-12-12-0005';'RG-RO-2011-12-12-0006';'RG-RO-2011-12-12-0007';'RG-RO-2011-12-12-0008';...
			'RG-RO-2012-01-11-0001';'RG-RO-2012-01-11-0002';'RG-RO-2012-01-11-0003';'RG-RO-2012-01-11-0004';...
			'RG-RO-2012-01-11-0005';'RG-RO-2012-01-11-0006';'RG-RO-2012-01-11-0007';'RG-RO-2012-01-11-0008';...
			'RG-RO-2012-01-18-0001';'RG-RO-2012-01-18-0002';'RG-RO-2012-01-18-0003';'RG-RO-2012-01-18-0004';...
			'RG-RO-2012-01-18-0005';'RG-RO-2012-01-18-0006';'RG-RO-2012-01-18-0007';'RG-RO-2012-01-18-0008';...
			};
		conditions = [
			3 2 1 3,...
			1 3 2 3,...
			3 1 3 2 ...
			3 2 1 3 ...
			2 3 1 3 ...
			3 1 3 2 ...
			];
	case 'HH'
		fnames = {
			'RG-HH-2011-11-24-0001';'RG-HH-2011-11-24-0002';'RG-HH-2011-11-24-0003';'RG-HH-2011-11-24-0004';...
			'RG-HH-2011-12-12-0001';'RG-HH-2011-12-12-0002';'RG-HH-2011-12-12-0003';'RG-HH-2011-12-12-0004';...
			'RG-HH-2012-01-09-0001';'RG-HH-2012-01-09-0002';'RG-HH-2012-01-09-0003';'RG-HH-2012-01-09-0004';...
			'RG-HH-2012-01-09-0005';'RG-HH-2012-01-09-0006';'RG-HH-2012-01-09-0007';'RG-HH-2012-01-09-0008';...
			'RG-HH-2012-01-13-0001';'RG-HH-2012-01-13-0002';'RG-HH-2012-01-13-0003';'RG-HH-2012-01-13-0004';...
			'RG-HH-2012-01-13-0005';'RG-HH-2012-01-13-0006';'RG-HH-2012-01-13-0007';'RG-HH-2012-01-13-0008';...
			};
		conditions = [
			3 2 3 1,...
			1 3 3 2,...
			2 3 1 3 ...
			3 3 1 2 ...
			2 3 1 3 ...
			3 1 2 3 ...
			];
	case 'RG'
		fnames = {
			'MW-RG-2011-12-08-0001';'MW-RG-2011-12-08-0002';'MW-RG-2011-12-08-0003';'MW-RG-2011-12-08-0004';...
			'MW-RG-2011-12-08-0005';'MW-RG-2011-12-08-0006';'MW-RG-2011-12-08-0007';'MW-RG-2011-12-08-0008';...
			'MW-RG-2012-01-12-0001';'MW-RG-2012-01-12-0002';'MW-RG-2012-01-12-0003';'MW-RG-2012-01-12-0004';...
			'MW-RG-2012-01-12-0005';'MW-RG-2012-01-12-0006';'MW-RG-2012-01-12-0007';'MW-RG-2012-01-12-0008';...
			};
		conditions = [
			2 2 3 1,...
			3 3 1 3,...
			3 2 3 1 ...
			2 3 1 3 ...
			];
end

%% Pool data
col = ['r';'g';'b';];
for ii = 1:3
	sel         = conditions == ii;
	condfnames  = fnames(sel);
	nsets       = length(condfnames);
	SS			= [];
	for jj = 1:nsets
		fname		= condfnames{jj};
		pa_datadir(['Prior\' fname(1:end-5)]);
		load(fname); %load fnames(ii) = load('fnames(ii)');
		SupSac  = pa_supersac(Sac,Stim,2,1);
		x		= SupSac(:,24);
		y		= SupSac(:,9);
		b		= regstats(y,x,'linear','beta');
		y		= y-b.beta(1);
		SupSac(:,9) = y;
		SS		= [SS;SupSac]; %#ok<AGROW>
	end
	
	sel				= abs(SS(:,24))<11 & abs(SS(:,23))<11; % should hold for both!
	Y				= SS(sel,9);
	X				= SS(sel,24);
	B(ii)			= regstats(Y,X,'linear',{'beta';'r'}); %#ok<AGROW>
	
	Y				= SS(sel,8);
	X				= SS(sel,23);
	B2(ii)			= regstats(Y,X,'linear',{'beta';'r'}); %#ok<AGROW>
	subplot(1,3,ii)
	
	uE		= unique(X);
	nE		= numel(uE);
	muE		= NaN(size(uE));
	sdE		= muE;
	for kk = 1:nE
		sel		= X == uE(kk);
		muE(kk) = mean(Y(sel));
		sdE(kk) = std(Y(sel))./sqrt(sum(sel));
	end
	hold on
	errorbar(uE,muE,sdE,'ko-','MarkerFaceColor',col(ii,:));
	axis square;
	axis([-20 20 -20 20]);
	pa_unityline;
	title(B(ii).beta(2));
end

g = NaN(3,1);
for ii = 1:3
	g(ii) = B(ii).beta(2);
end

% Correct for mean gain: is this correct/allowed?
for ii = 1:3
	B(ii).beta(2) = B(ii).beta(2)/mean(g); %#ok<AGROW>
	B(ii).r = B(ii).r/mean(g); %#ok<AGROW>
end

g = NaN(3,1);
for ii = 1:3
	g(ii) = B2(ii).beta(2);
end

for ii = 1:3
	B2(ii).beta(2) = B2(ii).beta(2)/mean(g); %#ok<AGROW>
	B2(ii).r = B2(ii).r/mean(g); %#ok<AGROW>
end

