function AnaCentralFilter
tic
clear all
% close all
clc

%-- Flags --%
ThrVsPB		=	0;
ThrVsSDM	=	0;
CompFixRnd	=	0;
ERBScale	=	1;

%-- Variables --%

% pname		=	[	...
% 					{'/Users/michieldirkx/Documents/UCI/CentralFilter/Data/Fix/UCIpb/'}; ...
% 					{'/Users/michieldirkx/Documents/UCI/CentralFilter/Data/Rnd/UCIpb/'}; ...
% 				];

pname		=	[	...
 					{'/Users/michieldirkx/Documents/UCI/CentralFilter/Data/Fix/UCImd/'}; ...
 					{'/Users/michieldirkx/Documents/UCI/CentralFilter/Data/Rnd/UCImd/'}; ...
 				];

%-- Main --%
D			=	loaddat(pname);
D			=	corrctrlindivsub(D,1);

%-- Plotting --%
if( ThrVsPB )
	sel		=	D(:,17) == 0;
	plotthrvspb(D(sel,:))
	plotthrvspb(D(~sel,:))
end

if( ThrVsSDM )
	sel		=	D(:,17) == 0;
	plotthrvssdm(D(sel,:))
	plotthrvssdm(D(~sel,:))
end

if( CompFixRnd )
	plotcompfixrnd(D)
end

if( ERBScale )
	ploterbscale(D)
end

%-- Attentional Filter Comparison Botte 1995 --%
% Fc		=	1000;
% Fl		=	900;
% Fu		=	1100;
% 
% ERB		=	(4.37*1.6+1)*24.7;
% Fc		=	1000;
% Fl		=	Fc-ERB/2;
% Fu		=	Fc+ERB/2;
% Noctl	=	log2(Fc/Fl);
% Noctu	=	log2(Fu/Fc);
% O		=	[Noctl Noctu]
% [1000 / 2^0.67, 1000 * 2^0.67]
% z	=	[0:1/3:2; 1600 ./ 2.^(0:1/3:2); 1600 .* 2.^(0:1/3:2)]

%-- Wrapping up --%
tend	=	( round(toc*100)/100 );
str		=	sprintf('\n%s\n',['Mission accomplished after ' num2str(tend) ' sec!']);
disp(str)

%-- Locals --%
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
% 		F		=	d(:,3);
		
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
			
			sel	=	D(:,8) == Utype(k) & D(:,7) == Utime(l) & D(:,17) == Upara(m);
			d		=	D(sel,[18 1 19]);
			[~,idx]	=	sort(d(:,3));
			d		=	d(idx,:);
			
			Maxd	=	max(d(:,2));
			att		=	d(:,2)-Maxd;
%	 		F		=	d(:,3);

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

%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
Ufreq	=	unique(D(:,2));

Ublock	=	unique(D(:,6));
Nblock	=	length(Ublock);

Utime	=	unique(D(:,7));
Ntime	=	length(Utime);

Utype	=	unique(D(:,8));
Ntype	=	length(Utype);

Upara	=	unique(D(:,17));
Npara	=	length(Upara);

Upb		=	dround(unique(D(:,19)));

MF		=	[Ufreq ./ 2.^Upb Ufreq .* 2.^Upb];
% sERB	=	(4.37 * Ufreq*10^-3 + 1) * 24.7;
% mERB	=	(4.37 * MF(:,1)*10^-3 + 1) * 24.7;
sERB	=	21.4 * log10(4.37 * Ufreq*10^-3 + 1 );
mERB	=	21.4 * log10(4.37 * MF(:,1)*10^-3 + 1 );
F		=	sERB - mERB;

Df		=	Ufreq-MF(:,1);

xx		=	[-100 max(Df)*1.1];
yy		=	[min(D(:,1))*1.1 max(D(:,1))*1.1];

% Fl		=	Ufreq / 2^0.5;
% Fu		=	Ufreq * 2^0.5;
% CB		=	Fu - Fl;
CB		=	(4.37 * Ufreq*10^-3 + 1) * 24.7;
x		=	100:20000;
y		=	exp( -( (x-Ufreq) ./ CB ).^2 );
yfit	=	fitroex(x,y,Ufreq);

ERB		=	21.4 * log10(4.37 * x*10^-3 + 1 );
xfit1	=	Ufreq - x;
xfit2	=	sERB - ERB;

[c,r]	=	FactorsForSubPlot(Ntype*2);

