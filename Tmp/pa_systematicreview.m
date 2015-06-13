%% Frissen 2003
% Figure 3, Experiment 2
% es = [2.19 1.75 2.11 1.49];
% mm2deg = es./[21.514 17.145 20.726 14.565];
% mm2deg = mean(mm2deg);
% se = [3.454 3.15 5.029 4.801]*mm2deg;
% [es; se]/9;

% Figure 3, Experiment 2
% es = [2.28 2.24 1.64 1.22];
% mm2deg = es./[22.225 21.946 16.079 11.964];
% mm2deg = mean(mm2deg);
% se = [4.648 4.013 4.725 3.556]*mm2deg
% [es; se]/9

%% Radeau & bertelson estimation SE
% se = mean([9.82 7.06 9.21 8.42 9.35 7.29])/sqrt(24)
% se/15

%% Woods & recanzone 2004
% mm2deg = 31/30.692;
% [13.582 2.999]*mm2deg
% [8.966 3.704]*mm2deg

%% Frissen 2012
% % % Figure 1, Experiment 1
% es = [9.239 16.982 9.894 15.699];
% mm2deg = 100/70.141;
% es = es*mm2deg
% se = [9.864 10.836 6.259 7.068]*mm2deg/2

%% Frissen 2012
% % Figure 2, Experiment 2
% es = [8.803 22.908 24.556];
% mm2deg = 100/66,595;
% es = es*mm2deg
% se = [9.358 15.096 11.119]*mm2deg/2

%% Forrest Plot
close all hidden;
clear all hidden;

cd('E:\DATA\Audiovisual\SystematicReview');
[N,T,R] = xlsread('systematicventriloquistaftereffect.xlsx');

[~,indx] = sort(N(:,1),'descend');
ES = N(indx,6);
SE = N(indx,7);
w = 1./(SE.^2);
yrs = N(indx,1);

muES = nansum(w.*ES)./nansum(w);
seES = 1/sqrt(nansum(w));

nstudy = length(ES);
Y = (1:length(ES))';
X = [ES-SE ES+SE];
Y2 = [Y Y];

sel = yrs==2013;
subplot(121)
[uyrs,indx] = unique(yrs);
for ii = 1:2:length(indx)-1
	x = [-30 120 120 -120];
	y = [indx(ii) indx(ii) indx(ii+1) indx(ii+1)]+0.5;
	hp = patch(x,y,[.9 .9 1]);
	set(hp,'EdgeColor','none');
end
hold on
axis square;
box off
xlim([-30 120]);
xlabel('Ventriloquist Affereffect shift (%)');
set(gca,'XTick',0:20:100);
ylim([-1 nstudy+1]);
set(gca,'YTick',flipud(indx),'YTickLabel',flipud(uyrs));

h = pa_verline(0,'k-'); set(h,'LineWidth',2);
h = pa_verline(muES,'b-'); set(h,'LineWidth',2);
plot([muES-1.96*seES muES+1.96*seES],[0 0],'b-','LineWidth',2);
plot(muES,0,'bd','MarkerFaceColor',[.7 .7 1],'MarkerSize',10,'LineWidth',2);

hold on
plot(X(~sel,:)',Y2(~sel,:)','b-','LineWidth',2)
hold on
plot(ES(~sel),Y(~sel),'bs','MarkerFaceColor',[.7 .7 1])

plot(X(sel,:)',Y2(sel,:)','g-','LineWidth',2)
hold on
plot(ES(sel),Y(sel),'go','MarkerFaceColor',[.7 1 .7])


subplot(122);
plot(ES,log2(SE),'bo','MarkerFaceColor',[.7 .7 1])
axis square
box off
xlabel('Aftereffect size (%)');
ylabel('Standard error (%)');
xlim([-30 120]);
h = pa_verline(0,'k-'); set(h,'LineWidth',2);
h = pa_verline(muES,'b-'); set(h,'LineWidth',2);

print('-depsc','-painter',mfilename);