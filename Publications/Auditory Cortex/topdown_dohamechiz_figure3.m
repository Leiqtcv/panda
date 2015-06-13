function topdown_dohamechiz_figure3

%% Cleansing
clc;
close all hidden;
clear all hidden;

%% Data directories and filenames
cd('E:\DATA\Cortex\top-down paper data'); % Change this to suit your needs
thorfiles	= dir('thor*'); % for monkey Thor
joefiles	= dir('joe*'); % and for monkey Joe
files		= [thorfiles' joefiles'];

%% Flags
wvflag		= false;
sdfflag		= false;
rmflag		= true;
dspflag = false;
meth = 2; % Method 2 = basic, real spike count / firing rate, just binning, no spike density, no Gaussian smoothing, no Passive removal, no baseline removal
% Method 1 = spike density smoothing, passive removal
% Because the basic method 2 also works, we do method 2!

%% Go through every cell
sigma = 25;
S500 = [];
S1000 = [];
FR = struct([]);
for ii	= 1:length(files)
	fname		  = files(ii).name;
	load(fname);
	% 	whos spikeA spikeP spikeAMA spikeAMP beh behAM
	% spikeA
	clear bf
	
	%% Waveforms
	% Check waveforms for every block of experiments (Passive vs Active, AM
	% vs Ripple). If recording was stable, spike waveforms should be
	% similar.
	if wvflag
		figure(1) %#ok<*UNRCH>
		clf
		checkwaveform([spikeP.spikewave],'k');
		hold on
		checkwaveform([spikeA.spikewave],'r');
		checkwaveform([spikeAMP.spikewave],'b');
		checkwaveform([spikeAMA.spikewave],'m');
		
		title(fname);
		xlabel('Time (ms)');
		ylabel('Voltage');
		box off
		axis square
		ylim([-20 20]);
		drawnow;
	end
	
	%% Separate active trials in two blocks
	P				= spikeP;
	[A500,A1000,RT500,RT1000]    = separate2active(spikeA,beh);
	clear spikeP spikeA beh
	
	PAM				= spikeAMP;
	[A500AM,A1000AM,RT500AM,RT1000AM]    = separate2active(spikeAMA,behAM);
