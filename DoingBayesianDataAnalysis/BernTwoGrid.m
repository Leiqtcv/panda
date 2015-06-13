function BernTwoGrid
% BERNTWOGRID
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all;

%% Specify the grid on theta1,theta2 parameter space.
nInt		= 501; % arbitrary number of intervals for grid on theta.
theta1		= 1/nInt/2:(1/nInt):(1-(1/nInt)/2);
theta2		= theta1;
[theta1,theta2] = meshgrid(theta1,theta2);

% Specify the prior probability _masses_ on the grid.
probDist	= {'Beta';'Ripples';'Null';'Alt'};
priorName	= probDist{1}; % or define your own.
switch priorName
	case 'Beta'
		a1 = 3; b1 = 3; a2 = 3; b2 = 3;
		prior1	= betapdf(theta1,a1,b1);
		prior2	= betapdf(theta2,a2,b2);
		prior	= prior1.*prior2; % density
		prior	= prior/sum(prior(:)); % convert to normalized mass
end

% if ( priorName == 'Ripples' ) {
% 	rippleAtPoint = function( theta1 , theta2 ) {
% 		m1 = 0 ; m2 = 1 ; k = 0.75*pi
% 		sin( (k*(theta1-m1))^2 + (k*(theta2-m2))^2 )^2 }
% 	prior = outer( theta1 , theta2 , rippleAtPoint )
% 	prior = prior / sum( prior ) % convert to normalized mass
% }
% if ( priorName == 'Null' ) {
%     % 1's at theta1=theta2, 0's everywhere else:
%     prior = diag( 1 , nrow=length(theta1) , ncol=length(theta1) )
%     prior = prior / sum( prior ) % convert to normalized mass
% }
% if ( priorName == 'Alt' ) {
%     % Uniform:
%     prior = matrix( 1 , nrow=length(theta1) , ncol=length(theta2) )
%     prior = prior / sum( prior ) % convert to normalized mass
% }
% 

%% Likelihood
% data are specified here
z1 = 5; 
N1 = 7;
z2 = 2 ; 
N2 = 7;
likelihood = likeAtPoint(theta1,theta2,N1,N2,z1,z2);



%% Compute posterior from point-by-point multiplication and normalizing:
pData		= sum(prior(:).*likelihood(:));
posterior	= (prior.*likelihood)/pData;

%% Display plots.
% Specify the probability mass for the HDI region
credib		= 0.95;

% Specify aspects of perspective and contour plots.
ncontours	= 9;
zmax		= max([max(posterior),max(prior)]);

% Specify the indices to be used for plotting. The full arrays would be too
% dense for perspective plots, so we plot only a thinned-out set of them.
nteeth1		= length(theta1);
thindex1	= 1:round(nteeth1/30):nteeth1;
thindex1	= [thindex1,nteeth1]; % makes sure last index is included
thindex2	= thindex1;

%% prior
subplot(321)
h = mesh(theta1(thindex1,thindex2),theta2(thindex1,thindex2),prior(thindex1,thindex2));
set(h,'EdgeColor',[.7 .7 1]);
axis square;
xlabel('\theta1');
ylabel('\theta2');
zlabel('p(\theta1,\theta2)');
title('Prior');
axis([0 1 0 1 0 zmax]);
grid off;
set(gca,'XTick',[],'YTick',[],'ZTick',[]);

subplot(322)
L		= linspace(0,zmax,ncontours);
[~,h]	= contour(theta1(thindex1,thindex2),theta2(thindex1,thindex2),prior(thindex1,thindex2),L);
set(h,'Color',[.7 .7 1]);
axis square;
xlabel('\theta1');
ylabel('\theta2');
axis([-0.1 1.1 -0.1 1.1]);
box off;
set(gca,'TickDir','out','XTick',0:0.2:1,'YTick',0:0.2:1);


%% likelihood
subplot(323)
h = mesh(theta1(thindex1,thindex2),theta2(thindex1,thindex2),likelihood(thindex1,thindex2));
set(h,'EdgeColor',[.7 .7 1]);
axis square;
xlabel('\theta1');
ylabel('\theta2');
zlabel('p(D|\theta1,\theta2)');
title('Likelihood');
xlim([0 1]);
ylim([0 1]);
grid off;
set(gca,'XTick',[],'YTick',[],'ZTick',[]);

subplot(324)
[~,h]	= contour(theta1(thindex1,thindex2),theta2(thindex1,thindex2),likelihood(thindex1,thindex2),ncontours-1);
set(h,'Color',[.7 .7 1]);
axis square;
xlabel('\theta1');
ylabel('\theta2');
axis([-0.1 1.1 -0.1 1.1]);
box off;
set(gca,'TickDir','out','XTick',0:0.2:1,'YTick',0:0.2:1);

% Include text for data
[I,J]		= find(likelihood==max(likelihood(:)));
if theta1(I,J)>0.5
	textxpos	= 0.1; 
	xadj		= 'left';
else
	textxpos = 0.9; 
	xadj = 'right';
end
if theta2(I,J)>0.5
	textypos	= 0.1;
	yadj		= 'bottom';
else
	textypos	= 0.9; 
	yadj		= 'top';
end
str = ['z1=' num2str(z1) ', N1=' num2str(N1) ', z2=' num2str(z2) ', N2=' num2str(N2)];
text(textxpos,textypos,str,'HorizontalAlignment',xadj,'VerticalAlignment',yadj);


%% posterior
subplot(325)
h = mesh(theta1(thindex1,thindex2),theta2(thindex1,thindex2),posterior(thindex1,thindex2));
set(h,'EdgeColor',[.7 .7 1]);
axis square;
xlabel('\theta1');
ylabel('\theta2');
zlabel('p(\theta1,\theta2|D)');
title('Posterior');
xlim([0 1]);
ylim([0 1]);
grid off;
set(gca,'XTick',[],'YTick',[],'ZTick',[]);

subplot(326)
L		= linspace(0,zmax,ncontours);
[~,h]	= contour(theta1(thindex1,thindex2),theta2(thindex1,thindex2),posterior(thindex1,thindex2),L);
set(h,'Color',[.7 .7 1]);
axis square;
xlabel('\theta1');
ylabel('\theta2');
axis([-0.1 1.1 -0.1 1.1]);
box off;
set(gca,'TickDir','out','XTick',0:0.2:1,'YTick',0:0.2:1);

% Include text for data
[I,J]		= find(posterior==max(posterior(:)));
if theta1(I,J)>0.5
	textxpos	= 0.1; 
	xadj		= 'left';
else
	textxpos = 0.9; 
	xadj = 'right';
end
if theta2(I,J)>0.5
	textypos	= 0.1;
	yadj		= 'bottom';
else
	textypos	= 0.9; 
	yadj		= 'top';
end
str = ['p(D)=' num2str(pData,3)];
text(textxpos,textypos,str,'HorizontalAlignment',xadj,'VerticalAlignment',yadj);

% % Mark the highest posterior density region
% source('HDIofGrid.R')
HDI			= HDIofGrid(posterior(:));
HDIheight	= HDI.height;
hold on
[~,h]	= contour(theta1(thindex1,thindex2),theta2(thindex1,thindex2),posterior(thindex1,thindex2),HDIheight);
set(h,'Color',[.7 .7 1],'LineWidth',3);

function p = likeAtPoint(t1,t2,N1,N2,z1,z2)
% Specify likelihood
p = t1.^z1.*(1-t1).^(N1-z1).*t2.^z2.*(1-t2).^(N2-z2);
 
