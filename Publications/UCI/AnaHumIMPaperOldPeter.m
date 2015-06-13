function AnaHumIMPaper
tic
clear all
close all
clc

%-- Flags --%
NewData		=	0;

PlotFig1	=	0;		%-- S0M0 for all frequencies and masker types						--%
PlotFig2	=	0;		%-- Cum. dis. with KS-tests for S0M0, all frequencies and maskers	--% 
PlotFig3	=	0;		%-- Compare sync vs async timing per subject & masker type			--% 
PlotFig4	=	0;		%-- Compare info SD with energ SD per subject & masker type			--%
PlotFig5	=	0;		%-- Space for all frequencies and masker types						--%
PlotFig6	=	0;		%-- Cum. dis. with KS-tests for space, all frequencies and maskers	--%
PlotFig7	=	1;		%-- Spatial release for all stimuli tested							--%
PlotFig8	=	0;		%-- IQR as function of masker location for all stimuli tested		--%
PlotFig9	=	0;		%-- IQR as function of masker location split for  all stimuli tested--%
PlotFig10	=	0;		%-- Correlation spatial release vs IQR								--%
PlotFig11	=	0;		%-- Regression analysis all data and all cues as regressors			--%
PlotFig12	=	0;		%-- Regression split according to sig freq. and spectral range		--%
PlotFig13	=	0;		%-- Regression split according to sig freq., spec range	& mask type	--%
PlotFig14	=	0;		%-- Regression for individual subjects								--%
PlotFig15	=	0;		%-- Regression for individual subjects: residual analysis			--%
PlotFig16	=	0;		%-- Regression split as function of spatial separation				--%
PlotOB		=	0;		%-- Oldenburg S0M0 figure											--%
PlotMaskF	=	0;		%-- Correlation between masker frequency composition and threshold	--%
PlotFried	=	0;		%-- Friedman test for distribution differences						--%
PlotOV		=	0;		%-- Plot a median overview chart									--%
PlotMIQR	=	0;		%-- IQR as function of median										--%
PlotPCA		=	0;		%-- Perform a principal component analysis							--%
PlotStaRef	=	0;		%-- Perform ranksum test against S0Mno condition					--%
PlotS0M0	=	1;		%-- The new Fig. 1													--%
PlotSpat	=	0;		%-- The new spatial plot											--%

Outlier		=	0;		%-- Remove outliers from distributions by applying the Tuckey test	--%
Location	=	0;		%-- Figs. 1 & 2: possible values are 0 = S0M0 & 80 = S0M80			--%
Utype		=	[1 2];	%-- Figs. 5 & 6: possible values [1 2] or [4 5] or any combination	--%

%-- Variables --%
if( NewData )
	pname		=	[	{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI032/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI036/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI037/'}; ...	%-- AP best --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI039/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI042/'}; ...	%-- AP worst --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI057/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP/UCI058/'}; ...
						...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI031/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI033/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI036/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI042/'}; ...	%-- AP worst --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI055/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI057/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI058/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/AP2/UCI059/'}; ...
						...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI031/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI032/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI033/'}; ...	%-- LP only --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI036/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI039/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI042/'}; ...	%-- AP worst --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI054/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI055/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/LP/All/UCI056/'}; ...
						...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI031/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI032/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI033/'}; ...	%-- LP only --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI036/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI039/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI042/'}; ...	%-- AP worst --%
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI054/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI055/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI056/'}; ...
						{'/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/HP/All/UCI059/'}; ...
					];
	
	%-- Main --%
	D	=	loaddat(pname);
	save('/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/SummaryNov2012.mat','D')
else
	load('/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/SummaryNov2012.mat')
end

% Ufreq	=	unique(D(:,2));
% Nfreq	=	length(Ufreq);
% %-- First correct for signal in silence threshold --%
% for k=1:Nfreq
% 	%-- Get control for individual subjects --%
% 	sel		=	D(:,2) == Ufreq(k);
% 	D(sel,:)=	corrctrlindivsub(D(sel,:));
% end
% %--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
% %-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
% sel		=	D(:,4) == 0 & D(:,5) ~= -80 & D(:,2) == 4000 & D(:,17) == 1;
% d		=	D(sel,:);
% d(:,5)	=	d(:,5)+20;
% D		=	d;
% 
% save('/Users/pbremen/Work/Experiments/Irvine/Data/Human/BeepBoop2010/NHforCI_S0M0_only_HP.mat','D')
% keyboard

%-- Plotting --%
if( PlotFig1 )
	plotfig1(D,Outlier,Location)								%#ok<*UNRCH>
end
if( PlotFig2 )
	plotdiscomp(D,Outlier,Location)
end
if( PlotFig3 )
	plottimecorr(D,Location)
end
if( PlotFig4 )
	plotsdcorr(D,Location)
end
if( PlotFig5 )
	plotfig5(D,Outlier,Utype)
end
if( PlotFig6 )
	plotdiscompspace(D,Outlier,Utype)
end
if( PlotFig7 )
	plotspatrel(D,Outlier)
end
if( PlotFig8 )
	plotiqr(D,Outlier)
end
if( PlotFig9 )
	plotiqr2(D,Outlier)
end
if( PlotFig10 )
	plotcorspatiqr(D,Outlier)
end
if( PlotFig11 )
	plotregressall(D,Outlier)
end
if( PlotFig12 )
	plotregress(D,Outlier)
end
if( PlotFig13 )
	plotregresstype(D,Outlier)
end
if( PlotFig14 )
	plotregressubj(D,Outlier)
end
if( PlotFig15 )
	plotregressubjres(D,Outlier)
end
if( PlotFig16 )
	plotregressspace(D,Outlier)
end
if( PlotOB )
	plotob(D,Outlier,Location)								%#ok<*UNRCH>
end
if( PlotMaskF )
	plotcorrmask(D)
end
if( PlotFried )
	plotfried(D)
end
if( PlotOV )
	plotov(D)
end
if( PlotMIQR )
	plotmiqr(D)
end
if( PlotPCA )
	plotpca(D)
end
if( PlotStaRef )
	plotstatref(D)
end
if( PlotS0M0 )
	plotsomo(D)
end
if( PlotSpat )
	plotspat(D,Utype)
end

%-- Wrapping up --%
tend	=	( round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%-- Locals --%
function plotfig1(D,Outlier,Loc)

if( nargin < 2 )
	Outlier	=	0;
end
if( nargin < 3 )
	Loc		=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	[5 4 2 1];%[4 5 1 2];		%-- Sorting: eMBD eMBS iMBD iMBS --%
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Ntime);
yy		=	[-5 95];

Usubj	=	selectsubj(D,[600 4000],Loc,[0 1],[1 2],[0 1]);
Nsubj	=	length(Usubj);

for k=1:Nfilt
% 	Usubj	=	selectsubj(D,[600 4000],Loc,[0 1],[1 2],Ufilt(k));
% 	Nsubj	=	length(Usubj);
	
	col		=	linspace(0,1,Nsubj)';
	red		=	flipud( [ones(Nsubj,1) repmat(col,1,2)] );
	blue	=	flipud( [repmat(col,1,2) ones(Nsubj,1)] );

	cnt		=	1;
	
	figure
	for l=1:Nfreq
		if( l == 1 )
			pcol	=	'r';
			pmk		=	'-';
			col		=	red;
			mk		=	'ko';
			offset	=	[-.3 -.05];
		elseif( l == 2 )
			pcol	=	'b';
			pmk		=	'-';
			col		=	blue;
			mk		=	'ko';
			offset	=	[.05 .3];
		end
		
		for m=1:Ntime
			if( Utime(m) == 0 )
				str		=	'asynchronous';
			else
				str		=	'synchronous';
			end
			
			for n=1:Ntype
				%-- Get control for all subjects --%
				cel		=	D(:,2) == Ufreq(l) & D(:,8) == 2 & D(:,5) == -80;
				CA		=	getctrl(D(cel,:),-80);
				
				%-- Current selection for all subjects --%
				if( Utype(n) == 4 || Utype(n) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
					sel	=	D(:,2) == Ufreq(l) & D(:,4) == Loc & ...
							D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,5) ~= -80;
				else
					sel	=	D(:,17) == Ufilt(k) & D(:,4) == Loc & D(:,2) == Ufreq(l) & ...
							D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,5) ~= -80;
				end
				
				%-- Median over all subjects --%
				A		=	median( D(sel,1)-CA(1,1) );
				
				%-- Get 25 & 75 percentiles --%
				[P,Crit]=	getpercentile( D(sel,1)-CA(1,1),[25 75] );
				
				%-- Patch & subject offset --%
				mx		=	n + offset;
				inc		=	diff(mx) / Nsubj;
				
				h		=	[];
				L		=	cell(0,1);
				
				%-- Get data from individual subjects --%
				for o=1:Nsubj
					if( Utype(n) == 4 || Utype(n) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
						sel		=	D(:,2) == Ufreq(l) & D(:,4) == Loc & ...
									D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o);
					else
						sel		=	D(:,17) == Ufilt(k) & D(:,4) == Loc & D(:,2) == Ufreq(l) & ...
									D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o);
					end
					d			=	D(sel,:);
					
					xloc		=	mx(1) + inc * (o-1) + inc/2;
					subplot(r,c,m)
					plot([xloc xloc],yy,'k:')
					hold on
					
					if( ~isempty(d) )
						L(cnt)	=	{['S' num2str(Usubj(o))]};
						
						%-- Get control data for normalization --%
						cel		=	D(:,2) == Ufreq(l) & D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(o);
						C		=	D(cel,:);
						C		=	getctrl(C,-80);
						d		=	[d(:,1) - C(1,1) d(:,2:end)];
						
						if( Outlier )
							%-- Remove outliers according to Tuckey --%
							sel		=	d(:,1) >= (P(1) - Crit) & d(:,1) <= (P(2) + Crit);
							
							out		=	d(~sel,:);
							xlocout	=	zeros( size(out,1),1 ) + mx(1) + inc * (o-1) + inc/2;
							
							plot(xlocout,out(:,1),'kd','MarkerFaceColor',col(o,:))
							
							d		=	d(sel,:);
						end
						
						xloc	=	zeros( size(d,1),1 ) + mx(1) + inc * (o-1) + inc/2;
						
						h(cnt)	=	plot(xloc,d(:,1),mk,'MarkerFaceColor',col(o,:));	%#ok<AGROW>
						cnt		=	cnt + 1;
					end
				end
				
				plot([.5 Ntype+.5],[0 0],'k--')
				plot(mx,[A A],'-','Color',pcol,'LineWidth',2)
				hp = patch([mx fliplr(mx)],[P(2) P(2) P(1) P(1)],pcol,'LineStyle',pmk);
				text(mx(1),90,['IQR= ' num2str(P(2)-P(1))],'FontName','Arial','FontWeight','bold','FontSize',12)
				set(hp,'EdgeColor',pcol,'FaceColor','none')
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',14)
				set(gca,'XTick',1:Ntype,'XTickLabel',[{'eC'},{'eR'},{'iC'},{'iR'}], ...
						'YTick',0:15:95)
				xlim([.5 Ntype+.5])
				ylim(yy)
				xlabel('masker type')
				ylabel('masked threshold [dB SPL]')
				title(str)
				if( l == 1 && m == 1 && n == 1 )
					L	=	L(h ~= 0);
					h	=	h(h ~= 0);
					legend(h,L,'Location','SouthWest','Orientation','horizontal')
					legend('boxoff')
				end
				if( l == 2 && m == 2 && n == 1 )
					L	=	L(h ~= 0);
					h	=	h(h ~= 0);
					legend(h,L,'Location','SouthWest','Orientation','horizontal')
					legend('boxoff')
				end
			end
		end
	end
end

function plotdiscomp(D,Outlier,Loc)

if( nargin < 2 )
	Outlier	=	0;
end
if( nargin < 3 )
	Loc		=	0;
end

Alpha	=	0.01;
Bin		=	-20:5:95;

%--			   1   2    3       4      5	--%
%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
% [H,~,I,C,CD,CDI]	=	getthrhis(D,Bin,Outlier);
[H,~,I,C]	=	getthrhis(D,Bin,Outlier);

Ufreq	=	unique(I(:,1));
Nfreq	=	length(Ufreq);

Utime	=	unique(I(:,3));
Ntime	=	length(Utime);

Ufilt	=	unique(I(:,4));
Nfilt	=	length(Ufilt);

Utype	=	[1 4 2 5];
Ntype	=	length(Utype);

[r,c]	=	FactorsForSubPlot(Nfreq*Ntime);
mk		=	[{'-'},{'--'},{'-'},{'--'}];
% col		=	[1 0 0; 1 0 0; 0 0 1; 0 0 1];
bcol	=	{[1 0 0; 1 0 0; 1 .5 .5; 1 .5 .5]; [0 0 1; 0 0 1; .5 .5 1; .5 .5 1]};
xx		=	[min(Bin)-5 max(Bin)+5];
yy		=	[-.1 1.1];

