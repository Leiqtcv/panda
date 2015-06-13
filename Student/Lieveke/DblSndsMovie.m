function tmp

%% Initialization
close all
clear all
clc;

%% Initial Parameters
% Subjects & Type
subj		= [1 3:5 7:10];

%% Flags
IntDiff			= -10:5:10;
PltTypFlag		= 1; % 0 - Imagesc, 1 - Contourf
GWNFac			= 5;
IntFlag = 1;
%% Data
[SupSac1,SupSac2,SumSnd]	= getdata(subj);

if IntFlag
	IntMod			= 4/90;
	IntBias = 0;
	SupSac1(:,29)	= round((SupSac1(:,29)+IntMod*SupSac1(:,24)+IntBias)/5)*5;
	SupSac2(:,29)	= round((SupSac2(:,29)+IntMod*SupSac2(:,24)+GWNFac+IntBias)/5)*5;
	SumSnd(:,29)	= round((SumSnd(:,29)+IntMod*SumSnd(:,24))/5)*5;
end

xin = -155:15:205;
for k = 1:length(IntDiff)
	IntD = IntDiff(k);

	%% Deselect & Select again on Level Difference
	[T1,T2,dT,R] = seldata(SupSac1,SupSac2,SumSnd,IntD);

	%%
	T2		= T2-T1;
	R		= R-T1;
	T1		= T1-T1;
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
			N(:,j,k)	= n;
		end


	end
end
whos uT
uT = unique(T2)-40;
xin = xin+40;
[m,n,o]=size(N);
nz = 5;
ZI = linspace(1,o,nz);
z = linspace(-10,10,nz);
LZ = length(ZI);
M = interp3(N,1:m,(1:n)',ZI,'cubic');
	marc
for i = 1:LZ
	hold off
	N = squeeze(M(:,:,i))';
	N(isnan(N)) = 0;
	contourf(uT,xin,N,20);
	hold on
	axis square
	ylim([-80 80]);
	xlim([-80 80]);
	set(gca,'YDir','normal');
shading flat
			h=verline(0,'w-');set(h,'LineWidth',2);
		h = unityline('w-');set(h,'LineWidth',2);
	% 		title(['\Delta Int_{adj}: ' num2str(z(i))]);
			title(round(z(i)));
			xlabel('\epsilon_{R} - \epsilon_{BZZ}');
			ylabel('\epsilon_{GWN} - \epsilon_{BZZ}');
	caxis([0 .5]);
% 	axis off
% 	str = ['print(''-dill'',''figure' num2str(i) ''');'];
% 	eval(str)
	drawnow
% 	pause(.01);
end
% keyboard
% for i = 1:o-1
% M = squeeze(N(:,:,i));
% M1 = M(:);
%
% M = squeeze(N(:,:,i+1));
% M2 = M(:);
%
%
% end

% figure
% movie(F,20);

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

function [T1,T2,dT,R] = seldata(SupSac1,SupSac2,SumSnd,IntD)

T1		= SupSac1(:,24);
T2		= SupSac2(:,24);
dInt	= SupSac2(:,29)-SupSac1(:,29);
% unique(dInt)
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

