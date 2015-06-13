close all

cd('/Users/marcw/DATA/tmp/MW-RG-2014-12-05');
fnames = {'MW-RG-2014-12-05-0001';'MW-RG-2014-12-05-0002'};

for jj = 1:2
	fname = fnames{jj};
hrtf = pa_readhrtf(fname);
[e,c,l] = pa_readcsv(fname);
sel = l(:,5) == 2;
lvl = l(sel,10);
hrtf = squeeze(hrtf);

hrtf = hrtf(1:8000,:);

[m,n] = size(hrtf);

whos hrf lvl
figure(1)
subplot(121)
plot(hrtf)
axis square
box off
xlabel('Time (samples)');
ylabel('Signal amplitude (V)');
hrtf = hrtf(2000:8000,:);
set(gca,'TickDir','out');


mu = NaN(n,1);
sd = mu;
for ii = 1:n
	a = hrtf(:,ii);
	mu(ii) = mean(a);
	sd(ii) = std(a);
end
subplot(122)
plot(mu,sd,'o')
hold on
end
lsline
axis square;
box off
xlabel('Mean (V)');
ylabel('Standard deviation  (V)');
set(gca,'TickDir','out');

rmu = round(mu*100)/100;
[umu,i,j] = unique(rmu);
[lvl(i) umu]
text(umu,[0.12 0.12 0.12]/1000,{'45';'55';'65'});
text(umu,[1.0 1.0 1.0]/1000,{'45';'55';'65'});
legend({'Old RP2';'Replacement RP2'},'Location','Best');

subplot(121)
text([4000 4000 4000],[0.7 0.8 0.9],{'45';'55';'65'});


print('-depsc','-painters',mfilename);