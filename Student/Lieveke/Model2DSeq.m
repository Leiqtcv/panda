function Model2DSeq
tic
close all
clc

%-- Flags --%
SubFlag		=	2;	%-- 1: DB, 2: RM, 3: MW, 4: PB						--%
NoWeigh		=	1;	%-- 1: No binaural weighing of pinna cues			--%
CorrFlag	=	1;	%-- 1: Correlation model; 0: Similarity model		--%
ScaleFlag	=	1;	%-- 1: Z-transform; 0: No Z-transform				--%

%-- Variables --%
tau			=	15;		%-- "Time" constant for weighing of pinna cues [deg]	--%
cuton		=	3900;	%-- Lower frequency cutoff for DTFs [Hz]				--%
cutoff		=	12100;	%-- Higher frequency cutoff for DTFs [Hz]				--%
Fcenter		=	9000;	%-- Center frequency for monaural gain calc. [Hz]	 	--%
Frange		=	6000;	%-- Frequency range: Fcenter +/- Frange [Hz]			--%

%-- Main --%

[Sac,Stim,DTFl,DTFr,Azi,Ele,f]		=	getdata(SubFlag);

%-- Saccades --%
[Sac,Stim1,Stim2,Sacsgl,Stimsgl]	=	trimsac(Sac,Stim);

uTsgl		=	unique(Stimsgl(:,4:5),'rows');
uTdbl		=	unique([Stim1(:,4:5) Stim2(:,4:5)],'rows');

%-- DTFs: Monaural Cues --%

%-- Get DTF corresponding to single speaker trials --%
T			=	[round(Azi),Ele];
sel			=	ismember(T,uTsgl,'rows');
DTFlsgl		=	DTFl(:,sel);
DTFrsgl		=	DTFr(:,sel);

%-- Get DTF corresponding to double speaker trials --%
[DTFl1,DTFl2,DTFr1,DTFr2]	=	getdblmtx(DTFl,DTFr,T,uTdbl);

%-- Sum the two DTFs -> eardrum	--%
DTFldbl		=	DTFl1 + DTFl2;
DTFrdbl		=	DTFr1 + DTFr2;

%-- Transform into log space --%
DTFl		=	10 * log10( DTFl );
DTFr		=	10 * log10( DTFr );
DTFlsgl		=	10 * log10( DTFlsgl );
DTFrsgl		=	10 * log10( DTFrsgl );
DTFldbl		=	10 * log10( DTFldbl );
DTFrdbl		=	10 * log10( DTFrdbl );

%--	Select frequency range --%
fel			=	f >= cuton & f <= cutoff;

%-- Calculate correlation/similarity --%
Clsgl		=	calcsimi(DTFl(fel,:),DTFlsgl(fel,:),CorrFlag);
Crsgl		=	calcsimi(DTFr(fel,:),DTFrsgl(fel,:),CorrFlag);

Cldbl		=	calcsimi(DTFl(fel,:),DTFldbl(fel,:),CorrFlag);
Crdbl		=	calcsimi(DTFr(fel,:),DTFrdbl(fel,:),CorrFlag);

%-- Z-Transform --%
if( ScaleFlag )
	Clsgl	=	(Clsgl-repmat(mean(Clsgl,1),size(Clsgl,1),1)) ./ repmat(std(Clsgl,[],1),size(Clsgl,1),1);
	Crsgl	=	(Crsgl-repmat(mean(Crsgl,1),size(Crsgl,1),1)) ./ repmat(std(Crsgl,[],1),size(Crsgl,1),1);
	
	Cldbl	=	(Cldbl-repmat(mean(Cldbl,1),size(Cldbl,1),1)) ./ repmat(std(Cldbl,[],1),size(Cldbl,1),1);
	Crdbl	=	(Crdbl-repmat(mean(Crdbl,1),size(Crdbl,1),1)) ./ repmat(std(Crdbl,[],1),size(Crdbl,1),1);
end

