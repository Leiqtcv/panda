function tmp
home;
close all;

%% Generative model

% cd('E:\MATLAB');
pa_datadir;



s		= -70:70;
x		= -70:70;
sigma_p	= 12;
sigma_x	= 10;
S		= 25; % actual location


n = 10000;
cntr = -90:5:90;
figure(1)
kk= 0;
X = sigma_p*randn(n,1);
Y = sigma_x*randn(n,1)+X;

flag = 0;
if flag
for ii = 1:100
	subplot(211)
	cla
	x = [(1:ii)' (1:ii)'];
	y = [X(1:ii)';Y(1:ii)']';
	plot(x,y,'k-','Color',[.7 .7 .7]);
	hold on
	plot(1:ii,X(1:ii),'k.','Color',[.7 .7 .7]);
	
	plot(1:ii,Y(1:ii),'k.');
	
	xlim([1 100]);
	ylim([-60 60]);
	box off
	axis off
	
	subplot(212)
	cla
	plot(1:ii,sqrt((Y(1:ii)-X(1:ii)).^2),'k-');
	hold on
	xlim([1 100]);
	ylim([0 60]);
	box off
	axis off
	
	drawnow
end
end
gain = 0:0.01:2;
ngain = numel(gain);

figure
gain = 0:0.1:1.5;
ngain = numel(gain);
E = gain;
for ii = [1:ngain ngain:-1:1]
	E(ii) = mean(sqrt((gain(ii)*Y-X).^2));
end
[mn,indx]= min(E);
gain(indx)
kk = 0;
for ii = [1:1:ngain ngain:-1:1]
	x = X(1:100);
	y = Y(1:100);
	

	subplot(131)
	cla
	cntr = -100:100;
	ps		= normpdf(cntr,0,sigma_p);
	ps		= 10*ps/max(ps);
	Xp = [0 0 ps]-60;
	Yp = [0 max(cntr) cntr];
	h = patch(Yp,Xp,'k'); set(h,'FaceColor',[.7 .7 .7]);
	hold on
	
	ps		= normpdf(cntr,0,sigma_p);
	ps		= 10*ps/max(ps);
	Xp = [0 0 ps]-60;
	Yp = [0 max(cntr) cntr];
	h = patch(Xp,Yp,'k'); set(h,'FaceColor',[.7 .7 .7]);
	
% 	plot(x,y,'k.','MarkerFaceColor',[.7 .7 .7],'LineWidth',1,'Color',[.7 .7 .7]);
	hold on
	plot(x,gain(ii)*y,'k.','MarkerFaceColor','k','LineWidth',1,'Color','k');
	
	box off
	axis square;
	axis([-60 60 -60 60]);
	h = pa_unityline('k-');set(h,'LineWidth',1);
	h = pa_horline(2*sigma_p,'k-');set(h,'LineWidth',1);
	h = pa_horline(-2*sigma_p,'k-');set(h,'LineWidth',1);
	axis off
	
	b = regstats(gain(ii)*y,x,'linear','beta');
	b = b.beta;
	h = pa_regline(b,'k-');
	
	subplot(132)
	cla
	plot(gain,E,'k-','LineWidth',2);
	hold on
	axis square;
	box off
	xlabel('Response gain');
	ylabel('Mean localization error (deg)');
	ylim([0 max(E)+1]);
	plot(gain(ii),E(ii),'ko','MarkerFaceColor','w','LineWidth',2)
	[~,indx] = min(E);
	h = pa_verline(gain(indx),'k-');
	set(h,'LineWidth',2,'Color',[.6 .6 .6]);
	h = pa_verline(1,'k-');
	set(h,'LineWidth',2);
	axis off
	drawnow
	
% 	pause(.5)
	if gain(ii)==1;
			kk = kk+1;
			pa_datadir;
			print('-depsc',[mfilename num2str(kk)]);	
	end
	
	if gain(ii)==gain(indx);
			kk = kk+1;
			pa_datadir;
			print('-depsc',[mfilename num2str(kk)]);	
	end
end






return
ps		= normpdf(s,0,sigma_p);
pxs		= normpdf(x,S,sigma_x);

