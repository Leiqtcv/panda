close all hidden;
clear all hidden;
clc;

cd('E:\DATA\Test\Lateralization');
fname = 'temporaldata';
load(fname);

%% Mean over subjects & conditions
a		= M.matrix;
mf		= M.modulation;
MF		= squeeze(mf(1,:,1));
mu		= mean(squeeze(mean(a)),2);

nsubjects	= size(a,3);
ncond		= size(a,1);
nf			= size(a,2);
for ii = 1:nsubjects
	y = squeeze(a([1 4],:,ii));
	% sel= y(1,:)<680 & y(2,:)<680;
	sel = MF<64;
	
	subplot(3,3,ii)
	plot(1./MF(sel),y(:,sel),'o','MarkerFaceColor','w');
	axis square;
	box off;
	xlim([-0.1 0.6]);
	lsline
end
figure
nsubjects	= size(a,3);
ncond		= size(a,1);
nf			= size(a,2);
hold on
Y = [];
for ii = 1:nsubjects
	y = squeeze(a(:,:,ii))';
	y = y-mean(y(:))+mean(mu(:));
	x = squeeze(mf(:,:,ii))';
	% 	plot(x,y,'o','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8]);
	% removed: subject's median
	% added subjects' median
	Y = [Y y];
end

for ii = 1:nf
	% 		y = squeeze(a(:,ii,:))';
	y = Y(ii,:);
	x = squeeze(mf(1,ii,1))';
	y = round(y/25)*25;
	uy = unique(y);
	ny = numel(uy);
	N = hist(y,uy);
	for jj = 1:ny
		if N(jj)>0
			plot(x,uy(jj),'ko','Color',[.8 .8 .8],'MarkerFaceColor',[.8 .8 .8],'MarkerSize',3*N(jj))
		end
	end
	
end

plot(MF,mu,'ko-','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);

x		= 1./squeeze(M.modulation(:));
y		= squeeze(a(:));
b		= regstats(y,x,'linear','all');
x		= MF;
rtpred	= b.beta(2)./x+b.beta(1);
plot(x,rtpred,'r-','LineWidth',2);


axis square;
set(gca,'TickDir','out','XScale','log','XTick',MF,'XTickLabel',MF);
box off
ylim([300 600])
xlim([1 128]);
xlabel('Modulation frequency (Hz)');
ylabel('Reaction time (ms)');
str = ['RT = ' num2str(b.beta(2)/1000,2) '/w + ' num2str(b.beta(1)/1000,3) ' s'];
title(str);
print('-depsc','-painter',[mfilename 'a']);


%% Mean over subjects, separate for conditions
figure
cond	= {'ReRh','ReLh','LeRh','LeLh'};
ncond	= numel(cond);
col		= summer(ncond+1);
% col = winter(ncond+1);
str = cell(ncond,1);
for ii = 1:ncond
	
	
	mf = M.modulation;
	% mf = squeeze(mf(1,:,1));
	sel		= strcmpi(cond,cond(ii));
	
	rt		= squeeze(a(sel,:,:));
	mf		= squeeze(mf(sel,:,:));
	mu		= mean(rt,2);
	u		= repmat(mean(rt),size(rt,1),1);
	sd		= 1.96*std(rt-u,[],2)./size(rt,2);
	
	
	T		= 1./mf(:);
	y		= rt(:);
	x		= T(:);
	
	% indx = 1:5;
	% T = T(indx,:);
	% y = y(indx,:);
	% x = x(indx,:);
	
	b		= regstats(y(:),x(:),'linear','all');
	b
	b.beta
	b.tstat
	b.tstat.se
	n = numel(x)
	t			= tinv(1-0.05/2,n-1);
	ci = t*b.tstat.se
	rtpred = b.beta(2)./mf(:,1)+b.beta(1);
	
	T		= 1./mf(:);
	u		= repmat(mean(rt),size(rt,1),1);
	y		= rt(:)-u(:);
	x		= T(:);
	n			= numel(x);
	Sxx			= sum((x-mean(x)).^2);
	Syy			= sum((y-mean(y)).^2);
	Sxy			= sum((x-mean(x)).*(y-mean(y)));
	SSE			= Syy-b.beta(2)*Sxy;
	Syx			= sqrt(SSE/(n-2));
	Xx			= unique(x); %predict Y for X=4.
	Yy			= b.beta(1)+b.beta(2).*(Xx); %Y predicted from regression line.
	SSX			= sum((x-mean(x)).^2);
	alpha		= 0.1;
	h			= 1/n + ((Xx-mean(x)).^2)/SSX;
	tn2			= tinv(1-alpha/2,n-2); %tn-2 - t critical
	interval	= tn2.*Syx.*sqrt(h);
	
	% 	c=0.2*ii*[1 1 1]
	
	% subplot(2,2,ii);
	subplot(121)
	errorbar(mf(:,1),mu,sd,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(ii,:))
	hold on
	set(gca,'TickDir','out','XScale','log','XTick',mf(:,1),'XTickLabel',mf(:,1));
	box off
	axis square;
	ylim([300 600])
	
	subplot(122)
	% 	plot(mf(:,1),rtpred,'o-','LineWidth',2,'Color',0.2*ii*[1 1 1])
	% 	pa_errorpatch(mf(:,1),rtpred,interval/2,0.2*ii*[1 1 1])
	x = mf(:,1);
	errorbar(x,rtpred,interval'/2,'ko-','LineWidth',2,'MarkerFaceColor','w','Color',col(ii,:));
	hold on
	
	str{ii} = [cond{ii} ': RT = ' num2str(b.beta(2)/1000,2) '/w + ' num2str(b.beta(1)/1000,3) ' s'];
	% 	title(str);
end
subplot(122)
legend(str)
axis square;
set(gca,'TickDir','out','XScale','log','XTick',mf(:,1),'XTickLabel',mf(:,1));
box off
ylim([300 600])
xlabel('Modulation frequency (Hz)');
ylabel('Reaction time (ms)');

subplot(121)
legend(cond)
axis square;
set(gca,'TickDir','out','XScale','log','XTick',mf(:,1),'XTickLabel',mf(:,1));
box off
ylim([300 600])
xlabel('Modulation frequency (Hz)');
ylabel('Reaction time (ms)');

print('-depsc','-painter',mfilename);
