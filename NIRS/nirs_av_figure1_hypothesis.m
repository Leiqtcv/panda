function tmp

close all
clear all

%% Example simulation
Fs			= 10;
X			= zeros(1, 500); % 200 samples = 20 s;
X(100:300)	= 1; % 1 samples = 0.1 s
hemoA		= pa_nirs_hdrfunction([1 1 1],X);
hemoV		= pa_nirs_hdrfunction([0.3 1 1],X);
hemoAV		= pa_nirs_hdrfunction([1.3 1 1],X);

x		= 1:length(hemoA);
x		= x./Fs;

patch([x(100) x(100) x(300) x(300)]-10,[-2 2 2 -2],[.9 .9 .9]);
hold on
plot(x-10,hemoA,'Color',[0 0 .9],'LineWidth',2)
hold on
plot(x-10,hemoV,'Color',[0.8 0 0],'LineWidth',2)
plot(x-10,hemoAV,'Color',[0 0.7 0],'LineWidth',2)

% plot(x,X,'r-');
xlabel('time (s)');
ylabel('\Delta HbO_2');
ylim([-0.2 1.5])


axis square;
box off
set(gca,'XTick',0:10:30,'YTick',[],'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('Time re stimulus onset (s)','FontSize',12);
ylabel('[\Delta HbO_2]','FontSize',12);
axis square;
box off
text(2,-0.1,'stimulus epoch','HorizontalAlignment','left');
text(12,0.35,'visual','HorizontalAlignment','left');
text(12,1.05,'auditory','HorizontalAlignment','left');
text(40,0.95,'inhibitory','HorizontalAlignment','right');
text(40,1.3,'additive','HorizontalAlignment','right');
text(40,1.15,'sub-additive','HorizontalAlignment','right');
text(40,1.45,'supra-additive','HorizontalAlignment','right');

pa_horline(1.3,'k-');
pa_horline(1,'k-');

print('-depsc','-painters',mfilename);
