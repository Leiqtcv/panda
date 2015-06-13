function predictfutureh(n,h,y,j,q)
% Predict future h-index according to
% Daniel E. Acuna, Stefano Allesina, Konrad P. Kording
% Nature 489, 201?202 (13 September 2012) doi:10.1038/489201a
% Published online 12 September 2012

clear all
close all
clc

if( nargin < 1 )
	n	=	11; %8;	%-- Nbr of articles						--%
end
if( nargin < 2 )
	h	=	5;	%-- Current h-index								--%
end
if( nargin < 3 )
	y	=	10; %5;	%-- years since first published article --%
end
if( nargin < 4 )
	j	=	7; %6;	%-- Number of distinct jounals			--%
end
if( nargin < 5 )
	q	=	0;	%-- Number of Nature, Science, Nature Neuroscience, Proceedings of the National Academy of Sciences and Neuron	--%
end


h1	=	0.76 + 0.37*sqrt(n) + 0.97*h - 0.07*y + 0.02*j + 0.03*q;	%-- Next years h-index	--%
h5	=	4 + 1.58*sqrt(n) + 0.86*h - 0.35*y + 0.06*j + 0.2*q;		%-- 5 years from now	--%
h10	=	8.73 + 1.33*sqrt(n) + 0.48*h - 0.41*y + 0.52*j + 0.82*q;	%-- 10 years fom now	--%

xx	=	1:4;
yy	=	[h h1 h5 h10];

yax	=	[h*.9 max(yy)*1.1];

figure
plot(xx,yy,'ko-','MarkerFaceColor',[.5 .5 .5],'MarkerSize',10,'LineWidth',2)
xlim([xx(1)-.5 xx(end)+.5])
ylim(yax)
set(gca,'XTick',xx,'XTickLabel',[0 1 5 10],'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('time [yrs]')
ylabel('h-index')
