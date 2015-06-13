function tmp

%% Initialization
close all
clear all
clc;

%% Initial Parameters
% Subjects & Type
% subj = [1 5 9];
% subj = [2 6 10];
% subj		= 1:10;
subj		= [1 3:5 7:10];
% subj		= [2 6];

% Histogram X-ticks
% xin		= [-100:10:-10 10:10:100];
xin			= -110:15:100;
% xin = 	[-100:20:-20 20:20:100];

%% Flags
Flag0		= 0; % Simulate 0-inhibition/abs(Response)>0: 0-no, 1-yes
IntD		= 0; % Plot data for this Intensity Difference
PltTypFlag	= 1; % 0 - Imagesc, 1 - Contourf
PltHstFlag = 1;
%% Data
[SupSac1,SupSac2,SumSnd]	= getdata(subj);

%% Select on Level Difference and GWNloc>Buzzloc
[T1,T2,dT,R]		= seldata(SupSac1,SupSac2,SumSnd,IntD);

%% Plot Histograms for each speaker-location
if PltHstFlag
	sel		= dT>0;
	T1		= T1(sel);
	T2		= T2(sel);
	dT		= dT(sel);
	R		= R(sel);
	plothist(T1,T2,dT,R,xin,Flag0,1)
end

%% Deselect & Select again on Level Difference
[T1,T2,dT,R] = seldata(SupSac1,SupSac2,SumSnd,IntD);

%% Buzzer is at constant location
plotdata(T1,T2,R,xin,2,PltTypFlag)
print -depsc BZZconstant

%%
% sel = ismember(T1,-100:100);
sel = ismember(T1,[-5 10 25]);
% sel = ismember(T1,[-50 70]);
plotdata2(T1(sel),T2(sel),R(sel),-155:15:205,4,PltTypFlag)

%% GWN is constant
T		= T1;
T1		= T2;
T2		= T;
plotdata(T1,T2,R,xin,3,PltTypFlag)
print -depsc GWNconstant

sel = ismember(T1,-100:100);
% % sel = ismember(T1,[-5 10 25]);
sel = ismember(T1,[-50 70]);
plotdata2(T1(sel),T2(sel),R(sel),-155:15:205,5,PltTypFlag)

function [SupSac1,SupSac2,SupSacSgl] = getdata(subj)
buzfac			=	3;
tSupSac1		=	[];
tSupSac2		=	[];
tSupSacSgl		=	[];
tSupSacSgl1		=	[];
tSupSacSgl2		=	[];

