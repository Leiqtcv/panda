close all hidden;
clear all hidden;

cd('C:\DATA\Maarten\Ripples');
fname = 'temporaldata';
load(fname);

whos
a = M.matrix;
cond = {'ReRh','ReLh','LeRh','LeLh'};
ncond = numel(cond);
col = summer(ncond+1);
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
