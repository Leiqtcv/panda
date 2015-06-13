function AnalRetentiveFit
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
 %%
tic
clear all
close all
clc


% Data
pa_datadir;
load Drempel

[DrempelFix]	= plotdat(D,0);
[DrempelRnd]	= plotdat(D,1);

% DrempelRnd		= plotdat2(D);
figure(1)
subplot(131)
axis square
xlabel('Median threshold (dB)');
ylabel('25th percentile (dB)');
box off
axis([0 70 -30 0]);


subplot(132)
axis square
xlabel('Median threshold (dB)');
ylabel('75th percentile (dB)');
box off
axis([0 70 0 30]);


subplot(133)
figure(666)
yt = pa_oct2bw(1,0:5);
set(gca,'YTick',yt,'YTickLabel',yt);
axis square
xlabel('Median threshold (dB)');
ylabel('IQR threshold (dB)');
box off
axis([0 70 4 60]);

pa_datadir;
print('-depsc',mfilename);
return
%%
tic
sd		= 35;
ceil	= 30;
floor	= 20;
beta0	= [sd ceil floor];
x = 0:100;

% y = limitfun(x,beta0);
% semilogy(x,y,'k-','LineWidth',2);
col = hsv(4);
for ii = 1:4
	t		= DrempelRnd(ii).T;
	X1		= t(:,2);
	Y1		= t(:,3)-t(:,1);
	
	t		= DrempelFix(ii).T;
	X2		= t(:,2);
	Y2		= t(:,3)-t(:,1);
	
	X = [X1; X2];
	Y = [Y1; Y2];
	beta	= fitlimit(X,Y,beta0);
	y = limitfun(x,beta);
	semilogy(x,y,'k-','Color',col(ii,:),'LineWidth',2);
	hold on
	str = ['Mean = ' num2str(round(beta(1))) ', Ceiling = ' num2str(round(beta(2))) ', Floor = ' num2str(round(beta(3)))];
	text(40,40+ii*3,str,'Color',col(ii,:))
% 	h = pa_verline(beta(2)); set(h,'Color',col(ii,:));
% 	h = pa_verline(beta(3)); set(h,'Color',col(ii,:));
	
end
toc

function Drempel =  plotdat(D,mem)

Onset	= D(:,7);
uOnset	= unique(Onset);     %unique timing (async. = 0 vs. sync = 1)
nOnset	= length(uOnset);
Freq	= D(:,8);
uFreq	= unique(Freq); % unique type (iC = 2 vs. iR = 1)
nFreq	= length(uFreq);
Memory	= D(:,17);
PB		= D(:,19);
uPB		= unique(PB); %unique protected band (octaves??)
nPB     = length(uPB);


figure(1)
k		= 0;
col		= hsv(4);
Drempel = struct([]);
stim	= NaN(4,2);
for kk = 1:nFreq
	for jj = (1:nOnset)-1
		k = k+1;
		seltype = Onset==jj & Freq==kk & Memory==mem; % TcFc, no memory
		T = NaN(nPB,3);
		for ii = 1:nPB
			selpb = PB==uPB(ii);
			sel = seltype & selpb;
			T(ii,:) = prctile(D(sel,1),[25 50 75]);
		end
		Drempel(k).T = T;
		stim(k,:) = [jj kk];
	end
	
end

if mem==0
	mrk = 'o';
else
	mrk = 's';
end
T = [];
for ii = 1:4
	t = Drempel(ii).T;
	md = t(:,2);
	iqr = t(:,3)-t(:,1);
	figure(1)
	subplot(131)
	plot(md,t(:,1)-md,['k' mrk],'MarkerFaceColor',col(ii,:));
	hold on

	subplot(132)
	plot(md,t(:,3)-md,['k' mrk],'MarkerFaceColor',col(ii,:));
	hold on

% 	subplot(133)
	figure(666)
	semilogy(md,iqr,['k' mrk],'MarkerFaceColor',col(ii,:));
	hold on
	
	T = [T;t]; %#ok<*AGROW>
end





function beta = fitlimit(X,Y,beta0)
% PA_FITSIN   Fit a sine through data.
%
%   PAR = FITSIN(X,Y) returns parameters of the sine a*sin(b*X+c)+d,
%   in the following order: [a b c d].
%
%   See also FMINSEARCH, NORM

% 2011, Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

beta = fminsearch(@limiterr,beta0,optimset('MaxFunEvals',100),X,Y);


function err =  limiterr(beta,X,Y)
%SINERR   Determines error between experimental data and calculated sine.
%   [ERR]=SINERR(PAR,X,Y) returns the error between the calculated parameters
%   PAR, given by FITSIN and the parameters given by experimental data X and Y.
err = norm(Y-limitfun(X,beta));
% chi = norm((Y-sinfun(X,beta))./sd);

function Y = limitfun(X,beta)
%%

sd		= beta(1);
md		= beta(2);
range	= beta(3);

ceil	= md+range;
floor	= md-range;

n		= 10000;
nX		= numel(X);
md		= NaN(nX,1);
iqr		= NaN(nX,1);
for ii = 1:nX
	% 	x = sd*2*(rand(n,1)-0.5)+mu(ii);
	x		= sd*randn(n,1)+X(ii);
	
	y		= x;
	sel		= x>ceil;
	y(sel)	= repmat(ceil,size(y(sel)));
	sel		= x<floor;
	y(sel)	= repmat(floor,size(y(sel)));
	
	p		= prctile(y,[25 50 75]);
	md(ii)	= p(2);
	iqr(ii) = p(3)-p(1);
end

Y = iqr;