%-- Weighing of ipsi & contra lateral ear --%
Csgl		=	weighpinna(Clsgl,Crsgl,uTsgl,tau,NoWeigh);
Cdbl		=	weighpinna(Cldbl,Crdbl,uTdbl,tau,NoWeigh);

%-- DTFs: ILDs --%
%-- Calculate monaural gain functions --%
Monl		=	calcmongain(DTFl,f,Fcenter,Frange);
Monr		=	calcmongain(DTFr,f,Fcenter,Frange);
Monlsgl		=	calcmongain(DTFlsgl,f,Fcenter,Frange);
Monrsgl		=	calcmongain(DTFrsgl,f,Fcenter,Frange);
Monldbl		=	calcmongain(DTFldbl,f,Fcenter,Frange);
Monrdbl		=	calcmongain(DTFrdbl,f,Fcenter,Frange);

%-- Calculate ILDs --%
ILDl		=	Monl-Monr;
ILDr		=	Monr-Monl;
ILDlsgl		=	Monlsgl-Monrsgl;
ILDrsgl		=	Monrsgl-Monlsgl;
ILDldbl		=	Monldbl-Monrdbl;
ILDrdbl		=	Monrdbl-Monldbl;

%-- Sequential model --%
Plsgl2(:,1)	=	findild(ILDlsgl,ILDl,Azi);
Prsgl2(:,1)	=	findild(ILDrsgl,ILDr,Azi);
Pldbl2(:,1)	=	findild(ILDldbl,ILDl,Azi);
Prdbl2(:,1)	=	findild(ILDrdbl,ILDr,Azi);

%-- Get monaural cues at pre-selected azimuth locations --%
Plsgl2(:,2)	=	getlocpred(Clsgl,Plsgl2(:,1),Azi,Ele);
Prsgl2(:,2)	=	getlocpred(Crsgl,Prsgl2(:,1),Azi,Ele);
Pldbl2(:,2)	=	getlocpred(Cldbl,Pldbl2(:,1),Azi,Ele);
Prdbl2(:,2)	=	getlocpred(Crdbl,Prdbl2(:,1),Azi,Ele);

%-- Z-Transform for parallel model --%
ILDl		=	(ILDl-mean(ILDl)) ./ std(ILDl);
ILDr		=	(ILDr-mean(ILDr)) ./ std(ILDr);
ILDlsgl		=	(ILDlsgl-mean(ILDl)) ./ std(ILDl);
ILDrsgl		=	(ILDrsgl-mean(ILDr)) ./ std(ILDr);
ILDldbl		=	(ILDldbl-mean(ILDl)) ./ std(ILDl);
ILDrdbl		=	(ILDrdbl-mean(ILDr)) ./ std(ILDr);

%-- Combine monaural & ILD cues in Z-Space to get the model prediction --%
Psgl		=	Csgl + repmat(ILDlsgl,size(Csgl,1),1);
Pdbl		=	Cdbl + repmat(ILDldbl,size(Cdbl,1),1);

%-- Plotting --%

%-- Plot single prediction vs responses --%
% figure
% plotsglpred(Plsgl,uTsgl,Sacsgl,Stimsgl)

%-- Monaural Cues: Single speaker trials --%
figure
plotmoncuessgl(Csgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl)

%-- Monaural Cues: Double speaker trials --%
figure
plotmoncuesdbl(Cdbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2)

%-- Monaural gain functions single speaker --%
figure
plotbincuesgl(Monr,Monrsgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl,'Monaural Gain Function right; single speaker')

figure
plotbincuesgl(Monl,Monlsgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl,'Monaural Gain Function left; single speaker')

%-- Monaural gain functions double speaker --%
figure
plotbincuedbl(Monr,Monrdbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2,'Monaural Gain Function right; double speaker')

figure
plotbincuedbl(Monl,Monldbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2,'Monaural Gain Function left; double speaker')

%-- ILDs single speaker --%
figure
plotbincuesgl(ILDr,ILDrsgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl,'ILD right; single speaker')

figure
plotbincuesgl(ILDl,ILDlsgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl,'ILD left; single speaker')

