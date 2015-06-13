function IM_IQRvsMedian
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

%%
maskers = {'TaFr';'TsFr';'TaFc';'TsFc'};
reindx	= [1 3 2 4];
maskers = maskers(reindx); %  'TaFr'     'TaFc'     'TsFr'    'TsFc'
% Is this correct?
load RedBlue
indx	= round(linspace(1,64,2));
col		= col(indx,:); %#ok<*NODEF>


figure(1)
subplot(121)
axis square
xlabel('Median threshold (dB)','FontName','Arial','FontWeight','bold','FontSize',12);
ylabel('25th percentile (dB)','FontName','Arial','FontWeight','bold','FontSize',12);
box off
% axis([0 70 -30 0]);
pa_verline(40,'k:');

subplot(122)
axis square
xlabel('Median threshold (dB)','FontName','Arial','FontWeight','bold','FontSize',12);
ylabel('75th percentile (dB)','FontName','Arial','FontWeight','bold','FontSize',12);
box off
% axis([0 70 0 30]);
pa_verline(30,'k:');

%% Models
% Needs a fit (nlinfit)
% Now just visual fit
theta	= 0.25:0.25:20;
ntheta	= numel(theta);
k		= [2 8];
nk		= numel(k);
n		= 10000;
for jj = 1:nk
	for ii = 1:ntheta
		x = gamrnd(k(jj),theta(ii),[n 1]);
		p = prctile(x,[25 50]);
		P(ii,jj) = p(1);
		M(ii,jj) = p(2);
	end
	figure(1)
	subplot(121)
	x		= M(:,jj);
	y		= P(:,jj);
	sel		= x<=40;
	plot(x(sel),y(sel),'Color',col(jj,:),'LineWidth',2);
end


theta	= 0.25:0.25:20;
ntheta	= numel(theta);
k		= [6 6];
nk		= numel(k);
n		= 10000;
for jj = 1:nk
	for ii = 1:ntheta
		x = 75-gamrnd(k(jj),theta(ii),[n 1]);
		p = prctile(x,[75 50]);
		P(ii,jj) = p(1);
		M(ii,jj) = p(2);
	end
	figure(1)
	subplot(122)
	x		= M(:,jj);
	y		= P(:,jj);
	sel		= x>=30;
	plot(x(sel),y(sel),'Color',col(jj,:),'LineWidth',2);
end

for ii = 1:2
	subplot(1,2,ii)
			set(gca,'FontName','Arial','FontWeight','bold','FontSize',12)
			ylim([-20 80]);
			pa_text(0.1,0.9,char(64+ii));
end
pa_datadir;
print('-depsc','-painter',mfilename);

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
maskers = {'TaFr';'TsFr';'TaFc';'TsFc'};
% y = -[TrFr TrFc TcFr TcFc;TrFr2 TrFc2 TcFr2 TcFc2;];whos y


load RedBlue
indx	= round(linspace(1,64,4));
col		= col(indx,:); %#ok<*NODEF>

figure(1)
k		= 0;
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

%% Rearrange
reindx = [1 3 2 4];
maskers = maskers(reindx);
disp(maskers)
Drempel = Drempel(reindx);

if mem==0
	mrk = 'o';
else
	mrk = 's';
end
T = [];
for ii = 1:4
	t		= Drempel(ii).T;
	md		= t(:,2);
	x	= md;
	y	= t(:,1);
	
	figure(1)
	subplot(121)
	h(ii) = plot(x,y,['k' mrk],'MarkerFaceColor',col(ii,:));
	hold on
	
	subplot(122)
	plot(x,t(:,3),['k' mrk],'MarkerFaceColor',col(ii,:));
	hold on
	
	
	T = [T;t]; %#ok<*AGROW>
end

legend(h,maskers,'Location','SE');





