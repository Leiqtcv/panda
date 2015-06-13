function nirs_av_figure7_glm
close all
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files

load('allglmbetas');

%%
figure(8)
for fi = 1:4
	subplot(2,2,fi)
	axis([-4 4 -4 4])
	pa_unityline;
	pa_horline;
end
%%
y	= [BETA.b];
A	= y(1,2:2:end);
AV	= y(2,2:2:end);
V	= y(3,2:2:end);
[H,P,CI] = ttest(A,V)
[P,H] = ranksum(A,V)

%% save csvfile
pa_datadir;
headers = {'A','V','AV'};
y = [A' V' AV'];
csvwrite_with_headers('beta.csv',y,headers);


% return
% keyboard
%%
figure(9)
clf
subplot(231)
% x		= A(1:end-5);
% y		= V(1:end-5);
x		= A;
y		= V;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end);
y		= V(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',10)
xlim([-1 2]);
ylim([ -1 2]);
set(gca,'XTick',-0.5:0.5:1.5,'YTick',-0.5:0.5:1.5,'TickDir','out',...
'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A,\DeltaHbO_2]','FontSize',12);
ylabel('\beta[V,\DeltaHbO_2]','FontSize',12);
title([]);
axis square;
pa_errorpatch([10 30],[-1.5 -1.5],[3 3]);
box off
h = pa_text(0.1,0.9,'A');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-');
% pa_regline(bCI.beta,'r-')

subplot(233)
x		= A(1:end-5)+V(1:end-5);
y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
x		= A+V;
y		= A+V+AV;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end)+V(end-4:end);
y		= A(end-4:end)+V(end-4:end)+AV(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',10)
xlim([-1 4]);
ylim([ -1 4]);
set(gca,'XTick',0:1:3,'YTick',-0:1:3,'TickDir','out',...
'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A+V,\DeltaHbO_2]','FontSize',12);
ylabel('\beta[A+V+AV,\DeltaHbO_2]','FontSize',12);
title([]);
axis square;
pa_errorpatch([10 30],[-1.5 -1.5],[3 3]);
box off
h = pa_text(0.1,0.9,'C');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-');
% pa_regline(bCI.beta,'r-')


% x		= A(1:end-5)+V(1:end-5);
% y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
% sel =x<1;
% b		= regstats(y(sel),x(sel),'linear','beta');
% plot([0 1],b.beta(2)*[0 1]+b.beta(1),'k-');
% % pa_regline(b.beta,'m-')
% x		= A(1:end-5)+V(1:end-5);
% y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
% sel =x>1;
% b		= regstats(y(sel),x(sel),'linear','beta');
% plot([1 3],b.beta(2)*[1 3]+b.beta(1),'k-');

subplot(232)
% x		= A(1:end-5);
% y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
x		= A;
y		= A+V+AV;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end);
y		= A(end-4:end)+V(end-4:end)+AV(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',10)
xlim([-1 2]);
ylim([ -1 2]);
set(gca,'XTick',-0.5:0.5:1.5,'YTick',-0.5:0.5:1.5,'TickDir','out',...
'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A,\DeltaHbO_2]','FontSize',12);
ylabel('\beta[A+V+AV,\DeltaHbO_2]','FontSize',12);
title([]);
axis square;
pa_errorpatch([10 30],[-1.5 -1.5],[3 3]);
box off
h = pa_text(0.1,0.9,'B');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-');
% pa_regline(bCI.beta,'r-')

%%


x		= A;
[P,~,stats] = signrank(x);
M(1,:)		= [P stats.zval stats.signedrank];

x		= V;
[P,~,stats] = signrank(x);
M(2,:)		= [P stats.zval stats.signedrank];

x		= AV;
[P,~,stats] = signrank(x);
M(3,:)		= [P stats.zval stats.signedrank];

x		= A;
y		= V;
[P,~,stats] = signrank(x,y);
M(4,:)		= [P stats.zval stats.signedrank];

x		= A;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(5,:)		= [P stats.zval stats.signedrank];

x		= V;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(6,:)		= [P stats.zval stats.signedrank];

x		= A+V;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(7,:)		= [P stats.zval stats.signedrank];



x		= A;
y		= V;
[P,~,stats] = signrank(x,y);
M(1,:)		= [P stats.zval stats.signedrank];

x		= A;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(2,:)		= [P stats.zval stats.signedrank];

y		= AV;
[P,~,stats] = signrank(y);
M(3,:)		= [P stats.zval stats.signedrank];


x		= A(end-4:end);
y		= A(1:end-5);
[P,~,stats] = ranksum(x,y);
if ~isfield(stats,'zval')
	stats.zval = NaN;
end
D(1,:)		= [P stats.zval stats.ranksum];

x		= V(end-4:end);
y		= V(1:end-5);
[P,~,stats] = ranksum(x,y);
if ~isfield(stats,'zval')
	stats.zval = NaN;
end
D(2,:)		= [P stats.zval stats.ranksum];

x		= AV(end-4:end);
y		= AV(1:end-5);
[P,~,stats] = ranksum(x,y);
if ~isfield(stats,'zval')
	stats.zval = NaN;
end
D(3,:)		= [P stats.zval stats.ranksum];

%%
y	= [BETA.b];
A	= y(1,1:2:end);
AV	= y(2,1:2:end);
V	= y(3,1:2:end);

subplot(234)
x		= A;
y		= V;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end);
y		= V(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',10)
xlim([-2 1]);
ylim([ -2 1]);
set(gca,'XTick',-1.5:0.5:0.5,'YTick',-1.5:0.5:0.5,'TickDir','out',...
'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A,\DeltaHbR]','FontSize',12);
ylabel('\beta[V,\DeltaHbR]','FontSize',12);
title([]);
axis square;
box off
h = pa_text(0.1,0.9,'D');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-')
% pa_regline(bCI.beta,'r-')

subplot(236)
x		= A(1:end-5)+V(1:end-5);
y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
x		= A+V;
y		= A+V+AV;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end)+V(end-4:end);
y		= A(end-4:end)+V(end-4:end)+AV(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',10)
xlim([-4 1]);
ylim([ -4 1]);
set(gca,'XTick',-3:1:0,'YTick',-3:1:0,'TickDir','out',... 
'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A+V,\DeltaHbR]','FontSize',12);
ylabel('\beta[A+V+AV,\DeltaHbR]','FontSize',12);
title([]);
axis square;
box off
h = pa_text(0.1,0.9,'F');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-')

subplot(235)
x		= A;
y		= A+V+AV;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end);
y		= A(end-4:end)+V(end-4:end)+AV(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','k','MarkerSize',10)
xlim([-2 1]);
ylim([ -2 1]);
set(gca,'XTick',-1.5:0.5:0.5,'YTick',-1.5:0.5:0.5,'TickDir','out',...
'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A,\DeltaHbR]','FontSize',12);
ylabel('\beta[A+V+AV,\DeltaHbR]','FontSize',12);
title([]);
axis square;
box off
h = pa_text(0.1,0.9,'E');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-')

%%

%%

x		= A;
[P,~,stats] = signrank(x);
M(8,:)		= [P stats.zval stats.signedrank];

x		= V;
[P,~,stats] = signrank(x);
M(9,:)		= [P stats.zval stats.signedrank];

x		= AV;
[P,~,stats] = signrank(x);
M(10,:)		= [P stats.zval stats.signedrank];

x		= A;
y		= V;
[P,~,stats] = signrank(x,y);
M(11,:)		= [P stats.zval stats.signedrank];

x		= A;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(12,:)		= [P stats.zval stats.signedrank];

x		= V;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(13,:)		= [P stats.zval stats.signedrank];

x		= A+V;
y		= A+V+AV;
[P,~,stats] = signrank(x,y);
M(14,:)		= [P stats.zval stats.signedrank];



x		= A(end-4:end);
y		= A(1:end-5);
[P,~,stats] = ranksum(x,y);
if ~isfield(stats,'zval')
	stats.zval = NaN;
end
D(4,:)		= [P stats.zval stats.ranksum];

x		= V(end-4:end);
y		= V(1:end-5);
[P,~,stats] = ranksum(x,y);
if ~isfield(stats,'zval')
	stats.zval = NaN;
end
D(5,:)		= [P stats.zval stats.ranksum];

x		= AV(end-4:end);
y		= AV(1:end-5);
[P,~,stats] = ranksum(x,y);
if ~isfield(stats,'zval')
	stats.zval = NaN;
end
D(6,:)		= [P stats.zval stats.ranksum];

%%
pa_datadir
print('-depsc','-painters',mfilename);
print('-dpng','-painters',mfilename);

%%
xlswrite('Wilcoxon.xlsx',M,'Modality')
% xlswrite('Wilcoxon.xlsx',D,'Cohort')

%%
keyboard