%-- ILDs double speaker --%
figure
plotbincuedbl(ILDr,ILDrdbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2,'ILD right; double speaker')

figure
plotbincuedbl(ILDl,ILDldbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2,'ILD left; double speaker')

%-- Monaural cues + ILDs singlee speaker --%
figure
plotpredictsgl(Psgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl,'ILDs + monaural cues; single speaker',Plsgl2,Prsgl2)

%-- Monaural cues + ILDs double speaker --%
figure
plotpredictdbl(Pdbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2,'ILDs + monaural cues; double speaker',Pldbl2,Prdbl2)

%-- Wrapping up --%
tend		=	( round(toc*100)/100 );
str			=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%-- Locals --%
function [Sac,Stim,DTFl,DTFr,Azi,Ele,f] = getdata(Subject)		%#ok<STOUT>

Root			=	'C:\DATA\Double\';

if( Subject == 1 )
	sfname1		=	[Root 'MW-DB-2010-07-29/MW-DB-2010-07-29-0001'];
	sfname2		=	[Root 'MW-DB-2010-07-30/MW-DB-2010-07-30-0001'];
	sfname3		=	[Root 'MW-DB-2010-07-30/MW-DB-2010-07-30-0002'];
	
	%-- Saccade data --%
	[Sac,Stim]	=	loadmat( [sfname1; sfname2; sfname3] );
	
	dpname		=	'C:\DATA\HRTFs\';
	dfname		=	'SglwithFFTDB';
elseif( Subject == 2 )
	sfname1		=	[Root 'MW-RM-2010-07-29/MW-RM-2010-07-29-0001'];
% 	sfname2		=	[Root 'MW-RM-2010-07-30/MW-RM-2010-07-30-0001'];	%-- ? --%
	sfname3		=	[Root 'MW-RM-2010-07-30/MW-RM-2010-07-30-0002'];
	
	%-- Saccade data --%
	[Sac,Stim]	=	loadmat( [sfname1; sfname3] );
	
	dpname		=	'C:\DATA\HRTFs\';
	dfname		=	'SglwithFFTRM';
elseif( Subject == 3 )
	sfname1		=	[Root 'DB-MW-2010-07-27/DB-MW-2010-07-27-0001'];
% 	sfname2		=	[Root 'DB-MW-2010-07-28/DB-MW-2010-07-28-0001'];
	
	%-- Saccade data --%
	[Sac,Stim]	=	loadmat( sfname1 );
	
	dpname		=	'C:\DATA\HRTFs\';
	dfname		=	'SglwithFFTMW';
elseif( Subject == 4 )
	sfname1		=	[Root 'MW-PB-2010-07-31/MW-PB-2010-07-31-0002'];
	sfname2		=	[Root 'MW-PB-2010-07-31/MW-PB-2010-07-31-0003'];
% 	sfname3		=	[Root 'MW-PB-2010-07-31/MW-PB-2010-07-31-0004'];
% 	sfname4		=	[Root 'MW-PB-2010-07-31/MW-PB-2010-07-31-0006'];
	
	%-- Saccade data --%
	[Sac,Stim]	=	loadmat( [sfname1; sfname2] );
% 	[Sac,Stim]	=	loadmat( [sfname1; sfname2; sfname3; sfname4] );
	
	dpname		=	'C:\DATA\HRTFs\';
	dfname		=	'SglwithFFTPB';
else
	error('Unknown subject! Valid entries are: 1: DB, 2: RM, 4: PB')
end

%-- DTF data --%
load([dpname dfname])

function [Sac,Stim1,Stim2,Sacsgl,Stimsgl] = trimsac(Sac,Stim,Fs)

if( nargin < 3 )
	Fs			=	48828.128;
end

Sac			=	firstsac(Sac);

sel			=	ismember(Stim(:,3),2);
Stim1		=	Stim(sel,:);

sel			=	ismember(Stim(:,3),3);
Stim2		=	Stim(sel,:);

