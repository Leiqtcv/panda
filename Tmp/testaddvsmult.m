%% Clean
close all
clear all

t = 1:5000;
t = t/1000;
f = 24;
w = 2*pi*f;
p = sin(w.*t);

%% Additive
ba = t.^2/10;
aa = p+ba;
subplot(221)
plot(t,p,'k-');
hold on
plot(t,ba,'b-')
plot(t,aa,'r-')
axis square
box off
ylim([-5 5])
title('Additive = true');
xlabel('Time');
ylabel('Signal');

%% Multiplicative
bm = t.^2/30+1;
am = p.*bm;
subplot(222)
plot(t,p,'k-');
hold on
plot(t,bm,'b-')
plot(t,am,'r-')
axis square
box off
ylim([-5 5]);
title('Multiplicative = true');
xlabel('Time');
ylabel('Signal');

%% Noise
sd = .1;
n = sd*randn(size(t));
sd = 10;
%% Test additive model
aan = aa+n;
amn = am+n;
s = 70;
bmodeladd = smooth(aan,s)-smooth(p,s);
bmodelmult = smooth(aan,s)./smooth(p,s);

subplot(223)
% plot(t,bmodelmult,'r-')
hold on
% plot(t,bmodeladd,'k-','LineWidth',2)
hold on
axis square;
ylim([-10 10])

Eadd = aan-(bmodeladd'+p);
Ladd = sum(-2*log(normpdf(Eadd,0,sd)));

plot(t,Eadd,'k-')
Emult = aan-(bmodelmult'.*p);
Lmult = sum(-2*log(normpdf(Emult,0,sd)));
plot(t,Emult,'r-');

str = {['Error Additive Model (black) = ' num2str(sum(Eadd.^2),3)];['Error Multiplicative Model (red) = ' num2str(sum(Emult.^2),3)];...
	['D = ' num2str(Ladd-Lmult)]};
title(str)
xlabel('Time');
ylabel('Error');
Ladd
Lmult

%% Test multiplicative model
aan = aa+n;
amn = am+n;

bmodeladd = smooth(amn,s)-smooth(p,s);
bmodelmult = smooth(amn,s)./smooth(p,s);

subplot(224)
% plot(t,bmodelmult,'r-')
hold on
% plot(t,bmodeladd,'k-','LineWidth',2)
hold on
axis square;
ylim([-10 10])

Eadd = amn-(bmodeladd'+p);
Ladd = sum(-2*log(normpdf(Eadd,0,sd)));
Emult = amn-(bmodelmult'.*p);
Lmult = sum(-2*log(normpdf(Emult,0,sd)));
plot(t,Eadd,'k-')
plot(t,Emult,'r-');
xlabel('Time');
ylabel('Error');
Ladd
Lmult

str = {['Error Additive Model (black) = ' num2str(sum(Eadd.^2),3)];['Error Multiplicative Model (red) = ' num2str(sum(Emult.^2),3)];...
	['D = ' num2str(Ladd-Lmult)]};
title(str)

pa_datadir;
print('-depsc','-painter',mfilename);