%% Fixed condition
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
		
		
% 			if Upara == 0
% 				mk			=	'-';
% 				L(cnt,1)	=	{['Fix ' Tstr]};
% 			elseif Upara == 1
% 				mk			=	'--';
% 				L(cnt,1)	=	{['Rnd ' Tstr]};
% 			end
			
			md = nan(length(Df),Nblock);
			matt = nan(length(F),Nblock);
			
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
			
			for n	= 1:Nblock-1
			
			sel		=	D(:,8) == Utype(k) & D(:,7) == Utime(l) & D(:,17) == 0 & D(:,6) == Ublock(n);
			d		=	D(sel,[18 1 19]);
			[~,idx]	=	sort(d(:,3));
			d		=	d(idx,:);
			md(:,n)	=	d(:,2);
			
			Maxd	=	max(d(:,2));
			att		=	d(:,2)-Maxd;
%	 		F		=	d(:,3);
			matt(:,n)	=	att;

			subplot(r,c,k)
			h1(cnt)	= plot(Df,d(:,2),'o','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			hold on
			
			subplot(r,c,k+2)
			h2(cnt)	= plot(F,att,'o','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			hold on
			
			cnt		=	cnt + 1;
			end
			
			subplot(r,c,k)
			plot(Df,mean(md,2),'-','color',col)
			
			subplot(r,c,k+2)
			plot(F,mean(matt,2),'-','color',col)
	end
	
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	hold on
	xlim(xx)
	ylim(yy)
	set(gca,'XTick',0:200:2000,'XTickLabel',0:200:2000)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('\Deltaf [Hz]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
% 	try
% 	legend(h1,L)
% 	catch
% 		keyboard
% 	end
% 	legend('boxoff')
	
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
% 	legend(h2,L,'Location','SouthWest')
% 	legend('boxoff')
end


%% random condition
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
		
		
% 			if Upara == 0
% 				mk			=	'-';
% 				L(cnt,1)	=	{['Fix ' Tstr]};
% 			elseif Upara == 1
% 				mk			=	'--';
% 				L(cnt,1)	=	{['Rnd ' Tstr]};
% 			end
			
			md = nan(length(Df),Nblock);
			matt = nan(length(F),Nblock);
			
%--		  1	   2     3   4     5    6      7     8     9      10        11 12   13 14  15    16		 17	  18	19		--%
%-- D = [Thr Sfreq Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Filter SDM PBoct];	--%
			
			for n	= 1:Nblock
			
			sel		=	D(:,8) == Utype(k) & D(:,7) == Utime(l) & D(:,17) == 1 & D(:,6) == Ublock(n);
			d		=	D(sel,[18 1 19]);
			[~,idx]	=	sort(d(:,3));
			d		=	d(idx,:);
% 			keyboard
			try
			md(:,n)	=	d(:,2);
			catch
				md(1:3,n)	=	d(:,2);
				md(4:7,n)	=	0;
			end
			
			Maxd	=	max(d(:,2));
			att		=	d(:,2)-Maxd;
%	 		F		=	d(:,3);
			try
			matt(:,n)	=	d(:,2);
			catch
				matt(1:3,n)	=	d(:,2);
				matt(4:7,n)	=	0;
			end

			subplot(r,c,k)
			try
			h1(cnt)	= plot(Df,d(:,2),'o','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			catch
				h1(cnt)	= plot(Df,md(:,3),'o','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			end
			plot(Df,md,'--','color',col)
			hold on
			
			subplot(r,c,k+2)
			try
			h2(cnt)	= plot(F,att,'o','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			catch
				attt	=	zeros(7,1)
				attt(1:3,1)	=	att
				h2(cnt)	= plot(F,attt,'o','Color',col,'MarkerFaceColor',col,'MarkerEdgeColor',col);
			end
			plot(F,matt,'--','color',col)
			hold on
			
			cnt		=	cnt + 1;
			end
			
			subplot(r,c,k)
			
			
			subplot(r,c,k+2)
			
	end
	
	subplot(r,c,k)
	plot(xx,[0 0],'k:')
	hold on
	xlim(xx)
	ylim(yy)
	set(gca,'XTick',0:200:2000,'XTickLabel',0:200:2000)
	set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
	xlabel('\Deltaf [Hz]')
	ylabel('masked threshold [dB]')
	title([Str ' f_{sig}= ' num2str(Ufreq) ' Hz'])
	axis('square')
% 	try
% 	legend(h1,L)
% 	catch
% 		keyboard
% 	end
% 	legend('boxoff')
	
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
% 	legend(h2,L,'Location','SouthWest')
% 	legend('boxoff')
end

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
		
		D(cnt,:)		=	[Thr Sfreq(1) Sloc Mloc Mspl NBlock Timing Type Nmask BaseRate ProtectBand CB1_3 Sspl Subject Folder Mfreq Cn.ProtectBand];	%#ok<AGROW>
		
		cnt				=	cnt + 1;
	end
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

Folder	=	Pname(idx(end-2)+1:idx(end-1)-1);

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