hw		= waitbar(0,'Please wait...');
for i=1:length(subj)
	%-- Load Data --%
	k = subj(i);
	switch k
		case 1
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-MW-2009-03-27/';
			fname		=	'PB-MW-2009-03-27-0001';
		case 2
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-MW-2009-03-31/';
			fname		=	'PB-MW-2009-03-31-0001';
		case 3
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-MW-2009-04-09/';
			fname		=	'PB-MW-2009-04-09-0001';
		case 4
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\MW-PB-2009-04-09/';
			fname		=	'MW-PB-2009-04-09-0001';
		case 5
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\MW-PB-2009-03-30/';
			fname		=	'MW-PB-2009-03-30-0001';
		case 6
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\MW-PB-2009-03-31/';
			fname		=	'MW-PB-2009-03-31-0001';
		case 7
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-DB-2009-03-30/';
			fname		=	'PB-DB-2009-03-30-0001';
		case 8
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-DB-2009-04-06/';
			fname		=	'PB-DB-2009-04-06-0001';
		case 9
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-DB-2009-03-24/';
			fname		=	'PB-DB-2009-03-24-0001';
		case 10
			pname		=	'C:\Documents and Settings\Marc van Wanrooij\Documents\MATLAB\Data\AudioSelection\NewSeries\PB-RM-2009-04-08/';
			fname		=	'PB-RM-2009-04-08-0001';
	end
	load([pname fname]);

	%-- Select first saccade --%
	% 	sel				=	Sac(:,2) == 1;
	sel				= lastsac(Sac);
	Sac				=	Sac(sel,:);

	%-- Obtain SupSac files for SND1 & SND2 --%
	SupSac1			=	superdouble(Sac,Stim,1);
	SupSac2			=	superdouble(Sac,Stim,4);

	%-- Get single speaker ... --%
	[C,I]			=	setdiff(SupSac1(:,1),SupSac2(:,1));
	if ~isempty(I)
		SupSacSgl	=	SupSac1(I,:);
	end

	sel				=	SupSacSgl(:,30) == 901;
	SupSacSgl1		=	SupSacSgl(sel,:);
	sel				=	SupSacSgl(:,30) == 902;
	SupSacSgl2		=	SupSacSgl(sel,:);
	sel				=	SupSacSgl(:,30) ~= 901 & SupSacSgl(:,30) ~= 902;
	SupSacSgl		=	SupSacSgl(sel,:);

	%-- ... and double speaker trials --%
	sel				=	ismember(SupSac1(:,1),SupSac2(:,1));
	SupSac1			=	SupSac1(sel,:);
	SupSac1(:,29)	=	SupSac1(:,29) + buzfac;

	sel				=	SupSac1(:,24) == SupSac2(:,24);
	SupSac1(sel,:)	=	[];
	SupSac2(sel,:)	=	[];

	tSupSac1		=	[tSupSac1; SupSac1];
	tSupSac2		=	[tSupSac2; SupSac2];
	tSupSacSgl		=	[tSupSacSgl; SupSacSgl];
	tSupSacSgl1		=	[tSupSacSgl1; SupSacSgl1];
	tSupSacSgl2		=	[tSupSacSgl2; SupSacSgl2];
	waitbar(i/length(subj),hw)
end
close(hw);

SupSac1			=	tSupSac1;
SupSac2			=	tSupSac2;
SupSacSgl		=	tSupSacSgl;

function [T1,T2,dT,R]		= seldata(SupSac1,SupSac2,SumSnd,IntD)

T1		= SupSac1(:,24);
T2		= SupSac2(:,24);
dInt	= SupSac2(:,29)-SupSac1(:,29);
dT		= T2-T1;
R		= SupSac1(:,9);

sel		= dInt == IntD;
T1		= T1(sel);
T2		= T2(sel);
dT		= dT(sel);
R		= R(sel);

%% Add the Single-speaker
sel		= ismember(SumSnd(:,30),905);
Tsum	= SumSnd(sel,24);
Rsum	= SumSnd(sel,9);

T1		= [T1;Tsum];
T2		= [T2;Tsum];
R		= [R;Rsum];
dT		= [dT;zeros(size(R))];

function plothist(T1,T2,dT,R,xin,Flag0,FigH)
uniek	= unique([dT T1],'rows');
for i		= 1:length(uniek)
	selt	= T1==uniek(i,2) & dT==uniek(i,1);
	mR		= mean(R(selt));

	%% Histogram
	figure(FigH)
	subplot(6,6,i)
	[n,x]=hist(R(selt),xin);
	n = n./sum(n);
	h=plot(x,n,'k-');set(h,'LineWidth',2);
	hold on

	%% Average Response with bias
	Y = ((12*randn(1000,1))+(12*randn(1000,1)))/2+mR;
	if Flag0
		sel = Y>=0 & Y<15;
		Y(sel) = Y(sel)+15;

		sel = Y<=0 & Y>-15;
		Y(sel) = Y(sel)-15;
	end
	[n,x]	= hist(Y,xin);
	n		= n./sum(n);
	h		= plot(x,n,'r-');set(h,'LineWidth',2);

	%% Extras
	verline(uniek(i,2)+uniek(i,1));
	xlim([-100 100]);
	verline(unique(T1(selt)),'r:');
	verline(unique(T2(selt)),'b:');
	verline(mR,'g:');
	title({['\Delta \epsilon: ' num2str(uniek(i,1))]; ['Buzzer: ' num2str(uniek(i,2))]})
