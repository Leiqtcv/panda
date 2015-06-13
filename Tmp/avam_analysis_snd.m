close all
clear all

cd('/Users/marcw/DATA/Student/Marleen/DATA')
fname = 'MH-RG-2015-01-09-0005';

% cd('/Users/marcw/DATA/Student/Marleen/DATA')
% fname = 'RG-MH-2015-01-09-0003';
% cd('/Users/marcw/DATA/Student/Marleen')
% fname = 'RG-MH-2015-01-08-0003';

[e,c,l] = pa_readcsv(fname);
nchan = e(:,8);
nsample = c(1,6);
dat = pa_loaddat(fname,nchan,nsample);

whos dat
btn = squeeze(dat(:,:,4));
trialn	= l(:,1);
mod		= l(:,5);
attr	= l(:,11); 
sel		= mod==3;
trialn	= trialn(sel);
mod		= mod(sel);
attr	= attr(sel);

mod
ntrials = size(btn,2);
BTN = NaN(ntrials,1);
for ii = 1:ntrials
sndfile = ['/Users/marcw/DATA/Student/Marleen/snd' num2str(attr(ii),'%03i') '.wav'];
	sndfile
	[snd,fs] = wavread(sndfile);
	tsnd = 1:length(snd);
	tsnd = tsnd/fs*1000;
	d = 1000*[0;diff(btn(:,ii))];
	
	sel = d>2*std(d);
	idx = find(sel,1','first');
	
	t	= 1:length(d);
	ax(1) = subplot(312);
	plot(t,d)
	hold on
	plot(t(sel),d(sel),'ro-');
	pa_horline(2*std(d));
	pa_verline(t(idx));
	hold off
	
	ax(2) = subplot(311);
	plot(t,btn(:,ii))
	pa_verline(t(idx));
	drawnow

	ax(3) = subplot(313);
	plot(tsnd,snd);
	
	linkaxes(ax,'x');
	drawnow
	BTN(ii) = idx;
% 	pause
end

%%


% Periods of the sounds: 15   136   258   379   500 ms
% snd0xx = 15
% snd1xx = 136
% snd2xx = 258
% snd3xx = 379
% snd5xx = 500 
% Dynamic onset: 500:100:1500 % so 11 IDs
% sndxx1 = 500
% sndxx2 = 600

x = attr;
x = 400+100*rem(x,100);
per = round((attr-rem(attr,100))/100);
per = per+1;
per(per==6) = 5;
uper = linspace(15,500,5);
per = uper(per);
rt = BTN/1017*1000-x;

mu = NaN(size(uper));
for ii = 1:numel(uper)
	sel = per==uper(ii) & rt'>100;
	
	mu(ii) = 1./mean(1./rt(sel));
	sd(ii) = 1./std(1./rt(sel))/sqrt(sum(sel))/2; % SE/2

end

close all
subplot(121)
hist(rt,-400:100:2000);
axis square
subplot(122)
errorbar(uper/1000,mu,sd,'k.');
hold on
plot(uper/1000,mu,'ko','MarkerFaceColor','w');
set(gca,'xtick',round(uper)/1000);
xlim([-0.1 0.6])
axis square
lsline
box off

x = per;
y = rt;
b = regstats(y,x,'linear','all');

b.beta
str = ['RT = ' num2str(b.beta(2),'%0.2f') '+' num2str(round(b.beta(1)))];
title(str)
