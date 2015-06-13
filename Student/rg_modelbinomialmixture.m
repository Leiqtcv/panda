function tmp
close all
clear all
clc

% py = -90:90;
% p = normpdf(py,0,30);
% p1 = normpdf(py,-20,10);
% p2 = normpdf(py,+20,10);
% p = p1+p2;
% p = p./sum(p);
% 
% subplot(121)
% plot(py,p)
% 
% % return
% n = 10000;
% 
% 
% y = randpdf(p,py,[n,1]);
% hold on
% N = hist(y,py);
% N = N./sum(N);
% plot(py,N,'r-');
% 
% x = pa_rndval(-90,90,[n,1]);
% whos y x
% y = x+y;
% 
% 
% subplot(122)
% plot(x,y,'.');

%% stim
xi = -50:5:50;
nrep = 100;
x = repmat(xi,1,nrep);
n = numel(x);
n = 1000;
x = round(30*randn([1,n])/5)*5;

% randpdf(pst,xi,[1 1]);
%% prior
p1	= normpdf(xi,-30,2);
p2	= normpdf(xi,+30,2);
p	= p1+p2;
p	= p./sum(p);

%% Likelihood
Y	= NaN(size(x));
for ii = 1:n
	y = x(ii)+5*randn(1);
	l = normpdf(xi,y,5);
	pst = p.*l;
	pst = pst./sum(pst);
	Y(ii) = randpdf(pst,xi,[1 1]);
% 	 = y
% 	plot(xi,l)
% 	drawnow
end
	
figure(666)
clf
% plot(x,Y,'.');
plot2dhist(x',Y',xi')

sel = abs(x)<=10;
b = regstats(Y(sel),x(sel),'linear','beta');
title(b.beta(2));
% keyboard
function plot2dhist(x,y,xi)

N		= hist3([x y],{xi xi});
col		= pa_statcolor(64,[],[],[],'def',6);
col		= col(:,[3 2 1]);
colormap(col)



		imagesc(xi,xi,N')
		axis square
		box off
		set(gca,'TickDir','out','YDir','normal');
		axis([-90 90 -90 90])
		cax = caxis;
		caxis([0 cax(end)]);
		% colorbar
		pa_unityline;
