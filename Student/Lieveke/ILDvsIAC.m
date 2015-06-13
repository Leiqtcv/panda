function tmp
close all
clear all
clc

%% Sounds
Fs          = 48828.125;
N2          = round(0.01*Fs);
N1			= N2*5;
snd1 = randn(N1,1);
snd2 = randn(N2,1);
snd2 = repmat(snd2,5,1);
snd1 = snd1';
snd2 = snd2';

snd1 = gengwn;
snd2 = gengwn;
snd2 = snd1;
% snd1 = snd1+0.1*randn(size(snd1));
% snd2 = snd2+0.1*randn(size(snd2));

%% Locations
x		= 0:90;
ILD		= NaN(size(x));
IPD		= ILD;
IAC		= ILD;
dLoc	= ILD;
ILDsnd1 = ILD;
for i = 1:length(x)
	% 	for i =1
	loc1 = x(i);
	loc2 = -x(i);
	ITD1 = round(loc1*700/90 *10^-6 *Fs);
	ITD2 = round(loc2*700/90 *10^-6 *Fs);
	ILD1 = 10^((loc1*20/90)/20);
	ILDsnd1(i) = loc1*20/90;
	ILD2 = 10^((loc2*20/90)/20);
	ITD1 = zeros(size(ITD1));
	ITD2 = zeros(size(ITD2));
	

	%% ILD
	SND1 = [ILD1^.5*snd1;snd1/ILD1^.5];
	% 	ILD1 = 20*log10(getrms(SND1(1,:))./getrms(SND1(2,:)));
	if ITD1>0
		indx = [ITD1:length(SND1) 1:(ITD1-1)];
		SND1 = [SND1(1,:);SND1(2,indx)];
	end
	SND2 = [ILD2^.5*snd2;snd2/ILD2^.5];
	if abs(ITD2)>0
		ITD2 = abs(ITD2);
		indx = [ITD2:length(SND2) 1:(ITD2-1)];
		SND2 = [SND2(1,indx);SND2(2,:)];
	end
	% 	ILD2 = 20*log10(getrms(SND2(1,:))/getrms(SND2(2,:)));

	SNDl = SND1(1,:)+SND2(1,:);
	SNDr = SND1(2,:)+SND2(2,:);
	rmsl = getrms(SNDl);
	rmsr = getrms(SNDr);
	ILD3 = 20*log10(rmsl/rmsr);
% 	c=xcorr(SNDl,SNDr,40);
% 	[m,IPD(i)] = max(c);

	%% IAC
	r1 = corrcoef(SND1(1,:),SND1(2,:));
	IAC1 = r1(2).^2;
	r2 = corrcoef(SND2(1,:),SND2(2,:));
	IAC2 = r2(2).^2;
	r3 = corrcoef(SNDl,SNDr);
	IAC3 = r3(2).^2;

	dLoc(i) = loc1-loc2;
	ILD (i) = ILD3;
	IAC(i) = IAC3;
end

subplot(121)
h1=plot(dLoc,ILD,'k-');
hold on
% h1=plot(dLoc,IPD,'b-');
h2=plot(dLoc,ILDsnd1,'r');
axis square
ylim([-20 20]);
xlim([min(dLoc) max(dLoc)]);
xlabel('\Delta Azimuth (deg)');
ylabel('ILD');

legend([h1,h2],{'Double';'Single'},'Location','SE');

subplot(122)
plot(dLoc,IAC,'k-');
axis square
ylim([0 1.1]);
xlim([min(dLoc) max(dLoc)]);
xlabel('\Delta Azimuth (deg)');
ylabel('Interaural Correlation');
set(gca,'YAxisLocation','right');

return
%% Graph
subplot(321)
plot(SND1(1,:));
ylim([-20 20]);
axis square
title(['ILD = ' num2str(ILD1)]);

subplot(322)
plot(SND1(2,:));
ylim([-20 20]);
axis square
title(['IAC = ' num2str(IAC1)]);

subplot(323)
plot(SND2(1,:));
ylim([-20 20]);
axis square
title(['ILD = ' num2str(ILD2)]);

subplot(324)
plot(SND2(2,:));
ylim([-20 20]);
axis square
title(['IAC = ' num2str(IAC2)]);

subplot(325)
plot(SNDl);
ylim([-20 20]);
axis square
title(['ILD = ' num2str(ILD3,2)]);

subplot(326)
plot(SNDr);
ylim([-20 20]);
axis square
title(['IAC = ' num2str(IAC3)]);

% SND1 =
% figure

function rms = getrms(snd)

rms = sqrt(mean(snd.^2));