%-- Get single trials --%
sel			=	Stim2(:,11) == 100;
Stimsgl		=	Stim1(sel,:);
Sacsgl		=	Sac(sel,:);

%-- Get double trials --%
sel			=	Stim2(:,11)==100;
Stim1		=	Stim1(~sel,:);
Stim2		=	Stim2(~sel,:);
Sac			=	Sac(~sel,:);

dT			=	( Stim2(:,8) - Stim1(:,8) ) / Fs;
dT			=	round( dT*10^4 ) / 10^4;
Stim1(:,8)	=	dT;
Stim2(:,8)	=	dT;

function [L1,L2,R1,R2] = getdblmtx(L,R,T,Td)

len		=	size(Td,1);

uT		=	unique( [Td(:,1:2); Td(:,3:4)],'rows' );
sel		=	ismember(T,uT(:,1:2),'rows');
L		=	L(:,sel);
R		=	R(:,sel);

L1		=	nan(size(L,1),len);
L2		=	L1;
R1		=	nan(size(R,1),len);
R2		=	R1;
for k=1:len
	sel1	=	uT(:,1) == Td(k,1) & uT(:,2) == Td(k,2);
	sel2	=	uT(:,1) == Td(k,3) & uT(:,2) == Td(k,4);
	
	L1(:,k)	=	L(:,sel1);
	L2(:,k)	=	L(:,sel2);
	R1(:,k)	=	R(:,sel1);
	R2(:,k)	=	R(:,sel2);
end

function C = calcsimi(Temp,Match,Flag)

if( nargin < 3 )
	Flag	=	1;
end

Nmatch		=	size(Match,2);
Ntemp		=	size(Temp,2);

C			=	nan(Ntemp,Nmatch);
for k=1:Nmatch
	for l=1:Ntemp
		if( Flag )
			c		=	corrcoef(Temp(:,l),Match(:,k));
			C(l,k)	=	c(1,2);
		else
			c			=	std(Temp(:,l)-Match(:,k));
			C(l,k)	=	-c;
		end
	end
end

function C = weighpinna(Cl,Cr,T,tau,flag)

if( nargin < 4 )
	tau		=	15;
end
if( nargin < 5 )
	flag	=	0;
end

if( flag )
	C	=	( Cl + Cr ) ./ 2;
	return
end

len		=	size(T,1);
C		=	nan(size(Cl));
for k=1:len
	w	=	exp(T(k,1)/tau);
	
	if( T(k,1) > 0 )
		C(:,k)	=	Cr(:,k) + w .* Cl(:,k);
	elseif( T(k,1) < 0 )
		C(:,k)	=	Cl(:,k) + w .* Cr(:,k);
	elseif( T(k,1) == 0 )
		C(:,k)	=	( Cr(:,k) + Cl(:,k) ) ./ 2;
	end
end

function M = calcmongain(DTF,f,Fcenter,Frange)

if( nargin < 2 )
	Fcenter		=	9000;
end
if( nargin < 3 )
	Frange		=	6000;
end

len				=	size(DTF,2);

[~,idx]			=	min( abs( f-Fcenter ) );
sel				=	f > f(idx)-Frange & f < f(idx)+Frange;

M				=	nan(1,len);
for k=1:len
	M(1,k)		=	mean( DTF(sel,k),1 );
end

function A = findild(I,Temp,Azi,crit)

if( nargin < 4 )
	crit	=	1;	%-- Criterion for ILD matching range --%
end

len		=	length(I);
idx		=	nan(len,1);
for k=1:len
	idx(k)	=	find( Temp >= I(k)-crit & Temp <= I(k)+crit,1,'first' );
end

A		=	Azi(idx);

function P = getlocpred(C,aILD,Azi,Ele)

len		=	size(C,2);
P		=	nan(len,1);
for k=1:len
	sel		=	round(Azi) == round( aILD(k) );
	E		=	Ele(sel);
	[~,idx]	=	max( C(sel) );
	P(k)	=	E(idx);
end

%-- Plot functions --%
function plotsglpred(P,uT,Sac,Stim)

