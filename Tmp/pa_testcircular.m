
clear all
close all
clc
n = 55;
x = pi*(rand(n,1)-0.5)+1;
y = 1*(randn(n,1))+1*x;

sel = x<0;
x(sel) = x(sel)+2*pi;

sel = y<0;
y(sel) = y(sel)+2*pi;


xd = pa_rad2deg(x);
[mean(x) circ_mean(x)]
yd = pa_rad2deg(y);
[mean(y) circ_mean(y)]
rc = circ_corrcc(x,y);
r = corrcoef(x,y); r = r(2);
[r rc]
subplot(224)
plot(x,y,'.');
% axis([-pi pi -pi pi]);

subplot(221)
polar(x,ones(size(x)),'.');

subplot(222)
polar(y,ones(size(y)),'.');
axis square;

subplot(223)
polar([x y]',[ones(size(x)) 0.8*ones(size(y))]','.-');
axis square;

return
sel = y>=-pi & y<=pi;
r = corrcoef(x(sel),y(sel));
r = r(2)

sel = y>pi;
y(sel) = y(sel)-2*pi;

sel = y<-pi;
y(sel) = y(sel)+2*pi;

r = corrcoef(x,y);
r = r(2)

x = x+pi;
y = y+pi;
r = circ_corrcc(x,y);
r

plot(x,y,'.');
axis([0 2*pi 0 2*pi]);
axis square;
