function [x,y] = pa_viscenter(xleft,xright)

close all
%% Intialization
%% BB Left eye  2012-10-23
if nargin<1
	xleft = -7.75;
	xright = 1.1;
end
y0 = 142.65; % distance centre wall - centre hoop

%% MW Left eye 2012-10-29
if nargin<1
	xleft = -(15-7.9);
	xright = 16.35-15;
end
y0 = 142.8; % distance centre wall - centre hoop

%% MW Right eye  2012-10-29
if nargin<1
	xleft = -(15-14.1);
	xright = 22.3-15;
end
y0 = 142.8; % distance centre wall - centre hoop

x0 = 81.8; % distance right wall-speaker - centre wall
% soscastoa

%% Hoop-wall
plot([0,0],[0,y0],'k-','LineWidth',2);
hold on
str = ['y0 = ' num2str(y0)];
text(5,y0/5*4,str);
text(0,0,'Visual frame centre','VerticalAlignment','top');

%% R-LED
plot([0,x0],[0,y0],'k:','LineWidth',2);
plot([0,x0],[y0,y0],'k-','LineWidth',2);
str = ['x0 = ' num2str(x0)];
text(x0/2,y0,str,'VerticalAlignment','bottom','HorizontalAlignment','center');
text(x0,y0,'Right LED','VerticalAlignment','bottom','HorizontalAlignment','center');
plot(x0,y0,'ko','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);

%% L_LED
plot([0,-x0],[0,y0],'k:','LineWidth',2);
plot([0,-x0],[y0,y0],'k-','LineWidth',2);
plot(-x0,y0,'ko','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);
str = ['-x0 = ' num2str(-x0)];
text(-x0/2,y0,str,'VerticalAlignment','bottom','HorizontalAlignment','center');
text(-x0,y0,'Left LED','VerticalAlignment','bottom','HorizontalAlignment','center');

%%
plot([xleft 0],[0 0],'r-','LineWidth',2);
plot([0 xright],[0 0],'b-','LineWidth',2);

plot(xleft,0,'ro','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);
plot(xright,0,'bo','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);

%% Calculon
% right
x = [xleft -x0; 1 1]';
y = [0 y0]';
betaright = x\y;
h = pa_regline(betaright([2 1]),'b--'); set(h,'LineWidth',2);

x = [xright x0; 1 1]';
y = [0 y0]';
betaleft = x\y
h = pa_regline(betaleft([2 1]),'r--'); set(h,'LineWidth',2);

%% Snijpunt
% ya-yb = 0;
% a*x+b-c*x-d=0
% (a-c)*x=(d-b)
% x = (d-b)/(a-c)
x = (betaleft(2)-betaright(2))./(betaright(1)-betaleft(1));
y = betaright(1)*x+betaright(2)
% keyboard
% axis off
plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2,'MarkerSize',15);
y2 = 160-(y0-y);
str = ['[x,y] = [' num2str(x,3) ',' num2str(y2,3) '] cm'];
text(x,y-10,str,'LineWidth',2,'FontSize',20,'VerticalAlignment','top','HorizontalAlignment','center')
y = y2;

%%
axis equal;
ax =  [-169.5000  169.5000  -20.0000  180.0000]
axis(ax);
axis off

%% Print
pa_datadir;
print('-depsc','-painter',[mfilename '2']);