len			=	size(uT,1);

for k=1:len
	sel		=	ismember(Stim(:,4:5),uT(k,:),'rows');
	Y		=	Sac(sel,8:9);
	X		=	repmat(P(k,:),sum(sel),1);
	
	subplot(2,2,k)
	plot(X(:,1),Y(:,1),'k.')
	hold on
	plot(X(:,2),Y(:,2),'r.')
% 	plotfartlim
% 	plot(uTsgl(:,1),uTsgl(:,2),'ks','MarkerFaceColor','w','MarkerSize',15)
% 	plot(uTsgl(k,1),uTsgl(k,2),'ks','MarkerFaceColor',[.7 .7 .7],'MarkerSize',15)
% 	plot(Sacsgl(sel,8),Sacsgl(sel,9),'k.')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title('monaural cues single speakers')
end

function plotmoncuessgl(Csgl,Azi,Ele,uTsgl,Sacsgl,Stimsgl)

len			=	size(uTsgl,1);

for k=1:len
	[X,Y]	=	meshgrid(unique(Azi),unique(Ele));
	[X,Y,Z]	=	griddata(Azi,Ele,Csgl(:,k),X,Y);
	
	sel		=	ismember(Stimsgl(:,4:5),uTsgl(k,:),'rows');
	
	subplot(2,2,k)
	contourf(X,Y,Z,-3:.3:3)
	hold on
% 	plotfartlim
	plot(uTsgl(:,1),uTsgl(:,2),'ks','MarkerFaceColor','w','MarkerSize',15)
	plot(uTsgl(k,1),uTsgl(k,2),'ks','MarkerFaceColor',[.7 .7 .7],'MarkerSize',15)
	plot(Sacsgl(sel,8),Sacsgl(sel,9),'k.')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title('monaural cues single speakers')
end

function plotmoncuesdbl(Cdbl,Azi,Ele,uTdbl,Sac,Stim1,Stim2)

len			=	size(uTdbl,1);

for k=1:len
	[X,Y]	=	meshgrid(unique(Azi),unique(Ele));
	[X,Y,Z]	=	griddata(Azi,Ele,Cdbl(:,k),X,Y);
	
	sel		=	Stim1(:,4) == uTdbl(k,1) & Stim1(:,5) == uTdbl(k,2) & ...
				Stim2(:,4) == uTdbl(k,3) & Stim2(:,5) == uTdbl(k,4) & ...
				Stim1(:,8) == 0;
	
	subplot(4,3,k)
	contourf(X,Y,Z,-3:.3:3)
	hold on
% 	plotfartlim
	plot(uTdbl(k,1),uTdbl(k,2),'ks','MarkerFaceColor','b')
	plot(uTdbl(k,3),uTdbl(k,4),'ks','MarkerFaceColor','r')
	plot(Sac(sel,8),Sac(sel,9),'k.')
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title('monaural cues double speakers')
end

function plotbincuesgl(Mon,Mont,Azi,Ele,uTsgl,Sacsgl,Stimsgl,str)

len				=	size(uTsgl,1);
for k=1:len
	crit		=	.1;
	idx			=	find( Mon >= Mont(:,k)-crit & Mon <= Mont(:,k)+crit );
	
	[X,Y]		=	meshgrid(unique(Azi),unique(Ele));
	[X,Y,Z]		=	griddata(Azi,Ele,Mon,X,Y);
	
	sel			=	ismember(Stimsgl(:,4:5),uTsgl(k,:),'rows');
	
	subplot(2,2,k)
	contourf(X,Y,Z)
	hold on
% 	plotfartlim
	plot(uTsgl(:,1),uTsgl(:,2),'ks','MarkerFaceColor','w','MarkerSize',15)
	plot(uTsgl(k,1),uTsgl(k,2),'ks','MarkerFaceColor',[.7 .7 .7],'MarkerSize',15)
	plot(Sacsgl(sel,8),Sacsgl(sel,9),'k.')
	plot([mean(Azi(idx)) mean(Azi(idx))],[-100 100],'k-','LineWidth',2)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title(str)