for k=1:Nfilt
	if( Ufilt(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
	
	cnt	=	1;
	figure
	
	for l=1:Ntime
		if( Utime(l) == 0 )
			Timing	=	'asynchronous';
		elseif( Utime(l) == 1 )
			Timing	=	'synchronous';
		end
		
		for m=1:Nfreq
% 			cd		=	cumsum( CD(m,:) );
% 			cd		=	cd ./ max(cd);
% 			cdi		=	CDI(k,:);
			
			col		=	bcol{m,1};

			L		=	cell(Ntype,1);
% 			h		=	nan(Ntype+1,1);
			h		=	nan(Ntype,1);
			
			sel		=	I(:,1) == Ufreq(m) & I(:,2) == Loc & I(:,3) == Utime(l) & ...
						I(:,4) == Ufilt(k);
			
			KS(1,:)	=	dokstest(C(sel,:),I(sel,end),[1 4],Alpha,Outlier);
			KS(2,:)	=	dokstest(C(sel,:),I(sel,end),[2 5],Alpha,Outlier);
			
			KS2(1,:)	=	dokstest(C(sel,:),I(sel,end),[1 2],Alpha,Outlier);
			KS2(2,:)	=	dokstest(C(sel,:),I(sel,end),[4 5],Alpha,Outlier);
			
			%-- Pooled energetic maskers as a reference--%
			%-- Filter should not be included in selection --%
% 			sel		=	I(:,1) == Ufreq(m) & I(:,2) == Loc & I(:,3) == Utime(l) & ...
% 						I(:,4) == Ufilt(k) & (I(:,5) == 4 | I(:,5) == 5);
			sel		=	I(:,1) == Ufreq(m) & I(:,2) == Loc & I(:,3) == Utime(l) & ...
						(I(:,5) == 4 | I(:,5) == 5);
			M		=	C(sel,1);
			M		=	cell2mat(M(:));
			
			if( Outlier )
				%-- Get 25 & 75 percentiles --%
				[P,Crit]=	getpercentile(M,[25 75]);
				
				%-- Remove outliers according to Tuckey --%
				sel		=	M >= (P(1) - Crit) & M <= (P(2) + Crit);
				M		=	M(sel,:);
			end
			
			M		=	median( M );
			
			subplot(r,c,cnt)
			plot([M M],yy,'k--');
			hold on
			plot([0 0],yy,'k:')
% 			h(1) = plot(Bin,cd,'k-','LineWidth',2);
			xlim(xx)
			ylim(yy)
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlabel('masked threshold [dB SPL]')
			ylabel('probability')
			title([num2str(Ufreq(m)) ' Hz ' ftr ' ' Timing])
			axis('square')
			
% 			L(1,1)	=	{['T_{Q}; N= ' num2str(cdi(1,2))]};
			
			for o=1:Ntype
				sel		=	I(:,1) == Ufreq(m) & I(:,2) == Loc & I(:,3) == Utime(l) & ...
							I(:,4) == Ufilt(k) & I(:,5) == Utype(o);
				
				d		=	cumsum( H(sel,:) );
				d		=	d ./ max(d);
				
% 				h(o+1,1)=	plot(Bin,d,mk{o},'Color',col(o,:),'LineWidth',2);
				h(o,1)=	plot(Bin,d,mk{o},'Color',col(o,:),'LineWidth',2);
				if( Utype(o) == 1 )
% 					L(o+1,1)	=	{['iR; N= ' num2str(KS(1,3))]};
					L(o,1)	=	{['iR; N= ' num2str(KS(1,3))]};
				elseif( Utype(o) == 2 )
% 					L(o+1,1)	=	{['iC; N= ' num2str(KS(2,3))]};
					L(o,1)	=	{['iC; N= ' num2str(KS(2,3))]};
				elseif( Utype(o) == 4 )
% 					L(o+1,1)	=	{['eR; N= ' num2str(KS(1,4))]};
					L(o,1)	=	{['eR; N= ' num2str(KS(1,4))]};
				elseif( Utype(o) == 5 )
% 					L(o+1,1)	=	{['eC; N= ' num2str(KS(2,4))]};
					L(o,1)	=	{['eC; N= ' num2str(KS(2,4))]};
				end
			end
			
			text(-20,1,['iR/eR: \alpha=' num2str(Alpha) '; p=' num2str(KS(1,1))],'FontName','Arial','FontWeight','bold','FontSize',12,'Color',col(1,:))
			text(-20,.9,['iC/eC: \alpha=' num2str(Alpha) '; p=' num2str(KS(2,1))],'FontName','Arial','FontWeight','bold','FontSize',12,'Color',col(3,:))
			text(-20,.7,['iR/iC: \alpha=' num2str(Alpha) '; p=' num2str(KS2(1,1))],'FontName','Arial','FontWeight','bold','FontSize',12)
			text(-20,.6,['eR/eC: \alpha=' num2str(Alpha) '; p=' num2str(KS2(2,1))],'FontName','Arial','FontWeight','bold','FontSize',12)
			legend(h,L,'Location','SouthEast')
			legend('boxoff')
			
			cnt	=	cnt + 1;
		end
	end
end

function plottimecorr(D,Loc)

if( nargin < 2 )
	Loc		=	0;
end

xx		=	[-10 85];
yy		=	[-10 85];

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Usubj	=	selectsubj(D,Ufreq,Loc,Utime,Utype,Ufilt);
Nsubj	=	length(Usubj);

%-- Make colormap --%
col		=	linspace(0,1,Nsubj+1)';
col		=	repmat(col,1,3);

%-- Legend handles --%
L		=	cell(Nsubj,1);
h		=	nan(Nsubj,1);

[r,c]	=	FactorsForSubPlot(Nfreq*Ntype);

for k=1:Nfilt
	cnt	=	1;
	figure
	
	for l=1:Ntype
		if( Utype(l) == 1 )
			Stm	=	'iR';
		elseif( Utype(l) == 2 )
			Stm	=	'iC';
		elseif( Utype(l) == 4 )
			Stm	=	'eR';
		elseif( Utype(l) == 5 )
			Stm	=	'eC';
		end
		
		for m=1:Nfreq
			
			M1	=	[];
			M2	=	[];
			
			subplot(r,c,cnt)
			plot(xx,yy,'k:')
			hold on
			xlim(xx)
			ylim(yy)
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlabel('asynchronous')
			ylabel('synchronous')
			title([Stm ' S0M' num2str(Loc) ' f_{sig}= ' num2str(Ufreq(m)) ' Hz'])
			axis('square')
			
			for o=1:Nsubj
				L(o,1)	=	{['S' num2str(Usubj(o))]};
				
				%-- Get control for all subjects --%
				cel		=	D(:,2) == Ufreq(m) & D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(o);
				CA		=	getctrl(D(cel,:),-80);
				
				%-- Current selection for all subjects --%
				if( Utype(l) == 4 || Utype(l) == 5 )
% 					sel	=	D(:,2) == Ufreq(m) & D(:,7) == 0 & ...
% 							D(:,4) == Loc & D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
					sel	=	D(:,2) == Ufreq(m) & D(:,7) == 0 & ...
							D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
				else
% 					sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(m) & D(:,7) == 0 & ...
% 							D(:,4) == Loc & D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
					sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(m) & D(:,7) == 0 & ...
							D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
				end
				
% 				sel	=	D(:,2) == Ufreq(m) & D(:,7) == 0 & ...
% 						D(:,8) == Utype(l) & D(:,16) == Usubj(o);
				
				d1		=	D(sel,1)-CA(1,1);
				m1		=	mean(d1(:,1));
				s1		=	std(d1(:,1));
				
				if( Utype(l) == 4 || Utype(l) == 5 )
% 					sel	=	D(:,2) == Ufreq(m) & D(:,7) == 1 & ...
% 							D(:,4) == Loc & D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
					sel	=	D(:,2) == Ufreq(m) & D(:,7) == 1 & ...
							D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
				else
% 					sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(m) & D(:,7) == 1 & ...
% 							D(:,4) == Loc & D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
					sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(m) & D(:,7) == 1 & ...
							D(:,8) == Utype(l) & D(:,16) == Usubj(o) & D(:,5) ~= -80;
				end
				
% 				sel	=	D(:,2) == Ufreq(m) & D(:,7) == 1 & ...
% 						D(:,8) == Utype(l) & D(:,16) == Usubj(o);
						
				d2		=	D(sel,1)-CA(1,1);
				m2		=	mean(d2(:,1));
				s2		=	std(d2(:,1));
				
				M1		=	[M1; m1];							%#ok<AGROW>
				M2		=	[M2; m2];							%#ok<AGROW>
				
				h(o,1)	=	errorbarxy(m1,m2,s1,s2,'ko','MarkerEdgeColor','k','MarkerFaceColor',col(o,:));
			end
			
			[~,stats]	=	fitline( M1(~isnan(M1)),M2(~isnan(M1)) );
			
			yfit		=	stats.Coef(1) .* xx + stats.Coef(2);
			plot(xx,yfit,'k-')
			text(xx(2)+15,yy(2)-10,['y= ' num2str(dround(stats.Coef(1))) '*x+' num2str(dround(stats.Coef(2)))], ...
							'FontName','Arial','FontWeight','bold','FontSize',12)
			text(xx(2)+15,yy(2)-25,['R^2= ' num2str(dround(stats.R2)) '; p= ' num2str(dround(stats.P,10^6))], ...
							'FontName','Arial','FontWeight','bold','FontSize',12)
			text(xx(2)+15,yy(2)-40,['N= ' num2str(stats.N)], ...
							'FontName','Arial','FontWeight','bold','FontSize',12)
% 			text(xx(1)+10,yy(2)-10,['y= ' num2str(dround(stats.Coef(1))) '*x+' num2str(dround(stats.Coef(2)))], ...
% 							'FontName','Arial','FontWeight','bold','FontSize',12)
% 			text(xx(1)+10,yy(2)-25,['R^2= ' num2str(dround(stats.R2))], ...
% 							'FontName','Arial','FontWeight','bold','FontSize',12)
% 			text(xx(1)+10,yy(2)-40,['N= ' num2str(stats.N)], ...
% 							'FontName','Arial','FontWeight','bold','FontSize',12)
			if( cnt == 5 )
				legend(h,L,'Location','WestOutside')
				legend('boxoff')
			else
				legend(h(1),L(1),'Location','WestOutside')
				legend('boxoff')
			end
			cnt	=	cnt + 1;
		end
	end
end

function plotsdcorr(D,Loc)

if( nargin < 2 )
	Loc		=	0;
end

% xx		=	[-10 95];
% yy		=	[-10 95];
xx		=	[-1 10];
yy		=	[-1 22];

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Usubj	=	selectsubj(D,Ufreq,Loc,Utime,Utype,Ufilt);
Nsubj	=	length(Usubj);

%-- Make colormap --%
col		=	linspace(0,1,Nsubj+1)';
col		=	repmat(col,1,3);

%-- Legend handles --%
L		=	cell(Nsubj,1);
h		=	nan(Nsubj,1);

[c,r]	=	FactorsForSubPlot(Nfreq*2);

for k=1:Nfilt
	if( Ufilt(k) == 0 )
		Filt	=	'all-pass';
	else
		Filt	=	'band-pass';
	end
	
	for l=1:Ntime
		if( Utime(l) == 0 )
			Time	=	'async';
		else
			Time	=	'sync';
		end
		
		cnt	=	1;
		figure
	
		for m=1:Nfreq
			for p=1:2	%-- Type loop --%
				
				if( p == 1 )
					Stm	=	'iR';
				else
					Stm	=	'iC';
				end
				
				M1	=	[];
				M2	=	[];
				S1	=	[];
				S2	=	[];
				
				subplot(r,c,cnt)
				plot(yy,yy,'k:')
				hold on
				xlim(xx)
				ylim(yy)
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
				xlabel('energetic SD [dB SPL]')
				ylabel('informational SD [dB SPL]')
				title([Filt ' ' Stm '_{' Time '}' ' S0M' num2str(Loc) ' f_{sig}= ' num2str(Ufreq(m)) ' Hz'])
				axis('square')
			
				for o=1:Nsubj
					L(o,1)	=	{['S' num2str(Usubj(o))]};
					
					%-- Get control for all subjects --%
					cel		=	D(:,2) == Ufreq(m) & D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(o);
					CA		=	getctrl(D(cel,:),-80);
					
					%-- Info masker current selection for all subjects --%
					sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(m) & D(:,7) == Utime(l) & ...
							D(:,4) == Loc & D(:,8) == p & D(:,16) == Usubj(o);
						
					d1		=	D(sel,1)-CA(1,1);
					m1		=	mean(d1(:,1));
					s1		=	std(d1(:,1));
					
					%-- Energetic masker current selection for all subjects --%
					sel		=	D(:,2) == Ufreq(m) & D(:,7) == Utime(l) & ...
								D(:,4) == Loc & D(:,8) == p+3 & D(:,16) == Usubj(o);
					
					d2		=	D(sel,1)-CA(1,1);
					m2		=	mean(d2(:,1));
					s2		=	std(d2(:,1));
					
					M1		=	[M1; m1];						%#ok<AGROW>
					M2		=	[M2; m2];						%#ok<AGROW>
					S1		=	[S1; s1];						%#ok<AGROW>
					S2		=	[S2; s2];						%#ok<AGROW>
					
					h(o,1)	=	plot(s2,s1,'ko','MarkerEdgeColor','k','MarkerFaceColor',col(o,:));
% 					h(o,1)	=	errorbarxy(m2,m1,s2,s1,'ko','MarkerEdgeColor','k','MarkerFaceColor',col(o,:));
				end
				
% 				[~,stats]	=	fitline( M2(~isnan(M1)),M1(~isnan(M1)) );
				[~,stats]	=	fitline( S2(~isnan(S2)),S1(~isnan(S2)) );
				yfit		=	stats.Coef(1) .* xx + stats.Coef(2);
				plot(xx,yfit,'k-')
				text(xx(1)+1,yy(2)-2,['y= ' num2str(dround(stats.Coef(1))) '*x+' num2str(dround(stats.Coef(2)))], ...
					'FontName','Arial','FontWeight','bold','FontSize',12)
				text(xx(1)+1,yy(2)-5,['R^2= ' num2str(dround(stats.R2))], ...
					'FontName','Arial','FontWeight','bold','FontSize',12)
				text(xx(1)+1,yy(2)-8,['N= ' num2str(stats.N)], ...
					'FontName','Arial','FontWeight','bold','FontSize',12)
				set(gca,'XTick',0:4:xx(end),'YTick',0:4:yy(end))
% 				if( cnt == 2 )
% 					legend(h,L,'Location','WestOutside')
% 					legend('boxoff')
% 				end
				cnt	=	cnt + 1;
			end
		end
	end
end

function plotfig5(D,Outlier,Utype)

if( nargin < 2 )
	Outlier	=	0;
end
if( nargin < 3 )
	Utype	=	[1 2];
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

[c,r]	=	FactorsForSubPlot(Ntime*Ntype);
yy		=	[-10 95];

col		=	linspace(0,1,Nsubj)';
red		=	flipud( [ones(Nsubj,1) repmat(col,1,2)] );
blue	=	flipud( [repmat(col,1,2) ones(Nsubj,1)] );

Pall	=	[];

for k=1:Nfilt
	if( Utime(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
		
	cnt		=	1;
	
	figure
	for l=1:Ntime
		if( Utime(l) == 0 )
			str		=	'asynchronous';
		else
			str		=	'synchronous';
		end
			
		for m=1:Ntype
			if( Utype(m) == 1 )
				msk	=	'iR';
			elseif( Utype(m) == 2 )
				msk	=	'iC';
			elseif( Utype(m) == 4 )
				msk	=	'eR';
			elseif( Utype(m) == 5 )
				msk	=	'eC';
			end
				
			subplot(r,c,cnt)
			
			for n=1:Nfreq
				if( n == 1 )
					pcol	=	'r';
					pmk		=	'-';
					col		=	red;
					mk		=	'ko';
					offset	=	[-.3 -.05];
				elseif( n == 2 )
					pcol	=	'b';
					pmk		=	'-';
					col		=	blue;
					mk		=	'ko';
					offset	=	[.05 .3];
				end
		
				%-- Get control for all subjects --%
				cel		=	D(:,2) == Ufreq(n) & D(:,8) == 2 & D(:,5) == -80;
				CA		=	getctrl(D(cel,:),-80);
				
				if( Utype(m) == 4 || Utype(m) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
					sel	=	D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,2) == Ufreq(n) & D(:,5) ~= -80;
				else
					sel	=	D(:,17) == Ufilt(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,2) == Ufreq(n) & D(:,5) ~= -80;
				end
				d		=	D(sel,:);
				
				Uloc	=	unique(d(:,4));
				Nloc	=	length(Uloc);
				for o=1:Nloc
					sel	=	d(:,4) == Uloc(o);
					dd	=	d(sel,:);
					
					%-- Median over all subjects --%
					A	=	median( dd(:,1)-CA(1,1) );
					
					%-- Get 25 & 75 percentiles --%
					[P,Crit]=	getpercentile( dd(:,1)-CA(1,1),[25 75] );
					
					%-- Patch & subject offset --%
					mx		=	o + offset;
					inc		=	diff(mx) / Nsubj;
					
					h		=	[];
					L		=	cell(0,1);
					Ptmp	=	[];
					cnt2	=	1;
					
					for p=1:Nsubj
						sel		=	dd(:,16) == Usubj(p);
						ddd		=	dd(sel,:);
						
						xloc	=	mx(1) + inc * (p-1) + inc/2;
						
						plot([xloc xloc],yy,'k:')
						hold on
						
						if( ~isempty(ddd) )
							%-- Get control data for normalization --%
							cel		=	D(:,2) == Ufreq(n) & D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(p);
							C		=	D(cel,:);
							C		=	getctrl(C,-80);
							ddd		=	[ddd(:,1) - C(1,1) ddd(:,2:end)];
							
							Pz		=	getpercentile( ddd(:,1)-C(1,1),[25 75] );
							Ptmp(cnt2)	=	Pz(2)-Pz(1);					%#ok<AGROW>
							
							if( Outlier )
								%-- Remove outliers according to Tuckey --%
								sel		=	ddd(:,1) >= (P(1) - Crit) & ddd(:,1) <= (P(2) + Crit);
								
								out		=	ddd(~sel,:);
								xlocout	=	zeros( size(out,1),1 ) + mx(1) + inc * (p-1) + inc/2;
								
								plot(xlocout,out(:,1),'kd','MarkerFaceColor',col(p,:))
								
								ddd		=	ddd(sel,:);
							end
							
							xloc	=	zeros( size(ddd,1),1 ) + mx(1) + inc * (p-1) + inc/2;
							
							h(cnt2)	=	plot(xloc,ddd(:,1),mk,'MarkerFaceColor',col(p,:));	%#ok<AGROW>
							L(cnt2)	=	{['S' num2str(Usubj(p))]};
							cnt2	=	cnt2 + 1;
						end
					end
					plot([.5 Nloc+.5],[0 0],'k--')
					plot(mx,[A A],'-','Color',pcol,'LineWidth',2)
					hp = patch([mx fliplr(mx)],[P(2) P(2) P(1) P(1)],pcol,'LineStyle',pmk);
					set(hp,'EdgeColor',pcol,'FaceColor','none')
					text(mx(1),75,['IQR= ' num2str(dround(P(2)-P(1)))],'FontName','Arial','FontWeight','bold','FontSize',12)
					set(gca,'FontName','Arial','FontWeight','bold','FontSize',14)
					set(gca,'XTick',1:Nloc,'XTickLabel',Uloc,'YTick',0:15:95)
					xlim([.5 Nloc+.5])
					ylim(yy)
					xlabel('masker location [deg]')
					ylabel('masked threshold [dB SPL]')
					title([msk ' ' ftr ' ' str])
					if( l == 1 && m == 1 && n == 1 )
						L	=	L(h ~= 0);
						h	=	h(h ~= 0);
						legend(h,L,'Location','NorthWest','Orientation','horizontal')
						legend('boxoff')
					end
					if( l == 2 && m == 1 && n == 2 )
						L	=	L(h ~= 0);
						h	=	h(h ~= 0);
						legend(h,L,'Location','NorthWest','Orientation','horizontal')
						legend('boxoff')
					end
				end
				Pall	=	[Pall Ptmp];						%#ok<AGROW>
			end
			cnt	=	cnt + 1;
		end
	end
end

disp(['Average IQR = ' num2str(dround(mean(Pall)))])

function plotdiscompspace(D,Outlier,Utype)

if( nargin < 2 )
	Outlier	=	0;
end
if( nargin < 3 )
	Utype	=	[1 2];
end
	
Alpha	=	0.01;%001;
Bin		=	-20:5:95;

%--			   1   2    3       4      5	--%
%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
% [H,~,I,C,CD,CDI]	=	getthrhis(D,Bin,Outlier);
[H,~,I,C]	=	getthrhis(D,Bin,Outlier);

Ufreq	=	unique(I(:,1));
Nfreq	=	length(Ufreq);

Utime	=	unique(I(:,3));
Ntime	=	length(Utime);

Ufilt	=	unique(I(:,4));
Nfilt	=	length(Ufilt);

Ntype	=	length(Utype);

[r,c]	=	FactorsForSubPlot(Nfreq*Ntime);
mk		=	[{'--'},{'--'},{'-'},{'-'}];
xx		=	[min(Bin)-5 max(Bin)+5];
yy		=	[-.1 1.1];

for k=1:Nfilt
	if( Ufilt(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
		
	cnt		=	1;
	
	figure
	for l=1:Ntime
		if( Utime(l) == 0 )
			Timing	=	'asynchronous';
		elseif( Utime(l) == 1 )
			Timing	=	'synchronous';
		end
		
		for m=1:Nfreq
			
			L		=	cell(Ntype,1);
			h		=	nan(Ntype,1);
			cnt2	=	1;
			
			subplot(r,c,cnt)
			for n=1:Ntype
				if( Utype(n) == 1 )
					msk	=	'iR';
					mk	=	'--';
				elseif( Utype(n) == 2 )
					msk	=	'iC';
					mk	=	'-';
				elseif( Utype(n) == 4 )
					msk	=	'eR';
					mk	=	'--';
				elseif( Utype(n) == 5 )
					msk	=	'eC';
					mk	=	'-';
				end
				
				%--			   1   2    3       4      5	--%
				%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
				sel	=	I(:,4) == Ufilt(k) & I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m);
				dI	=	I(sel,:);
				dH	=	H(sel,:);
				
				Uloc	=	unique(dI(:,2));
				Nloc	=	length(Uloc);
				
				col		=	linspace(0,.8,Nloc)';
				red		=	flipud( [ones(Nloc,1) repmat(col,1,2)] );
				blue	=	flipud( [repmat(col,1,2) ones(Nloc,1)] );
				if( m == 1 )
					col	=	red;
				elseif( m == 2 )
					col	=	blue;
				end
				
				%-- Pooled energetic maskers as a reference--%
				sel		=	I(:,1) == Ufreq(m) & I(:,2) == 0 & I(:,3) == Utime(l) & ...
							(I(:,5) == 4 | I(:,5) == 5);
				M		=	C(sel,1);
				M		=	cell2mat(M(:));
				
				if( Outlier )
					%-- Get 25 & 75 percentiles --%
					[P,Crit]=	getpercentile(M,[25 75]);
					
					%-- Remove outliers according to Tuckey --%
					sel		=	M >= (P(1) - Crit) & M <= (P(2) + Crit);
					M		=	M(sel,:);
				end
				
				M	=	median( M );
				
				disp([num2str(Ufreq(m)) ' Hz ' ftr ' ' Timing ' ' msk])
				
				%-- Kolmogorov-Smirnov tests --%
				sel				=	I(:,1) == Ufreq(m) & I(:,3) == Utime(l) & ...
									I(:,4) == Ufilt(k) & I(:,5) == Utype(n);
				
				KW				=	dokruskal(C(sel,:),I(sel,2));
				
				if( Utype(n) == 2 )
					tLoc		=	[0 20];
					KS(1,:)		=	dokstest(C(sel,:),I(sel,2),tLoc,Alpha,Outlier);
				else
					tLoc		=	[0 80];
					KS(1,:)		=	dokstest(C(sel,:),I(sel,2),tLoc,Alpha,Outlier);
				end
				
				%-- Plot it! --%
				subplot(r,c,cnt)
				plot([M M],yy,'k--');
				hold on
				plot([0 0],yy,'k:')
				xlim(xx)
				ylim(yy)
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
				xlabel('masked threshold [dB SPL]')
				ylabel('probability')
				title([num2str(Ufreq(m)) ' Hz ' ftr ' ' Timing])
				axis('square')
				
				for o=1:Nloc
					sel	=	dI(:,2) == Uloc(o,:);
					ddH	=	dH(sel,:);
					
					ddH	=	cumsum( ddH );
					ddH	=	ddH ./ max(ddH);
					
					L(cnt2,1)	=	{[msk ' @' num2str(Uloc(o,:)) '; N= ' num2str(sum(KS(1,3)))]};
					
					h(cnt2) = plot(Bin,ddH,mk,'Color',col(o,:),'LineWidth',2);
					cnt2	=	cnt2 + 1;
				end
% 				text(-20,1-(n-1)*.1,[msk '_{' num2str(tLoc(1)) '/' num2str(tLoc(2)) '}= ' num2str(KS(1,1)) '; p<' num2str(Alpha)],'FontName','Arial','FontWeight','bold','FontSize',12,'Color','k')
% 				text(-20,1-(n-1)*.1,[msk '_{' num2str(tLoc(1)) '/\Deltamin}= ' num2str(KW) '; p>' num2str(Alpha)],'FontName','Arial','FontWeight','bold','FontSize',12,'Color','k')
				text(-20,1-(n-1)*.1,[msk '_{' num2str(tLoc(1)) '/\Deltamin}= ' num2str(KW) '; \alpha=' num2str(Alpha) '; p=' num2str(KS(1,1))],'FontName','Arial','FontWeight','bold','FontSize',12,'Color','k')
			end
			legend(h,L,'Location','SouthEast')
			legend('boxoff')
			
			cnt	=	cnt + 1;
		end
	end
end

function plotspatrel(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

Bin		=	-20:5:95;

%--			   1   2    3       4      5	--%
%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
% [H,~,I,C,CD,CDI]	=	getthrhis(D,Bin,Outlier);
[~,~,I,C]	=	getthrhis(D,Bin,Outlier);

Ufreq	=	unique(I(:,1));
Nfreq	=	length(Ufreq);

Utime	=	unique(I(:,3));
Ntime	=	length(Utime);

Ufilt	=	unique(I(:,4));
Nfilt	=	length(Ufilt);

Utype	=	unique(I(:,5));
Ntype	=	length(Utype);

[c,r]	=	FactorsForSubPlot(Ntime*Nfilt);

cnt		=	1;
	
figure
for k=1:Nfilt
	if( Utime(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
		
	for l=1:Ntime
		if( Utime(l) == 0 )
			Timing	=	'asynchronous';
		elseif( Utime(l) == 1 )
			Timing	=	'synchronous';
		end
		
		L		=	cell(Nfreq*Ntype,1);
		h		=	nan(Nfreq*Ntype,1);
		cnt2	=	1;
		
		subplot(r,c,cnt)
		plot([5 95],[0 0],'k:')
		hold on
		
		for m=1:Nfreq
			if( Ufreq(m) == 600 )
				col	=	'r';
			elseif( Ufreq(m) == 4000 )
				col	=	'b';
			end
			
			for n=1:Ntype
				if( Utype(n) == 1 )
					msk	=	'iR';
					mk	=	's';
				elseif( Utype(n) == 2 )
					msk	=	'iC';
					mk	=	'v-';
				elseif( Utype(n) == 4 )
					msk	=	'eR';
					mk	=	'd';
				elseif( Utype(n) == 5 )
					msk	=	'eC';
					mk	=	'^';
				end
				
				L(cnt2,1)	=	{[num2str(Ufreq(m)) ' Hz; ' msk]};
				
				%--			   1   2    3       4      5	--%
				%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
				if( Utype(n) == 4 || Utype(n) == 5 )
					sel	=	I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m) & I(:,4) == 0;
				else
					sel	=	I(:,4) == Ufilt(k) & I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m);
				end
				dI	=	I(sel,:);
				dC	=	C(sel,:);
				
				Uloc	=	unique(dI(:,2));
				sel		=	Uloc == 0;
				
				if( Utype(n) == 1 )
					Uloca	=	max(Uloc);
					if( Ufreq(m) == 600 )
						off	=	9;
					elseif( Ufreq(m) == 4000 )
						off	=	7;
					end
				elseif( Utype(n) == 2 )
					Uloca	=	Uloc(~sel);
					if( Ufreq(m) == 600 )
						off	=	-1;
					elseif( Ufreq(m) == 4000 )
						off	=	1;
					end
				elseif( Utype(n) == 4 )
					Uloca	=	max(Uloc);
					if( Ufreq(m) == 600 )
						off	=	5;
					elseif( Ufreq(m) == 4000 )
						off	=	3;
					end
				elseif( Utype(n) == 5 )
					Uloca	=	max(Uloc);
					if( Ufreq(m) == 600 )
						off	=	-5;%9;
					elseif( Ufreq(m) == 4000 )
						off	=	-3;%7;
					end
				end
				
				Nloca	=	length(Uloca);
				
				dC0		=	median( dC{sel,:} );
				dCa		=	dC(~sel,:);
				
				dd		=	nan(Nloca,4);
				for o=1:Nloca
					dd(o,:)	=	[Uloca(o) dC0 - median( dCa{o,:} ) getpercentile( dC0-dCa{o,:},[25 75] )' ];
				end
				
				h(cnt2)	=	errorperc(dd(:,1)+off,dd(:,2),dd(:,[3 4]),mk,'Color',col,'LineWidth',1,'MarkerSize',10);
				
% 				h(cnt2) = plot(dd(:,1),dd(:,2),mk,'Color',col,'LineWidth',1,'MarkerSize',10);
				
				cnt2	=	cnt2 + 1;
			end
		end
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlim([5 95])
		ylim([-10 50])
		set(gca,'XTick',unique(I(:,2)))
		xlabel('spatial separation[deg]')
		ylabel('spatial release [dB]')
		title([ftr ' ' Timing])
		axis('square')
		if( cnt == 4 )
			legend(h,L,'Location','NorthWest')
			legend('boxoff')
		end
		
		cnt	=	cnt + 1;
	end
end

function plotiqr(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

Bin		=	-20:5:95;
xx		=	[-5 85];
yy		=	[-5 50];

%--			   1   2    3       4      5	--%
%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
% [H,~,I,C,CD,CDI]	=	getthrhis(D,Bin,Outlier);
[~,~,I,C]	=	getthrhis(D,Bin,Outlier);

Ufreq	=	unique(I(:,1));
Nfreq	=	length(Ufreq);

Utime	=	unique(I(:,3));
Ntime	=	length(Utime);

Ufilt	=	unique(I(:,4));
Nfilt	=	length(Ufilt);

Utype	=	unique(I(:,5));
Ntype	=	length(Utype);

[c,r]	=	FactorsForSubPlot(Ntime*Nfilt);

cnt		=	1;
	
figure
for k=1:Nfilt
	if( Utime(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
		
	for l=1:Ntime
		if( Utime(l) == 0 )
			Timing	=	'asynchronous';
		elseif( Utime(l) == 1 )
			Timing	=	'synchronous';
		end
		
		L		=	cell(Nfreq*Ntype,1);
		h		=	nan(Nfreq*Ntype,1);
		cnt2	=	1;
		
		subplot(r,c,cnt)
		plot(xx,[0 0],'k:')
		hold on
		
		for m=1:Nfreq
			if( Ufreq(m) == 600 )
				col	=	'r';
			elseif( Ufreq(m) == 4000 )
				col	=	'b';
			end
			
			for n=1:Ntype
				if( Utype(n) == 1 )
					msk	=	'iR';
					mk	=	's--';
				elseif( Utype(n) == 2 )
					msk	=	'iC';
					mk	=	'v-';
				elseif( Utype(n) == 4 )
					msk	=	'eR';
					mk	=	'd-.';
				elseif( Utype(n) == 5 )
					msk	=	'eC';
					mk	=	'^-.';
				end
				
				L(cnt2,1)	=	{[num2str(Ufreq(m)) ' Hz; ' msk]};
				
				%--			   1   2    3       4      5	--%
				%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
				if( Utype(n) == 4 || Utype(n) == 5 )
					sel	=	I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m) & I(:,4) == 0;
				else
					sel	=	I(:,4) == Ufilt(k) & I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m);
				end
				dI	=	I(sel,:);
				dC	=	C(sel,:);
				
				Uloc	=	unique(dI(:,2));
				sel		=	Uloc == 0;
				Uloca	=	Uloc(~sel);
				Nloca	=	length(Uloca);
				
				P0		=	getpercentile( dC{sel,:},[25 75] );
				dCa		=	dC(~sel,:);
				
				dd		=	nan(Nloca+1,2);
				dd(1,:)	=	[0 P0(2)-P0(1)];
				for o=1:Nloca
					%-- Get 25 & 75 percentiles --%
					P			=	getpercentile( dCa{o,:},[25 75] );
					dd(o+1,:)	=	[Uloca(o) P(2)-P(1) ];
				end
				
				h(cnt2) = plot(dd(:,1),dd(:,2),mk,'Color',col,'LineWidth',1,'MarkerSize',10);
				
				cnt2	=	cnt2 + 1;
			end
		end
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlim(xx)
		ylim(yy)
		set(gca,'XTick',unique(I(:,2)))
		xlabel('spatial separation[deg]')
		ylabel('IQR [dB SPL]')
		title([ftr ' ' Timing])
		axis('square')
		if( cnt == 4 )
			legend(h,L)
			legend('boxoff')
		end
		
		cnt	=	cnt + 1;
	end
end

function plotiqr2(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

Bin		=	-20:5:95;
xx		=	[-5 85];
yy		=	[-5 50];

%--			   1   2    3       4      5	--%
%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
% [H,~,I,C,CD,CDI]	=	getthrhis(D,Bin,Outlier);
[~,~,I,C]	=	getthrhis(D,Bin,Outlier);

Ufreq	=	unique(I(:,1));
Nfreq	=	length(Ufreq);

Utime	=	unique(I(:,3));
Ntime	=	length(Utime);

Ufilt	=	unique(I(:,4));
Nfilt	=	length(Ufilt);

Utype	=	[1 2];
Ntype	=	length(Utype);

Etype	=	[4 5];
Netype	=	length(Etype);

[c,r]	=	FactorsForSubPlot(Ntime*Nfilt*Ntype);

cnt		=	1;
	
figure
for k=1:Nfilt
	if( Utime(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
	
	for l=1:Ntime
		if( Utime(l) == 0 )
			Timing	=	'asynchronous';
		elseif( Utime(l) == 1 )
			Timing	=	'synchronous';
		end
		
		for n=1:Ntype
			L		=	cell(Nfreq*Netype+2,1);
			h		=	nan(Nfreq*Netype+2,1);
			cnt2	=	1;
			
			subplot(r,c,cnt)
			plot(xx,[0 0],'k:')
			hold on
		
			for m=1:Nfreq
				if( Ufreq(m) == 600 )
					col	=	'r';
				elseif( Ufreq(m) == 4000 )
					col	=	'b';
				end
				
				for p=1:Netype
					if( Etype(p) == 4 )
						msk	=	'eR';
						mk	=	'd--';
					elseif( Etype(p) == 5 )
						msk	=	'eC';
						mk	=	'^--';
					end
					
					L(cnt2,1)	=	{[num2str(Ufreq(m)) ' Hz; ' msk]};
					
					sel	=	I(:,3) == Utime(l) & I(:,5) == Etype(p) & I(:,1) == Ufreq(m) & I(:,4) == 0;
					
					dI	=	I(sel,:);
					dC	=	C(sel,:);
					
					Uloc	=	unique(dI(:,2));
					sel		=	Uloc == 0;
					Uloca	=	Uloc(~sel);
					Nloca	=	length(Uloca);
					
					P0		=	getpercentile( dC{sel,:},[25 75] );
					dCa		=	dC(~sel,:);
					
					dd		=	nan(Nloca+1,2);
					dd(1,:)	=	[0 P0(2)-P0(1)];
					for o=1:Nloca
						%-- Get 25 & 75 percentiles --%
						P			=	getpercentile( dCa{o,:},[25 75] );
						dd(o+1,:)	=	[Uloca(o) P(2)-P(1) ];
					end
					
					h(cnt2) = plot(dd(:,1),dd(:,2),mk,'Color',col,'LineWidth',1,'MarkerSize',10);
					
					cnt2	=	cnt2 + 1;
				end
				
				if( Utype(n) == 1 )
					msk	=	'iR';
					mk	=	's-';
				elseif( Utype(n) == 2 )
					msk	=	'iC';
					mk	=	'v-';
				end
				
				L(cnt2,1)	=	{[num2str(Ufreq(m)) ' Hz; ' msk]};
				
				%--			   1   2    3       4      5	--%
				%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
				sel	=	I(:,4) == Ufilt(k) & I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m);
				dI	=	I(sel,:);
				dC	=	C(sel,:);
				
				Uloc	=	unique(dI(:,2));
				sel		=	Uloc == 0;
				Uloca	=	Uloc(~sel);
				Nloca	=	length(Uloca);
				
				P0		=	getpercentile( dC{sel,:},[25 75] );
				dCa		=	dC(~sel,:);
				
				dd		=	nan(Nloca+1,2);
				dd(1,:)	=	[0 P0(2)-P0(1)];
				for o=1:Nloca
					%-- Get 25 & 75 percentiles --%
					P			=	getpercentile( dCa{o,:},[25 75] );
					dd(o+1,:)	=	[Uloca(o) P(2)-P(1) ];
				end
				
				h(cnt2) = plot(dd(:,1),dd(:,2),mk,'Color',col,'LineWidth',1,'MarkerSize',10);
				
				cnt2	=	cnt2 + 1;
			end
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlim(xx)
			ylim(yy)
			set(gca,'XTick',unique(I(:,2)))
			xlabel('spatial separation[deg]')
			ylabel('IQR [dB SPL]')
			title([ftr ' ' Timing])
			axis('square')
			if( cnt == 6 || cnt == 8 )
				legend(h,L)
				legend('boxoff')
			end
			
			cnt	=	cnt + 1;
		end
	end
end

function plotcorspatiqr(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

Bin		=	-20:5:95;
xx		=	[-5 40];
yy		=	[0 45];

%--			   1   2    3       4      5	--%
%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
% [H,~,I,C,CD,CDI]	=	getthrhis(D,Bin,Outlier);
[~,~,I,C]	=	getthrhis(D,Bin,Outlier);

Ufreq	=	unique(I(:,1));
Nfreq	=	length(Ufreq);

Utime	=	unique(I(:,3));
Ntime	=	length(Utime);

Ufilt	=	unique(I(:,4));
Nfilt	=	length(Ufilt);

Utype	=	unique(I(:,5));
Ntype	=	length(Utype);

[c,r]	=	FactorsForSubPlot(Ntime*Nfilt);

cnt		=	1;
	
figure
for k=1:Nfilt
	if( Utime(k) == 0 )
		ftr		=	'all-pass';
	else
		ftr		=	'band-pass';
	end
		
	for l=1:Ntime
		if( Utime(l) == 0 )
			Timing	=	'asynchronous';
		elseif( Utime(l) == 1 )
			Timing	=	'synchronous';
		end
		
		L		=	cell(Nfreq*Ntype,1);
		h		=	nan(Nfreq*Ntype,1);
		cnt2	=	1;
		
		subplot(r,c,cnt)
		plot(xx,yy,'k:')
		hold on
		
		for m=1:Nfreq
			if( Ufreq(m) == 600 )
				col	=	'r';
			elseif( Ufreq(m) == 4000 )
				col	=	'b';
			end
			
			for n=1:Ntype
				if( Utype(n) == 1 )
					msk	=	'iR';
					mk	=	's';
				elseif( Utype(n) == 2 )
					msk	=	'iC';
					mk	=	'v-';
				elseif( Utype(n) == 4 )
					msk	=	'eR';
					mk	=	'd';
				elseif( Utype(n) == 5 )
					msk	=	'eC';
					mk	=	'^';
				end
				
				L(cnt2,1)	=	{[num2str(Ufreq(m)) ' Hz; ' msk]};
				
				%--			   1   2    3       4      5	--%
				%-- I	=	[Freq Loc Timing MaskFilt Type]	--%
				if( Utype(n) == 4 || Utype(n) == 5 )
					sel	=	I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m) & I(:,4) == 0;
				else
					sel	=	I(:,4) == Ufilt(k) & I(:,3) == Utime(l) & I(:,5) == Utype(n) & I(:,1) == Ufreq(m);
				end
				dI	=	I(sel,:);
				dC	=	C(sel,:);
				
				Uloc	=	unique(dI(:,2));
				sel		=	Uloc == 0;
				Uloca	=	Uloc(~sel);
				Nloca	=	length(Uloca);
				
				dC0		=	median( dC{sel,:} );
				P0		=	getpercentile( dC{sel,:},[25 75] );
				dCa		=	dC(~sel,:);
				
				dd		=	nan(Nloca+1,3);
				dd(1,:)	=	[0 dC0 P0(2)-P0(1)];
				for o=1:Nloca
					%-- Get 25 & 75 percentiles --%
					P			=	getpercentile( dCa{o,:},[25 75] );
					
					dd(o,:)	=	[Uloca(o) dC0 - median( dCa{o,:} ) P(2)-P(1) ];
				end
				
				h(cnt2) = plot(dd(:,2),dd(:,3),mk,'Color',col,'LineWidth',1,'MarkerSize',10);
				
				cnt2	=	cnt2 + 1;
			end
		end
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlim(xx)
		ylim(yy)
		xlabel('spatial release [deg]')
		ylabel('IQR [deg]')
		title([ftr ' ' Timing])
		axis('square')
		if( cnt == 2 )
			legend(h,L)
			legend('boxoff')
		end
		
		cnt	=	cnt + 1;
	end
end

function plotregressall(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

if( Outlier )
	D	=	removeoutlier(D);
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
idx		=	[7 2 4 8 17];
Lbl		=	makelabel(idx);
[b,bint,~,r,~,stats]	=	multiregres(D(:,1),D(:,idx));

Nreg	=	length(b);
xvec	=	1:Nreg;
xx		=	[.5 Nreg+.5];
yy		=	[-1 1];

figure
subplot(1,2,1)
plot(xx,[0 0],'k:')
hold on
for m=1:Nreg
	plot([xvec(m) xvec(m)],[bint(m,1) bint(m,2)],'-','Color','k','LineWidth',1)
end
plot(xvec,b,'ko-','MarkerFaceColor',[.5 .5 .5],'LineWidth',1)
xlim(xx)
ylim(yy)
set(gca,'XTick',xvec,'XTicklabel',Lbl)
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('regressor')
ylabel('partial correlation coefficient')
title(['R^2= ' num2str(dround(stats(1))) ' p= ' num2str(3)])
axis('square')

%-- Residuals --%
bins	=	-4:.1:4;
[n,bin]	=	hist(r,bins);

Normfit	=	pdf('Norm',bins,mean(r),std(r));
Normfit	=	( Normfit ./ max(Normfit) ) .* max(n);

[h,p]	=	ttest2(n,Normfit);
if( h == 0 )
	Str	=	'not different with p = ';
else
	Str	=	'different with p =';
end

subplot(1,2,2)
h1 = bar(bin,n);
set(h1,'FaceColor',[.7 .7 .7],'BarWidth',1)
hold on
plot(bins,Normfit,'k-')
xlim([bins(1)-.2 bins(end)+.2])
ylim([0 max(n)]*1.1)
set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
xlabel('residuals')
ylabel('# of occurences')
axis('square')
title([Str num2str(dround(p)) ' N= ' num2str(length(r))])

function plotregress(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

if( Outlier )
	D	=	removeoutlier(D);
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
idx		=	[7 4 8];

Lbl		=	makelabel(idx);

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Nfilt*Nfreq);

Nfig	=	get(0,'CurrentFigure');
if( isempty(Nfig) )
	Nfig	=	1;
end

cnt		=	1;
for k=1:Nfilt
	if( Ufilt(k) == 0 )
		Filt	=	'all-pass';
	elseif( Ufilt(k) == 1 )
		Filt	=	'band-pass';
	end

	for l=1:Nfreq
		sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(l);% & D(:,8) ~= 4 & D(:,8) ~= 5;
		d	=	D(sel,:);
		
		[b,bint,~,res,~,stats]	=	multiregres(d(:,1),d(:,idx));
		
		Nreg	=	length(b);
		xvec	=	1:Nreg;
		xx		=	[.5 Nreg+.5];
		yy		=	[-1 1];
		
		figure(Nfig+1)
		subplot(r,c,cnt)
		plot(xx,[0 0],'k:')
		hold on
		for m=1:Nreg
			plot([xvec(m) xvec(m)],[bint(m,1) bint(m,2)],'-','Color','k','LineWidth',1)
		end
		plot(xvec,b,'ko-','MarkerFaceColor',[.5 .5 .5],'LineWidth',1)
		text(xvec(1)-.25,.8,['R^2= ' num2str(dround(stats(1))) ' p= ' num2str(3) ' N= ' num2str(size(d,1))],'FontName','Arial','FontWeight','bold','FontSize',12)
		xlim(xx)
		ylim(yy)
		set(gca,'XTick',xvec,'XTicklabel',Lbl)
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlabel('regressor')
		ylabel('partial correlation coefficient')
		title([num2str(Ufreq(l)) ' Hz ' Filt])
		axis('square')
		
		%-- Residuals --%
		bins	=	-4:.1:4;
		[n,bin]	=	hist(res,bins);
		
		Normfit	=	pdf('Norm',bins,mean(res),std(res));
		Normfit	=	( Normfit ./ max(Normfit) ) .* max(n);
		
		[h,p]	=	ttest2(n,Normfit);
		if( h == 0 )
			Str	=	{'not different'};
		else
			Str	=	{'different'};
		end
		
		figure(Nfig+2)
		subplot(r,c,cnt)
		h1 = bar(bin,n);
		set(h1,'FaceColor',[.7 .7 .7],'BarWidth',1)
		hold on
		plot(bins,Normfit,'k-')
		text(bins(2),max(n),[Str {['p = ' num2str(dround(p))]} {[' N= ' num2str(length(res))]}])
		xlim([bins(1)-.2 bins(end)+.2])
		ylim([0 max(n)]*1.1)
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlabel('residuals')
		ylabel('# of occurences')
		axis('square')
		title([num2str(Ufreq(l)) ' Hz ' Filt])
		
		cnt	=	cnt + 1;
	end
end

function plotregresstype(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

if( Outlier )
	D	=	removeoutlier(D);
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
idx		=	[7 4];

Lbl		=	makelabel(idx);

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

[r,c]	=	FactorsForSubPlot(Nfilt*Nfreq);

Nfig	=	get(0,'CurrentFigure');
if( isempty(Nfig) )
	Nfig	=	0;
end

cnt		=	1;
for k=1:Nfilt
	if( Ufilt(k) == 0 )
		Filt	=	'all-pass';
	elseif( Ufilt(k) == 1 )
		Filt	=	'band-pass';
	end

	for l=1:Nfreq
		for o=1:Ntype
			if( Utype(o) == 1 )
				mk	=	'rs-';
				col	=	'r';
			elseif( Utype(o) == 2 )
				mk	=	'bv-';
				col	=	'b';
			elseif( Utype(o) == 4 )
				mk	=	'rd-';
				col	=	[1 .5 .5];
			elseif( Utype(o) == 5 )
				mk	=	'^-';
				col	=	[.5 .5 1];
			end
			
			sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(l) & D(:,8) ~= Utype(o);
			d	=	D(sel,:);
			
			[b,bint,~,res,~,stats]	=	multiregres(d(:,1),d(:,idx));
			
			Nreg	=	length(b);
			xvec	=	1:Nreg;
			xx		=	[.5 Nreg+.5];
			yy		=	[-1 1];
			
			figure(Nfig+1)
			subplot(r,c,cnt)
			plot(xx,[0 0],'k:')
			hold on
			for m=1:Nreg
				plot([xvec(m) xvec(m)],[bint(m,1) bint(m,2)],'-','Color',col,'LineWidth',1)
			end
			plot(xvec,b,mk,'LineWidth',1)
			text(xvec(1)-.25,.8,['R^2= ' num2str(dround(stats(1))) ' p= ' num2str(3) ' N= ' num2str(size(d,1))],'FontName','Arial','FontWeight','bold','FontSize',12)
			xlim(xx)
			ylim(yy)
			set(gca,'XTick',xvec,'XTicklabel',Lbl)
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlabel('regressor')
			ylabel('partial correlation coefficient')
			title([num2str(Ufreq(l)) ' Hz ' Filt])
			axis('square')
			
			%-- Residuals --%
			bins	=	-4:.1:4;
			[n,bin]	=	hist(res,bins);
			
			Normfit	=	pdf('Norm',bins,mean(res),std(res));
			Normfit	=	( Normfit ./ max(Normfit) ) .* max(n);
			
			[h,p]	=	ttest2(n,Normfit);
			if( h == 0 )
				Str	=	{'not different'};
			else
				Str	=	{'different'};
			end
			
			figure(Nfig+2)
			subplot(r,c,cnt)
			plot(bin,n,mk);
			hold on
			text(bins(2),max(n),[Str {['p = ' num2str(dround(p))]} {[' N= ' num2str(length(res))]}])
			xlim([bins(1)-.2 bins(end)+.2])
			ylim([0 max(n)]*1.1)
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlabel('residuals')
			ylabel('# of occurences')
			axis('square')
			title([num2str(Ufreq(l)) ' Hz ' Filt])
		end
		cnt	=	cnt + 1;
	end
end

function plotregressubj(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
idx		=	[7 8 4];%[7 4 8];
vec		=	1:length(idx);
off		=	-.37:.0617:.4;

Lbl		=	makelabel(idx);

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utype	=	[1 2; 4 5];
Ntype	=	size(Utype,2);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);
Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Nfilt*Nfreq);

Nfig	=	get(0,'CurrentFigure');
if( isempty(Nfig) )
	Nfig	=	0;
end

if( Outlier )
	D	=	removeoutlier(D);
else
	%-- First correct for signal in silence threshold --%
	for k=1:Nfreq
		%-- Get control for individual subjects --%
		sel		=	D(:,2) == Ufreq(k);
		D(sel,:)=	corrctrlindivsub(D(sel,:));
	end
	
	%-- Second get rid off the ctrl thresholds --%
	sel		=	D(:,5) ~= -80;
	D		=	D(sel,:);
end

for k=1:Ntype	%-- 1: Info data; 2: Energetic data --%	
	Stats	=	[];
	
	figure(Nfig+k)
	
	cnt		=	1;
	for l=1:Nfilt
		if( Ufilt(l) == 0 )
			Filt	=	'all-pass';
		elseif( Ufilt(l) == 1 )
			Filt	=	'band-pass';
		end
		
		for m=1:Nfreq
			if( Utype(k,1) < 3 )		%-- Info mask: difference between all-pass & band-pass --%
				sel	=	(D(:,8) == Utype(k,1) | D(:,8) == Utype(k,2) ) & D(:,17) == Ufilt(l,1) & ...
						D(:,2) == Ufreq(m,1) & (D(:,4) == 0 | D(:,4) == 80 );
			elseif( Utype(k,1) > 3 )	%-- Energ mask: no difference between all-pass & band-pass --%
				sel	=	(D(:,8) == Utype(k,1) | D(:,8) == Utype(k,2) ) & ...
						D(:,2) == Ufreq(m,1) & (D(:,4) == 0 | D(:,4) == 80 );
			end
			d	=	D(sel,:);
			
			if( Ufilt(l,1) == 1 && Ufreq(m,1) == 4000 && any(idx == 8) && Utype(k,1) < 3 )
				sel	=	d(:,16) ~= 39;	%-- S39 did not complete iMBD for HP info maskers --%
				d	=	d(sel,:);
			end
			
			b		=	nan(length(idx),Nsubj);
			bint	=	nan(length(idx),2,Nsubj);
			stats	=	nan(Nsubj,4);
			
			for n=1:Nsubj
				sel	=	d(:,16) == Usubj(n);
				if( sum(sel) > 0 )
					dd		=	d(sel,:);
					dd(:,4)	=	-dd(:,4);	%-- Express as difference Sloc - Mloc so that weights are positive --%
				
					[b(:,n),bint(:,:,n),~,~,~,stats(n,:)]	=	multiregres(dd(:,1),dd(:,idx));
				end
			end
			
			Stats	=	[Stats; stats];
			
			subplot(r,c,cnt)
			for n=1:Nsubj
				for o=1:length(vec)
					plot([vec(o)+off(n) vec(o)+off(n)],[-1.1 1.1],'k:')
					hold on
				end
			end
			h = bar(b);
			set(h,'BarWidth',1)
			colormap('gray')
			
			for n=1:Nsubj
				int	=	squeeze(bint(:,:,n));
				for o=1:length(vec)
					plot([vec(o)+off(n) vec(o)+off(n)],int(o,:),'k-')
				end
			end
			
			plot(vec,nanmedian(b,2),'ro-','MarkerFaceColor','r')
			
			xlim([.5 vec(end)+.5])
			ylim([-.6 1.1])
			set(gca,'XTick',vec,'XTicklabel',Lbl)
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlabel('regressor')
			ylabel('partial correlation coefficient')
			axis('square')
			title([num2str(Ufreq(m)) ' Hz ' Filt])
			
			cnt	=	cnt + 1;
		end
	end
	
	disp([ 'MAX -- type ' num2str(Utype(k,1)) ': R^2= ' num2str(nanmax(Stats(:,1))) ...
			' F= ' num2str(nanmax(Stats(:,2))) ' p= ' num2str(nanmax(Stats(:,3))) ...
			' errorvar= ' num2str(nanmax(Stats(:,4)))])
	disp([ 'MIN -- type ' num2str(Utype(k,1)) ': R^2= ' num2str(nanmin(Stats(:,1))) ...
			' F= ' num2str(nanmin(Stats(:,2))) ' p= ' num2str(nanmin(Stats(:,3))) ...
			' errorvar= ' num2str(nanmin(Stats(:,4)))])
	disp([ 'MEA -- type ' num2str(Utype(k,1)) ': R^2= ' num2str(nanmean(Stats(:,1))) ...
			' F= ' num2str(nanmean(Stats(:,2))) ' p= ' num2str(nanmean(Stats(:,3))) ...
			' errorvar= ' num2str(nanmean(Stats(:,4)))])
end

function plotregressubjres(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

resbin	=	-3:.5:3;

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
idx		=	[7 4 8];

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utype	=	[1 2; 4 5];
Ntype	=	size(Utype,2);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Nfilt*Nfreq);

col		=	linspace(0,.7,Nsubj)';
col		=	repmat(col,1,3);

P		=	nan(Nfilt*Nfreq,Ntype);

Nfig	=	get(0,'CurrentFigure');
if( isempty(Nfig) )
	Nfig	=	0;
end

if( Outlier )
	D	=	removeoutlier(D);
else
	%-- First correct for signal in silence threshold --%
	for k=1:Nfreq
		%-- Get control for individual subjects --%
		sel		=	D(:,2) == Ufreq(k);
		D(sel,:)=	corrctrlindivsub(D(sel,:));
	end
	
	%-- Second get rid off the ctrl thresholds --%
	sel		=	D(:,5) ~= -80;
	D		=	D(sel,:);
end

for k=1:Ntype	%-- 1: Info data; 2: Energetic data --%
	if( Utype(k,1) < 3 )
		Type	=	'IM';
	elseif( Utype(k,1) > 3 )
		Type	=	'EM';
	end
	
	figure(Nfig+k)
	
	cnt		=	1;
	for l=1:Nfilt
		if( Ufilt(l) == 0 )
			Filt	=	'all-pass';
		elseif( Ufilt(l) == 1 )
			Filt	=	'band-pass';
		end
		
		for m=1:Nfreq
			if( Utype(k,1) < 3 )		%-- Info mask: difference between all-pass & band-pass --%
				sel	=	(D(:,8) == Utype(k,1) | D(:,8) == Utype(k,2) ) & D(:,17) == Ufilt(l,1) & ...
						D(:,2) == Ufreq(m,1) & (D(:,4) == 0 | D(:,4) == 80 );
			elseif( Utype(k,1) > 3 )	%-- Energ mask: no difference between all-pass & band-pass --%
				sel	=	(D(:,8) == Utype(k,1) | D(:,8) == Utype(k,2) ) & D(:,2) == Ufreq(m,1) & ...
						(D(:,4) == 0 | D(:,4) == 80 );
			end
			d	=	D(sel,:);
			
			if( Ufilt(l,1) == 1 && Ufreq(m,1) == 4000 && any(idx == 8) && Utype(k,1) < 3 )
				sel	=	d(:,16) ~= 39;	%-- S39 did not complete iMBD for HP info maskers --%
				d	=	d(sel,:);
			end
			
			Pstat	=	nan(Nsubj,1);
			
			for n=1:Nsubj
				sel	=	d(:,16) == Usubj(n);
				if( sum(sel) > 0 )
					dd	=	d(sel,:);
				
					[~,~,~,res,~,~]	=	multiregres(dd(:,1),dd(:,idx));
					
					Normfit			=	normrnd(mean(res),std(res),1,length(res));
					
					[h,Pstat(n,1)]=	ttest2(res,Normfit,.01,'both');
					if( h == 1 )
						disp([	'Residuals for S' num2str(Usubj(n)) ' with ' num2str(Ufreq(m)) ' Hz ' Filt ' ' ...
								Type ' are not normally distributed'])
					end
					
					[N,bins]	=	hist(res,resbin);
					
					Normfit	=	pdf('Norm',bins,mean(res),std(res));
					Normfit	=	( Normfit ./ max(Normfit) ) .* max(N);
					
					subplot(r,c,cnt)
					plot(bins,N,'-','Color',col(n,:))
					hold on
					plot(bins,Normfit,':','Color',col(n,:))
				end
			end
			
			xlim([resbin(1)-.1 resbin(end)+.1])
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			xlabel('residual')
			ylabel('# of occurences')
			axis('square')
			title([num2str(Ufreq(m)) ' Hz ' Filt])
			
			P(cnt,k)	= nanmin(Pstat);
			
			cnt			=	cnt + 1;
		end
	end
end

disp(['p > ' num2str(min(P(:))) ' mean(p)= ' num2str(mean(P(:)))])

function plotregressspace(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
idx		=	[7 4];

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utype	=	2;

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);
Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Nfilt*Nfreq);

Nfig	=	get(0,'CurrentFigure');
if( isempty(Nfig) )
	Nfig	=	0;
end

if( Outlier )
	D	=	removeoutlier(D);
else
	%-- First correct for signal in silence threshold --%
	for k=1:Nfreq
		%-- Get control for individual subjects --%
		sel		=	D(:,2) == Ufreq(k);
		D(sel,:)=	corrctrlindivsub(D(sel,:));
	end
	
	%-- Second get rid off the ctrl thresholds --%
	sel		=	D(:,5) ~= -80;
	D		=	D(sel,:);
end

Uloc	=	unique(D(:,4));
sel		=	Uloc ~= 0;
Uloc	=	Uloc(sel);
Nloc	=	length(Uloc);

figure(Nfig+k)

cnt		=	1;
for l=1:Nfilt
	if( Ufilt(l) == 0 )
		Filt	=	'all-pass';
	elseif( Ufilt(l) == 1 )
		Filt	=	'band-pass';
	end
	
	for m=1:Nfreq
		sel	=	D(:,8) == Utype & D(:,17) == Ufilt(l,1) & D(:,2) == Ufreq(m,1);
		d	=	D(sel,:);
		
		if( Ufilt(l,1) == 1 && Ufreq(m,1) == 4000 && any(idx == 8) && Utype(k,1) < 3 )
			sel	=	d(:,16) ~= 39;	%-- S39 did not complete iMBD for HP info maskers --%
			d	=	d(sel,:);
		end
		
		b		=	nan(length(idx),Nsubj,Nloc);
		bint	=	nan(length(idx),2,Nsubj,Nloc);
		stats	=	nan(Nsubj,Nloc,4);
		
		for n=1:Nsubj
			sel	=	d(:,16) == Usubj(n);
			if( sum(sel) > 0 )
				dd		=	d(sel,:);
				
				for k=1:Nloc
					sel			=	dd(:,4) == 0 | dd(:,4) == Uloc(k);
					ddd			=	dd(sel,:);
					ddd(:,4)	=	-ddd(:,4);	%-- Express as difference Sloc - Mloc so that weights are positive --%
					
					[b(:,n,k),bint(:,:,n,k),~,~,~,stats(n,k,:)]	=	multiregres(ddd(:,1),ddd(:,idx));
				end
			end
		end
		
		subplot(r,c,cnt)
% 		patch([Uloc; flipud(Uloc)],[mb(1,:)-sb(1,:) fliplr(mb(1,:))+fliplr(sb(1,:))],[1 .7 .7])
% 		hold on
% 		plot(Uloc,mb(1,:),'r-')
% 		patch([Uloc; flipud(Uloc)],[mb(2,:)-sb(2,:) fliplr(mb(2,:))+fliplr(sb(2,:))],[.7 .7 1],'FaceAlpha',.5)
% 		plot(Uloc,mb(2,:),'b-')
		
		for o=1:2
			if( o == 1 )
				mk	=	'ko';
				col	=	[.7 .7 .7];
				off	=	-1;
			else
				mk	=	'ks';
				col	=	[.3 .3 .3];
				off	=	+1;
			end
				
			bb		=	squeeze(b(o,:,:));
			sel		=	~isnan(bb(:,1));
			bb		=	bb(sel,:);

			plot(Uloc+off,bb',mk,'MarkerFaceColor',col)
			hold on
		end
		
		mb(1,:)	=	nanmedian(squeeze(b(1,:,:)),1);
		mb(2,:)	=	nanmedian(squeeze(b(2,:,:)),1);
		sb(1,:)	=	nanstd(squeeze(b(1,:,:)),1);
		sb(2,:)	=	nanstd(squeeze(b(2,:,:)),1);
		
		h(1) = plot(Uloc-1,mb(1,:),'-','Color',[.7 .7 .7]);
		h(2) = plot(Uloc+1,mb(2,:),'-','Color',[.3 .3 .3]);
		
		xlim([Uloc(1)-5 Uloc(end)+5])
		ylim([-.6 1.1])
		set(gca,'XTick',Uloc,'Layer','top')
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlabel('spatial separation [deg]')
		ylabel('partial correlation coefficient')
		axis('square')
		box('on')
		title([num2str(Ufreq(m)) ' Hz ' Filt])
		
		if( l == 1 && m == 1 )
			legend(h,[{'time'},{'space'}],'Location','SouthEast')
			legend('boxoff')
		end
		
		cnt	=	cnt + 1;
	end
end

function plotob(D,Outlier,Loc)

if( nargin < 2 )
	Outlier	=	0;
end
if( nargin < 3 )
	Loc		=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	[1 2 4 5];		%-- Sorting: eMBD eMBS iMBD iMBS --%
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Ntime);
yy		=	[-5 95];

Usubj	=	selectsubj(D,[600 4000],Loc,[0 1],[1 2],[0 1]);
Nsubj	=	length(Usubj);

for k=1:Nfilt
% 	Usubj	=	selectsubj(D,[600 4000],Loc,[0 1],[1 2],Ufilt(k));
% 	Nsubj	=	length(Usubj);
	
	col		=	linspace(0,1,Nsubj)';
	red		=	flipud( [ones(Nsubj,1) repmat(col,1,2)] );
	blue	=	flipud( [repmat(col,1,2) ones(Nsubj,1)] );

	cnt		=	1;
	
	figure
	for l=1:Nfreq
		if( l == 1 )
			pcol	=	'r';
			pmk		=	'-';
			col		=	red;
			mk		=	'ko';
			offset	=	[-.3 -.05];
		elseif( l == 2 )
			pcol	=	'b';
			pmk		=	'-';
			col		=	blue;
			mk		=	'ko';
			offset	=	[.05 .3];
		end
		
		for m=1:Ntime
			if( Utime(m) == 0 )
				str	=	'asynchronous';
			else
				str	=	'synchronous';
			end
			
			Tlbl	=	cell(Ntype,1);
			
			for n=1:Ntype
				if( Utype(n) == 1 )
					Tlbl(n)	=	{'iMBD'};
				elseif( Utype(n) == 2 )
					Tlbl(n)	=	{'iMBS'};
				elseif( Utype(n) == 4 )
					Tlbl(n)	=	{'eMBD'};
				elseif( Utype(n) == 5 )
					Tlbl(n)	=	{'eMBS'};
				end
					
				%-- Get control for all subjects --%
				cel		=	D(:,2) == Ufreq(l) & D(:,8) == 2 & D(:,5) == -80;
				CA		=	getctrl(D(cel,:),-80);
				
				%-- Current selection for all subjects --%
				if( Utype(n) == 4 || Utype(n) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
					sel	=	D(:,2) == Ufreq(l) & D(:,4) == Loc & ...
							D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,5) ~= -80;
				else
					sel	=	D(:,17) == Ufilt(k) & D(:,4) == Loc & D(:,2) == Ufreq(l) & ...
							D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,5) ~= -80;
				end
				
				%-- Median over all subjects --%
				A		=	median( D(sel,1)-CA(1,1) );
				
				%-- Get 25 & 75 percentiles --%
				[P,Crit]=	getpercentile( D(sel,1)-CA(1,1),[25 75] );
				
				%-- Patch & subject offset --%
				mx		=	n + offset;
				inc		=	diff(mx) / Nsubj;
				
				h		=	[];
				L		=	cell(0,1);
				
				%-- Get data from individual subjects --%
				for o=1:Nsubj
					if( Utype(n) == 4 || Utype(n) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
						sel		=	D(:,2) == Ufreq(l) & D(:,4) == Loc & ...
									D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o);
					else
						sel		=	D(:,17) == Ufilt(k) & D(:,4) == Loc & D(:,2) == Ufreq(l) & ...
									D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o);
					end
					d			=	D(sel,:);
					
					xloc		=	mx(1) + inc * (o-1) + inc/2;
					subplot(r,c,m)
					plot([xloc xloc],yy,'k:')
					hold on
					
					if( ~isempty(d) )
						L(cnt)	=	{['S' num2str(Usubj(o))]};
						
						%-- Get control data for normalization --%
						cel		=	D(:,2) == Ufreq(l) & D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(o);
						C		=	D(cel,:);
						C		=	getctrl(C,-80);
						d		=	[d(:,1) - C(1,1) d(:,2:end)];
						
						if( Outlier )
							%-- Remove outliers according to Tuckey --%
							sel		=	d(:,1) >= (P(1) - Crit) & d(:,1) <= (P(2) + Crit);
							
							out		=	d(~sel,:);
							xlocout	=	zeros( size(out,1),1 ) + mx(1) + inc * (o-1) + inc/2;
							
							plot(xlocout,out(:,1),'kd','MarkerFaceColor',col(o,:))
							
							d		=	d(sel,:);
						end
						
						xloc	=	zeros( size(d,1),1 ) + mx(1) + inc * (o-1) + inc/2;
						
						h(cnt)	=	plot(xloc,d(:,1),mk,'MarkerFaceColor',col(o,:));	%#ok<AGROW>
						cnt		=	cnt + 1;
					end
				end
				
				plot([.5 Ntype+.5],[0 0],'k--')
				plot(mx,[A A],'-','Color',pcol,'LineWidth',2)
				hp = patch([mx fliplr(mx)],[P(2) P(2) P(1) P(1)],pcol,'LineStyle',pmk);
				set(hp,'EdgeColor',pcol,'FaceColor','none')
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',14)
				set(gca,'XTick',1:Ntype,'XTickLabel',Tlbl, ...
						'YTick',0:15:95)
				xlim([.5 Ntype+.5])
				ylim(yy)
				xlabel('masker type')
				ylabel('masked threshold [dB SPL]')
				title(str)
				axis('square')
% 				if( l == 1 && m == 1 && n == 1 )
% 					L	=	L(h ~= 0);
% 					h	=	h(h ~= 0);
% 					legend(h,L,'Location','SouthWest','Orientation','horizontal')
% 					legend('boxoff')
% 				end
% 				if( l == 2 && m == 2 && n == 1 )
% 					L	=	L(h ~= 0);
% 					h	=	h(h ~= 0);
% 					legend(h,L,'Location','SouthWest','Orientation','horizontal')
% 					legend('boxoff')
% 				end
			end
		end
	end
end

function plotcorrmask(D,Outlier)

if( nargin < 2 )
	Outlier	=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	[4; 5; 1; 2];
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

col		=	linspace(0,.7,Nsubj)';
col		=	repmat(col,1,3);

if( Outlier )
	D	=	removeoutlier(D);
else
	%-- First correct for signal in silence threshold --%
	for k=1:Nfreq
		%-- Get control for individual subjects --%
		sel		=	D(:,2) == Ufreq(k);
		D(sel,:)=	corrctrlindivsub(D(sel,:));
	end
	
	%-- Second get rid off the ctrl thresholds --%
	sel		=	D(:,5) ~= -80;
	D		=	D(sel,:);
end

for k=1:Nfreq
	for l=1:Nfilt
		if( Ufilt(l) == 0 )
			Filt	=	'all-pass';
		elseif( Ufilt(l) == 1 )
			Filt	=	'band-pass';
		end
		
		figure
		cnt	=	1;
		
		for m=1:Ntime
			if( Utime(m) == 0 )
				Time	=	'async';
			elseif( Utime(m) == 1 )
				Time	=	'sync';
			end
				
			for n=1:Ntype
				if( Utype(n) == 1 )
					Type	=	'iR';
				elseif( Utype(n) == 2 )
					Type	=	'iC';
				elseif( Utype(n) == 4 )
					Type	=	'eR';
				elseif( Utype(n) == 5 )
					Type	=	'eC';
				end
				
				subplot(2,Ntype,cnt)
				
				if( Utype(n) > 2 )
					sel		=	D(:,2) == Ufreq(k) & D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,4) == 0;
				else
					sel		=	D(:,2) == Ufreq(k) & D(:,17) == Ufilt(l) & D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,4) == 0;
				end
				
				Store		=	[];
				
				if( sum(sel) > 0 )
					dd		=	D(sel,:);
					
					for o=1:Nsubj
						sel		=	dd(:,16) == Usubj(o);
						if( sum(sel) > 0 )
							ddd		=	dd(sel,:);
							Store	=	[Store; ddd(:,18),ddd(:,1)];			%#ok<AGROW>
						
							plot(ddd(:,18),ddd(:,1),'ko','MarkerFaceColor',col(o,:))
							hold on
						end
					end
				end
				
				if( ~isempty(Store) )
					[yfit,stats]	=	fitline(Store(:,1),Store(:,2));
					plot(Store(:,1),yfit,'r-')
					
					plot([log2(mean(ddd(:,12))/Ufreq(k)) log2(mean(ddd(:,12))/Ufreq(k))],[-10 95],'k:')
				end
				
				xlim([0 max( [log2(Ufreq(k)/150) log2(15000/Ufreq(k))] )])
				ylim([-10 95])
				set(gca,'FontName','Arial','FontWeight','bold')
				xlabel('\Delta frequency [oct]')
				ylabel('masked threshold [dB SPL]')
				
				if( ~isempty(Store) )
					title([	{[num2str(Ufreq(k)) ' Hz ' Filt ' ' Type ' ' Time ' S' num2str(Usubj(o))]} ...
							{[	'y=' num2str(dround(stats.Coef(1))) '*x+' num2str(dround(stats.Coef(2))) ...
								'; R^2=' num2str(dround(stats.R2)) '; N=' num2str(dround(stats.N)) ...
								'; p=' num2str(dround(stats.P))]}])
				else
					title([num2str(Ufreq(k)) ' Hz ' Filt ' ' Type ' ' Time ' S' num2str(Usubj(o))])
				end
				cnt	=	cnt + 1;
			end
		end
	end
end

function plotfried(D,flag)

if( nargin < 2 )
	flag	=	2;	%-- 0: Frequency comparison; 1: Timing comparison; 2: Type per Freq; 3: Per filter --%
end

Loc		=	80;

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));

Utype	=	unique(D(:,8));
% Utype	=	[4 5];

% sel		=	D(:,2) == 600;
% D		=	D(sel,:);

%-- First correct for signal in silence threshold --%
for k=1:Nfreq
	%-- Get control for individual subjects --%
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
end

%-- Second get rid off the ctrl thresholds --%
sel		=	D(:,5) ~= -80;
D		=	D(sel,:);

if( flag == 1 )
% 	d		=	seltime2(D,Utime,Utype);
	[dd,Group,ID]	=	seltime(D,Utime,Utype);
elseif( flag == 2 )
	[dd,Group,ID]	=	selfreqpertype(D,Loc);
elseif( flag == 3 )
	[dd,Group,ID]	=	selfilter(D);
else
	d		=	selfreqtype(D,Ufreq,Utype,Loc);
	Group	=	[];
end

if( flag == 0 )
	d1		=	cell2mat(d(:,1));
	len1	=	length(d1);
	d2		=	cell2mat(d(:,2));
	len2	=	length(d2);
	
	if( len2 < len1 )
		len	=	len2;
	else
		len	=	len1;
	end
	dd			=	nan(len,2);
	dd(1:len,1)	=	d1(1:len,1);
	dd(1:len,2)	=	d2(1:len,1);
end

% p		=	ranksum(dd(~isnan(dd(:,1)),1),dd(~isnan(dd(:,2)),2),'alpha',0.01);
% [p,table,stats]	=	friedman(d,len/8);
[p,table,stats]	=	kruskalwallis(dd,Group,'on');
figure
[c,m,h,gnames] = multcompare(stats,'alpha',0.01,'ctype','bonferroni','display','on');

[p,IDstr,ID]	=	posthockw(dd,Group,ID);

if( flag == 2 )
	%-- Energetic --%
% 	sel		=	ID(:,1) == 4000 & (ID(:,2) == 4 | ID(:,2) == 5) & ID(:,3) == 1 & ...
% 				ID(:,4) == 600 & (ID(:,5) == 4 | ID(:,5) == 5) & ID(:,6) == 1;
% 	sel		=	ID(:,1) == 4000 & (ID(:,2) == 4 | ID(:,2) == 5) & ...
% 				ID(:,4) == 600 & (ID(:,5) == 4 | ID(:,5) == 5);
% 	%-- iCa --%
% 	sel		=	ID(:,1) == 4000 & ID(:,2) == 2 & ID(:,3) == 0 & ...
% 				ID(:,4) == 600 & ID(:,5) == 2 & ID(:,6) == 0;
	%-- iCs --%
% 	sel		=	ID(:,1) == 4000 & ID(:,2) == 2 & ID(:,3) == 1 & ...
% 				ID(:,4) == 600 & ID(:,5) == 2 & ID(:,6) == 1;
	
% 	sel		=	ID(:,1) == 4000 & (ID(:,2) == 1 | ID(:,2) == 4) & ID(:,3) == 1 & ...
% 				ID(:,4) == 4000 & (ID(:,5) == 1 | ID(:,5) == 4) & ID(:,6) == 1;
	%-- 4000 vs 600 --%
% 	sel		=	ID(:,1) == 4000 & ID(:,4) == 600;
	sel		=	ID(:,1) == 4000 & ID(:,2) < 3 & ID(:,3) == 1 & ...
				ID(:,4) == 600 & ID(:,5) < 3  & ID(:,6) == 1;
% 	sel		=	ID(:,1) == 4000 & ID(:,2) == 4 & ID(:,3) == 0 & ...
% 				ID(:,4) == 4000 & ID(:,5) == 4 & ID(:,6) == 1;
elseif( flag == 1 )
	%-- Info --%
	sel		=	ID(:,1) < 3 & ID(:,2) == 0 & ID(:,3) < 3 & ID(:,4) == 1;
	%-- Energetic --%
	sel		=	ID(:,1) > 3 & ID(:,2) == 0 & ID(:,3) > 3 & ID(:,4) == 1;
	%-- iC --%
	sel		=	ID(:,1) == 5 & ID(:,3) == 5;
elseif( flag == 3 )
	sel		=	ID(:,2) < 3 & ID(:,4) == 0 & ID(:,6) < 3 & ID(:,8) == 1 & ID(:,1) ~= ID(:,5);
end

ID(sel,:)
p(sel)

z=p(sel);
zel=z>.1;
max(z(~zel))
keyboard

function plotov(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

% Utype	=	[4; 5; 1; 2];
Utype	=	[5; 4; 2; 1];
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Uloc	=	[0 80];
Nloc	=	length(Uloc);

% [r,c]	=	FactorsForSubPlot(Nloc);

%-- First correct for signal in silence threshold --%
for k=1:Nfreq
	%-- Get control for individual subjects --%
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
end

%-- Second get rid off the ctrl thresholds --%
sel		=	D(:,5) ~= -80;
D		=	D(sel,:);

cnt		=	1;

figure
for o=1:Nloc
	xtick	=	[];
	x		=	1:Ntype;
	
	if( Uloc(o) == 0 )
		mkk	=	'o-';
		of	=	-.05;
		lw	=	2;
% 	elseif( Uloc(o) == 80 )
	elseif( Uloc(o) > 0 )
		mkk	=	's--';
		of	=	+.05;
		lw	=	1;
	end
	
% 	subplot(r,c,o)
	for k=1:Nfreq
		for l=1:Nfilt
			if( Ufilt(l) == 0 )
				filt	=	'all-pass';
			else
				filt	=	'band-pass';
			end
			
% 			Lgd	=	cell(Ntime,1);
% 			h1	=	nan(Ntime,1);
			for m=1:Ntime
				if( Utime(m) == 0 )
					off			=	-.1+of;
					col			=	'r';
					mk			=	[col mkk];
					Lgd(cnt,1)	=	{['S0M' num2str(Uloc(o)) ' async']};	%#ok<AGROW>
				else
					off			=	+.1+of;
					col			=	'b';
					mk			=	[col mkk];
					Lgd(cnt,1)	=	{['S0M' num2str(Uloc(o)) ' sync']};		%#ok<AGROW>
				end
				
				Lbl		=	cell(Ntype,1);
				M		=	nan(Ntype,3);
				for n=1:Ntype
					if( Utype(n) == 1 )
% 						Lbl(n,1)	=	{'iR'};
						Lbl(n,1)	=	{'iMBD'};
					elseif( Utype(n) == 2 )
% 						Lbl(n,1)	=	{'iC'};
						Lbl(n,1)	=	{'iMBS'};
					elseif( Utype(n) == 4 )
% 						Lbl(n,1)	=	{'eR'};
						Lbl(n,1)	=	{'eMBD'};
					elseif( Utype(n) == 5 )
% 						Lbl(n,1)	=	{'eC'};
						Lbl(n,1)	=	{'eMBS'};
					end
					
					if( Utype(n) < 3 )
						sel	=	D(:,2) == Ufreq(k) & D(:,17) == Ufilt(l) & D(:,7) == Utime(m) & ...
								D(:,8) == Utype(n) & D(:,4) == Uloc(o);
					else
						sel	=	D(:,2) == Ufreq(k) & D(:,7) == Utime(m) & ...
								D(:,8) == Utype(n) & D(:,4) == Uloc(o);
					end
					
					d		=	D(sel,:);
					P		=	getpercentile( d(:,1),[25 75] );
					M(n,:)	=	[median(d(:,1)) P'];
				end
				
				h1(cnt,1) = errorperc(x+off,M(:,1),M(:,2:3),mk,'Color',col,'LineWidth',lw);		%#ok<AGROW>
				text(mean(x)-1,72,[num2str(Ufreq(k)) ' Hz ' filt],'FontName','Arial','FontWeight','bold','FontSize',20)
				
				cnt	=	cnt + 1;
			end
			xtick	=	[xtick x];								%#ok<AGROW>
			x	=	(1:Ntype) + x(end) + .5;
		end
	end
	
% 	plot([.5 x(1)-1],[0 0],'k:')
% 	xlim([.5 x(1)-1])
% 	ylim([-5 75])
% 	set(gca,'XTick',xtick,'XTickLabel',Lbl,'YTick',0:15:100)
% 	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
% 	xlabel('stimulus')
% 	ylabel('masked threshold [dB SPL]')
% 	title(['S0M' num2str(Uloc(o))])
% 	legend(h1,Lgd,'Location','SouthEast')
% 	legend('boxoff')
end

plot([.5 x(1)-1],[0 0],'k:')
xlim([.5 x(1)-1])
ylim([-5 75])
set(gca,'XTick',xtick,'XTickLabel',Lbl,'YTick',0:15:100)
set(gca,'FontName','Arial','FontWeight','bold','FontSize',20)
xlabel('stimulus')
ylabel('masked threshold [dB SPL]')
legend(h1([1:Ntime end-Ntime+1:end]),Lgd([1:Ntime end-Ntime+1:end]),'Location','SouthEast')
legend('boxoff')

function plotmiqr(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Uloc	=	unique(D(:,4));
Nloc	=	length(Uloc);

col		=	linspace(0,1,Nloc)';
red		=	flipud( [ones(Nloc,1) repmat(col,1,2)] );
blue	=	flipud( [repmat(col,1,2) ones(Nloc,1)] );

%-- First correct for signal in silence threshold --%
for k=1:Nfreq
	%-- Get control for individual subjects --%
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
end

%-- Second get rid off the ctrl thresholds --%
sel		=	D(:,5) ~= -80;
D		=	D(sel,:);

% cnt		=	1;
for k=2%:Nfreq
	if( Ufreq(k) == 600 )
		col	=	red;
	else
		col	=	blue;
	end
	
	for m=1:Ntime
		if( Utime(m) == 0 )
			Time	=	'async';
		else
			Time	=	'sync';
		end
		
		for l=1:Nfilt
			figure
			if( Ufilt(l) == 0 )
				Filt	=	'all-pass';
			elseif( Ufilt(l) == 1 )
				Filt	=	'band-pass';
			end
			
			for n=1:Ntype
				if( Utype(n) == 1 )
					Type	=	'iR';
					mk		=	'ks';
				elseif( Utype(n) == 2 )
					Type	=	'iC';
					mk		=	'kv';
				elseif( Utype(n) == 4 )
					Type	=	'eR';
					mk		=	'kd';
				elseif( Utype(n) == 5 )
					Type	=	'eC';
					mk		=	'k^';
				end
				
				if( Utype(n) < 3 )
					sel	=	D(:,2) == Ufreq(k) & D(:,17) == Ufilt(l) & D(:,7) == Utime(m) & D(:,8) == Utype(n);
				else
					sel	=	D(:,2) == Ufreq(k) & D(:,7) == Utime(m) & D(:,8) == Utype(n);
				end
				d	=	D(sel,:);
				
				Uloc	=	unique(d(:,4));
				Nloc	=	length(Uloc);
				
				Usubj	=	unique(d(:,16));
				Nsubj	=	length(Usubj);
				
				for o=1:Nloc
					for p=1:Nsubj
						sel	=	d(:,4) == Uloc(o) & d(:,16) == Usubj(p);
						dd	=	d(sel,:);
						
						P	=	getpercentile( dd(:,1),[25 75] );
						P	=	P(2)-P(1);
						M	=	median(dd(:,1));
						
% 						Store(cnt,:)	=	[M P];				%#ok<NASGU>
% 						cnt	=	cnt + 1;
						
						subplot(2,2,n)
						loglog(M,P,mk,'MarkerFaceColor',col(o,:))
						hold on
					end
				end
				
				plot([1 90],[1 90],'k:')
				xlim([1 90])
				ylim([1 90])
				set(gca,'XTick',[2.5 5 10 20 40 80],'YTick',[2.5 5 10 20 40 80])
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
				xlabel('median [dB SPL]')
				ylabel('IQR [dB SPL]')
				axis('square')
				title([num2str(Ufreq(k)) ' Hz ' Filt ' ' Type ' ' Time])
			end
		end
	end
end

function plotpca(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Uloc	=	[0 80];%unique(D(:,4));
Nloc	=	length(Uloc);

col		=	linspace(0,1,Nloc)';
red		=	flipud( [ones(Nloc,1) repmat(col,1,2)] );
blue	=	flipud( [repmat(col,1,2) ones(Nloc,1)] );

%-- First correct for signal in silence threshold --%
for k=1:Nfreq
	%-- Get control for individual subjects --%
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
end

%-- Second get rid off the ctrl thresholds --%
sel		=	D(:,5) ~= -80;
D		=	D(sel,:);

for k=1:Nfreq
	for l=1:Nfilt
		for p=1:Ntype
			cnt	=	1;
			figure
			for m=1:Ntime
				for n=1:Nloc
					sel		=	D(:,2) == Ufreq(k) & D(:,17) == Ufilt(l) & ...
								D(:,7) == Utime(m) & D(:,4) == Uloc(n) & D(:,8) == Utype(p);
					d		=	D(sel,:);
					
					Usubj	=	unique(d(:,16));
					Nsubj	=	length(Usubj);
					for o=2%:Nsubj
						sel			=	d(:,16) == Usubj(o);
						dd(:,cnt)	=	d(sel,1);
						cnt			=	cnt + 1;
					end
				end
			end
			
			[pc,score,var,tsquare] = princomp(dd);
			
			cumsum(var)./sum(var)
			
			subplot(1,2,1)
			pareto(100*var/sum(var))
			xlabel('Principal Component')
			ylabel('Variance Explained (%)')
			
			
			subplot(1,2,2)
			biplot(pc(:,[1 2 3]),'Scores',score(:,[1 2 3]),'VarLabels',...
			{'sync' 'async' 'M0' 'M80'})
			axis('square')
			keyboard
		end
	end
end
keyboard

function plotstatref(D,alpha,Loc)

if( nargin < 2 )
	alpha	=	0.01;
end
if( nargin < 3 )
	Loc		=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	[5 4 2 1];%[4 5 1 2];		%-- Sorting: eMBD eMBS iMBD iMBS --%
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

cnt		=	1;
for k=1:Nfilt
	for l=1:Nfreq
		cel	=	D(:,8) == 2 & D(:,5) == -80;
		c	=	D(cel,:);
		
		for m=1:Ntime
			for n=1:Ntype
				if( Utype(n) > 3 )	%-- Energetic masking without filter selection --%
					sel	=	D(:,2) == Ufreq(l) & D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,4) == Loc;
				else
					sel	=	D(:,17) == Ufilt(k) & D(:,2) == Ufreq(l) & D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,4) == Loc;
				end
				d	=	D(sel,:);
				
				[p,~,~]			=	ranksum(d(:,1),c(:,1),'alpha',alpha);
				Stats(cnt,:)	=	[p Ufilt(k) Ufreq(l) Utime(m) Utype(n) Loc];	%#ok<AGROW>
				cnt				=	cnt + 1;		
			end
		end
	end
end

Stats															%#ok<NOPRT>

function plotsomo(D,Loc)

if( nargin < 2 )
	Loc		=	0;
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	[5 4 2 1];%[4 5 1 2];		%-- Sorting: eMBD eMBS iMBD iMBS --%
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

[r,c]	=	FactorsForSubPlot(Ntime);
yy		=	[-5 95];

%-- First correct for signal in silence threshold --%
for k=1:Nfreq
	%-- Get control for individual subjects --%
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
end

%-- Second get rid off the ctrl thresholds --%
sel		=	D(:,5) ~= -80;
D		=	D(sel,:);

Usubj	=	selectsubj(D,[600 4000],Loc,[0 1],[1 2],[0 1]);
Nsubj	=	length(Usubj);

for k=1:Nfilt
	col		=	linspace(0,1,Nsubj)';
	red		=	flipud( [ones(Nsubj,1) repmat(col,1,2)] );
	blue	=	flipud( [repmat(col,1,2) ones(Nsubj,1)] );

	cnt		=	1;
	xcnt	=	-1;
	
	figure
	for m=1:Ntime
		if( Utime(m) == 0 )
			str		=	'Asynchronous';
		else
			str		=	'Synchronous';
		end
		
		subplot(c,r,m)
		
		for l=1:Nfreq
			if( l == 1 )
				pcol	=	'r';
				pmk		=	'-';
				col		=	red;
				mk		=	'ko';
			elseif( l == 2 )
				pcol	=	'b';
				pmk		=	'-';
				col		=	blue;
				mk		=	'ko';
			end
			
			for n=1:Ntype
				xcnt	=	xcnt + 1;
				%-- Current selection for all subjects --%
				if( Utype(n) == 4 || Utype(n) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
					sel	=	D(:,2) == Ufreq(l) & D(:,4) == Loc & ...
							D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,5) ~= -80;
				else
					sel	=	D(:,17) == Ufilt(k) & D(:,4) == Loc & D(:,2) == Ufreq(l) & ...
							D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,5) ~= -80;
				end
				
				%-- Median over all subjects --%
				A		=	median( D(sel,1) );
				
				%-- Get 25 & 75 percentiles --%
				[P,~]	=	getpercentile( D(sel,1),[25 75] );
				
				mx(1,1)	=	xcnt + (0.8/Nsubj * (1-Nsubj/2));
				mx(1,2)	=	xcnt + (0.8/Nsubj * (Nsubj-Nsubj/2));
				
				h		=	[];
				L		=	cell(0,1);
				
				%-- Get data from individual subjects --%
				for o=1:Nsubj
					if( Utype(n) == 4 || Utype(n) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
						sel		=	D(:,2) == Ufreq(l) & D(:,4) == Loc & ...
									D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o);
					else
						sel		=	D(:,17) == Ufilt(k) & D(:,4) == Loc & D(:,2) == Ufreq(l) & ...
									D(:,7) == Utime(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o);
					end
					d			=	D(sel,:);
					
					if( ~isempty(d) )
						L(cnt)	=	{['S' num2str(Usubj(o))]};
						
						xloc	=	zeros( size(d,1),1 ) + xcnt + (0.8/Nsubj * (o-Nsubj/2));
						
						h(cnt)	=	plot(xloc,d(:,1),mk,'MarkerFaceColor',col(o,:));	%#ok<AGROW>
						hold on
						cnt		=	cnt + 1;
					end
				end
				
				plot([-.6 2*Ntype+.6-1],[0 0],'k--')
				plot(mx,[A A],'-','Color',pcol,'LineWidth',2)
				hp = patch([mx fliplr(mx)],[P(2) P(2) P(1) P(1)],pcol,'LineStyle',pmk);
% 				text(mx(1),90,['IQR= ' num2str(P(2)-P(1))],'FontName','Arial','FontWeight','bold','FontSize',12)
				set(hp,'EdgeColor',pcol,'FaceColor','none')
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',14)
				set(gca,'XTick',0:2*Ntype,'XTickLabel',[{'eC'},{'eR'},{'iC'},{'iR'},{'eC'},{'eR'},{'iC'},{'iR'}], ...
						'YTick',0:15:95)
				xlim([-.6 2*Ntype+.6-1])
				ylim(yy)
				xlabel('Masker Type')
				ylabel('Threshold [dB re TQ]')
				title(str)
				axis('square')
% 				if( l == 1 && m == 1 && n == 1 )
% 					L	=	L(h ~= 0);
% 					h	=	h(h ~= 0);
% 					legend(h,L,'Location','NorthWest','Orientation','vertical')
% 					legend('boxoff')
% 				end
% 				if( l == 2 && m == 2 && n == 1 )
% 					L	=	L(h ~= 0);
% 					h	=	h(h ~= 0);
% 					legend(h,L,'Location','SouthWest','Orientation','vertical')
% 					legend('boxoff')
% 				end
			end
			xcnt	=	Ntype-1;
		end
		xcnt	=	-1;
	end
end

function plotspat(D,Utype)

if( nargin < 2 )
	Utype	=	[1 2];
end

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

[c,r]	=	FactorsForSubPlot(Ntime*Ntype);
yy		=	[-10 95];

col		=	linspace(0,1,Nsubj)';
red		=	flipud( [ones(Nsubj,1) repmat(col,1,2)] );
blue	=	flipud( [repmat(col,1,2) ones(Nsubj,1)] );

%-- First correct for signal in silence threshold --%
for k=1:Nfreq
	%-- Get control for individual subjects --%
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
end

%-- Second get rid off the ctrl thresholds --%
sel		=	D(:,5) ~= -80;
D		=	D(sel,:);

Usubj	=	selectsubj(D,[600 4000],0,[0 1],[1 2],[0 1]);
Nsubj	=	length(Usubj);

Pall	=	[];

for k=1:Nfilt
	if( Utime(k) == 0 )
		ftr		=	'All-Pass';
	else
		ftr		=	'Band-Pass';
	end
		
	cnt		=	1;
	scnt	=	0;
	
	figure
	for l=1:Ntime
		if( Utime(l) == 0 )
			str		=	'Asynchronous';
		else
			str		=	'Synchronous';
		end
		
		for m=1:Ntype
			scnt	=	scnt + 1;
			subplot(r,c,scnt)
			if( Utype(m) == 1 )
				msk	=	'iR';
			elseif( Utype(m) == 2 )
				msk	=	'iC';
			elseif( Utype(m) == 4 )
				msk	=	'eR';
			elseif( Utype(m) == 5 )
				msk	=	'eC';
			end
			
			xcnt	=	-1;
			
			for n=1:Nfreq
				if( n == 1 )
					pcol	=	'r';
					pmk		=	'-';
					col		=	red;
					mk		=	'ko';
				elseif( n == 2 )
					pcol	=	'b';
					pmk		=	'-';
					col		=	blue;
					mk		=	'ko';
				end
					
				if( Utype(m) == 4 || Utype(m) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
					sel	=	D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,2) == Ufreq(n) & D(:,5) ~= -80;
				else
					sel	=	D(:,17) == Ufilt(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,2) == Ufreq(n) & D(:,5) ~= -80;
				end
				d		=	D(sel,:);
				
				Uloc	=	unique(d(:,4));
				Nloc	=	length(Uloc);
				for o=1:Nloc
					xcnt	=	xcnt + 1;
					
					sel		=	d(:,4) == Uloc(o);
					dd		=	d(sel,:);
					
					%-- Median over all subjects --%
					A		=	median( dd(:,1) );
					
					%-- Get 25 & 75 percentiles --%
					[P,~]	=	getpercentile( dd(:,1),[25 75] );
					
					mx(1,1)	=	xcnt + (0.8/Nsubj * (1-Nsubj/2));
					mx(1,2)	=	xcnt + (0.8/Nsubj * (Nsubj-Nsubj/2));
					
					h		=	[];
					L		=	cell(0,1);
					Ptmp	=	[];
					cnt2	=	1;
					
					for p=1:Nsubj
						sel		=	dd(:,16) == Usubj(p);
						ddd		=	dd(sel,:);
						
						if( ~isempty(ddd) )
							ddd		=	[ddd(:,1) ddd(:,2:end)];
							
							Pz		=	getpercentile( ddd(:,1),[25 75] );
							Ptmp(cnt2)	=	Pz(2)-Pz(1);					%#ok<AGROW>
							
							xloc	=	zeros( size(ddd,1),1 ) + xcnt + (0.8/Nsubj * (p-Nsubj/2));
							
							h(cnt2)	=	plot(xloc,ddd(:,1),mk,'MarkerFaceColor',col(p,:));	%#ok<AGROW>
							hold on
							L(cnt2)	=	{['S' num2str(Usubj(p))]};
							cnt2	=	cnt2 + 1;
						end
					end
					plot([-.6 2*Nloc+.6-1],[0 0],'k--')
					plot(mx,[A A],'-','Color',pcol,'LineWidth',2)
					hp = patch([mx fliplr(mx)],[P(2) P(2) P(1) P(1)],pcol,'LineStyle',pmk);
					set(hp,'EdgeColor',pcol,'FaceColor','none')
% 					text(mx(1),75,['IQR= ' num2str(dround(P(2)-P(1)))],'FontName','Arial','FontWeight','bold','FontSize',12)
					set(gca,'FontName','Arial','FontWeight','bold','FontSize',14)
					set(gca,'XTick',0:2*Nloc,'XTickLabel',[Uloc' Uloc'],'YTick',0:15:95)
					xlim([-.6 2*Nloc+.6-1])
					ylim(yy)
					xlabel('Masker Location [deg]')
					ylabel('threshold [dB re TQ]')
					title([msk ' ' ftr ' ' str])
% 					if( l == 1 && m == 1 && n == 1 )
% 						L	=	L(h ~= 0);
% 						h	=	h(h ~= 0);
% 						legend(h,L,'Location','NorthWest','Orientation','horizontal')
% 						legend('boxoff')
% 					end
% 					if( l == 2 && m == 1 && n == 2 )
% 						L	=	L(h ~= 0);
% 						h	=	h(h ~= 0);
% 						legend(h,L,'Location','NorthWest','Orientation','horizontal')
% 						legend('boxoff')
% 					end
				end
				Pall	=	[Pall Ptmp];						%#ok<AGROW>
				xcnt	=	Nloc-1;
			end
			cnt	=	cnt + 1;
		end
	end
end

disp(['Average IQR = ' num2str(dround(mean(Pall)))])

%-- Helpers --%
function [D,T] = loaddat(pname,Check)

if( nargin < 2 )
	Check	=	0;
end

T			=	[];
Store		=	zeros(1,6);
len			=	length(pname);
cnt			=	1;
for k=1:len
	Pname	=	cell2mat(pname(k,1));
	name	=	dir([ Pname '*.mat' ]);
	
	Subject	=	getsubj(Pname);
	
	Ndat	=	length(name);
	for l=1:Ndat
		N		=	name(l,1).name;
		load([Pname N])
		
		idx1	=	strfind(N,'_')+1;
		idx2	=	strfind(N,'.')-1;
		NBlock	=	str2double( N(idx1(end):idx2(end)) );
		
		if( ~isnan(NBlock) )
		%-- Check file name congruency --%
		if( Check )
			if( ~strcmpi(N(1:idx1-2),Cn.ParamFile) )
				disp(['S' num2str(Subject) ' File ' num2str(l) ' Block ' num2str(NBlock) ' ' N(1:idx1-2) '   ' Cn.ParamFile ])
				in	=	input('Files do not match. Continue (1) or Quit (0): ');
				if( ~in )
					error('Parameter file name and executed parameter file are different!')
				end
			end
		end
		
		Thr		=	Threshold + 20;
		Sfreq	=	Cn.SigBand;
		Sloc	=	Cn.SigLoc;
		Mloc	=	abs( Cn.MaskLoc );
		Mspl	=	Cn.MaskSPL;
		Sspl	=	Cn.SigSPLStart;
		
		Timing	=	N(idx1-4);
		if( strcmp(Timing,'s') )
			Timing		=	0;
		elseif( strcmp(Timing,'S') )
			Timing		=	1;
		end
		
		Type			=	Cn.Paradigm;	%-- Stimulus types: 1: BS 2: BD 4: ES 5: ED	--%
		
		if( isfield( Cn,'NMask' ) )
			Nmask	=	Cn.NMask;
		else
			Nmask	=	Cn.NMaskBand;
		end
		
		Store(cnt,:)	=	[Type NBlock Sloc Mloc Mspl Timing];
		
		BaseRate		=	Cn.BaseRate;
		
		F				=	mean(Sfreq);
		ProtectBand		=	[F / 2^Cn.ProtectBand, F * 2^Cn.ProtectBand] + [-100 100];
		CB1_3			=	[F / 2^(1/6), F * 2^(1/6)];
		Folder			=	getfolder(Pname);
		
		Mfreq			=	getmaskfreq(TrlVal);
		
		D(cnt,:)		=	[Thr Sfreq(1) Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Folder Mfreq];	%#ok<AGROW>
		
		cnt				=	cnt + 1;
		end
	end
end

function Subject = getsubj(Pname)
	
if( isunix)
	idx	=	strfind(Pname,'/');
else
	idx	=	strfind(Pname,'\');
end

Subject	=	str2double( Pname(idx(end-1)+4:end-1) );

if( isnan(Subject) )
	Subject	=	0;
end

function Folder = getfolder(Pname)

idx	=	strfind(Pname,'BeepBoop2010');
Folder	=	Pname(idx+13:end);

if( isunix)
	idx	=	strfind(Folder,'/');
else
	idx	=	strfind(Folder,'\');
end

Folder	=	Folder(1:idx(1)-1);

if( strcmpi(Folder,'AP') || strcmpi(Folder,'AP2') )
	Folder	=	0;
elseif( strcmpi(Folder,'LP') || strcmpi(Folder,'HP') )
	Folder	=	1;
else
	Folder	=	NaN;
	disp('Unknown folder! Inserting NaN.')
end

function Mfreq = getmaskfreq(D,MedianFlag,PlotFlag)

if( nargin < 2 )
	MedianFlag	=	1;
end
if( nargin < 3 )
	PlotFlag	=	0;
end

Sfreq		=	D(1,1).SigFreq;

N		=	length(D);
% Mfreq	=	nan(N,1);
for k=N%1:N
	SI	=	D(1,k).SigInterval;
	MF	=	eval(['D(1,k).MaskFreq' num2str(SI)]);
	
	if( MedianFlag )
		%-- "Reversal" function lower octave --%
		Noctl		=	log2( Sfreq ./ MF );

		%-- "Reversal" function upper octave --%
		Noctu		=	log2( MF ./ Sfreq );
		
		dMF			=	abs( [Noctu(:); Noctl(:)] );
		Mfreq		=	median(dMF(:));
% 		Mfreq(k,1)	=	median(dMF(:));
	else
		Mfreq(k,1)	=	sum(MF(:));
	end
	
	if( PlotFlag )
		f = figure;
		for l=1:size(dMF,1)
			for m=1:size(dMF,2)
				plot(l,dMF(l,m),'k.')
				hold on
			end
		end
		plot(2.5,Mfreq(k,1),'ko')
% 		ylim([200 15000])
		ylim([0 4.5])
		xlim([.5 4.5])
		set(gca,'XTick',1:4)
		set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
		xlabel('pulse #')
		ylabel('frequency [oct]')
		pause
		close(f)
	end
end

%-- Median across all trials until end of tracking --%
if( MedianFlag )
	Mfreq	=	median(Mfreq);
else
	Mfreq	=	sum(Mfreq);
end

function C = getctrl(D,Mlvl)

if( nargin < 2 )
	Mlvl	=	-80;	%-- If signal alone Masker level = -80 --%
end

sel	=	D(:,5) == Mlvl;

mC	=	nanmean(D(sel,1),1);
% sC	=	nanstd(D(sel,:),[],1);				%-- Std deviation		--%
sC	=	nanstd(D(sel,1),[],1) / sqrt(sum(sel));	%-- Std error of mean	--%

C	=	[mC sC];

function Usubj = selectsubj(D,Freq,Mloc,Timing,Type,Mfilt)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Nfreq	=	length(Freq);
Nloc	=	length(Mloc);
Ntime	=	length(Timing);
Ntype	=	length(Type);
Nfilt	=	length(Mfilt);

Sub		=	[];
for k=1:Nfreq
	for l=1:Nloc
		for m=1:Ntime
			for n=1:Ntype
				for o=1:Nfilt
					sel		=	D(:,2) == Freq(k) & D(:,4) == Mloc(l) & D(:,7) == Timing(m) & ...
								D(:,8) == Type(n) & D(:,17) == Mfilt(o);
					
					Sub		=	[Sub; unique(D(sel,16))];					%#ok<AGROW>
				end
			end
		end
	end
end

Usubj	=	unique(Sub);

function [H,B,I,C,CD,CDI] = getthrhis(D,B,outlier)

if( nargin < 2 )
	B	=	[min(D(:,1)) max(D(:,1))];
	B	=	B(1):diff(B)/10:B(2);
end
if( nargin < 3 )
	outlier	=	1;
end

Nbin	=	length(B);

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Uloc	=	unique(D(:,4));
Nloc	=	length(Uloc);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

CD		=	nan(Nfreq,Nbin);
CDI		=	nan(Nfreq,2);
H		=	nan(Nfreq*Nloc*Ntime*Nfilt*Ntype,Nbin);
I		=	nan(Nfreq*Nloc*Ntime*Nfilt*Ntype,5);
C		=	cell(Nfreq*Nloc*Ntime*Nfilt*Ntype,1);
cnt		=	1;

for k=1:Nfreq
	%-- Get control for individual subjects --%	
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
	cel		=	D(:,2) == Ufreq(k) & D(:,8) == 2 & D(:,5) == -80;
	CD(k,:)	=	hist(D(cel,1),B);
	CDI(k,:)=	[Ufreq(k),sum(cel)];
	
	for l=1:Nloc
		for m=1:Ntime
			for n=1:Nfilt
				for o=1:Ntype
					if( Utype(o) == 4 || Utype(o) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
						sel	=	D(:,2) == Ufreq(k) & D(:,4) == Uloc(l) & ...
								D(:,7) == Utime(m) & D(:,8) == Utype(o) & D(:,5) ~= -80;
					else
						sel	=	D(:,2) == Ufreq(k) & D(:,4) == Uloc(l) & D(:,7) == Utime(m) & ...
								D(:,8) == Utype(o) & D(:,17) == Ufilt(n) & D(:,5) ~= -80;
					end
					
					d		=	D(sel,:);
					
					if( ~isempty(d) )
						if( outlier )
							%-- Get 25 & 75 percentiles --%
							[P,Crit]=	getpercentile( d(:,1),[25 75] );
							
							%-- Remove outliers according to Tuckey --%
							sel		=	d(:,1) >= (P(1) - Crit) & d(:,1) <= (P(2) + Crit);
							d		=	d(sel,:);
						end
						
						H(cnt,:)=	hist(d(:,1),B);
						I(cnt,:)=	[Ufreq(k) Uloc(l) Utime(m) Ufilt(n) Utype(o)];
						C(cnt,:)=	{d(:,1)};
						
						cnt		=	cnt + 1;
					end
				end
			end
		end
	end
end

%-- Get rid of combinations that haven't been tested --%
sel	=	~isnan(I(:,1));
H	=	H(sel,:);
I	=	I(sel,:);
C	=	C(sel,:);

function [P,Crit] = getpercentile( D,Per )

sd		=	sort( D );
P(1,1)	=	round( (Per(1)/100) * length(D) + .5 );
P(2,1)	=	round( (Per(2)/100) * length(D) + .5 );
P(1,1)	=	sd(P(1),1);
P(2,1)	=	sd(P(2),1);

IQR		=	P(2) - P(1);
Crit	=	IQR * 1.5;	%-- Tuckey criterion for outliers --%

function D = corrctrlindivsub(D)

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

for k=1:Nsubj
	cel	=	D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(k);
	CA	=	getctrl(D(cel,:),-80);
	
	sel			=	D(:,16) == Usubj(k);
	D(sel,1)	=	D(sel,1) - CA(1,1);
end

function KS = dokstest(D,I,Type,alpha,outlier)

if( nargin < 4 )
	alpha	=	0.01;
end
if( nargin < 5 )
	outlier	=	0;
end

sel1	=	I == Type(1);
sel2	=	I == Type(2);

d1		=	D{sel1,1};
d2		=	D{sel2,1};

if( outlier )	
	[P,Crit]=	getpercentile( d1,[25 75] );
			
	%-- Remove outliers according to Tuckey --%
	sel		=	d1 >= (P(1) - Crit) & d1 <= (P(2) + Crit);
	d1		=	d1(sel);
	
	[P,Crit]=	getpercentile( d2,[25 75] );
			
	%-- Remove outliers according to Tuckey --%
	sel		=	d2 >= (P(1) - Crit) & d2 <= (P(2) + Crit);
	d2		=	d2(sel);
end

[KS,p]	=	kstest2(d1,d2,alpha);
KS		=	[KS p length(d1) length(d2)];

[p,~,~]	=	ranksum(d1,d2,'alpha',alpha);
KS		=	[p KS(2:end)];

function mD = dokruskal(D,I,alpha)

if( nargin < 3 )
	alpha	=	0.05;
end

N	=	length(D);
len	=	nan(N,1);
for k=1:N
	len(k,1)	=	length(D{k,1});
end

Maxlen	=	max(len);
d		=	nan(Maxlen,N);
for k=1:N
	d(1:len(k),k)	=	D{k,1};
	
	Nrep	=	length(d(:,k));
	for l=1:Nrep
		G(l,k)	=	{num2str( I(k) )};
	end
end
[p,table,stats]	=	kruskalwallis(d,[],'off');
stats.gnames	=	G(1:end,1);
[c,m,h,gnames]	=	multcompare(stats,'alpha',alpha,'ctype','bonferroni','display','off');

% p	=	ranksum(d(:,1),d(:,2),'alpha',alpha);
% p	=	kstest2(d(:,1),d(:,2),alpha);

H	=	nan(N-1,2);
for k=1:N-1
	sel		=	c(k,3) <= 0 | c(k,5) <= 0;
	H(k,:)	=	[I(k+1) sel];
end

sel	=	H(:,2) == 0;
mD	=	min(H(sel,1));
if( isempty(mD) )
	mD	=	NaN;
	disp('no spatial separation is different from M0 deg.')
else
	disp(['M' num2str(mD) ' deg is different from M0 deg.'])
end

% Test	=	d(:,sel);
% p	=	ranksum(d(:,1),Test(:,1),'alpha',alpha);

function D = removeoutlier(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Uloc	=	unique(D(:,4));
Nloc	=	length(Uloc);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

C		=	[];

for k=1:Nfreq
	%-- Get control for individual subjects --%	
	sel		=	D(:,2) == Ufreq(k);
	D(sel,:)=	corrctrlindivsub(D(sel,:));
	
	for l=1:Nloc
		for m=1:Ntime
			for n=1:Nfilt
				for o=1:Ntype
					if( Utype(o) == 4 || Utype(o) == 5 )	%-- LP & HP energetic maskers == AP & AP2 energetic maskers --%
						sel	=	D(:,2) == Ufreq(k) & D(:,4) == Uloc(l) & D(:,7) == Utime(m) & ...
								D(:,8) == Utype(o) & D(:,17) ~= 1 & D(:,5) ~= -80;
					else
						sel	=	D(:,2) == Ufreq(k) & D(:,4) == Uloc(l) & D(:,7) == Utime(m) & ...
								D(:,8) == Utype(o) & D(:,17) == Ufilt(n) & D(:,5) ~= -80;
					end
					
					d		=	D(sel,:);
					
					if( ~isempty(d) )
						%-- Get 25 & 75 percentiles --%
						[P,Crit]=	getpercentile( d(:,1),[25 75] );
						
						%-- Remove outliers according to Tuckey --%
						sel		=	d(:,1) >= (P(1) - Crit) & d(:,1) <= (P(2) + Crit);
						d		=	d(sel,:);
						
						C	=	[C; d];						%#ok<AGROW>
					end
				end
			end
		end
	end
end

D	=	C;

function [b,bint,s,r,rint,stats] = multiregres(Xin,Yin,Ztrans)

if( nargin < 3 )
	Ztrans	=	1;
end

Ndat		=	size(Yin,1);

if( Ztrans )
	%-- Z-Transform to get partial correlation coefficients --%
	X		=	( Xin - mean(Xin) ) ./ std(Xin);
	mYin	=	mean(Yin);
	mYin	=	repmat(mYin,Ndat,1);
	sYin	=	std(Yin,[],1);
	sYin	=	repmat(sYin,Ndat,1);
	Y		=	( Yin - mYin ) ./ sYin;
else
	X		=	Xin;
	Y		=	Yin;
end

%-- Add a 0 column as a control --%
Y			=	[Y ones(Ndat,1)];

%-- Do the regression --%
[b,bint,r,rint,stats]		=	regress(X,Y);

s			=	std(bootstrp(1000,@regress,X,Y));

if( b(end) < 10^-6 )
	b		=	b(1:end-1);
	bint	=	bint(1:end-1,:);
	s		=	s(1:end-1);
end

function Lbl = makelabel(idx)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%
D	=	[	{'thr'} {'spectral'} {'Sloc'} {'space'} {'Mspl'} {'NBlock'} {'time'} {'type'} {'Nmask'} {'BaseRate'} ...
			{'ProtectBand'} {'ProtectBand'} {'CB1_3'} {'CB1_3'} {'Sspl'} {'Subject'} {'filter'}	];
Lbl	=	D(idx);

function h1 = errorbarxy(x,y,sx,sy,mk,varargin)

col	=	[];

h2	=	plot([x-sx x+sx],[y y],'-');
h3	=	plot([x x],[y-sy y+sy],'-');
h1	=	plot(x,y,mk);

len	=	length(varargin);
for k=1:2:len
	set(h1,varargin{1,k},varargin{1,k+1})
	
	if( strcmpi(varargin{1,k},'MarkerFaceColor') )
		col	=	varargin{1,k+1};
	end
end

if( isempty(col) )
	col	=	'k';
end
set(h2,'Color',col)
set(h3,'Color',col)

function h1 = errorperc(x,y,s,mk,varargin)

col	=	[];

N	=	length(x);

h2	=	nan(N,1);
for k=1:N
	h2(k,1)	=	plot([x(k) x(k)],[s(k,1) s(k,2)],mk(3:end));%'-');
	hold on
end

h1	=	plot(x,y,mk);

len	=	length(varargin);
for k=1:2:len
	set(h1,varargin{1,k},varargin{1,k+1})
	
	if( strcmpi(varargin{1,k},'Color') )
		col	=	varargin{1,k+1};
	end
end

if( isempty(col) )
	col	=	'k';
end
set(h2,'Color',col)

function d = selfreqtype(D,Ufreq,Utype,Loc)

Nfreq	=	length(Ufreq);
Ntype	=	length(Utype);

cnt		=	1;
for k=1:Nfreq
	for l=1:Ntype
		if( Utype(l) < 4 )
% 			sel		=	D(:,2) == Ufreq(k) & D(:,4) == Loc &  D(:,5) ~= -80 & D(:,17) == 0 & D(:,8) == Utype(l);
			sel		=	D(:,2) == Ufreq(k) & D(:,5) ~= -80 & D(:,17) == 1 & D(:,8) == Utype(l);
		else
% 			sel		=	D(:,2) == Ufreq(k) & D(:,4) == Loc & D(:,5) ~= -80 & D(:,8) == Utype(l);
			sel		=	D(:,2) == Ufreq(k) & D(:,5) ~= -80 & D(:,8) == Utype(l);
		end
		
		d(cnt,k)	=	{ D(sel,:) };							%#ok<AGROW>
		cnt			=	cnt + 1;
	end
end

function d = seltime2(D,Utime,Utype)

Ntime	=	length(Utime);
Ntype	=	length(Utype);

cnt		=	1;
for k=1:Ntime
	for l=1:Ntype
		if( Utype(l) < 4 )
			sel		=	D(:,4) == 0 &  D(:,5) ~= -80 & D(:,7) == Utime(k) & D(:,8) == Utype(l) & D(:,17) == 0;
		else
			sel		=	D(:,4) == 0 &  D(:,5) ~= -80 & D(:,7) == Utime(k) & D(:,8) == Utype(l);
		end
		
		d(cnt,k)	=	{ D(sel,:) };							%#ok<AGROW>
		cnt			=	cnt + 1;
	end
end

function [Mtx,Str,ID] = seltime(D,Utime,Utype)

Ntime	=	length(Utime);
Ntype	=	length(Utype);

d		=	cell(Ntime,Ntype);
len		=	nan(Ntime,Ntype);
for k=1:Ntime
	for l=1:Ntype
		if( Utype(l) < 4 )
			sel		=	D(:,4) == 0 &  D(:,5) ~= -80 & D(:,7) == Utime(k) & D(:,8) == Utype(l) & D(:,17) == 1;
		else
			sel		=	D(:,4) == 0 &  D(:,5) ~= -80 & D(:,7) == Utime(k) & D(:,8) == Utype(l);
		end
		
		d(k,l)		=	{ D(sel,:) };
		len(k,l)	=	sum(sel);
	end
end

mxlen	=	max(len(:));
Mtx		=	nan(mxlen,Ntime*Ntype);
Str		=	cell(1,Ntime*Ntype);
ID		=	nan(Ntime*Ntype,2);
cnt		=	1;
for l=1:Ntime
	if( Utime(l) == 0 )
		Time	=	'a';
	else
		Time	=	's';
	end
	
	for m=1:Ntype
		if( Utype(m) == 1 )
			Type	=	'iR';
		elseif( Utype(m) == 2 )
			Type	=	'iC';
		elseif( Utype(m) == 4 )
			Type	=	'eR';
		elseif( Utype(m) == 5 )
			Type	=	'eC';
		end
		
		Mtx(1:len(l,m),cnt)		=	d{l,m}(:,1);
		Str(1,cnt)				=	{[Type ' ' Time]};
		ID(cnt,:)				=	[Utype(m) Utime(l)];
		cnt						=	cnt + 1;
	end
end

function [Mtx,Str,ID] = selfreqpertype(D,Loc)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

d		=	cell(Ntime,Nfreq,Ntype);
len		=	nan(Ntime,Nfreq,Ntype);
for l=1:Ntime
	for k=1:Nfreq
		for m=1:Ntype
			if( Utype(m) > 3 )
				sel			=	D(:,2) == Ufreq(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,4) == Loc;
			else
				sel			=	D(:,2) == Ufreq(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,17) == 0 & D(:,4) == Loc;
			end
			
			d(l,k,m)	=	{D(sel,:)};
			len(l,k,m)	=	sum(sel);
		end
	end
end

mxlen	=	max(len(:));
Mtx		=	nan(mxlen,Ntime*Nfreq*Ntype);
Str		=	cell(1,Ntime*Nfreq*Ntype);
ID		=	nan(Ntime*Nfreq*Ntype,3);
cnt		=	1;
for l=1:Ntime
	if( Utime(l) == 0 )
		Time	=	'a';
	else
		Time	=	's';
	end
	
	for k=1:Nfreq
		for m=1:Ntype
			if( Utype(m) == 1 )
				Type	=	'iR';
			elseif( Utype(m) == 2 )
				Type	=	'iC';
			elseif( Utype(m) == 4 )
				Type	=	'eR';
			elseif( Utype(m) == 5 )
				Type	=	'eC';
			end
				
			Mtx(1:len(l,k,m),cnt)	=	d{l,k,m}(:,1);
			Str(1,cnt)				=	{[num2str(Ufreq(k)/10^3) ' ' Type ' ' Time]};
			ID(cnt,:)				=	[Ufreq(k) Utype(m) Utime(l)];
			cnt						=	cnt + 1;
		end
	end
end

function [Mtx,Str,ID] = selfilter(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		   17		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject MaskFilter];	--%

Ufreq	=	unique(D(:,2));
Nfreq	=	length(Ufreq);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Ufilt	=	unique(D(:,17));
Nfilt	=	length(Ufilt);

d		=	cell(Ntime,Nfreq,Ntype,Nfilt);
len		=	nan(Ntime,Nfreq,Ntype,Nfilt);
for l=1:Ntime
	for k=1:Nfreq
		for m=1:Ntype
			for n=1:Nfilt
				sel			=	D(:,2) == Ufreq(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,17) == Ufilt(n);% & D(:,4) == 80;
			
				d(l,k,m,n)	=	{D(sel,:)};
				len(l,k,m,n)=	sum(sel);
			end
		end
	end
end

mxlen	=	max(len(:));
Mtx		=	nan(mxlen,Ntime*Nfreq*Ntype*Nfilt);
Str		=	cell(1,Ntime*Nfreq*Ntype*Nfilt);
ID		=	nan(Ntime*Nfreq*Ntype*Nfilt,4);
cnt		=	1;
for l=1:Ntime
	if( Utime(l) == 0 )
		Time	=	'a';
	else
		Time	=	's';
	end
	
	for k=1:Nfreq
		for m=1:Ntype
			if( Utype(m) == 1 )
				Type	=	'iR';
			elseif( Utype(m) == 2 )
				Type	=	'iC';
			elseif( Utype(m) == 4 )
				Type	=	'eR';
			elseif( Utype(m) == 5 )
				Type	=	'eC';
			end
			
			for n=1:Nfilt
				if( Ufilt(n) == 0 )
					Filt	=	'all';
				else
					Filt	=	'band';
				end
				Mtx(1:len(l,k,m,n),cnt)	=	d{l,k,m,n}(:,1);
				Str(1,cnt)				=	{[num2str(Ufreq(k)/10^3) ' ' Type ' ' Time ' ' Filt]};
				ID(cnt,:)				=	[Ufreq(k) Utype(m) Utime(l) Ufilt(n)];
				cnt						=	cnt + 1;
			end
		end
	end
end

function [p,IDstr,ID] = posthockw(D,G,I)

N		=	size(D,2);
p		=	nan(N,N);
IDstr	=	cell(N,N);
% ID		=	nan(N*N,6);
ID		=	nan(N*N,size(I,2)*2);
cnt		=	1;
for k=1:N
	for l=1:N
		d						=	[D(:,k) D(:,l)];
		g						=	[G(1,k) G(1,l)];
		IDstr(k,l)				=	{[G{1,k} ' vs ' G{1,l}]};
		ID(cnt,:)				=	[I(k,:) I(l,:)];
		cnt						=	cnt + 1;
		
		[p(k,l),table,stats]	=	kruskalwallis(d,g,'off');
	end
end

p		=	p(:);
IDstr	=	IDstr(:);
