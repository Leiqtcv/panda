function AnaCentralFilterMD
% This function analyses the data collected from iMBD/iMBS or fix/random
% conditions (script name....)

%Data that is loaded contains:
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19  20		21			--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct AvgDist UpLow   ];	--%
% 1: Threshold
% 2: Signal Frequency kHz
% 3: Signal location (degrees)
% 4: Masker location (degrees)
% 5: Masker intensity (dB SPL)
% 6: Block number
% 7: Asynchronous = 0 / Synchronous = 1
% 8: iMBS(C) = 0 / iMBD(R) = 1
% 9: Number of masker
% 10: Basal Rate (usually 10 Hz)
% 11: Protected Band
% 12:
% 13:
% 14:
% 15: Signal intensity (dB SPL)
% 16: Subject
% 17: Fix = 0 / Rnd = 1
% 18: SDM
% 19: Protected Band (octaves)
% 20: Average Distance of Masker to Signal Frequency
% 21: UpperLowermasker (0 = only lower, 1 = only upper, 99 = both)

%if CheckmaskerFreq || ThrVsCOG == 1
% 22/37: Maskerfrequencies (1/4 = first pulse, 5/8 = second puls, 9/12 =
% third puls, 13/16 = fourth pulse)

tic
clear all
close all
clc

%% Flags
ThrVsPB			=	0;   %Plots Threshold vs Protected Band
ThrVsSDM		=	0;   %Plots Threshold vs SDM
CompFixRnd		=	0;   %Plots Fix vs Random
ERBScale		=	0;   %Plots everything on ERB scale, averages subject blocks and subjects
ERBScaleUL		=	0;	 %Plots everything on ERB scale, for the UpLow condition (only usable for one subject)
ThrVsBlock		=	0;   %Plots thresholds for every PB as function of block
BoxplotVsCond	=	0;	 %Plots a boxplot as function of condition per protected band
BoxplotVsPB		=   0;	 %Plots a boxplot as function of protected band per condition
BoxplotVsEnInf	=	1;	 %Plots a boxplot as function of both the energetic (PB0) conditions and informational (PB~=0)
ThrVsDist		=	0;	 %Plots the threshold vs. the average distance [in Hz] of masker frequency from signal for all condition, Only applicable for fixed
ThrVsDistUL		=	0;	 %Plots the threshold vs. the average distance [in Hz] of masker frequency from signal for all condition, for the UpLow condition
CheckMaskerFreq	=	0;   %Plot the Masker Frequencies, only for fixed conditions!
ThrVsCOG		=	0;	 %Plot the threshold vs. the masker's center of gravity

%% Subject Data

% -- All Data -- %
% pname		=	[	...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCIpb\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCIpb\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCImd\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCImd\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCI033\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCI033\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCI037\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCI057\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCI058\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCI058\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCI059\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCI059\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Fix\UCI060\'}; ...
% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCI060\'}; ...
% 				];

p = 'C:\DATA\Irvine\';

