function tmp
close all
clear all

cd('/Users/marcw/DATA/Student/Patty/Level/PA-MW-2015-02-12');

load('PA-MW-2015-02-12-0001'); %load saccade parameters
SupSac1 = pa_supersac(Sac,Stim,3,1); % select SND2
load('PA-MW-2015-02-12-0002'); %load saccade parameters
SupSac2 = pa_supersac(Sac,Stim,3,1); % select SND2

SupSac = [SupSac1;SupSac2];
% intensity
int = SupSac(:,29); % intensity
uint = unique(int);
nint = numel(uint);

% bandpass
bp = SupSac(:,30); % intensity
ubp = unique(bp);
nbp = numel(ubp);

%% Plot data and regression
BetaAz = NaN(nint,nbp); % initialization
BetaEl = BetaAz;
BetaAzSE = BetaAz; % initialization
BetaElSE = BetaAz;
for ii = 1:nint
	for jj = 1:nbp
		sel = int==uint(ii) & bp == ubp(jj);
		[baz,bel] = plotgraph(SupSac(sel,:));
		BetaAz(ii,jj) = baz.beta(2); % gain/slope
		BetaEl(ii,jj) = bel.beta(2);
		
		BetaAzSE(ii,jj) = baz.tstat.se(2);
		BetaElSE(ii,jj) = bel.tstat.se(2);
	end
end


%% Nice graphs
for ii = 1:2
	figure(1)
	subplot(1,2,ii)
	axis square
	axis([-100 100 -100 100])
	set(gca,'TickDir','out','XTick',-90:30:90,'YTick',-90:30:90);
	box off;
	lsline;
	pa_unityline;
end
% keyboard

%% Overview
col = pa_statcolor(3,[],[],[],'def',1);
for ii = 1:nbp
	
	figure(2);
	subplot(1,2,1)
	hp(ii) = pa_errorpatch(uint,BetaAz(:,ii),BetaAzSE(:,ii),col(ii,:));
	hold on
	axis square
	
	box off
	ylim([0 1.6]);
	xlim([10 60]);
	
	set(gca,'TickDir','out');
	subplot(1,2,2)
	
	pa_errorpatch(uint,BetaEl(:,ii),BetaElSE(:,ii),col(ii,:));
	axis square
	
	box off
	set(gca,'TickDir','out');
	ylim([-0.2 1.2]);
	xlim([10 60]);
	
end

subplot(121)
legend(hp,{'BB','HP','LP'},'Location','SE')
xlabel('Intensity (au)');
ylabel('Stimulus-response gain');
title('Azimuth');

subplot(122)
legend(hp,{'BB','HP','LP'},'Location','SE')
xlabel('Intensity (au)');
ylabel('Stimulus-response gain');
title('Elevation');


% 
print('-dpng','-r300',mfilename);
%% Helper functions
function [baz,bel] = plotgraph(SupSac)

x = SupSac(:,23);
y = SupSac(:,8);
figure(1)
subplot(121)
plot(x,y,'.');
hold on
baz = regstats(y,x,'linear','all');

x = SupSac(:,24);
y = SupSac(:,9);
subplot(122)
plot(x,y,'.');
hold on
bel = regstats(y,x,'linear','all');
