function IM_figure4
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

pa_datadir;
load Drempel

% [DrempelFix]	= plotdat(D);
M0 = plotdat(D,0);

M1 = plotdat(D,1);

figure(3)
k = 0;
tit = {'TaFr';'TsFr';'TaFc';'TsFc'};
col = ['r';'b'];
str = 'Threshold (dB) ';
colh = hot(9);
colb = colh(:,[3 2 1]);
% if mem==0
% 	col = col(:,[3 2 1]);
% end

for ii = [1 3]
	x1 = [M0(ii).T(:,2)];
	y1 = [M1(ii).T(:,2)];
	x2 = [M0(ii+1).T(:,2)];
	y2 = [M1(ii+1).T(:,2)];
	
	x = [x1 x2];
	y = [y1 y2];
	subplot(1,2,ceil(ii/2))
	plot(x',y','k-');
	
	x = x1;
	y = y1;
	u = [x2-x1];
		v = [y2-y1];
		for jj = 1:numel(x)
	quiver(x(jj),y(jj),u(jj),v(jj),0.8,'Color','k','LineWidth',1)
	hold on
		end

% 	for kk = 1:numel(y)
% 		if pa_iseven(ii)
% 		plot(x(kk),y(kk),'ko','MarkerFaceColor',colh(kk,:));
% 		else
% 		plot(x(kk),y(kk),'ko','MarkerFaceColor',colb(kk,:));
% 		end
% 		hold on
% 	end
end

for ii = 1:4
	x = [M0(ii).T(:,2)];
	y = [M1(ii).T(:,2)];
	subplot(1,2,ceil(ii/2))
% 	plot(x,y,'k');
	hold on
	for kk = 1:numel(y)
		if pa_iseven(ii)
		h(kk) = plot(x(kk),y(kk),'ks','MarkerFaceColor',colh(kk,:));
		else
		h2(kk) = plot(x(kk),y(kk),'ko','MarkerFaceColor',colb(kk,:));
		end
		hold on
	end
end

PB = {'0';'1/3';'2/3';'1';'4/3';'5/3';'2';'0';'1/3';'2/3';'1';'4/3';'5/3';'2'}
legend([h h2],PB);
tit = {'Frequency random';'Frequency constant'};

for ii = 1:2
	subplot(1,2,ii)
	axis square;
	axis([-10 70 -10 70]);
	pa_unityline('k:');
% 	pa_verline([0 55],'k:');
% 	pa_horline([0 55],'k:');
	title(tit{ii});
	xlabel('Frozen Threshold (dB)');
	ylabel('Fresh Threshold (dB)');
	
end
% 	for jj = 1:4
% 		k = k+1;
% 		subplot(4,4,k);
% 		y = [Drempel(jj).T(:,2)];
% 		plot(y,x,'k-');
% 		hold on
% 		for kk = 1:numel(y)
% 			plot(y(kk),x(kk),'ko','MarkerFaceColor',col(kk,:));
% 			hold on
% 		end
% 		xlabel([str tit{ii}]);
% 		ylabel([str tit{jj}]);
% 	end
% end
print('-depsc','-painter',mfilename);



function Drempel =  plotdat(D,mem)
% Ublock	= unique(D(:,6));     %unique block

Onset	= D(:,7);
uOnset	= unique(Onset);     %unique timing (async. = 0 vs. sync = 1)
nOnset	= length(uOnset);

Freq	= D(:,8);
uFreq	= unique(Freq); % unique type (iC = 2 vs. iR = 1)
nFreq	= length(uFreq)

Memory	= D(:,17);
% uMem	= unique(Memory);    %unique filter (fix = 0, rnd = 1)

PB		= D(:,19);
uPB		= unique(PB); %unique protected band (octaves??)
nPB     = length(uPB);


%% x = PB
figure(1)
k		= 0;
col		= summer(5);
Drempel = struct([]);
h		= NaN(4,1);
mrk		= flipud(['^';'s';'d';'v']);
stim	= NaN(4,2);
for kk = 1:nFreq
	for jj = (1:nOnset)-1
		k = k+1;
		seltype = Onset==jj & Freq==kk & Memory==mem; % TcFc, no memory
		T = NaN(nPB,3);
		for ii = 1:nPB
			selpb = PB==uPB(ii);
			sel = seltype & selpb;