% 	clear spikeP spikeA beh
	
	switch meth
		case 1
			%% Determine spike density function
			[ma1,sdfA500]	= pa_spk_sdf(A500,'Fs',1000,'sigma',sigma); %#ok<*ASGLU>
			[ma2,sdfA1000]	= pa_spk_sdf(A1000,'Fs',1000,'sigma',sigma);
			[mp,sdfP]		= pa_spk_sdf(P,'Fs',1000,'sigma',sigma);
			
			if sdfflag
				figure(2)
				clf
				plot(ma1,'r-')
				hold on
				plot(ma2,'b-')
				plot(mp,'k-')
				axis square;
				box off
				xlabel('Time (ms)');
				pa_verline([0 300],'k-');
				pa_verline([0 800 1800],'b-');
				pa_verline([0 1300 2300],'r-');
				drawnow
			end
			
			%% Remove acoustics from active trials
			
			sdf500	= remacoustics(sdfA500,sdfP,A500,P);
			sdf1000 = remacoustics(sdfA1000,sdfP,A1000,P,1000);
			
			if rmflag
				ma1 = nanmedian(sdf500);
				ma2 = nanmedian(sdf1000);
				figure(3)
				clf
				plot(ma1,'k-')
				hold on
				plot(ma2,'r-')
				% 		plot(mp,'k-')
				axis square;
				box off
				xlabel('Time (ms)');
				pa_verline([0 300],'k-');
				pa_verline([0 800 1800],'k-');
				pa_verline([0 1300 2300],'r-');
				drawnow
			end
			
			S500	= [S500;sdf500(:,1:2000)]; %#ok<*AGROW>
			S1000	= [S1000;sdf1000(:,1:2000)];
			
		case 2
			
			%% Ripple
			dx	= 100;
			x	= 0:dx:2500;
			r	= -1000:dx:1000;
			n	= numel(A500);
			fr1	= NaN(n,numel(x));
			fr1reR = NaN(n,numel(r));
			rd1 = NaN(n,1);
			rv1 = rd1;
			for jj = 1:n
				a	= [A500(jj).spiketime];
				rd1(jj) = A500(jj).stimvalues(6);
				rv1(jj) = A500(jj).stimvalues(5);
				N	= hist(a,x);
				N	= N/dx*1000;
				fr1(jj,:) = N;
				
				a	= a-RT500(jj)-800;
				N	= hist(a,r);
				N	= N/dx*1000;
				fr1reR(jj,:) = N;
			end
			
			n		= numel(A1000);
			fr2		= NaN(n,numel(x));
			fr2reR = NaN(n,numel(r));
			rd2 = NaN(n,1);
			rv2 = rd2;
			for jj = 1:n
				a	= [A1000(jj).spiketime];
				rd2(jj) = A1000(jj).stimvalues(6);
				rv2(jj) = A1000(jj).stimvalues(5);

				N	= hist(a,x);
				N	= N/dx*1000;
				fr2(jj,:) = N;
				
				a = a-RT1000(jj)-1300;
				N	= hist(a,r);
				N	= N/dx*1000;
				fr2reR(jj,:) = N;
			end

			n		= numel(P);
			fr3		= NaN(n,numel(x));
			rd3 = NaN(n,1);
			rv3= rd3;
			for jj = 1:n
				a	= [P(jj).spiketime];
				rd3(jj) = P(jj).stimvalues(6);
				rv3(jj) = P(jj).stimvalues(5);
				N	= hist(a,x);
				N	= N/dx*1000;
				fr3(jj,:) = N;
			end
			
			fr1reR = fr1reR(:,2:end-1);
			fr2reR = fr2reR(:,2:end-1);
			r = r(2:end-1);
			
			FR(ii).reO500	= fr1';
			FR(ii).reO1000	= fr2';
			FR(ii).reR500	= fr1reR';
			FR(ii).reR1000	= fr2reR';
			FR(ii).O		= x;
			FR(ii).R		= r;
			FR(ii).reOP		= fr3';
			FR(ii).rd500		= rd1';
			FR(ii).rd1000		= rd2';
			FR(ii).rv500		= rv1';
			FR(ii).rv1000		= rv2';
			FR(ii).rdP		= rd3';
			FR(ii).rvP		= rv3';
			

			%% AM
			dx	= 100;
			x	= 0:dx:2500;
			r	= -1000:dx:1000;
			n	= numel(A500AM);
			fr1	= NaN(n,numel(x));
			fr1reR = NaN(n,numel(r));
			mf1 = NaN(n,1);
			for jj = 1:n
				a	= [A500AM(jj).spiketime];
				mf1(jj)	= A500AM(jj).stimvalues(5);
				
				N	= hist(a,x);
				N	= N/dx*1000;
				fr1(jj,:) = N;
				
				a	= a-RT500AM(jj)-800;
				N	= hist(a,r);
				N	= N/dx*1000;
				fr1reR(jj,:) = N;
			end
			
			n		= numel(A1000AM);
			fr2		= NaN(n,numel(x));
			fr2reR = NaN(n,numel(r));
			mf2 = NaN(n,1);
			for jj = 1:n
				a	= [A1000AM(jj).spiketime];
				mf2(jj)	= A1000AM(jj).stimvalues(5);
				N	= hist(a,x);
				N	= N/dx*1000;
				fr2(jj,:) = N;
				
				a = a-RT1000AM(jj)-1300;
				N	= hist(a,r);
				N	= N/dx*1000;
				fr2reR(jj,:) = N;
			end

			n		= numel(PAM);
			fr3		= NaN(n,numel(x));
			mf3 = NaN(n,1);
			for jj = 1:n
				a	= [PAM(jj).spiketime];
				mf3(jj)	= PAM(jj).stimvalues(5);
				N	= hist(a,x);
				N	= N/dx*1000;
				fr3(jj,:) = N;
			end
			
			fr1reR = fr1reR(:,2:end-1);
			fr2reR = fr2reR(:,2:end-1);
			r = r(2:end-1);
			
			FR(ii).reO500AM = fr1';
			FR(ii).reO1000AM = fr2';
			FR(ii).reR500AM = fr1reR';
			FR(ii).reR1000AM = fr2reR';
			FR(ii).OAM = x;
			FR(ii).RAM = r;
			FR(ii).reOPAM = fr3';			
			FR(ii).mf500		= mf1';
			FR(ii).mf1000		= mf2';
			FR(ii).mfP		= mf3';
			
			%% Graphics
			if dspflag
			figure(2)
			clf
			subplot(121)
			hold on
			n = size(fr1,1);
			mu = mean(fr1);
			sd = std(fr1)/sqrt(n);
			plot(x,mu,'k-','Color',[.5 .5 .5],'LineWidth',2);
			errorbar(x,mu,sd,'ko','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);
			
			n = size(fr2,1);
			mu = mean(fr2);
			sd = std(fr2)/sqrt(n);
			plot(x,mu,'k-','Color','r','LineWidth',2);
			errorbar(x,mu,sd,'ko','MarkerFaceColor','r','LineWidth',2);
			
			mu = mean(fr3);
			plot(x,mu,'k:','LineWidth',2);

			ax = axis;
			mx = max([20 ax(4)]);
			ax = [ax(1) ax(2) 0 mx];
			axis(ax);

			axis square;
			xlabel('Time (ms)');
			ylabel('Firing rate (spikes/s)');
			pa_verline([0 300 800 1800],'k-');
			pa_verline([1300 2800],'r-');
			pa_horline(0,'k-');
			
			subplot(122)
			hold on
			n = size(fr1reR,1);
			mu = mean(fr1reR);
			sd = std(fr1reR)/sqrt(n);
			plot(r,mu,'k-','Color',[.5 .5 .5],'LineWidth',2);
			errorbar(r,mu,sd,'ko','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);
			
			n = size(fr2reR,1);
			mu = mean(fr2reR);
			sd = std(fr2reR)/sqrt(n);
			plot(r,mu,'k-','Color','r','LineWidth',2);
			errorbar(r,mu,sd,'ko','MarkerFaceColor','r','LineWidth',2);
			
			ax = axis;
			mx = max([20 ax(4)]);
			ax = [ax(1) ax(2) 0 mx];
			axis(ax);
			
			axis square;
			xlabel('Time (ms)');
			ylabel('Firing rate (spikes/s)');
			pa_verline(0,'k-');
			pa_horline(0,'k-');
			drawnow
			end
	end
end

%%

figure(666)
clf
subplot(221)
hold on
x = FR(1).O;
y = [FR.reOP];
mu = mean(y,2);
sel = x>700 & x<1900;
x = x(sel)-300;
mu = mu(sel);
plot(x,mu,'k-','Color','k');

x = FR(1).O;
y = [FR.reO500];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>700 & x<1900;
x = x(sel)-300;
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color',[.5 .5 .5],'LineWidth',2);
errorbar(x,mu,sd,'ks','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);

x = FR(1).O;
y = [FR.reO1000];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>700 & x<1900;
x = x(sel)-300;
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color','r','LineWidth',2);
errorbar(x,mu,sd,'kd','MarkerFaceColor','r','LineWidth',2);

axis square;
ylim([25 50]);
xlabel('Time re sound onset (ms)');
ylabel('Firing rate (spikes/s)');
pa_verline([500 1000],'k-');
pa_horline(0,'k-');
h = pa_text(0.1,0.9,'A');
set(h,'FontWeight','bold')
text(750,45,'A500','FontWeight','bold');
text(850,40,'A1000','Color','r','FontWeight','bold');
text(800,27,'Passive','FontWeight','bold');
set(gca,'XTick',500:250:1500,'YTick',25:5:50);
subplot(222)
hold on
x = FR(1).R;
y = [FR.reR500];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>-600 & x<300;
x = x(sel);
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color',[.5 .5 .5],'LineWidth',2);
errorbar(x,mu,sd,'ks','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);
sel = x==0;
mu500 = mu(sel);

x = FR(1).R;
y = [FR.reR1000];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>-600 & x<300;
x = x(sel);
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color','r','LineWidth',2);
errorbar(x,mu,sd,'kd','MarkerFaceColor','r','LineWidth',2);

[~,indx] = min(abs(mu-mu500));
x1000 = x(indx);
plot([x1000 0],[mu500 mu500],'k-');
text(x1000/2,mu500,[num2str(abs(x1000)) ' ms'],'HorizontalAlignment','center','VerticalAlignment','top');

axis square;
ylim([25 50]);
xlim([-600 350])
xlabel('Time re bar release (ms)');
ylabel('Firing rate (spikes/s)');
pa_verline(0,'k-');
pa_horline(0,'k-');
h = pa_text(0.1,0.9,'B');
set(h,'FontWeight','bold')
text(-200,33,'A500','FontWeight','bold');
text(-200,47,'A1000','Color','r','FontWeight','bold');
set(gca,'XTick',-500:250:250,'YTick',25:5:50);

subplot(223)
hold on
x = FR(1).O;
y = [FR.reOPAM];
mu = mean(y,2);
sel = x>700 & x<1900;
x = x(sel)-300;
mu = mu(sel);

plot(x,mu,'k-','Color','k');

x = FR(1).O;
y = [FR.reO500AM];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>700 & x<1900;
x = x(sel)-300;
mu = mu(sel);
sd = sd(sel);

plot(x,mu,'k-','Color',[.5 .5 .5],'LineWidth',2);
errorbar(x,mu,sd,'ks','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);

x = FR(1).O;
y = [FR.reO1000AM];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>700 & x<1900;
x = x(sel)-300;
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color','r','LineWidth',2);
errorbar(x,mu,sd,'kd','MarkerFaceColor','r','LineWidth',2);

axis square;
ylim([25 50]);
xlabel('Time re sound onset (ms)');
ylabel('Firing rate (spikes/s)');
pa_verline([500 1000],'k-');
pa_horline(0,'k-');
h = pa_text(0.1,0.9,'C');
set(h,'FontWeight','bold')
text(750,42,'A500','FontWeight','bold');
text(950,38,'A1000','Color','r','FontWeight','bold');
text(800,33,'Passive','FontWeight','bold');
set(gca,'XTick',500:250:1500,'YTick',25:5:50);

subplot(224)
hold on
x = FR(1).R;
y = [FR.reR500AM];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>-600 & x<300;
x = x(sel);
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color',[.5 .5 .5],'LineWidth',2);
errorbar(x,mu,sd,'ks','MarkerFaceColor',[.5 .5 .5],'LineWidth',2);
sel = x==0;
mu500 = mu(sel);

x = FR(1).R;
y = [FR.reR1000AM];
n = size(y,2);
mu = mean(y,2);
sd = std(y,[],2)/sqrt(n);
sel = x>-600 & x<300;
x = x(sel);
mu = mu(sel);
sd = sd(sel);
plot(x,mu,'k-','Color','r','LineWidth',2);
errorbar(x,mu,sd,'kd','MarkerFaceColor','r','LineWidth',2);

[~,indx] = min(abs(mu-mu500));
x1000 = x(indx);
plot([x1000 0],[mu500 mu500],'k-');
text(x1000/2,mu500,[num2str(abs(x1000)) ' ms'],'HorizontalAlignment','center','VerticalAlignment','top');

axis square;
ylim([25 50]);
xlim([-600 350])
xlabel('Time re bar release (ms)');
ylabel('Firing rate (spikes/s)');
pa_verline(0,'k-');
pa_horline(0,'k-');
h = pa_text(0.1,0.9,'D');
set(h,'FontWeight','bold')
text(-200,30,'A500','FontWeight','bold');
text(-200,43,'A1000','Color','r','FontWeight','bold');
set(gca,'XTick',-500:250:250,'YTick',25:5:50);

drawnow

pa_datadir
print('-depsc','-painter','figure3');

%%

% keyboard
% %%
% figure(667)
% clf
% subplot(121)
% hold on
% mf = abs([FR.mf500]);
% mf = round(mf/10)*10;
% umf = unique(mf);
% n = numel(umf);
% y = [FR.reO500AM];
% mu = NaN(size(y,1),n);
% sd = NaN(size(y,1),n);
% 
% X = FR(1).O;
% col = jet(n);
% for ii = 1:n
% 	sel = mf == umf(ii);
% 	sum(sel)
% 	mu(:,ii) = nanmean(y(:,sel),2);
% 	sd(:,ii) = nanstd(y(:,sel),[],2)./sqrt(sum(sel));
% sel = X>700 & X<1900;
% x = X(sel)-300;
% plot(x,mu(sel,ii),'k-','LineWidth',2,'Color',col(ii,:));
% % errorbar(x,mu(:,ii),sd(:,ii),'ko','LineWidth',2,'MarkerFaceColor','w');
% end
% axis square;
% % ylim([25 50]);
% xlabel('Time re sound onset (ms)');
% ylabel('Firing rate (spikes/s)');
% pa_verline([500 1000],'k-');
% pa_horline(0,'k-');
% h = pa_text(0.1,0.9,'A');
% set(h,'FontWeight','bold')
% % text(750,42,'A500','FontWeight','bold');
% % text(950,38,'A1000','Color','r','FontWeight','bold');
% % text(800,33,'Passive','FontWeight','bold');
% set(gca,'XTick',500:200:1500,'YTick',25:5:50);
% 
% 
% subplot(122)
% hold on
% mf = abs([FR.mf500]);
% mf = round(mf/10)*10;
% 
% umf = unique(mf);
% n = numel(umf);
% y = [FR.reR500AM];
% mu = NaN(size(y,1),n);
% sd = NaN(size(y,1),n);
% 
% X = FR(1).R;
% col = jet(n);
% for ii = 1:n
% 	sel = mf == umf(ii);
% 	mu(:,ii) = nanmean(y(:,sel),2);
% 	sd(:,ii) = nanstd(y(:,sel),[],2)./sqrt(sum(sel));
% sel = X>-600 & X<300;
% x = X(sel);
% plot(x,mu(sel,ii),'k-','LineWidth',2,'Color',col(ii,:));
% % errorbar(x,mu(:,ii),sd(:,ii),'ko','LineWidth',2,'MarkerFaceColor','w');
% end
% axis square;
% % ylim([25 50]);
% xlabel('Time re bar release (ms)');
% ylabel('Firing rate (spikes/s)');
% pa_verline(0,'k-');
% pa_horline(0,'k-');
% h = pa_text(0.1,0.9,'B');
% set(h,'FontWeight','bold')
% set(gca,'XTick',-500:100:300,'YTick',25:5:50);

%%

function checkwaveform(spikewave,col)
% Determine the median spike waveform, the sd, and plot with the wonderful
% pa_errorpatch.
mu	= median(spikewave,2);
n	= size(spikewave,1);
sd	= std(spikewave,[],2)./sqrt(n);
x	= 1:length(mu);
pa_errorpatch(x,mu,sd,col);

function [S500,S1000,RT500,RT1000] = separate2active(spike,beh)
% Separate the spike-structure for an active block experiments in the 500
% and 1000 trials. Also separate behavior

%% Separate Spikes
stmat        = [spike.stimvalues];
ststat       = stmat(3,:);
sel500       = ststat==500;
S500         = spike(sel500);
for ii       = 1:length(S500)
	[m,n]          = size(S500(ii).trial);
	S500(ii).trial = repmat(ii,m,n);
	S500(ii).trial;
end

sel1000      = ststat==1000;
S1000        = spike(sel1000);
for ii              = 1:length(S1000)
	[m,n]           = size(S1000(ii).trial);
	S1000(ii).trial = repmat(ii,m,n);
	S1000(ii).trial;
end

%% Separate behavior
sel500	= beh(4,:)==500; %#ok<*NODEF>
reac	= beh(2,:);
RT500	= reac(sel500);
mn		= min(length(S500),length(RT500)); % sometimes the last trial is missing,
S500	= S500(1:mn);
RT500	= RT500(:,1:mn);

sel1000 = beh(4,:)==1000;
reac	= beh(2,:);
RT1000	= reac(sel1000);
mn		= min(length(S1000),length(RT1000));
S1000	= S1000(1:mn);
RT1000	= RT1000(:,1:mn);


function sdf = remacoustics(sdfA,sdfP,A,P,typ)
if nargin<5
	typ = 500;
end
ntrials	= size(sdfA,1);
stm		= [P.stimvalues];
stm		= stm([5 6],:); % modulation frequency (velocity)
stmP	= round(stm*1000)/1000;
sdf		= NaN(size(sdfA));
for jj	 = 1:ntrials
	stm				= A(jj).stimvalues([5 6]); % current trial
	stm				= round(stm*1000)/1000;
	selv			= stmP(1,:) == stm(1);
	seld			= stmP(2,:) == stm(2);
	sel				= selv & seld;
	if sum(sel)>1
		pass			= mean(sdfP(sel,:));
	elseif sum(sel)==1
		pass			= sdfP(sel,:);
	else
		disp('QUE?');
	end
	
	act			= sdfA(jj,:);
	if typ==1000
		pass = [pass(1:300) pass(301:800) pass(551:800) pass(551:800) pass(801:end)];
		whos pass
	end
	n1			= size(pass,2);
	n2			= size(act,2);
	n			= min([n1,n2]);
	act			= act(:,1:n);
	pass		= pass(:,1:n);
	% 	pass = 0;
	sdf(jj,1:n)	= act - pass;    % subtracting passive from active
end
