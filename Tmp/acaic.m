function tmp

clc;
close all;
clear all;
warning off; %#ok<*WNOFF>

cd('E:\DATA\Cortex\AMcells with tonespike');

% cd('C:\all Data\Gain paper\BothAMandripple\fixed order cells\both');
% cd('C:\gain paper\gain\reaction-excluded cells');


thorfiles   = dir('thor*');
joefiles    = dir('joe*');

files			= [thorfiles' joefiles'];
sigma			= 70;
RP500_ADD		= [];
RP500_MLT		= [];
AM500_ADD		= [];
AM500_MLT		= [];
RP1000_ADD		= [];
RP1000_MLT		= [];
AM1000_ADD		= [];
AM1000_MLT		= [];

for ii				 = 1:length(files)
	close all;
	ii %#ok<*NOPRT>
	fname			 = files(ii).name
	load(fname);
	whos
	[A500,A1000]     = separate2active(spikeA);
	sel500           = beh(4,:)==500; %#ok<*NODEF>
	reac             = beh(2,:);
	reac500          = reac(sel500);
	mn               = min(length(A500),length(reac500));
	A500             = A500(1:mn);
	rt500            = reac500(:,1:mn);
	
	[AM500,AM1000]   = separate2active(spikeAMA);
	sel500           = behAM(4,:)==500;
	reac             = behAM(2,:);
	reac500          = reac(sel500);
	mn               = min(length(AM500),length(reac500));
	AM500            = AM500(1:mn);
	rtAM500          = reac500(:,1:mn);
	
	%% temporal modulations
	
	st500           = [A500.stimvalues];
	vel_RP500       = st500(5,:);
	vel_RP500       = round(vel_RP500*1000)/1000;
	uvel_RP500      = unique(vel_RP500);
	
	st1000          = [A1000.stimvalues];
	vel_RP1000      = st1000(5,:);
	vel_RP1000      = round(vel_RP1000*1000)/1000;
	uvel_RP1000     = unique(vel_RP1000);
	
	Ast500          = [AM500.stimvalues];
	vel_AM500       = Ast500(5,:);
	vel_AM500       = round(vel_AM500*1000)/1000;
	uvel_AM500      = unique(vel_AM500);
	
	Ast1000         = [AM1000.stimvalues];
	vel_AM1000      = Ast1000(5,:);
	vel_AM1000      = round(vel_AM1000*1000)/1000;
	uvel_AM1000     = unique(vel_AM1000);
	
	%% spectral modulations
	
	st500           = [A500.stimvalues];
	den_RP500       = st500(6,:);
	den_RP500       = round(den_RP500*1000)/1000;
	uden_RP500      = unique(den_RP500);
	
	st1000          = [A1000.stimvalues];
	den_RP1000      = st1000(6,:);
	den_RP1000      = round(den_RP1000*1000)/1000;
	uden_RP1000     = unique(den_RP1000);
	
	%%
	sel1000          = beh(4,:)==1000;
	reac             = beh(2,:);
	reac1000         = reac(sel1000);
	mn               = min(length(A1000),length(reac1000));
	A1000            = A1000(1:mn);
	rt1000           = reac1000(:,1:mn);
	
	sel1000          = behAM(4,:)==1000;
	reac             = behAM(2,:);
	reac1000         = reac(sel1000);
	mn               = min(length(AM1000),length(reac1000));
	AM1000           = AM1000(1:mn);
	rtAM1000         = reac1000(:,1:mn);
	vel_AM1000       = vel_AM1000(1:mn);
	
	%%
	[sdfA500,Add500,Mlt500]      = do_predict500(A500,spikeP,rt500,sigma);

	[sdfAM500,AMdd500,AMlt500]   = do_predict500(AM500,spikeAMP,rtAM500,sigma);

	%% comparison
	
	RP500_add      = sum(sum((sdfA500 - Add500).^2));
	RP500_mlt      = sum(sum((sdfA500 - Mlt500).^2));
		
	AM500_add      = sum(sum((sdfAM500 - AMdd500).^2));
	AM500_mlt      = sum(sum((sdfAM500 - AMlt500).^2));
	
	RP500_ADD      = [RP500_ADD RP500_add];
	RP500_MLT      = [RP500_MLT RP500_mlt];
	AM500_ADD      = [AM500_ADD AM500_add];
	AM500_MLT      = [AM500_MLT AM500_mlt];
	
	%%  A1000
	[sdfA1000,Add1000,Mlt1000]      = do_predict1000(A1000,spikeP,rt1000,sigma);
	[sdfAM1000,AMdd1000,AMlt1000]   = do_predict1000(AM1000,spikeAMP,rtAM1000,sigma);
	
	%%
		%% comparison
	
	RP1000_add      = sum(sum((sdfA1000 - Add1000).^2));
	RP1000_mlt      = sum(sum((sdfA1000 - Mlt1000).^2));
		
	AM1000_add      = sum(sum((sdfAM1000 - AMdd1000).^2));
	AM1000_mlt      = sum(sum((sdfAM1000 - AMlt1000).^2));
	
	RP1000_ADD      = [RP1000_ADD RP1000_add];
	RP1000_MLT      = [RP1000_MLT RP1000_mlt];
	AM1000_ADD      = [AM1000_ADD AM1000_add];
	AM1000_MLT      = [AM1000_MLT AM1000_mlt];