subplot(245)
h = patch(x,pxs,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',[0 S],'YTick',[]);
set(gca,'XTickLabel',{'0';'S'});
axis square
axis([-70 70 0 0.05]);
mx = nanmax(pxs);
plot(S+[0 0],[0 mx],'k--');
plot(S+[0 sigma_x],0.60655*[mx mx],'k-');
text(S+sigma_x/2,0.60655*mx,'\sigma_X','HorizontalAlignment','center','VerticalAlignment','top');
xlabel('Internal representation X (deg)');
ylabel({'Probability'})
title({'Noise distribution';'P(X|S)'})


%% Inference model
figure(1)
s		= -70:70;
x		= -70:70;
sigma_p	= 12;
sigma_s	= 15;
S		= 25; % actual location
ps		= normpdf(s,0,sigma_p);
pxs		= normpdf(s,S,sigma_s);

subplot(242)
h		= patch(s,ps,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',0,'YTick',[]);
axis square
axis([-70 70 0 0.05]);
xlabel('Hypothesized location S (deg)');
ylabel({'Probability'})
title({'Internal prior';'P_i(S)'})
mx = max(ps);
plot([0 sigma_p],0.60655*[mx mx],'k-');
plot([0 0],[0 mx],'k--');
text(0+sigma_p/2,0.60655*mx,'\sigma_{P_i}','HorizontalAlignment','center','VerticalAlignment','top');
h = pa_horline(0.01,'k-');
set(h,'Color',[.5 .5 .5],'LineWidth',2);
text(0,1.1*mx,'Central','HorizontalAlignment','center');
text(40,0.013,'Uniform','HorizontalAlignment','center');

subplot(246)
h = patch(x,pxs,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',[0 S],'YTick',[]);
set(gca,'XTickLabel',{'0';'X'});
axis square
axis([-70 70 0 0.05]);
mx = nanmax(pxs);
plot(S+[0 0],[0 mx],'k--');
plot(S+[0 sigma_x],0.60655*[mx mx],'k-');
text(S+sigma_x/2,0.60655*mx,'\sigma_S','HorizontalAlignment','center','VerticalAlignment','top');
xlabel('Hypothesized location S (deg)');
ylabel({'Probability'})
title({'Likelihood';'L(S)'})


a	= sigma_p^2/(sigma_p^2+sigma_s^2);
ssp = sqrt((sigma_p^2*sigma_s^2)/(sigma_p^2+sigma_s^2));
pxo = normpdf(s,a*S,ssp);
subplot(247)
h = patch(x,pxo,'k');
hold on
alpha(h,0.3);
box off
set(gca,'XTick',[0 S],'YTick',[]);
set(gca,'XTickLabel',{'0';'X'});
axis square
axis([-70 70 0 0.05]);
mx = nanmax(pxo);
plot(a*S+[0 0],[0 mx],'k--');
plot(a*S+[0 ssp],0.60655*[mx mx],'k-');
text(a*S+ssp/2,0.60655*mx,'\sigma_{P,L}','HorizontalAlignment','center','VerticalAlignment','top');
xlabel('Hypothesized location S (deg)');
ylabel({'Probability'})
title({'Posterior';'P(S|X)'})

pa_datadir
print('-depsc','-painter',[mfilename '1']);


figure(2)
%% Optimal
x			= 0:600;
sl = 1-cdf('Normal',x,280,40);
sl = sl*25;
sl = sl+5;

%% Dynamic likelihood
subplot(241)
h=plot(x,sl,'k');set(h,'LineWidth',2);
hold on
axis([220 380 0 30]);
box off
% set(gca,'XTick',[],'YTick',[]);
xlabel('Processing time');
ylabel({'Likelihood';'standard deviation'});
axis square;

% return

%% Posterior


sp		= 15;
Sp		= sp^2;
S		= (Sp*sl.^2)./(Sp+sl.^2);
gain	= 1-S/Sp;
sdmap	= sqrt(S);
% gain	= Sp./(Sp+S.^2);
% sdmap	= sqrt( S.^2 ./ (1+S.^2/Sp).^2 );


subplot(243)
plot(x,gain,'k-','LineWidth',2);
hold on
ylim([0 1.2]);
xlim([220 380])
box off
% set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Reaction time');
ylabel('Response gain');
pa_horline(0,'k--');
pa_horline(1,'k--');

subplot(244)
plot(x,sdmap,'k-','LineWidth',2);
hold on
ylim([0 15]);
xlim([220 380])
box off
% set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Reaction time');
ylabel('Response standard deviation');

subplot(247)
sel = x>220 & x<380;

plot(sdmap(sel),gain(sel),'k-','LineWidth',2);
hold on
ylim([0 1.2]);
xlim([0 15])
box off
set(gca,'XTick',[],'YTick',[]);
axis square
ylabel('Response gain');
xlabel('Response standard deviation');
pa_horline(0,'k--');
pa_horline(1,'k--');
return
subplot(247)
S		= 0:0.1:2*sp^2;
gain	= Sp./(Sp+S.^2);
sdmap	= sqrt( S.^2 ./ (1+S.^2/Sp).^2 );
plot(sdmap,gain,'k-','LineWidth',2,'Color',[.7 .7 .7]);
hold on
ylim([0 1.2]);
xlim([0 15])
box off
set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Response gain');
ylabel('Response standard deviation');
pa_horline(0,'k--');
pa_horline(1,'k--');

% plot(sopv,av,'k-','LineWidth',2);
sopv = 0:.1:15;
g = 1-sopv.^2/sp^2;

plot(sopv,g,'k-','LineWidth',2);
hold on
ylim([0 1.2]);
xlim([0 15])
box off
set(gca,'XTick',[],'YTick',[]);
axis square
xlabel('Response gain');
ylabel('Response standard deviation');
pa_horline(0,'k--');
pa_horline(1,'k--');


marc
print('-depsc','-painters',mfilename);



function h = pa_ellipseplot(Mu,SD,Phi,varargin)
% PA_ELLIPSEPLOY(MU,SD,A)
%
%  draw an ellipse with long and short axes SD(1) and SD(2)
%  with orientation A (in deg) at point Mu(1),Mu(2).
%
% see also PA_ELLIPSE

% 2011  Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
col         = pa_keyval('Color',varargin);
if isempty(col)
	col = 'k';
end
Xo	= Mu(1);
Yo	= Mu(2);
L	= SD(1);
S	= SD(2);
DTR = pi/180;
Phi = Phi*DTR;

%% Ellipse
wt  = (0:.1:360).*DTR;
X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);

%% Graphics
plot(X,Y,col,'LineWidth',2);
% h = patch(X,Y,col);
hold on
% alpha(h,.2);
% set(h,'EdgeColor',col,'LineWidth',2);

%% Rest
% wt = [0 180]*DTR;
% X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
% Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% plot(X,Y,'-','Color',Sty);
%
% wt = [90 270]*DTR;
% X   = Xo + L*cos(Phi)*cos(wt) - S*sin(Phi)*sin(wt);
% Y   = Yo + L*sin(Phi)*cos(wt) + S*cos(Phi)*sin(wt);
% plot(X,Y,'-','Color',Sty);


function [hpatch,hline] = pa_errorpatch(X,Y,E,col)
% PA_ERRORPATCH(X,Y,E)
%
% plots the graph of vector X vs. vector Y with error patch specified by
% the vector E.
%
% PA_ERRORPATCH(...,'ColorSpec') uses the color specified by the string
% 'ColorSpec'. The color is applied to the data line and error patch, with
% the error patch having an alpha value of 0.4.
%
% [HPATCH,HLINE] = PA_ERRORPATCH(...) returns a vector of patchseries and
% lineseries handles in HPATCH and HLINE, respectively.

% (c) 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Check whether
if size(X,1)>1
	X=X(:)';
	if size(X,1)>1
		error('X should be a row vector');
	end
end
if size(Y,1)>1
	Y   = Y(:)';
	if size(Y,1)>1
		error('Y should be a row vector');
	end
end
if size(E,1)>2
	E   = E(:)';
	if size(E,1)>2
		error('E should be a row vector or 2-row matrix');
	end
end
if length(Y)~=length(X)
	error('Y and X should be the same size');
end
if size(E,2)~=size(X,2)
	error('E and X should be the same size');
end
if nargin<4
	col = 'k';
end

%% remove nans
if size(E,1)>1
	sel		= isnan(X) | isnan(Y) | isnan(E(1,:)) | isnan(E(2,:));
	E		= E(:,~sel);
else
	sel		= isnan(X) | isnan(Y) | isnan(E);
	E		= E(~sel);
end
X		= X(~sel);
Y		= Y(~sel);

%% Create patch
x           = [X fliplr(X)];
if size(E,1)>1
	y           = [E(1,:) zeros(size(E(1,:)))];
else
	y           = [Y+E fliplr(Y)];
end
%% Graph
hpatch           = patch(x,y,col);
% alpha(hpatch,0.4);
set(hpatch,'EdgeColor','none','FaceColor',[.6 .6 .6]);
hold on;
% hline = plot(X,Y,'k-'); set(hline,'LineWidth',2,'Color',col);
box on;

function [hpatch,hline] = pa_errorpatch(X,Y,E,col)
% PA_ERRORPATCH(X,Y,E)
%
% plots the graph of vector X vs. vector Y with error patch specified by
% the vector E.
%
% PA_ERRORPATCH(...,'ColorSpec') uses the color specified by the string
% 'ColorSpec'. The color is applied to the data line and error patch, with
% the error patch having an alpha value of 0.4.
%
% [HPATCH,HLINE] = PA_ERRORPATCH(...) returns a vector of patchseries and
% lineseries handles in HPATCH and HLINE, respectively.

% (c) 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Check whether
if size(X,1)>1
	X=X(:)';
	if size(X,1)>1
		error('X should be a row vector');
	end
end
if size(Y,1)>1
	Y   = Y(:)';
	if size(Y,1)>1
		error('Y should be a row vector');
	end
end
if size(E,1)>2
	E   = E(:)';
	if size(E,1)>2
		error('E should be a row vector or 2-row matrix');
	end
end
if length(Y)~=length(X)
	error('Y and X should be the same size');
end
if size(E,2)~=size(X,2)
	error('E and X should be the same size');
end
if nargin<4
	col = 'k';
end

%% remove nans
if size(E,1)>1
	sel		= isnan(X) | isnan(Y) | isnan(E(1,:)) | isnan(E(2,:));
	E		= E(:,~sel);
else
	sel		= isnan(X) | isnan(Y) | isnan(E);
	E		= E(~sel);
end
X		= X(~sel);
Y		= Y(~sel);

%% Create patch
x           = [X fliplr(X)];
if size(E,1)>1
	y           = [E(1,:) zeros(size(E(1,:)))];
else
	y           = [Y+E fliplr(Y)];
end
%% Graph
hpatch           = patch(x,y,col);
% alpha(hpatch,0.4);
set(hpatch,'EdgeColor','none','FaceColor',[.6 .6 .6]);
hold on;
% hline = plot(X,Y,'k-'); set(hline,'LineWidth',2,'Color',col);
box on;