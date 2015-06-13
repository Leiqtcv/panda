function AnaASArippleExp

tic
close all
clc

%-- Flags --%
Dprime	=	1;

%-- Variables --%
Pname	=	'/Users/pbremen/Work/Experiments/Irvine/Data/Human/ASAripple/';
Subj	=	'Peter_Pilot1';

%-- Main --%
load([Pname Subj '.mat'])

sel	=	D(:,2) == 1;											%#ok<*NODEF>
C	=	D(sel,:);
D	=	D(~sel,:);

uVel1	=	unique(D(:,6));
uDens1	=	unique(D(:,7));
uMod1	=	unique(D(:,8));

uMod	=	unique(D(:,5));
Nmod	=	length(uMod);

[c,r]	=	FactorsForSubPlot(Nmod);

cR		=	getpcorr(C(:,1));

figure

for k=1:Nmod
	sel	=	D(:,5) == uMod(k);
	d	=	D(sel,:);
	
	%--			  1		2	  3	  4		5	6	  7		8	9	  10  11  12 13		--%
	%-- D	=	[Resp Catch Vel2 Den2 Mod2 Vel1 Dens1 Mod1 Delay Amp Dur1 Fs k];	--%
	uStim	=	unique(d(:,3:5),'rows');
	Nstim	=	length(uStim);
	
	R		=	nan(Nstim,1);
	
	subplot(r,c,k)
	for l=1:Nstim
		sel	=	d(:,3) == uStim(l,1) & d(:,4) == uStim(l,2) & d(:,5) == uStim(l,3);
		
		if( Dprime )
			z		=	p2z( getpcorr(d(sel,1)) );
			R(l,1)	=	z - p2z( cR );
		else
			R(l,1)	=	getpcorr(d(sel,1));						%#ok<*UNRCH>
		end
	end
	
	[X,Y]	=	meshgrid(unique(uStim(:,1)),unique(uStim(:,2)));
	[X,Y,Z]	=	griddata(uStim(:,1),uStim(:,2),R,X,Y);			%#ok<GRIDD>
	
% 	pcolor(Y,X,Z)
	contourf(Y,X,Z)
	hold on
	plot(uDens1,uVel1,'wo','MarkerFaceColor','w')
	
	axis('square')
	if( Dprime )
		caxis([-.5 4])
		h = colorbar('YTick',-.5:.5:4,'FontName','Arial','FontWeight','bold','FontSize',12);
		set(get(h,'Ylabel'),'String','d''')
	else
		caxis([0 1])
		h = colorbar('YTick',0:.25:1,'FontName','Arial','FontWeight','bold','FontSize',12);
		set(get(h,'Ylabel'),'String','prop. signal present')
	end
	set(get(h,'Ylabel'),'Rotation',-90,'VerticalAlignment','Bottom','FontName','Arial','FontWeight','bold','FontSize',12)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	set(gca,'YTick',unique(uStim(:,1)),'XTick',unique(uStim(:,2)))
	xlabel('density [cyc/oct]')
	ylabel('velocity [Hz]')
	title(['mod 2 ' num2str(uMod(k)*100) ' % & signal mod ' num2str(uMod1*100) ' %' ])
end

disp(['The subject perceived the signal in ' num2str(cR) ' % of the catch trials'])

%-- Wrapping up --%
tend	=	( round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%-- Locals --%
function C = getpcorr(D)

sel	=	D == 1;
C	=	1 - (sum(D(sel,1)) / size(D,1));	%-- % signal detected in mixture --%

if( C == 0 )
	C	=	1/(2*length(D));
end
if( C == 1 )
	C	=	1 - ( 1/(2*length(D)) );
end

function z = p2z(p)

z	=	(p) -sqrt(2) * erfcinv(p*2);