end

function plotdata(T1,T2,R,xin,FigH,PltTypFlag)

uniek		= unique(T1);
for i		= 1:length(uniek)
	sel		= T1==uniek(i);
	Tar2	= T2(sel);
	Res		= R(sel);
	uT2		= unique(Tar2);
	l		= length(uT2);
	for j	= 1:l
		sel		= Tar2 == uT2(j);
		Y		= Res(sel);
		n		= hist(Y,xin);
		n		= n./sum(n);
		N(j,:)	= n;
	end

	figure(FigH)
	subplot(3,3,i)
	switch PltTypFlag
		case 0
% 			imagesc(xin,uT2,N);
			pcolor(xin,uT2,N);
% 			surf(xin,uT2,N);

		case 1
			contourf(xin,uT2,N)
	end
	hold on
	% 	axis square
	% 	colorbar
	ylim([-80 80]);
	xlim([-80 80]);
	h		= verline(uniek(i),'w-');set(h,'LineWidth',2);
	avg		= (uT2+uniek(i))/2;
	h		= plot(avg,uT2,'w--');set(h,'LineWidth',2);
	verline(0,'r-');
	set(gca,'YDir','normal');
	h		= unityline('w-');set(h,'Color','w','LineWidth',2);
	switch FigH
		case 2
			xlabel('\epsilon_{R} (deg)');
			ylabel('\epsilon_{GWN} (deg)');
			title(['\epsilon_{Buzz}: ' num2str(uniek(i))]);
		case 3
			xlabel('\epsilon_{R} (deg)');
			ylabel('\epsilon_{Buzz} (deg)');
			title(['\epsilon_{GWN}: ' num2str(uniek(i))]);
		otherwise
			xlabel('\epsilon_{R} (deg)');
			ylabel('\epsilon_{1} (deg)');
			title(['\epsilon_{2}: ' num2str(uniek(i))]);			
	end
	ylim([-50 70]);
end

function plotdata2(T1,T2,R,xin,FigH,PltTypFlag)

T2	= T2-T1;
R	= R-T1;
T1	= T1-T1;
uniek		= unique(T1);
for i		= 1:length(uniek)
	sel		= T1==uniek(i);
	Tar2	= T2(sel);
	Res		= R(sel);
	uT2		= unique(Tar2);
	l		= length(uT2);
	for j	= 1:l
		sel		= Tar2 == uT2(j);
		Y		= Res(sel);
		n		= hist(Y,xin);
		n		= n./sum(n);
		N(j,:)	= n;
	end

	figure(FigH)
% 	subplot(3,3,i)
	switch PltTypFlag
		case 0
% 			imagesc(xin,uT2,N);
			pcolor(xin,uT2,N);
% 			surf(xin,uT2,N);

		case 1
			contourf(xin,uT2,N,20)
	end
	hold on
	% 	axis square
	% 	colorbar
	ylim([-100 100]);
	xlim([-100 100]);
	h		= verline(uniek(i),'w-');set(h,'LineWidth',2);
	avg		= (uT2+uniek(i))/2;
	h		= plot(avg,uT2,'w--');set(h,'LineWidth',2);
	verline(0,'r-');
	set(gca,'YDir','normal');
	h		= unityline('w-');set(h,'Color','w','LineWidth',2);
	switch FigH
		case 2
			xlabel('\epsilon_{R} (deg)');
			ylabel('\epsilon_{GWN} (deg)');
			title(['\epsilon_{Buzz}: ' num2str(uniek(i))]);
		case 3
			xlabel('\epsilon_{R} (deg)');
			ylabel('\epsilon_{Buzz} (deg)');
			title(['\epsilon_{GWN}: ' num2str(uniek(i))]);
		otherwise
			xlabel('\epsilon_{R} (deg)');
			ylabel('\epsilon_{1} (deg)');
			title(['\epsilon_{2}: ' num2str(uniek(i))]);			
	end
% 	ylim([-50 70]);
end