% 			sum(sel)
			T(ii,:) = prctile(D(sel,1),[25 50 75]);
		end
		% 		a = T(:,2);
		% 		A(k,:) = a;
		subplot(2,2,1+mem)
		errorbar(uPB+k*0.075-2.5*0.075,T(:,2),T(:,2)-T(:,1),T(:,3)-T(:,2),['k' mrk(k) '-'],'LineWidth',2,'Color',col(k,:));
		hold on
		h(k) = plot(uPB+k*0.075-2.5*0.075,T(:,2),['k' mrk(k)],'LineWidth',2,'MarkerFaceColor',col(k,:));
		Drempel(k).T = T;
		
		stim(k,:) = [jj kk];
	end
	
end
legend(h,{'TrFr','TcFr','TrFc','TcFc'});
% legend(h,{'asyn iR','syn iR','asyn iC','syn iC'});
xlabel('Protected band (oct)');
ylabel('Threshold (dB)');
axis square
box off
ylim([-10 70]);
xlim([-0.2 2.2])
pa_horline([0 60]);


%%

subplot(2,2,3+mem);
hold on
% TrFr = Async iR = 1
% TcFr = Sync iR = 2
% TrFc = Async iC = 3
% TcFc = Sync iC = 4

% if mem==0
col = winter(nPB+1);
% else
% 	col = spring(nPB+1);
% end
x = 1:4;
h = NaN(nPB,1);
M = NaN(nPB,4);
for ii = 1:nPB
	TrFr = Drempel(1).T(ii,:);
	TcFr = Drempel(2).T(ii,:);
	TrFc = Drempel(3).T(ii,:);
	TcFc = Drempel(4).T(ii,:);
	Y = [TrFr(:,2) TrFc(:,2) TcFr(:,2) TcFc(:,2)];
	L = Y-[TrFr(:,1) TrFc(:,1) TcFr(:,1) TcFc(:,1)];
	U = [TrFr(:,3) TrFc(:,3) TcFr(:,3) TcFc(:,3)]-Y;
	% 	if ii==2
	errorbar(x+ii*0.1-2.5*0.1,Y,L,U,'k-','Color',col(ii,:),'LineWidth',2)
	hold on
	h(ii) = plot(x+ii*0.1-2.5*0.1,Y,'ko','MarkerFaceColor',col(ii,:),'LineWidth',2);
	% 	end
	% 	plot
	M(ii,:) = Y;
end
% legend(h,{PB});
xlim([0 5]);
xlabel('Masker');
ylabel('Threshold (dB)');
axis square
box off
ylim([-10 70]);
pa_horline([0 60]);
set(gca,'XTick',1:4,'XTickLabel',{'TrFr','TrFc','TcFr','TcFc'});


figure(2)
TrFr = [Drempel(1).T];
TcFr = [Drempel(2).T];
TrFc = [Drempel(3).T];
TcFc = [Drempel(4).T];

k = 0;
tit = {'TaFr';'TsFr';'TaFc';'TcFc'};
col = ['b';'r'];
str = ['Threshold (dB) '];
col = hot(9);
if mem==0
	col = col(:,[3 2 1]);
end
for ii = 1:4
	x = [Drempel(ii).T(:,2)];
	for jj = 1:4
		k = k+1;
		subplot(4,4,k);
		y = [Drempel(jj).T(:,2)];
		plot(y,x,'k-');
		hold on
		for kk = 1:numel(y)
			plot(y(kk),x(kk),'ko','MarkerFaceColor',col(kk,:));
			hold on
		end
		xlabel([str tit{ii}]);
		ylabel([str tit{jj}]);
	end
end
for ii = 1:16
	subplot(4,4,ii)
	axis square;
	axis([-10 70 -10 70]);
	pa_unityline('k:');
	set(gca,'XTick',0:20:60,'YTick',0:20:60);
	% 		box off
end