end

function plotbincuedbl(Mon,Mont,Azi,Ele,uTdbl,Sac,Stim1,Stim2,str)

len				=	size(uTdbl,1);
for k=1:len
	crit		=	.1;
	idx			=	find( Mon >= Mont(:,k)-crit & Mon <= Mont(:,k)+crit );
	
	[X,Y]		=	meshgrid(unique(Azi),unique(Ele));
	[X,Y,Z]		=	griddata(Azi,Ele,Mon,X,Y);
	
	sel			=	Stim1(:,4) == uTdbl(k,1) & Stim1(:,5) == uTdbl(k,2) & ...
					Stim2(:,4) == uTdbl(k,3) & Stim2(:,5) == uTdbl(k,4) & ...
					Stim1(:,8) == 0;
	
	subplot(4,3,k)
	contourf(X,Y,Z)
	hold on
% 	plotfartlim
	plot(uTdbl(k,1),uTdbl(k,2),'ks','MarkerFaceColor','b')
	plot(uTdbl(k,3),uTdbl(k,4),'ks','MarkerFaceColor','r')
	plot(Sac(sel,8),Sac(sel,9),'k.')
	plot([mean(Azi(idx)) mean(Azi(idx))],[-100 100],'k-','LineWidth',2)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title(str)
end

function plotpredictsgl(Pred,Azi,Ele,uTsgl,Sacsgl,Stimsgl,str,Pl,Pr)

len				=	size(uTsgl,1);
for k=1:len
	
	[X,Y]		=	meshgrid(unique(Azi),unique(Ele));
	[X,Y,Z]		=	griddata(Azi,Ele,Pred(:,k),X,Y);
	
	sel			=	ismember(Stimsgl(:,4:5),uTsgl(k,:),'rows');
	
	subplot(2,2,k)
	contourf(X,Y,Z)
	hold on
% 	plotfartlim
	plot(uTsgl(:,1),uTsgl(:,2),'ks','MarkerFaceColor','w','MarkerSize',15)
	plot(uTsgl(k,1),uTsgl(k,2),'ks','MarkerFaceColor',[.7 .7 .7],'MarkerSize',15)
	plot(Sacsgl(sel,8),Sacsgl(sel,9),'k.')
	plot(Pl(k,1),Pl(k,2),'kd','MarkerFaceColor',[.7 .7 1],'MarkerSize',15)
	plot(Pr(k,1),Pr(k,2),'kd','MarkerFaceColor',[1 .7 .7],'MarkerSize',15)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title(str)
end

function plotpredictdbl(Pred,Azi,Ele,uTdbl,Sac,Stim1,Stim2,str,Pl,Pr)

len				=	size(uTdbl,1);
for k=1:len
	
	[X,Y]		=	meshgrid(unique(Azi),unique(Ele));
	[X,Y,Z]		=	griddata(Azi,Ele,Pred(:,k),X,Y);
	
	sel			=	Stim1(:,4) == uTdbl(k,1) & Stim1(:,5) == uTdbl(k,2) & ...
					Stim2(:,4) == uTdbl(k,3) & Stim2(:,5) == uTdbl(k,4) & ...
					Stim1(:,8) == 0;
	
	subplot(4,3,k)
	contourf(X,Y,Z)
	hold on
% 	plotfartlim
	plot(uTdbl(k,1),uTdbl(k,2),'ks','MarkerFaceColor','b')
	plot(uTdbl(k,3),uTdbl(k,4),'ks','MarkerFaceColor','r')
	plot(Sac(sel,8),Sac(sel,9),'k.')
	plot(Pl(k,1),Pl(k,2),'kd','MarkerFaceColor',[.7 .7 1],'MarkerSize',15)
	plot(Pr(k,1),Pr(k,2),'kd','MarkerFaceColor',[1 .7 .7],'MarkerSize',15)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('azimuth [deg]')
	ylabel('elevation [deg]')
	title(str)
end