% -- Completed Blocks -- %
pname		=	[	...
	{[p 'Rnd\UCImd\']}; ...
	{[p 'Fix\UCImd\']}; ...
	{[p 'Rnd\UCI060\']}; ...
	{[p 'Fix\UCI060\']}; ...
	{[p 'Rnd\UCI059\']}; ...
	{[p 'Fix\UCI059\']}; ...
	{[p 'Rnd\UCI058\']}; ...
	{[p 'Fix\UCI058\']}; ...
	{[p 'Rnd\UCI057\']}; ...
	{[p 'Fix\UCI057\']}; ...
	{[p 'Rnd\UCI037\']}; ...
	{[p 'Fix\UCI037\']}; ...
	{[p 'Rnd\UCI033\']};...
	{[p 'Fix\UCI033\']};...
	
	% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\UpLowMask\LowMask\Fix\UCImd\'};...
	% 					{'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\UpLowMask\UpMask\Fix\UCImd\'};...
	];

%% Load data
D			=	loaddat(pname,CheckMaskerFreq, ThrVsCOG);
% return
D			=	corrctrlindivsub(D,1);  %Correct for control condition (individual subjects)

Usubj		=	1;
Ublock		=	2;
Upara		=	0; %unique Paradigm (fix = 0, rnd = 1)
Utype		=	2; %unique type (iR = 1 vs. iC = 2)
Utime		=	0; %unique timing (async. = 0 vs. sync = 1)
Upb			=	(1/3); %oct %-- [0    0.33    0.67    1   1.33   1.67   2]
Uuplow		=	1; %unique uplow (low = 0, up = 1, original = 99)

% keyboard
%% Plotting
if( ThrVsPB )
	sel		=	D(:,17) == 0;
	plotthrvspb(D(sel,:))   %Random/Fix
	plotthrvspb(D(~sel,:))  %Random/Fix
end

if( ThrVsSDM )
	sel		=	D(:,17) == 0;
	plotthrvssdm(D(sel,:))  %Random/Fix condition
	plotthrvssdm(D(~sel,:)) %Random/Fix condition
end

if( CompFixRnd )
	plotcompfixrnd(D)
end

if ( ERBScale )			%if multiple subjects/blocks, average is plotted
	ploterbscale(D)
end

if ( ERBScaleUL )
	ploterbscaleUL(D)
end

if ( ThrVsBlock )
	plotthrvsblock(D)
end

if ( BoxplotVsCond )
	plotBoxPlotVsCond(D)
end

if ( BoxplotVsPB )
	plotBoxPlotVsPB(D)
end

if ( BoxplotVsEnInf )
	plotBoxPlotVsEnInf(D)
end

if ( ThrVsDist )
	plotThrVsDist(D)
end

if ( ThrVsDistUL )
	plotThrVsDistUL(D)
end

if ( CheckMaskerFreq )
	plotCheckMaskFreq(D,Usubj,Ublock,Upara,Utype,Utime,Upb,Uuplow)
end

if ( ThrVsCOG )
	plotThrVsCOG(D)
end

%% Wrapping up
tend	=	( round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%% Functions
function plotthrvspb(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ufreq	=	unique(D(:,2));

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Upb		=	dround(unique(D(:,19)));
xx		=	[-.2 max(Upb)*1.1];
yy		=	[min(D(:,1))*1.1 max(D(:,15))*1.2];

F		=	(Ufreq - Ufreq ./ 2.^(Upb)) / Ufreq;

[c,r]	=	FactorsForSubPlot(Ntype*2);

figure
for k=1:Ntype
	if( Utype(k) == 1 )
		Str	=	'iR';
	elseif( Utype(k) == 2 )
		Str	=	'iC';
	end
	
	h1	=	nan(Ntime,1);
	h2	=	nan(Ntime,1);
	L	=	cell(Ntime,1);
	
	for l=1:Ntime
		if( Utime(l) == 1 )
			col		=	'b';
			L(l,1)	=	{'sync'};
		elseif( Utime(l) == 0 )
			col	=	'r';
			L(l,1)	=	{'async'};
		end
		
		sel	=	D(:,8) == Utype(k) & D(:,7) == Utime(l);
		d		=	D(sel,[18 1 19]);
		[~,idx]	=	sort(d(:,3));
		d		=	d(idx,:);
		
		Maxd	=	max(d(:,2));
		att		=	d(:,2)-Maxd;
		F		=	d(:,3);
		
		subplot(r,c,k)
		h1(l) = plot(d(:,3),d(:,2),'.-','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
		hold on
		
		subplot(r,c,k+2)
		h2(l) = plot(F,att,'.-','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
		hold on
	end
	
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	hold on
	xlim(xx)
	ylim(yy)
	set(gca,'XTick',Upb,'XTickLabel',Upb)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('protected band [oct]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	legend(h1,L)
	legend('boxoff')
	
	subplot(r,c,k+2)
	plot(xx,[0 0],'k:')
	hold on
	xlim([-.05 .85])
	ylim([-60 5])
	% 	xlim([0 .4])
	% 	ylim([-50 0])
	% 	set(gca,'XTick',dround(F),'XTickLabel',dround(F))
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('\Deltaf / f_{0}')
	ylabel('attenuation [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	legend(h2,L,'Location','SouthWest')
	legend('boxoff')
end

function plotthrvssdm(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ufreq	=	unique(D(:,2));

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

xx		=	[-.2 max(D(:,18))*1.1];
yy		=	[min(D(:,1))*1.1 max(D(:,15))*1.1];

[c,r]	=	FactorsForSubPlot(Ntype*2);

figure
for k=1:Ntype
	if( Utype(k) == 1 )
		Str	=	'iR';
	elseif( Utype(k) == 2 )
		Str	=	'iC';
	end
	
	h	=	nan(Ntime,1);
	L	=	cell(Ntime,1);
	
	for l=1:Ntime
		if( Utime(l) == 1 )
			col		=	'b';
			L(l,1)	=	{'sync'};
		elseif( Utime(l) == 0 )
			col	=	'r';
			L(l,1)	=	{'async'};
		end
		
		sel		=	D(:,8) == Utype(k) & D(:,7) == Utime(l);
		d		=	D(sel,[18 1 19]);
		[~,idx]	=	sort(d(:,1));
		d		=	d(idx,:);
		
		subplot(r,c,k)
		h(l) = plot(d(:,1),d(:,2),'.-','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
		% keyboard
		hold on
		
		
		subplot(r,c,k+2)
		plot(d(:,3),d(:,1),'.-','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
		hold on
	end
	
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	hold on
	xlim(xx)
	ylim(yy)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('SDM [oct]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	legend(h,L)
	legend('boxoff')
	
	subplot(r,c,k+2)
	plot(xx,xx,'k:')
	xlim(xx)
	ylim(xx)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('protected band [oct]')
	ylabel('SDM [oct]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
end

function plotcompfixrnd(D)

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ufreq	=	unique(D(:,2));

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));
Npara	=	length(Upara);

Upb		=	dround(unique(D(:,19)));
xx		=	[-.2 max(Upb)*1.1];
yy		=	[min(D(:,1))*1.1 max(D(:,15))*1.1];

F		=	(Ufreq - Ufreq ./ 2.^(Upb)) / Ufreq;

% Fl		=	Ufreq / 2^0.25;
% Fu		=	Ufreq * 2^0.25;
% CB		=	Fu - Fl;
CB		=	(4.37 * Ufreq*10^-3 + 1) * 24.7;
x		=	100:20000;
y		=	exp( -( (x-Ufreq) ./ CB ).^2 );
yfit	=	fitroex(x,y,Ufreq);

Noctl	=	log2( Ufreq ./ x( x <= Ufreq ) );
Noctu	=	log2( x( x > Ufreq ) / Ufreq );
xfit1	=	[-Noctl Noctu];
xfit2	=	(Ufreq - x) / Ufreq;

[c,r]	=	FactorsForSubPlot(Ntype*2);

figure
for k=1:Ntype
	if( Utype(k) == 1 )
		Str	=	'iR';
	elseif( Utype(k) == 2 )
		Str	=	'iC';
	end
	
	h1	=	nan(Ntime*Npara,1);
	h2	=	nan(Ntime*Npara,1);
	L	=	cell(Ntime*Npara,1);
	cnt	=	2;
	
	subplot(r,c,k)
	h1(1) = plot(xfit1,yfit./max(yfit).*max(D(:,1)),'k-.','LineWidth',1);
	hold on
	
	subplot(r,c,k+2)
	h2(1) = plot(xfit2,20.*log(yfit),'k-.','LineWidth',1);
	hold on
	
	L(1,1)	=	{'roex'};
	
	for l=1:Ntime
		if( Utime(l) == 1 )
			col		=	'b';
			Tstr	=	'sync';
		elseif( Utime(l) == 0 )
			col		=	'r';
			Tstr	=	'async';
		end
		
		for m=1:Npara
			if( Upara(m) == 0 )
				mk			=	'.-';
				L(cnt,1)	=	{['Fix ' Tstr]};
			elseif( Upara(m) == 1 )
				mk			=	'.--';
				L(cnt,1)	=	{['Rnd ' Tstr]};
			end
			
			% 			md = nan(length(Df),Nblock);        %Df, corrected protected band?
			% 			matt = nan(length(F),Nblock);       %F, sERB - mERB
			
			sel	=	D(:,8) == Utype(k) & D(:,7) == Utime(l) & D(:,17) == Upara(m);
			d		=	D(sel,[18 1 19]);
			[~,idx]	=	sort(d(:,3));
			d		=	d(idx,:);
			
			Maxd	=	max(d(:,2));
			att		=	d(:,2)-Maxd;
			% 	 		F		=	d(:,3);
			
			subplot(r,c,k)
			h1(cnt)	= plot(d(:,3),d(:,2),mk,'Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			
			subplot(r,c,k+2)
			h2(cnt)	= plot(F,att,mk,'Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			hold on
			
			cnt		=	cnt + 1;
		end
	end
	
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	xlim(xx)
	ylim(yy)
	set(gca,'XTick',Upb,'XTickLabel',Upb)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('protected band [oct]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	legend(h1,L)
	legend('boxoff')
	
	subplot(r,c,k+2)
	plot(xx,[0 0],'k:')
	xlim([-.05 .85])
	ylim([-50 5])
	% 	xlim([0 .4])
	% 	ylim([-50 0])
	% 	set(gca,'XTick',dround(F),'XTickLabel',dround(F))
	set(gca,'YTick',-50:10:0,'YTickLabel',-50:10:0)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('\Deltaf / f_{0}')
	ylabel('attenuation [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	legend(h2,L,'Location','SouthWest')
	legend('boxoff')
end

function ploterbscale(D)
% parameters
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ufreq	=	unique(D(:,2));     %unique signal frequency

Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (sync. = 1 vs. async = 0)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iMBS(C) = 0 vs. iMBD(R) = 1)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)

Npara	=	length(Upara);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

Upb		=	dround(unique(D(:,19))); %unique protected band (octaves??)
Npb		=	length(Upb);

Uuplow	=	unique(D(:,21));		%
Nuplow	=	length(Uuplow);

MF		=	[Ufreq ./ 2.^Upb Ufreq .* 2.^Upb]; %protected band

%The ERB-rate scale, or simply ERB scale,
%can be defined as a function ERBS(f) which returns the number of equivalent rectangular bandwidths below the given frequency f.
sERB	=	21.4 * log10(4.37 * Ufreq*10^-3 + 1 ); %Signal Frequency (1600 Hz) ERB
mERB	=	21.4 * log10(4.37 * MF(:,1)*10^-3 + 1 ); %masker ERB
F		=	sERB - mERB; %sERB - upper limit of masker ERB per protected band

Df		=	Ufreq-MF(:,1);                      %lower limit ERB of masker per protected band

xx		=	[-0.02 max(Upb)*1.1];                 % setting x-axis
yy		=	[min(D(:,1))*1.1 max(D(:,1))*1.1];  % setting y-axis

CB		=	(4.37 * Ufreq*10^-3 + 1) * 24.7;    %Critical Band

x		=	100:20000;                          %bandwidth of frequencies to be analyzed

y		=	exp( -( (x-Ufreq) ./ CB ).^2 );     %??
yfit	=	fitroex(x,y,Ufreq);                 %19901

Noctl   =   log2(Ufreq./x(x<=Ufreq));
Noctu   =   fliplr(Noctl);
xoct    =   [Noctl nan(1,length(yfit)-length(Noctl))];

ERB			=	21.4 * log10(4.37 * x*10^-3 + 1 );
xfit1		=	xoct;		                            %For x frequencies
xfit2		=	sERB - ERB;								%For all ERB's for the frequencies x, corrected for signal ERB

[c,r]	=	FactorsForSubPlot(Ntype*2);

% col		=	linspace(0,1,Nsubj+1);
% colr	=	[ones(Nsubj+1,1) col' col'];
% colb	=   [col' col' ones(Nsubj+1,1)];

figure
for k=1:Ntype               %length type (iR vs iC)
	if( Utype(k) == 1 )
		Str	=	'iR';
	elseif( Utype(k) == 2 )
		Str	=	'iC';
	end
	
	h1	=	nan(Ntime*Npara,1); %vector depending on (a)/synchronous and fix/rnd
	h2	=	nan(Ntime*Npara,1);
	L	=	cell(Ntime*Npara,1);
	LL	=	cell(Nsubj,1);
	cnt	=	2;                  %counter for fix/rnd condition
	
	subplot(r,c,k)
	h1(1) = plot(xfit1,yfit./max(yfit).*max(D(:,1)),'k-.','LineWidth',1); %fill graph with background filter
	hold on
	subplot(r,c,k+2)
	h2(1) = plot(xfit2,20.*log(yfit),'k-.','LineWidth',1);              %fill graph with background filter
	hold on
	
	L(1,1)	=	{'Roex'};
	
	for l=1:Ntime                   %for every (a)synchronous condition
		if( Utime(l) == 1 )         %synchronous
			col		=	'b';
			Tstr	=	'sync';
		elseif( Utime(l) == 0 )     %asynchronous
			col		=	'r';
			Tstr	=	'async';
		end
		
		for m = 1:Npara %for every fix/rnd
			if( Upara(m) == 0 )          %fixed
				mk			=	'.-';
				ParaStr		=	'Fix';
			elseif ( Upara(m) == 1 )      %random
				mk			=	'.-.';
				ParaStr		=	'Rnd';
			end
			
			Subd	=	nan(length(Df),Nsubj);
			subatt	=	nan(length(Df),Nsubj);
			
			for x = 1:Nuplow
				if Uuplow(x) == 0
					UpLowStr	=	'Maskers < Signal';
					col			=	'k';
				elseif Uuplow(x) == 1
					UpLowStr	=	'Maskers > Signal';
					col			=	'k';
				elseif Uuplow(x) == 99
					UpLowStr	=	'Original';
				end
				
				L(cnt,1)	=	{[ParaStr ' ' Tstr]};
				
				for n = 1:Nsubj
					CurSub = Usubj(n);
					LL(n,1)	=	{[num2str(CurSub)]};
					COL	   = col;
					
					md = nan(length(Df),Nblock);        %Df, corrected protected band?
					matt = nan(length(F),Nblock);       %F, sERB - mERB
					
					for o	= 1:Nblock   %Nblock
						
						sel		=	D(:,8) == Utype(k) & D(:,7) == Utime(l) & D(:,17) == Upara(m) & D(:,16) == Usubj(n) & D(:,6) == Ublock(o) & D(:,21) == Uuplow(x);
						d		=	D(sel,[18 1 19]);
						[~,idx]	=	sort(d(:,3));       % sort by PBoct
						d		=	d(idx,:);           % apply sort to Thr and SDM
						try
							md(:,o)	=	d(:,2);             % apply thresholds in md (for different blocks)
						catch
							disp('Error filling md: check if blocks are uneven')
						end
						
						Maxd	=	max(d(:,2));
						att		=	d(:,2)-Maxd;
						% 				F		=	d(:,3);
						try
							matt(:,o)	=	att;             % apply thresholds in md (for different blocks)
						catch
							disp('Error filling matt: check if blocks are uneven')
						end
					end
					
					Subd(:,n)		=	nanmean(md,2);
					subatt(:,n)		=	nanmean(matt,2);
				end
				
				subplot(r,c,k)
				h1(cnt)	= plot(Upb,nanmean(Subd,2),mk,'Color',COL,'MarkerFaceColor',COL,'MarkerEdgeColor',COL); %mark thresholds for every block
				hold on
				
				subplot(r,c,k+2)
				h2(cnt)	= plot(F,nanmean(subatt,2),mk,'Color',COL,'MarkerFaceColor',COL,'MarkerEdgeColor',COL);
				hold on
				
				cnt		=	cnt + 1;
			end
		end
	end
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	hold on
	xlim(xx)
	ylim(yy)
	set(gca,'XTick',Upb,'XTickLabel',Upb)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('Protected Band [Oct]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	try
		legend(h1,L,'Location','NorthEast')
		legend('boxoff')
	catch
		% keyboard
	end
	
	subplot(r,c,k+2)
	plot([-1 max(F)*1.1],[0 0],'k:')
	hold on
	xlim([-1 max(F)*1.1])
	ylim([-yy(2) 5])
	set(gca,'YTick',-50:10:0,'YTickLabel',-50:10:0,'XTick',0:2:12)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('\Delta ERB_{N} number [Hz]')
	ylabel('attenuation [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	try
		legend(h2,L,'Location','SouthEast')
		legend('boxoff')
	catch
		% keyboard
	end
	% 	LL
	% % 	legend(LL,'Location','NorthEastOutside')
	
end

function ploterbscaleUL(D)
% parameters
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19	20		21      --%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct	AvgDist UpLow  ];	--%
Ufreq	=	unique(D(:,2));     %unique signal frequency

Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (sync. = 1 vs. async = 0)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iR = 1 vs. iC = 2)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

Upb		=	dround(unique(D(:,19))); %unique protected band (octaves??)

Uuplow	=	unique(D(:,21));
Nuplow	=	length(Uuplow);

MF		=	[Ufreq ./ 2.^Upb Ufreq .* 2.^Upb]; %????????
% sERB	=	(4.37 * Ufreq*10^-3 + 1) * 24.7;
% mERB	=	(4.37 * MF(:,1)*10^-3 + 1) * 24.7;

%The ERB-rate scale, or simply ERB scale,
%can be defined as a function ERBS(f) which returns the number of equivalent rectangular bandwidths below the given frequency f.
sERB	=	21.4 * log10(4.37 * Ufreq*10^-3 + 1 ); %Signal Frequency (1600 Hz) ERB
mERB	=	21.4 * log10(4.37 * MF(:,1)*10^-3 + 1 ); %masker ERB
F		=	sERB - mERB; %sERB - upper limit of masker ERB per protected band

Df		=	Ufreq-MF(:,1);                      %lower limit ERB of masker per protected band
Df		=	[Df Upb];

xx		=	[-0.02 max(Upb)*1.1];                 % setting x-axis;                 % setting x-axis
yy		=	[min(D(:,1))*1.1 max(D(:,1))*1.1];  % setting y-axis

CB		=	(4.37 * Ufreq*10^-3 + 1) * 24.7;    %Critical Band
x		=	100:20000;                          %bandwidth of frequencies to be analyzed
y		=	exp( -( (x-Ufreq) ./ CB ).^2 );     %??
yfit	=	fitroex(x,y,Ufreq);                 %??

Noctl   =   log2(Ufreq./x(x<=Ufreq));
xoct    =   [Noctl nan(1,length(yfit)-length(Noctl))];

ERB			=	21.4 * log10(4.37 * x*10^-3 + 1 );
xfit1		=	xoct;		                            %For x frequencies
xfit2	=	sERB - ERB;							%For all ERB's for the frequencies x, corrected for signal ERB

% [c,r]	=	FactorsForSubPlot(Ntype*2);
c		=	2;
r		=	1;

col		=	linspace(0,1,Nblock+1);
colr	=	[ones(Nblock+1,1) col' col'];
colb	=   [col' col' ones(Nblock+1,1)];
colk	=   [zeros(Nblock+1,1) zeros(Nblock+1,1) zeros(Nblock+1,1)];

figure
for k=1:Ntype               %length type (iR vs iC)
	if( Utype(k) == 1 )
		Str	=	'iR';
	elseif( Utype(k) == 2 )
		Str	=	'iC';
	end
	
	h1	=	nan(Ntime*Npara,1); %vector depending on (a)/synchronous and fix/rnd
	h2	=	nan(Ntime*Npara,1);
	L	=	cell(Ntime*Npara,1);
	LL	=	cell(Nsubj,1);
	cnt	=	1;                  %counter for fix/rnd condition
	
	subplot(r,c,k)
	h1(1) = plot(xfit1,yfit./max(yfit).*max(D(:,1)),'k-.','LineWidth',1); %fill graph with background filter
	hold on
	
	% 	subplot(r,c,k+2)
	% 	h2(1) = plot(xfit2,20.*log(yfit),'k-.','LineWidth',1);              %fill graph with background filter
	% 	hold on
	
	% 	L(1,1)	=	{'roex'};
	
	for x = 1:Nuplow
		if Uuplow(x) == 0 % lower case
			UpLowStr	=	'"LowMask"';
			col			=	colr;
		elseif Uuplow(x) == 1 %upper case
			UpLowStr	=	'"UpMask"';
			col			=	colb;
		elseif Uuplow(x) == 99 %both upper and lower
			UpLowStr	=	'"Original"';
			col			=	colk;
		end
		
		for l=1:Ntime
			%for every (a)synchronous condition
			if( Utime(l) == 1 )         %synchronous
				Tstr	=	'Sync';
				mk			=	'.-';
			elseif( Utime(l) == 0 )     %asynchronous
				Tstr	=	'Async';
				mk			=	'.-.';
			end
			
			for m = 1:Npara %for every fix/rnd
				if( Upara(m) == 0 )          %fixed
					ParaStr		=	'Fix';
				elseif ( Upara(m) == 1 )      %random
					ParaStr		=	'Rnd';
				end
				
				for o	= 1:Nblock
					COL		=	col(o,:);
					L(cnt,1)	=	{[UpLowStr ' ' Tstr ' Block ' num2str(Ublock(o))]};
					
					sel		=	D(:,8) == Utype(k) & D(:,7) == Utime(l) & D(:,17) == Upara(m) & D(:,6) == Ublock(o) & D(:,21) == Uuplow(x);
					d		=	D(sel,[18 1 19]);
					[~,idx]	=	sort(d(:,3));       % sort by PBoct
					d		=	d(idx,:);           % apply sort to Thr and SDM
					Thr		=	d(:,2);
					
					% 					len		=	length(d(:,3));
					% 					UPB			=	nan(len,1);
					% 					for z = 1:len
					% 						sel			=	Upb == dround(d(z,3));
					% 						UPB(z,:)	=	UPB(sel,:);
					% 					end
					
					Maxd	=	max(d(:,2));
					att		=	d(:,2)-Maxd;
					
					subplot(r,c,k)
					try
						h1(cnt)	= plot(d(:,3),Thr,mk,'Color',COL,'MarkerFaceColor',COL,'MarkerEdgeColor',COL); %mark thresholds for every block
						hold on
					catch
						disp('Error');
					end
					
					% 					subplot(r,c,k+2)
					% 					h2(cnt)	= plot(F,att,mk,'Color',COL,'MarkerFaceColor',COL,'MarkerEdgeColor',COL);
					% 					hold on
					
					cnt		=	cnt + 1;
				end
			end
		end
	end
	
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	hold on
	xlim(xx)
	ylim(yy)
	set(gca,'XTick',Upb,'XTickLabel',Upb)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('\Deltaf [Hz]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
	try
		legend(h1,L,'Location','NorthEast')
	catch
		% keyboard
	end
	legend('boxoff')
	
	% 	subplot(r,c,k+2)
	% 	plot([-1 max(F)*1.1],[0 0],'k:')
	% 	hold on
	% 	xlim([-1 max(F)*1.1])
	% 	ylim([-yy(2) 5])
	% 	set(gca,'YTick',-50:10:0,'YTickLabel',-50:10:0,'XTick',0:2:12)
	% 	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	% 	xlabel('\Delta ERB_{N} number [Hz]')
	% 	ylabel('attenuation [dB]')
	% 	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	% 	axis('square')
	% 	legend(LL,'Location','NorthEastOutside')
end

function plotthrvsblock(D)
% parameters
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ufreq	=	unique(D(:,2));     %unique signal frequency

Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (sync. = 1 vs. async = 0)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iMBS(C) = 0 vs. iMBD(R) = 1)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

xx		=	[0.8 max(Ublock)*1.1];  %setting x-axis
yy		=	[min(D(:,1))*1.1 max(D(:,1))*1.2]; %setting y-axis

cmtx	=	jet(Npb);

for k = 1:Npara
	
	if( Upara(k) == 0 )
		Pstr	=	'Fix';
	elseif( Upara(k) == 1 )
		Pstr	=	'Rnd';
	end
	
	figure
	
	[c,r]	=	FactorsForSubPlot(Ntype*Ntime);
	
	for m=1:Ntype               %length type (iR vs iC)
		if( Utype(m) == 1 )
			Str	=	'iR';
		elseif( Utype(m) == 2 )
			Str	=	'iC';
		end
		
		for l=1:Ntime                   %for every (a)synchronous condition
			if( Utime(l) == 1 )         %synchronous
				Tstr	=	'Sync';
			elseif( Utime(l) == 0 )     %asynchronous
				Tstr	=	'Async';
			end
			
			L			=	cell(Npb,1);
			h1			=	nan(Npb,1);
			h2			=	nan(Npb,1);
			for n=1:Npb
				col		=	cmtx(n,:);
				L(n,1)	=	{['PB' num2str( dround(Upb(n)) )]};
				
				sel		=	D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n) & D(:,17) == Upara(k);
				d		=	D(sel,[1 6 19]);
				
				if Utime(l) == 0 %asynchronous
					subplot(r,c,m) % (m=1 --> iR, m=2 --> iC)
					h1(n) = plot(d(:,2),d(:,1),'.-','Color',col);
					hold on
				elseif Utime(l) == 1 %synchronous
					subplot(r,c,m+2) %(m=2 --> iR, m=2 --> iC)
					h2(n) = plot(d(:,2),d(:,1),'.-','Color',col);
					hold on
				end
			end
			
			if Utime(l) == 0 %asynchronous
				subplot(r,c,m)
				xlim(xx)
				ylim(yy)
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
				xlabel('Block number')
				ylabel('Masked Threshold [dB]')
				title([Pstr ' ' Str ' ' Tstr])
				axis('square')
				legend(h1,L,'Location','NorthEast')
				legend('boxoff')
			elseif Utime(l) == 1 %synchronous
				subplot(r,c,m+2) %(m=2 --> iR, m=2 --> iC)
				xlim(xx)
				ylim(yy)
				set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
				xlabel('Block number')
				ylabel('Masked Threshold [dB]')
				title([Pstr ' ' Str ' ' Tstr])
				axis('square')
				legend(h2,L,'Location','NorthEast')
				legend('boxoff')
			end
		end
	end
end

function plotBoxPlotVsCond(D)
% parameters
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (sync. = 1 vs. async = 0)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iMBS(C) = 0 vs. iMBD(R) = 1)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

c		=	round(sqrt(Npb));
r		=   round(sqrt(Npb));

col		=	linspace(0,1,Nsubj+1);
colr	=	[ones(Nsubj+1,1) col' col'];
colb	=   [col' col' ones(Nsubj+1,1)];

h1			 = nan(Nsubj,1);
ll			 = cell(Nsubj,1);
Xlabel		 = cell(Ntime*Npara*Ntype,1);
ColLeg		 = cell(Ntime,1);

figure
for k = 1:Npb
	cnt = 0;
	cnt2	=	1;
	PlotTitle = {'PB' num2str( dround(Upb(k)))};
	
	for l = 1:Ntime
		if Utime(l) == 0
			TimeStr = 'Async';
			col		= colr;
			Place1	= 0;
			
		elseif Utime(l) == 1    %% add 4 after end of this loop to count
			TimeStr = 'Sync';
			col		= colb;
			Place1  = 3;
		end
		
		ColLeg(l,1)	= {TimeStr};
		
		for m = 1:Npara %% add 2 to cnt2 after end of this loop
			if Upara(m) == 0
				ParaStr = 'Fix';
				Place2 = 1 + cnt;
			elseif Upara(m) == 1
				ParaStr = 'Rnd';
				Place2 = 3 + cnt;
			end
			
			for n = 1:Ntype
				if Utype(n) == 1
					TypeStr	=	'iR';
					Place3  = 0;
				elseif Utype(n) == 2
					TypeStr =	'iC';
					Place3  = 1;
				end
				
				Xlabel(cnt2,1)	    = {[ParaStr ' ' TypeStr]};
				Rightplace			= Place1 + Place2 + Place3;
				
				for o = 1:Nsubj
					RightPlace = Rightplace + (o-1)*0.1;
					
					CurSub		=	Usubj(o);
					ll(o,1)		=   {['Subject' num2str(CurSub)]};
					
					for p = 1:Nblock
						sel = D(:,19) == Upb(k) & D(:,7) == Utime(l) & D(:,17) == Upara(m) & D(:,8) == Utype(n) & D(:,16) == Usubj(o) & D(:,6) == Ublock(p) ;
						d = D(sel,1);
						
						subplot(c,r,k)
						try
							if k == Npb
								if Utime(l) == 0
									h1(o,1) = plot(RightPlace, d, '.', 'Color', col(o,:));
									hold on
								elseif Utime(l) == 1
									h2(o,1) = plot(RightPlace, d, '.', 'Color', col(o,:));
									hold on
								end
							else
								plot(RightPlace, d, '.', 'Color', col(o,:));
								hold on
							end
						catch
							disp('Error Plotting d: Check if Nblocks of individual subjects mismatch')
						end
					end
				end
				
				sel					=	D(:,19) == Upb(k) & D(:,7) == Utime(l) & D(:,17) == Upara(m) & D(:,8) == Utype(n);
				d					=	D(sel,1);
				
				P					=	getpercentile( d,[25 75] );
				mP					=	nanmedian(d);
				plot([RightPlace-Nsubj*.0833 RightPlace],[mP mP],'-','Color',col(1,:),'LineWidth',2)
				hp					= patch([RightPlace-Nsubj*.0833 RightPlace RightPlace RightPlace-Nsubj*.0833],[P(1) P(1) P(2) P(2)],col(1,:));
				HP(l)				= hp;
				Center(cnt2,:)		= [RightPlace-Nsubj*.0833 RightPlace];
				set(hp,'EdgeColor',col(1,:),'FaceColor','none')
				cnt2	=	cnt2 + 1;
			end
		end
		cnt = cnt + 1;
	end
	title(PlotTitle);
	ylabel('Threshold dB')
	Centers		=	mean(Center,2);
	set(gca,'Xtick',Centers,'XtickLabel',Xlabel,'FontSize',7)
	axis([min(Center(:,1))*0.6 max(Center(:,2))*1.05 -10 max(D(:,1))*1.1])
	plot([-2 max(Center(:,2))*1.05],[0 0],'k:')
	legend(HP,ColLeg,'Location','NorthEast')
	legend('boxoff')
	if k == Npb		%plot only one legend for last figure (same as others)
		h = [h1; h2];
		L = [ll; ll];
		pause(0.2)
		legend(h,L,'Location','SouthEastOutside')
	end
end

function plotBoxPlotVsPB(D)
% parameters
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%

Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (async. = 0 vs. sync = 1)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iC = 1 vs. iR = 2)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

[c,r]	=	FactorsForSubPlot(Ntype*Ntime);

col		=	linspace(0,1,Nsubj+1);
colr	=	[ones(Nsubj+1,1) col' col'];
colb	=   [col' col' ones(Nsubj+1,1)];

h1		= nan(Nsubj*Npara,1);
L		= cell(Npb,1);
ll		= cell(Nsubj*Npara,1);

cnt		= 0;

figure
for k = 1:Ntime
	if Utime(k) == 0
		TimeStr	=	'Async';
	elseif Utime(k) == 1
		TimeStr =	'Sync';
	end
	
	for l = 1:Ntype
		if Utype(l) == 1
			TypeStr	=	'iR';
		elseif Utype(l) == 2
			TypeStr =	'iC';
		end
		
		for m = 1:Npara
			if Upara(m) == 0
				ParaStr = 'Fix';
				col		= colb;
				nn		= 0;
				nlegend	= 0;
				Place1	= 0;
			elseif Upara(m) == 1    %% add 4 after end of this loop to count
				ParaStr = 'Rnd';
				col		= colr;
				nn		= 7;
				nlegend = Nsubj;
				Place1  = 15;
			end
			
			for n = 1:Npb
				L(n,1)	=	{ num2str( dround(Upb(n)) ) };
				
				for o = 1:Nsubj
					RightPlace(n+nn,1)		=   Place1 + (n-1)*2 + (o-1)*0.1;
					CurSub					=	Usubj(o);
					
					ll(o+nlegend,1)					=   {['Subject' num2str(CurSub)]};
					
					for p = 1:Nblock
						sel = D(:,7) == Utime(k) & D(:,8) == Utype(l) & D(:,17) == Upara(m) & D(:,19) == Upb(n) & D(:,16) == Usubj(o) & D(:,6) == Ublock(p) ;
						d = D(sel,1);
						
						subplot(c,r,k+cnt)
						try
							h1(o+nlegend,1) = plot(RightPlace(n+nn,1), d, '.', 'Color', col(o,:));
							hold on
						catch
							disp('Error Plotting d: Check if Nblocks of individual subjects mismatch')
						end
					end
				end
				sel	=	D(:,19) == Upb(n) & D(:,7) == Utime(k) & D(:,17) == Upara(m) & D(:,8) == Utype(l);
				d	=	D(sel,1);
				
				P	=	getpercentile( d,[25 75] );
				mP	=	median(d);
				plot([RightPlace(n+nn,1)-Nsubj*.09 RightPlace(n+nn,1)],[mP mP],'-','Color',col(1,:),'LineWidth',2)
				hp = patch([RightPlace(n+nn,1)-Nsubj*.09 RightPlace(n+nn,1) RightPlace(n+nn,1) RightPlace(n+nn,1)-Nsubj*.09],[P(1) P(1) P(2) P(2)],col(1,:));
				HP(m) = hp;
				set(hp,'EdgeColor',col(1,:),'FaceColor','none')
				Center				=	[RightPlace-Nsubj*.090 RightPlace];
				Centers				=	mean(Center,2);
			end
		end
		
		% 		for z = 1:length(h1)
		% 			if isnan(h1(z,1))
		% 				h1(z,1) = 9999999;
		% 			end
		% 		end
		plot([-2 max(RightPlace)*1.05],[0 0],'k:')
		cnt = cnt + 1;
		title([TimeStr ' ' TypeStr],'Fontsize',14,'Fontweight','b')
		tick = [L; L];
		set(gca,'Xtick',Centers,'Xticklabel',tick,'FontSize',10)
		axis([-2 max(RightPlace)*1.05 -10 max(D(:,1))*1.1])
		xlabel('Protected Band [Oct]','fontsize',12)
		ylabel('Masked Threshold [dB]','fontsize',12)
		legend(HP,'Fix','Rnd','Location','NorthEast')
		legend('boxoff')
	end
	cnt = 1;
end

function plotBoxPlotVsEnInf(D)
Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (async. = 0 vs. sync = 1)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iC = 1 vs. iR = 2)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

Usubj	=	[1 59 60 33 57 58];%unique(D(:,16));Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

col		=	linspace(0,1,Nsubj+1);
colr	=	[ones(Nsubj+1,1) col' col'];
colb	=   [col' col' ones(Nsubj+1,1)];

Subplot1	=	(Npb-1)/3;
Subplot2	=	(Npb-1)/2;

for j = 1:Ntime
	if Utime(j) == 0
		TimeStr = 'Async';
	elseif Utime(j) == 1
		TimeStr = 'Sync';
	end
	
	figure
	for k = 1:Npb-1
		Title			= (['PB ' num2str(Upb(k+1)) ' ' TimeStr ]);
		Labels			=  cell(Ntype*4,1);
		
		for l = 1:Npara
			if Upara(l) == 0
				ParaStr = 'Fix';
				col = colb;
				Place1 = 1;
				RPfactor = 0;
			elseif Upara(l) == 1
				ParaStr = 'Rnd';
				col = colr;
				Place1 = 5;
				RPfactor	=	4;
			end
			
			for m = 1:Ntype*2
				if m <= 2 && Utype(m) == 1
					TypeStr = 'eR';
					Place2	= 0;
					RPidx	= 1 + RPfactor;
				elseif m <= 2 && Utype(m) == 2
					TypeStr = 'eC';
					Place2	= 1;
					RPidx	= 2 + RPfactor;
				elseif m == 3
					TypeStr = 'iR';
					mm = m - 2;
					Place2	= 2;
					RPidx	= 3 + RPfactor;
				elseif m == 4
					TypeStr = 'iC';
					mm = m-2;
					Place2	= 3;
					RPidx	= 4 + RPfactor;
				end
				
				for n = 1:Nsubj
					CurSub = Usubj(n);
					
					RightPlace	=	Place1 + Place2 + (n-1)*0.1;
					
					for o = 1:Nblock
						
						if m <= 2
							sel = D(:,7) == Utime(j) & D(:,19) == 0 & D(:,17) == Upara(l) & D(:,8) == Utype(m)...
								& D(:,16) == Usubj(n) & D(:,6) == Ublock(o);
							d = D(sel,1);
							
							selBP	=	D(:,19) == 0 & D(:,7) == Utime(j) & D(:,17) == Upara(l) & D(:,8) == Utype(m);
							dBP		=	D(selBP,1);
						elseif m > 2
							sel = D(:,7) == Utime(j) & D(:,19) == Upb(k+1) & D(:,17) == Upara(l) & D(:,8) == Utype(mm)...
								& D(:,16) == Usubj(n) & D(:,6) == Ublock(o);
							d = D(sel,1);
							
							selBP	=	D(:,19) == Upb(k+1) & D(:,7) == Utime(j) & D(:,17) == Upara(l) & D(:,8) == Utype(mm);
							dBP		=	D(selBP,1);
						end
						try
							subplot(Subplot1,Subplot2,k)
							plot(RightPlace, d, '.', 'Color', col(n,:));
							hold on
							title(Title,'fontsize',12,'fontweight','b')
							ylabel('Masked Threshold [dB]','fontsize',11)
						catch
							disp('Error Plotting d: Check if Nblocks of individual subjects mismatch')
						end
						
					end
				end
				P	=	getpercentile( dBP,[25 75] );
				mP	=	nanmedian(dBP);
				plot([RightPlace-Nsubj*.090 RightPlace],[mP mP],'-','Color',col(1,:),'LineWidth',2)
				hp = patch([RightPlace-Nsubj*.090 RightPlace RightPlace RightPlace-Nsubj*.090],[P(1) P(1) P(2) P(2)],col(1,:));
				Center			=	[RightPlace-Nsubj*.090 RightPlace];
				Centers(RPidx)	=	mean(Center);
				Labels(RPidx)	=	{TypeStr};
				HP(l) = hp;
				set(hp,'EdgeColor',col(1,:),'FaceColor','none')
			end
		end
		set(gca,'Xtick',Centers,'Xticklabel',Labels,'Fontsize',11)
		axis([.5 max(RightPlace)*1.05 -10 max(D(:,1))*1.1])
		legend(HP,'Fix','Random','Location','NorthEast')
		legend('boxoff')
		plot([.5 max(RightPlace)*1.05],[0 0],'k:')
	end
end

function plotThrVsDist(D)
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19    20		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct  AvgDiff];	--%
Ufreq	=	unique(D(:,2));     %unique signal frequency

Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (async. = 0 vs. sync = 1)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iC = 1 vs. iR = 2)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

cmtx	=	jet(Nsubj);

for k = 1:Npara
	if Upara(k) == 0
		ParaStr	=	'Fix';
	elseif Upara(k) ==1
		ParaStr =	'Rnd';
	end
	
	for l = 1:Ntime
		if Utime(l) == 0
			TimeStr	=	'Async';
		elseif Utime(l) == 1
			TimeStr =	'Sync';
		end
		
		for m = 1:Ntype
			if Utype(m) == 1
				TypeStr = 'iC';
			elseif Utype(m) == 2
				TypeStr = 'iR';
			end
			
			figure
			for n = 1:Npb
				PB	=	(['PB ' num2str(Upb(n))]);
				
				for o = 1:Nsubj
					CurSub = Usubj(o);
					cnt	= 1;
					
					for p = 1:Nblock
						sel = D(:,17) == Upara(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n)...
							& D(:,16) == Usubj(o) & D(:,6) == Ublock(p);
						d	=	D(sel,[1 20]);
						col	   = cmtx(o,:).*cnt;
						cnt	   = cnt - 0.15;
						
						subplot(3,3,n)
						plot(d(:,2),d(:,1),'.','Color',col)
						hold on
					end
					
					sel = D(:,17) == Upara(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n)...
						& D(:,16) == Usubj(o);
					d	=	D(sel,[1 20]);
					plot(d(:,2),d(:,1),'-','Color',cmtx(o,:))
				end
				title([ParaStr ' ' TimeStr ' ' TypeStr ' ' PB])
				xlabel('Average distance of Maskers per Signal Trial [Hz]')
				ylabel('Threshold [dB]')
				axis([0 max(D(:,20))*1.1 -10 max(D(:,1))*1.1])
				set(gca,'Xtick',0:1000:max(D(:,20))*1.1)
			end
		end
	end
end

function plotThrVsDistUL(D)
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19    20		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct  AvgDiff];	--%
Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (async. = 0 vs. sync = 1)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iC = 1 vs. iR = 2)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

Uuplow	=	unique(D(:,21));
Nuplow	=	length(Uuplow);

cmtx	=	jet(Nsubj);
h		=	nan(Npb*2,1);
Legend	=	cell(Npb*2,1);

col		=	linspace(0,1,Npb+1);
colr	=	[ones(Npb+1,1) col' col'];
colb	=   [col' col' ones(Npb+1,1)];
colk	=   [zeros(Npb+1,1) zeros(Npb+1,1) zeros(Npb+1,1)];
cnt2	=	1;
cnt3	=	0;

figure
for k = 1:Npara
	if Upara(k) == 0
		ParaStr	=	'Fix';
	elseif Upara(k) ==1
		ParaStr =	'Rnd';
	end
	
	for m = 1:Ntype
		if Utype(m) == 1
			TypeStr = 'iR';
			cnt		=	0;
		elseif Utype(m) == 2
			TypeStr = 'iC';
			cnt		=	2;
		end
		
		for l = 1:Ntime
			if Utime(l) == 0
				TimeStr	=	'Async';
			elseif Utime(l) == 1
				TimeStr =	'Sync';
			end
			
			for x = 1:Nuplow
				if Uuplow(x) == 0 % lower case
					UpLowStr	=	'"LowMask"';
					col			=	colr;
				elseif Uuplow(x) == 1 %upper case
					UpLowStr	=	'"UpMask"';
					col			=	colb;
				elseif Uuplow(x) == 99 %both upper and lower
					UpLowStr	=	'"Original"';
					col			=	colk;
				end
				
				subplot(2,2,l + cnt)
				for n = 1:Npb
					PB			=	(['PB ' num2str(Upb(n))]);
					COL			=	col(n,:);
					L(n,1)		=	{[PB]};
					
					for p = 1:Nblock
						sel = D(:,17) == Upara(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n)...
							& D(:,6) == Ublock(p) & D(:,21) == Uuplow(x);
						d	=	D(sel,[1 20]);
						
						h(n+cnt3,1) = plot(d(:,2),d(:,1),'.','Color',COL);
						hold on
					end
					% 					sel = D(:,17) == Upara(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n);
					% 					d	=	D(sel,[1 20]);
					% 					plot(d(:,2),d(:,1),'-','Color','k')
					
				end
				Legend(cnt2:cnt2+6,1)	=	L;
				cnt2	=	cnt2 + 7;
				cnt3	=	7;
			end
			title([ParaStr ' ' TimeStr ' ' TypeStr])
			xlabel('Average distance of Maskers per Signal Trial [Hz]')
			ylabel('Threshold [dB]')
			axis([0 max(D(:,20))*1.1 -10 max(D(:,1))*1.1])
			set(gca,'Xtick',0:1000:max(D(:,20))*1.1)
			pause(1)
			legend(h,Legend,'Location','NorthEast')
			legend('boxoff')
		end
	end
end

function plotCheckMaskFreq(D,Usubj,Ublock,Upara,Utype,Utime,Upb,Uuplow)
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19    20	 21		22 t/m 37	--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct  AvgDiff UpLow	MaskFreq			];	--%
Ufreq	=	unique(D(:,2));

if nargin < 2
	Usubj		=	unique(D(:,16));
end

if nargin < 3
	Ublock		=	unique(D(:,6));
end

if nargin < 4
	Upara		=	unique(D(:,17)); %unique filter (fix = 0, rnd = 1)
end

if nargin < 5
	Utype		=	unique(D(:,8)); %unique type (iC = 1 vs. iR = 2)
end

if nargin < 6
	Utime		=	unique(D(:,7)); %unique timing (async. = 0 vs. sync = 1)
end

if nargin < 7
	Upb			=	unique(D(:,19)); %unique protected band (octaves??)
end

if nargin < 8
	Uuplow		=	unique(D(:,21));
end

Nsubj		=	length(Usubj);
CurSub		=	cell(Nsubj,1);

Nblock	 =	length(Ublock);
CurBlock =	cell(Nblock,1);

Ntime	=	length(Utime);

Ntype	=	length(Utype);

Npara	=	length(Upara);

Npb     =   length(Upb);
PB		=	cell(Npb,1);

Nuplow	=	length(Uuplow);

FMin	=   200;
FMax	=   14370;
FStep	=   1/6;
Flist	=   FMin * 2.^(0:FStep:log2(FMax/FMin));
Nflist	=	length(Flist);

Vec		=	[Ufreq-15:1:Ufreq+15];
Nvec	=	length(Vec);

% XTick          = sort(unique(round([Xtick MaskFreqlabel PBfreq])));

for h = 1:Nuplow
	
	for i = 1:Nsubj
		CurSub = [num2str(Usubj(i))];
		
		for j = 1:Nblock
			CurBlock = [' Block ' num2str(Ublock(j))];
			
			for k = 1:Npara
				if Upara(k) == 0
					ParaStr = 'Fix';
				elseif Upara(k) == 1
					ParaStr = 'Rnd';
				end
				
				for l = 1:Ntype
					if Utype(l) == 1
						TypeStr = 'iR';
					elseif Utype(l) == 2
						TypeStr = 'iC';
					end
					
					for m = 1:Ntime
						if Utime(m) == 0
							TimeStr = ' async';
						elseif Utime(m) == 1
							TimeStr = ' sync';
						end
						
						for n = 1:Npb
							PB(n)	=	{[' PB ' num2str(Upb(n))]};
							
							sel = D(:,16) == Usubj(i) & D(:,6) == Ublock(j) & D(:,17) == Upara(k) & D(:,8) == Utype(l) & D(:,7) == Utime(m) &...
								D(:,19) == Upb(n) & D(:,21) == Uuplow(h);
							d	= D(sel,22:37);
							Thr		= D(sel,1);
							THR		= [' Threshold = ' num2str(Thr) ' dB'];
							Avgdist = round((D(sel,20)));
							AvgDist = [' AvgDist = ' num2str(Avgdist) ' Hz'];
							figure
							MaskFreq		=   [d(1,1:4)' d(1,5:8)' d(1,9:12)' d(1,13:16)' ];		%Masker Frequencies of iR condition
							[NN,bin]		=	hist(MaskFreq,Flist);	%get masker frequencies for histogram (y = times masker frequency occurred)
							hold on
							h1				=	bar(bin,NN,'stacked');					%plot masker frequencies
							
							for x = 1:Nflist
								if Flist(x) == Ufreq
									for z = 1:Nvec
										verline(Vec(z),'g.-');   %plot signal frequency GREEN
									end
								else
									verline(Flist(x));           %plot all possible maskers BLACK
								end
							end
							
							PBfreq = [oct2bw(Ufreq,-1*Upb(n)) oct2bw(Ufreq,Upb(n))]; %get frequencies of Protected Band
							PBFreq = [PBfreq PBfreq PBfreq PBfreq];
							[N,BIN] = hist(PBFreq,Flist);
							h2	=	bar(BIN,N);			%plot the protected band
							set(h2,'FaceColor','r');				%Prtotected band is RED
							pa_horline(0.5,'k.-', Avgdist, Ufreq);	%plot horizontal line from SigFreq +/- AvgDist
							Xtick		   =	Flist;
							Xticklabel	   =	[-1*(18:-1:1) 0 1:1:19];
							axis([Flist(1) Flist(end) 0  max(sum(NN,2))]);
							set(gca,'XScale','Log','XTick',Xtick,'XTickLabel',Xticklabel,'Fontsize',8)
							title([TypeStr TimeStr PB{n} AvgDist CurBlock THR],'fontweight','b','fontsize',16);
							xlabel('Signal + 200*n*(1/6)Octaves','fontsize',16)
							ylabel('Times frequency (masker/signal) occurred during one trial','fontsize',16)
						end
					end
				end
			end
		end
	end
end

function plotThrVsCOG(D)
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19    20	 21			22/37	--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct  AvgDiff UpperLower	MaskFreq	 ];	--%
Ufreq	=	unique(D(:,2));     %unique signal frequency

Ublock	=	unique(D(:,6));     %unique block
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));     %unique timing (async. = 0 vs. sync = 1)
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));     %unique type (iC = 1 vs. iR = 2)
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));    %unique filter (fix = 0, rnd = 1)
Npara	=	length(Upara);

Upb		=	unique(D(:,19)); %unique protected band (octaves??)
Npb     =   length(Upb);

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

% % keyboard
Q		=	unique(D(:,22:37))

% QQ		=	[Q;zeros Flist]

cmtx	=	jet(Nsubj);

FMin	=   200;
FMax	=   14370;
FStep	=   1/6;
Flist	=   FMin * 2.^(0:FStep:log2(FMax/FMin));
Nflist	=	length(Flist);

for k = 1:Npara
	if Upara(k) == 0
		ParaStr	=	'Fix';
	elseif Upara(k) ==1
		ParaStr =	'Rnd';
	end
	
	for l = 1:Ntime
		if Utime(l) == 0
			TimeStr	=	'Async';
		elseif Utime(l) == 1
			TimeStr =	'Sync';
		end
		
		for m = 1:Ntype
			if Utype(m) == 1
				TypeStr = 'iC';
			elseif Utype(m) == 2
				TypeStr = 'iR';
			end
			
			figure
			for n = 1:Npb
				PB	=	(['PB ' num2str(Upb(n))]);
				
				for o = 1:Nsubj
					CurSub = Usubj(o);
					cnt	= 1;
					
					for p = 1:Nblock
						sel = D(:,17) == Upara(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n)...
							& D(:,16) == Usubj(o) & D(:,6) == Ublock(p);
						d	=	D(sel,[1 20]);
						col	   = cmtx(o,:).*cnt;
						cnt	   = cnt - 0.15;
						
						subplot(3,3,n)
						plot(d(:,2),d(:,1),'.','Color',col)
						hold on
					end
					
					sel = D(:,17) == Upara(k) & D(:,7) == Utime(l) & D(:,8) == Utype(m) & D(:,19) == Upb(n)...
						& D(:,16) == Usubj(o);
					d	=	D(sel,[1 20]);
					plot(d(:,2),d(:,1),'-','Color',cmtx(o,:))
				end
				title([ParaStr ' ' TimeStr ' ' TypeStr ' ' PB])
				xlabel('Average distance of Maskers per Signal Trial [Hz]')
				ylabel('Threshold [dB]')
				axis([0 max(D(:,20))*1.1 -10 max(D(:,1))*1.1])
				set(gca,'Xtick',0:1000:max(D(:,20))*1.1)
			end
		end
	end
end


%% Helpers
function [D,T] = loaddat(pname,CheckMaskerFreq,ThrVsCOG,Check)

if( nargin < 4 )
	Check	=	0;
end

T			=	[];
Store		=	zeros(1,6);
len			=	length(pname);
cnt			=	1;
for k=1:len
	tic
	Pname	=	cell2mat(pname(k,1));
	Pname
	name	=	dir([ Pname '*.mat' ]);
	
	idx		=	strfind(Pname,'\');
	
	if strcmpi(Pname(idx(end-4):idx(end-3)),'\UpLowMask\')
		UpperLower = 1;
	else
		UpLow = 99;
		UpperLower = 0;
	end
	
	Subject	=	getsubj(Pname);
	Ndat	=	length(name);
	for l=1:Ndat
		N		=	name(l,1).name;
		load([Pname N])
		
		idx1	=	strfind(N,'_')+1;
		idx2	=	strfind(N,'.')-1;
		NBlock	=	str2double( N(idx1(end):idx2(end)) );
		
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
		
		Timing	=	N(idx1(end)-4);
		if( strcmp(Timing,'s') )
			Timing		=	0;
		elseif( strcmp(Timing,'S') )
			Timing		=	1;
		end
		
		% Warning: only for fixed conditions!!!
		MaskFreqHz	=	[TrlVal(1).MaskFreq1(1,:) TrlVal(1).MaskFreq1(2,:) TrlVal(1).MaskFreq1(3,:) TrlVal(1).MaskFreq1(4,:)];
		MaskFreq	=	TrlVal(1).MaskFreq1;
		% 		FMin	=   200;
		% 		FMax	=   14370;
		% 		FStep	=   1/6;
		% 		Flist	=   FMin * 2.^(0:FStep:log2(FMax/FMin));
		% 		Nflist	=	length(Flist);
		%
		
		LowerM		=	sum( mean(MaskFreq(:,1:Cn.NMaskLow),2) ) / 4;
		diffLowM	=	Sfreq(1) - LowerM;
		UpperM		=	sum( mean(MaskFreq(:,Cn.NMaskLow+1:end),2) ) / 4;
		diffUpM		=	UpperM - Sfreq(1);
		if UpperLower == 1
			if MaskFreq(:,:) > 1600
				UpLow	=	1;		%for the upper masker type
				AvgDiff	=	diffUpM;
			elseif MaskFreq(:,:) < 1600
				UpLow	=	0;		%for the lower masker type
				AvgDiff =	diffLowM;
			end
		elseif UpLow == 99
			AvgDiff		=	(diffLowM + diffUpM)/2;
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
		
		if CheckMaskerFreq == 1 || ThrVsCOG == 1
			D(cnt,:)		=	[Thr Sfreq(1) Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Folder...
				Mfreq Cn.ProtectBand AvgDiff UpLow MaskFreqHz];	%#ok<AGROW>
		elseif CheckMaskerFreq == 0 && ThrVsCOG == 0
			D(cnt,:)		=	[Thr Sfreq(1) Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Folder...
				Mfreq Cn.ProtectBand AvgDiff UpLow];
		end
		cnt				=	cnt + 1;
	end
	toc
end

function Subject = getsubj(Pname)

if( isunix)
	idx	=	strfind(Pname,'/');
else
	idx	=	strfind(Pname,'\');
end

Name	=	Pname(idx(end-1)+4:end-1);
Subject	=	str2double( Name );

if( isnan(Subject) )
	if( strcmpi(Name,'pb') )
		Subject	=	0;
	elseif( strcmpi(Name,'md') )
		Subject	=	1;
	else
		Subject	=	99;
	end
end

function Folder = getfolder(Pname)

if( isunix)
	idx	=	strfind(Pname,'/');
else
	idx	=	strfind(Pname,'\');
end

Folder	=	Pname(idx(end-2)+1:idx(end-1)-1); %all data

if( strcmpi(Folder,'Fix') )
	Folder	=	0;
elseif( strcmpi(Folder,'Rnd') )
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

function D = corrctrlindivsub(D,RemoveCtrl)

if( nargin < 2 )
	RemoveCtrl	=	0;
end

Usubj	=	unique(D(:,16));
Nsubj	=	length(Usubj);

for k=1:Nsubj
	cel	=	D(:,8) == 2 & D(:,5) == -80 & D(:,16) == Usubj(k);
	CA	=	getctrl(D(cel,:),-80);
	
	sel			=	D(:,16) == Usubj(k);
	D(sel,1)	=	D(sel,1) - CA(1,1);
end

if( RemoveCtrl )
	sel			=	D(:,5) == -80;
	D(sel,:)	=	[];
end

function Usubje = selectsubj(D,Freq,Mloc,Timing,Type,Mfilt)

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

Usubje	=	unique(Sub);

function [P,Crit] = getpercentile( D,Per )

sd		=	sort( D );
P(1,1)	=	round( (Per(1)/100) * length(D) + .5 );
P(2,1)	=	round( (Per(2)/100) * length(D) + .5 );
P(1,1)	=	sd(P(1),1);
P(2,1)	=	sd(P(2),1);

IQR		=	P(2) - P(1);
Crit	=	IQR * 1.5;	%-- Tuckey criterion for outliers --%

function v = verline(x, style)

if nargin < 2, style = 'k--'; end
if nargin < 1, x = 0; end

x       = x(:)'; % Create a column vector
n_as    = get(gca,'Nextplot');
n_fi    = get(gcf,'Nextplot');
oldhold = ishold;
hold on;
y_lim   = get(gca,'YLim');
for i = 1:length(x)
	v       = plot([x(i);x(i)], y_lim, style);
end
set(gca,'Nextplot',n_as);
set(gcf,'Nextplot',n_fi);
if ~oldhold
	hold off;
end

function h = pa_horline(y, style, Avgdist, Ufreq)
% PA_HORLINE(Y)
%
% Plot horizontal line through current axis at height Y.
%
% PA_HORLINE(...,'LineSpec') uses the color and linestyle specified by
% the string 'LineSpec'. See PLOT for possibilities.
%
% H = PA_HORLINE(...) returns a vector of lineseries handles in H.
%
% See also PA_VERLINE, PA_UNITYLINE

%% Initialization
if nargin < 2, style = 'k--'; end
if nargin < 1, y = 0; end

y       = y(:)'; % Create a column vector
n_as    = get(gca,'Nextplot');
n_fi    = get(gcf,'Nextplot');
oldhold = ishold;
hold on
x_lim   = [Ufreq - Avgdist Ufreq + Avgdist];
for i = 1:length(y)
	h       = plot(x_lim, [y(i);y(i)], style);
end
set(gca,'Nextplot',n_as);
set(gcf,'Nextplot',n_fi);
if ~oldhold
	hold off;
end

function F = oct2bw(F1,oct)
% F2 = PA_OCT2BW(F1,OCT)
% Determine frequency F that lies OCT octaves from frequency F1
if nargin < 1
	F1 = 1600; %Hz
end

if nargin < 2
	oct = (1/3);
end

F = F1 .* 2.^oct;







