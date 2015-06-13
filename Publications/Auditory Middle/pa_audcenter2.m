function [x,y] = pa_audcenter2(leftbetahoop,rightbetahoop)


%% Intialization
if nargin<1
	leftbetahoop = -39;
	%% Bert
		leftbetahoop = -45;
		rightbetahoop = 40;

end
y0 = 160; % distance centre wall - centre hoop
% y1 = 
y2 = 120; % distance centre hoop - outer rim hoop
x0 = 149.5; % distance right wall-speaker - centre wall
% soscastoa
alpha = atand(x0/y0); % right-speaker angle

%% Hoop-wall
plot([0,0],[0,y0],'k-','LineWidth',2);
hold on
str = ['y0 = ' num2str(y0)];
text(5,y0/5*4,str);
text(0,0,'Hoop centre','VerticalAlignment','top');

%% R-speaker-wall
plot([0,x0],[0,y0],'k:','LineWidth',2);
plot([0,x0],[y0,y0],'k-','LineWidth',2);
str = ['x0 = ' num2str(x0)];
text(x0/2,y0,str,'VerticalAlignment','bottom','HorizontalAlignment','center');
text(x0,y0,'Right wall-speaker','VerticalAlignment','bottom','HorizontalAlignment','center');
plot(x0,y0,'ko','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);

% angle
t = 90-alpha:90;
x = 15*cosd(t);
y = 15*sind(t);
plot(x,y,'k-','LineWidth',2);
t = 90-alpha/2;
x = 15*cosd(t);
y = 15*sind(t);
str = {'\alpha = ';[ num2str(alpha,3) '\circ']};
text(x,y,str,'VerticalAlignment','bottom','HorizontalAlignment','center')

%% L-speaker-wall
plot([0,-x0],[0,y0],'k:','LineWidth',2);

% angle
t = 90:90+alpha;
x = 20*cosd(t);
y = 20*sind(t);
plot(x,y,'k-','LineWidth',2);
t = 90+alpha/2;
x = 20*cosd(t);
y = 20*sind(t);
str = {'-\alpha = ';[ num2str(-alpha,3) '\circ']};
text(x,y,str,'VerticalAlignment','bottom','HorizontalAlignment','center')

plot([0,-x0],[y0,y0],'k-','LineWidth',2);
plot(-x0,y0,'ko','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);
str = ['-x0 = ' num2str(-x0)];
text(-x0/2,y0,str,'VerticalAlignment','bottom','HorizontalAlignment','center');
text(-x0,y0,'Left wal-speaker','VerticalAlignment','bottom','HorizontalAlignment','center');


%% Left hoop angle
t = 90:90-leftbetahoop;
x = 40*cosd(t);
y = 40*sind(t);
plot(x,y,'r-','LineWidth',2);
t = 90-leftbetahoop/2;
x = 40*cosd(t);
y = 40*sind(t);
str = {'-\beta_{left} = ';[ num2str(leftbetahoop,3) '\circ']};
text(x,y,str,'VerticalAlignment','bottom','HorizontalAlignment','center','Color','r')

% soscastoa
x2left			= y2*sind(leftbetahoop);
y2left		= y2*cosd(leftbetahoop);
plot([0,x2left],[0,y2left],'r:','LineWidth',2);

plot([0,0],[0,y2],'r-','LineWidth',2);
hold on
str = ['y2 = ' num2str(y2)];
text(5,y2*0.75,str,'Color','r');
t = 90:90-leftbetahoop;
x = y2*cosd(t);
y = y2*sind(t);
plot(x,y,'r:','LineWidth',2);

plot(x2left,y2left,'ro','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);

%% Right hoop angle
t = 90-rightbetahoop:90;
x = 35*cosd(t);
y = 35*sind(t);
plot(x,y,'b-','LineWidth',2);
t = 90-rightbetahoop/2;
x = 35*cosd(t);
y = 35*sind(t);
str = {'\beta_{right} = ';[ num2str(rightbetahoop,3) '\circ']};
text(x,y,str,'VerticalAlignment','bottom','HorizontalAlignment','center','Color','b')

% soscastoa
x2right = y2*sind(rightbetahoop);
y2right = y2*cosd(rightbetahoop);
plot([0,x2right],[0,y2right],'b:','LineWidth',2);
axis([-x0-20 x0+20 0-20 y0+20]);

t = 90-rightbetahoop:90;
x = y2*cosd(t);
y = y2*sind(t);
plot(x,y,'b:','LineWidth',2);

plot(x2right,y2right,'bo','LineWidth',2,'MarkerFaceColor','w','MarkerSize',10);

%%
plot(0,0,'ko','MarkerFaceColor','w','LineWidth',2,'MarkerSize',10);
%% Calculon
% right
x = [x2right x0; 1 1]';
y = [y2right y0]';
betaright = x\y;
h = pa_regline(betaright([2 1]),'b--'); set(h,'LineWidth',2);

x = [x2left -x0; 1 1]';
y = [y2left y0]';
betaleft = x\y
h = pa_regline(betaleft([2 1]),'r--'); set(h,'LineWidth',2);

%% Snijpunt
% ya-yb = 0;
% a*x+b-c*x-d=0
% (a-c)*x=(d-b)
% x = (d-b)/(a-c)
x = (betaleft(2)-betaright(2))./(betaright(1)-betaleft(1));
y = betaright(1)*x+betaright(2);

% keyboard
% axis off
plot(x,y,'ko','MarkerFaceColor','w','LineWidth',2,'MarkerSize',15);
str = ['[x,y] = [' num2str(x,3) ',' num2str(y,3) '] cm'];
text(x,y-10,str,'LineWidth',2,'FontSize',20,'VerticalAlignment','top','HorizontalAlignment','center')

%%
axis equal;
axis([-x0-20 x0+20 0-20 y0+20]);
axis off