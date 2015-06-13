clear all
close all
clc

dBRef	=	94;

load('HumLoc0MicStraight')
S	=	DAC1ToneGain(:,[1 16]);

load('HumLoc0MicUp')
U	=	DAC1ToneGain(:,[1 16]);

D	=	(dBRef + 20*log10(S(:,2))) - (dBRef + 20*log10(U(:,2)));

[yfit,stats]	=	fitline(U(:,1),D);

Coef	=	dround(stats.Coef);
R2		=	dround(stats.R2);

% save('DirexCoef','stats')

figure(1)
clf
subplot(2,1,1)
h(1) = plot(S(:,1),dBRef + 20*log10(S(:,2)),'kx-');
hold on
h(2) = plot(U(:,1),dBRef + 20*log10(U(:,2)),'rx-');
set(gca,'xlim',[0 42000],'xtick',0:10000:40000,'xticklabel',0:10:40,'ylim',[10 80]);
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('frequency [kHz]')
ylabel('magnitude [dB]')
legend(h,'straight','up')

subplot(2,1,2)
plot(U(:,1),D,'kx-')
hold on
plot(U(:,1),yfit,'r-')
set(gca,'xlim',[0 42000],'xtick',0:10000:40000,'xticklabel',0:10:40);%,'ylim',[10 80]);
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
title(['y= ' num2str(Coef(1)) 'x+' num2str(Coef(2)) '; R^2= ' num2str(R2)])
xlabel('frequency [kHz]')
ylabel('\Delta straight/up [dB]')
