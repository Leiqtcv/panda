
close all
clear all;


k = 5;
theta = 2.9;

n = 10000;
R = 1.5*gamrnd(k,theta,[n 1]);
x = 0:100;
NR = hist(R,x);


subplot(121);
N = hist(R,x);
stairs(x,N,'k-');
xlim([0 80]);
p = prctile(R,[25 75]);
iqr = p(2)-p(1);
title(iqr);
axis square
box off
xlabel('IQR');
ylabel('N');




nrep = 10000;
samples = round(logspace(0.5,2,20));
nsamples = numel(samples);
iqrn = NaN(nrep,nsamples);
M = NaN(nsamples,1);

for jj = 1:nsamples
	for ii = 1:nrep
		R = 1.5*gamrnd(k,theta,[samples(jj) 1]);
		p = prctile(R,[25 75]);
		iqrn(ii,jj) = p(2)-p(1);
	end
	M(jj) = mean(iqrn(:,jj)-iqr);
end
subplot(122)
plot(samples,M-(M(end)),'ko-','MarkerFaceColor','w','LineWidth',2);
box off
axis square;
xlabel('Number of samples');
ylabel('Standard deviation in IQR');
% % subplot(223)
% Nhigh = hist(iqrhigh,x);
% Nlow = hist(iqrlow,x);
% 
% Nhigh = Nhigh/sum(Nhigh);
% Nlow = Nlow/sum(Nlow);
% NR = NR/sum(NR);
% 
% stairs(NR,'k-');
% hold on
% stairs(Nhigh,'b-');
% stairs(Nlow,'r-');
% xlim([0 80]);