end

keyboard
%%
close all;
figure;
subplot(121)
sel  = RP500_MLT < 2 * 10^9;
h1 = loglog(RP500_ADD(sel),RP500_MLT(sel),'r.')
pa_unityline;
xlabel('Additive difference');
ylabel('Multiplicative difference');
box off;
axis square;
% title('Ripple500');
hold on

subplot(122)
sel  = AM500_MLT < 10^10;
g1 = loglog(AM500_ADD(sel),AM500_MLT(sel),'r.')
pa_unityline;
xlabel('Additive difference');
ylabel('Multiplicative difference');
box off;
axis square;
% title('AM500');
hold on

% figure;
% subplot(121);
% sel      = RP500_MLT < 2 * 10^9;
% RP500    = RP500_MLT(sel)./RP500_ADD(sel);
% x        = 0:0.1:15;
% h = hist(RP500,x);
% bar(x,h,'Facecolor',[0.3 0.3 0.3],'Edgecolor',[0 0 0]);
% xlabel('multiplicative/additive ratio');
% ylabel('number of cells');
% xlim([0 4]);
% ylim([0 30]);
% box off;
% axis square;
% title('RP500');
% pa_verline(1);
% 
% subplot(122);
% sel      = AM500_MLT < 10^10;
% AM500    = AM500_MLT(sel)./AM500_ADD(sel);
% x        = 0:0.1:15;
% h = hist(AM500,x);
% bar(x,h,'Facecolor',[0.3 0.3 0.3],'Edgecolor',[0 0 0]);
% xlabel('multiplicative/additive ratio');
% ylabel('number of cells');
% xlim([0 4]);
% ylim([0 30]);
% box off;
% axis square;
% title('AM500');
% pa_verline(1);


subplot(121)
sel  = RP1000_MLT < 2 * 10^9;
h2 = loglog(RP1000_ADD(sel),RP1000_MLT(sel),'b.')
pa_unityline;
xlabel('Additive difference');
ylabel('Multiplicative difference');
box off;
axis square;
title('Ripple');
legend([h1,h2],'RP500','RP1000','Location','NW');

subplot(122)
sel  = AM1000_MLT < 10^10;
g2 = loglog(AM1000_ADD(sel),AM1000_MLT(sel),'b.')
pa_unityline;
xlabel('Additive difference');
ylabel('Multiplicative difference');
box off;
axis square;
title('AM');
legend([g1,g2],'AM500','AM1000','Location','NW');


% figure;
% subplot(121);
% sel      = RP1000_MLT < 2 * 10^9;
% RP1000    = RP1000_MLT(sel)./RP1000_ADD(sel);
% x        = 0:0.1:15;
% h = hist(RP1000,x);
% bar(x,h,'Facecolor',[0.3 0.3 0.3],'Edgecolor',[0 0 0]);
% xlabel('multiplicative/additive ratio');
% ylabel('number of cells');
% xlim([0 4]);
% ylim([0 30]);
% box off;
% axis square;
% title('RP1000');
% pa_verline(1);
% 
% subplot(122);
% sel      = AM1000_MLT < 10^10;
% AM1000    = AM1000_MLT(sel)./AM1000_ADD(sel);
% x        = 0:0.1:15;
% h = hist(AM1000,x);
% bar(x,h,'Facecolor',[0.3 0.3 0.3],'Edgecolor',[0 0 0]);
% xlabel('multiplicative/additive ratio');
% ylabel('number of cells');
% xlim([0 4]);
% ylim([0 30]);
% box off;
% axis square;
% title('AM1000');
% pa_verline(1);
%%

function [SDF500,ADD_fr,MLT_fr] = do_predict500(A500,spikecontrol,rt,sigma)
hh               = (A500(1).stimvalues);
if size(hh,1)    == 6;
	
	[~,sdf]			 = pa_spk_sdf(A500,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	[~,Psdf]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',5);   % passive response with sigma = 5
	[~,sdf500]		 = pa_spk_sdf(A500,'Fs',1000,'sigma',5);           % A500 response with sigma = 5
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	ntrials			 = size(sdf,1);
	mx               = 1900;
	%% check for mechanism
	Ad500            = NaN(ntrials,mx);
	Ml500            = Ad500;
	for jj			 = 1:ntrials
		cMF			 = A500(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		sel          = mfcntrl1 == cMF; % current trial
		pass         = mean(sdfctrl(sel,1:mx));
		
		%% Additive
		ad500        = sdf(jj,1:mx) - pass;    % subtracting passive from active
		Ad500(jj,:)  = ad500;
		
		%% Multiplicative
		ml500        = sdf(jj,1:mx) ./ pass;    % dividing active by passive
		Ml500(jj,:)  = ml500;
	end
	add_FR			 = NaN(size(Ad500,1),2501);
	mlt_FR           = add_FR;
	n			     = 0;
	
	%%	aligning to the reaction time and averaging over the trials
	Add_fr           = NaN(1,701);
	Mlt_fr           = Add_fr;
	ad_FR            = NaN(ntrials,2501);
	ml_FR            = ad_FR;
	SD500            = ad_FR;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Ad500);
		indx(sel)	 = length(Ad500);
		for kk       = 1:size(Ad500,1);
			ad_FR(kk,n) = Ad500(kk,indx(kk));
			ml_FR(kk,n) = Ml500(kk,indx(kk));
			SD500(kk,n) = sdf500(kk,indx(kk));
		end
	end
	Add_fr               = nanmean(ad_FR(:,700:1400));
	Mlt_fr               = nanmean(ml_FR(:,700:1400));

	%% aligning the passive response with sigma = 5 to the reaction time
	Pass             = NaN(ntrials,mx);
	Mlt500           = NaN(ntrials,701);
	for jj			 = 1:ntrials
		cMF			 = A500(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		sel          = mfcntrl1 == cMF; % current trial
		pass         = mean(Psdf(sel,1:mx));
		Pass(jj,:)   = pass;
	end
	PAss             = NaN(ntrials,2501);
	PAS              = NaN(1,701);
    n = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Pass);
		indx(sel)	 = length(Pass);
		for kk       = 1:size(Pass,1);
			PAss(kk,n) = Pass(kk,indx(kk));
		end
	end
	PASS              = PAss(:,700:1400);
	%% constructing the predictions
	ADD_fr               = NaN(ntrials,701);
	MLT_fr               = ADD_fr;
	SDF500               = SD500(:,700:1400);
	
	for i                = 1:size(PAss,1)
		ADD_fr(i,:)      = PASS(i,:)+ Add_fr;
		MLT_fr(i,:)      = PASS(i,:).* Mlt_fr;
	end
	
elseif size(hh,1)    == 7;
	
	[~,sdf]			 = pa_spk_sdf(A500,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	[~,Psdf]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',5);   % passive response with sigma = 5
	[~,sdf500]		 = pa_spk_sdf(A500,'Fs',1000,'sigma',5);           % A500 response with sigma = 5
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	mfcntrl2		 = mfcntrl(6,:);
	mfcntrl2		 = round(mfcntrl2*1000)/1000;
	ntrials			 = size(sdf,1);
	mx               = 2400;
	
	%% check for mechanism
	Ad500            = NaN(ntrials,mx);
	Ml500            = Ad500;
	for jj			 = 1:ntrials
		cMF			 = A500(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		cD			 = A500(jj).stimvalues(6);
		cD  		 = round(cD*1000)/1000;
		sel          = mfcntrl1 == cMF & mfcntrl2 == cD; % current trial
		pass         = mean(sdfctrl(sel,1:mx));
		
		%% Additive
		ad500        = sdf(jj,1:mx) - pass;    % subtracting passive from active
		Ad500(jj,:)  = ad500;
		
		%% Multiplicative
		ml500        = sdf(jj,1:mx) ./ pass;    % dividing active by passive
		Ml500(jj,:)  = ml500;
	end
	add_FR			 = NaN(size(Ad500,1),2501);
	mlt_FR           = add_FR;
	n			     = 0;
	
	%%	aligning to the reaction time and averaging over the trials
	Add_fr           = NaN(1,701);
	Mlt_fr           = Add_fr;
	ad_FR            = NaN(ntrials,2501);
	ml_FR            = ad_FR;
	SD500            = ad_FR;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Ad500);
		indx(sel)	 = length(Ad500);
		for kk       = 1:size(Ad500,1);
			ad_FR(kk,n) = Ad500(kk,indx(kk));
			ml_FR(kk,n) = Ml500(kk,indx(kk));
			SD500(kk,n) = sdf500(kk,indx(kk));
		end
	end
	Add_fr               = nanmean(ad_FR(:,700:1400));
	Mlt_fr               = nanmean(ml_FR(:,700:1400));

	%% aligning the passive response with sigma = 5 to the reaction time
	Pass             = NaN(ntrials,mx);
	Mlt500           = NaN(ntrials,701);
	for jj			 = 1:ntrials
		cMF			 = A500(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		cD			 = A500(jj).stimvalues(6);
		cD  		 = round(cD*1000)/1000;
		sel          = mfcntrl1 == cMF & mfcntrl2 == cD; % current trial
		pass         = mean(Psdf(sel,1:mx));
		Pass(jj,:)   = pass;
	end
	PAss             = NaN(ntrials,2501);
	PAS              = NaN(1,701);
    n = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Pass);
		indx(sel)	 = length(Pass);
		for kk       = 1:size(Pass,1);
			PAss(kk,n) = Pass(kk,indx(kk));
		end
	end
	PASS              = PAss(:,700:1400);
	%% constructing the predictions
	ADD_fr               = NaN(ntrials,701);
	MLT_fr               = ADD_fr;
	SDF500               = SD500(:,700:1400);
	
	for i                = 1:size(PAss,1)
		ADD_fr(i,:)      = PASS(i,:)+ Add_fr;
		MLT_fr(i,:)      = PASS(i,:).* Mlt_fr;
	end
end

%%
function [SDF1000,ADD_fr,MLT_fr] = do_predict1000(A1000,spikecontrol,rt,sigma)
hh               = (A1000(1).stimvalues);
if size(hh,1)    == 6;
	
	[~,sdf]			 = pa_spk_sdf(A1000,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	[~,Psdf]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',5);   % passive response with sigma = 5
	[~,sdf1000]		 = pa_spk_sdf(A1000,'Fs',1000,'sigma',5);           % A1000 response with sigma = 5
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	ntrials			 = size(sdf,1);
	mx               = 1900;
	%% check for mechanism
	Ad1000            = NaN(ntrials,1001);
	Ml1000            = Ad1000;
	for jj			 = 1:ntrials
		cMF			 = A1000(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		sel          = mfcntrl1 == cMF; % current trial
		pass         = mean(sdfctrl(sel,400:1400));
		
		%% Additive
		ad1000        = sdf(jj,900:mx) - pass;    % subtracting passive from active
		Ad1000(jj,:)  = ad1000;
		
		%% Multiplicative
		ml1000        = sdf(jj,900:mx) ./ pass;    % dividing active by passive
		Ml1000(jj,:)  = ml1000;
	end
	add_FR			 = NaN(size(Ad1000,1),2501);
	mlt_FR           = add_FR;
	n			     = 0;
	
	%%	aligning to the reaction time and averaging over the trials
	Add_fr           = NaN(1,701);
	Mlt_fr           = Add_fr;
	ad_FR            = NaN(ntrials,2501);
	ml_FR            = ad_FR;
	SD1000            = ad_FR;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Ad1000);
		indx(sel)	 = length(Ad1000);
		for kk       = 1:size(Ad1000,1);
			ad_FR(kk,n) = Ad1000(kk,indx(kk));
			ml_FR(kk,n) = Ml1000(kk,indx(kk));
			SD1000(kk,n) = sdf1000(kk,indx(kk));
		end
	end
	Add_fr               = nanmean(ad_FR(:,300:1000));
	Mlt_fr               = nanmean(ml_FR(:,300:1000));

	%% aligning the passive response with sigma = 5 to the reaction time
	Pass             = NaN(ntrials,1001);
	Mlt1000           = NaN(ntrials,701);
	for jj			 = 1:ntrials
		cMF			 = A1000(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		sel          = mfcntrl1 == cMF; % current trial
		pass         = mean(Psdf(sel,400:1400));
		Pass(jj,:)   = pass;
	end
	PAss             = NaN(ntrials,2501);
	PAS              = NaN(1,701);
    n = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Pass);
		indx(sel)	 = length(Pass);
		for kk       = 1:size(Pass,1);
			PAss(kk,n) = Pass(kk,indx(kk));
		end
	end
	PASS              = PAss(:,300:1000);
	%% constructing the predictions
	ADD_fr               = NaN(ntrials,701);
	MLT_fr               = ADD_fr;
	SDF1000               = SD1000(:,300:1000);
	
	for i                = 1:size(PAss,1)
		ADD_fr(i,:)      = PASS(i,:)+ Add_fr;
		MLT_fr(i,:)      = PASS(i,:).* Mlt_fr;
	end
	
elseif size(hh,1)    == 7;
	
	[~,sdf]			 = pa_spk_sdf(A1000,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	[~,Psdf]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',5);   % passive response with sigma = 5
	[~,sdf1000]		 = pa_spk_sdf(A1000,'Fs',1000,'sigma',5);           % A1000 response with sigma = 5
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	mfcntrl2		 = mfcntrl(6,:);
	mfcntrl2		 = round(mfcntrl2*1000)/1000;
	ntrials			 = size(sdf,1);
	mx               = 1900;
	
	%% check for mechanism
	Ad1000            = NaN(ntrials,1001);
	Ml1000            = Ad1000;
	for jj			 = 1:ntrials
		cMF			 = A1000(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		cD			 = A1000(jj).stimvalues(6);
		cD  		 = round(cD*1000)/1000;
		sel          = mfcntrl1 == cMF & mfcntrl2 == cD; % current trial
		pass         = mean(sdfctrl(sel,400:1400));
	
		%% Additive
		ad1000        = sdf(jj,900:mx) - pass;    % subtracting passive from active
		Ad1000(jj,:)  = ad1000;
		
		%% Multiplicative
		ml1000        = sdf(jj,900:mx) ./ pass;    % dividing active by passive
		Ml1000(jj,:)  = ml1000;
	end
	add_FR			 = NaN(size(Ad1000,1),2501);
	mlt_FR           = add_FR;
	n			     = 0;
	
	%%	aligning to the reaction time and averaging over the trials
	Add_fr           = NaN(1,701);
	Mlt_fr           = Add_fr;
	ad_FR            = NaN(ntrials,2501);
	ml_FR            = ad_FR;
	SD1000            = ad_FR;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Ad1000);
		indx(sel)	 = length(Ad1000);
		for kk       = 1:size(Ad1000,1);
			ad_FR(kk,n) = Ad1000(kk,indx(kk));
			ml_FR(kk,n) = Ml1000(kk,indx(kk));
			SD1000(kk,n) = sdf1000(kk,indx(kk));
		end
	end
	Add_fr               = nanmean(ad_FR(:,300:1000));
	Mlt_fr               = nanmean(ml_FR(:,300:1000));

	%% aligning the passive response with sigma = 5 to the reaction time
	Pass             = NaN(ntrials,1001);
	Mlt1000           = NaN(ntrials,701);
	for jj			 = 1:ntrials
		cMF			 = A1000(jj).stimvalues(5);
		cMF  		 = round(cMF*1000)/1000;
		cD			 = A1000(jj).stimvalues(6);
		cD  		 = round(cD*1000)/1000;
		sel          = mfcntrl1 == cMF & mfcntrl2 == cD; % current trial
		pass         = mean(Psdf(sel,400:1400));
		Pass(jj,:)   = pass;
	end
	PAss             = NaN(ntrials,2501);
	PAS              = NaN(1,701);
    n = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(Pass);
		indx(sel)	 = length(Pass);
		for kk       = 1:size(Pass,1);
			PAss(kk,n) = Pass(kk,indx(kk));
		end
	end
	PASS              = PAss(:,300:1000);
	%% constructing the predictions
	ADD_fr               = NaN(ntrials,701);
	MLT_fr               = ADD_fr;
	SDF1000               = SD1000(:,300:1000);
	
	for i                = 1:size(PAss,1)
		ADD_fr(i,:)      = PASS(i,:)+ Add_fr;
		MLT_fr(i,:)      = PASS(i,:).* Mlt_fr;
	end

end
