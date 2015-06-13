function topdown_matrix

clc;
close all;
clear all;
warning off; %#ok<*WNOFF>

cd('C:\all Data\Gain paper\BothAMandripple\fixed order cells\both');
% cd('C:\gain paper\gain\reaction-excluded cells');


thorfiles = dir('thor*');
joefiles  = dir('joe*');

files     = [thorfiles' joefiles'];

RP1000    = [];
RM1000    = [];
RP500     = [];
RM500     = [];
k         = 0;
g         = 0;
p         = 0;
q         = 0;

for ii				 = 1:length(files)% [1:3,5:31,33:48,50:64,66:73,75:length(files)]
	close all;
	ii; %#ok<*NOPRT>
	fname		  = files(ii).name
	load(fname);
	
	[A500,A1000]     = separate2active(spikeA);
	[AM500,AM1000]    = separate2active(spikeAMA);
	sigma         = 70;
	dsp           = 0;
	
	%% Separate behavior
	sel500           = beh(4,:)==500; %#ok<*NODEF>
	reac             = beh(2,:);
	reac500          = reac(sel500);
	mn               = min(length(A500),length(reac500)); % sometimes the last trial is missing,
	A500             = A500(1:mn);
	rt500            = reac500(:,1:mn);
	
	sel500           = behAM(4,:)==500;
	reac             = behAM(2,:);
	reac500          = reac(sel500);
	mn               = min(length(AM500),length(reac500));
	AM500            = AM500(1:mn);
	rtAM500          = reac500(:,1:mn);
	
	
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
	
	%% 500
	
	[mfr500,Amfr500,fr500,Afr500,rt,rtAM,vel,velAM,den,denAM,O500,OM500]        = get_info500(A500,spikeP,rt500,AM500,spikeAMP,rtAM500,sigma);
	mfr500  = mfr500 - mean(mfr500(1:201));
	Amfr500 = Amfr500 - mean(Amfr500(1:201));

	for i = 1:size(fr500,1)
		p = p+1;
		RP500(p).rt    = rt(i);
		RP500(p).rv    = vel(i);
		RP500(p).rd    = den(i);
		RP500(p).cell  = ii;
		RP500(p).Fr    = fr500(i,:);
		RP500(p).FrO   = O500(i,:);
	end
	
	for j = 1:size(Afr500,1)
		q = q+1;
		RA500(q).rt    = rtAM(j);
		RA500(q).rv    = velAM(j);
		RA500(q).rd    = denAM;
		RA500(q).cell  = ii;
		RA500(q).Fr    = Afr500(j,:);
		RA500(q).FrO   = OM500(j,:);
	end
	
	%% 1000
	
	[mfr1000,Amfr1000,fr1000,Afr1000,rt,rtAM,vel,velAM,den,denAM,O1000,OM1000]        = get_info1000(A1000,spikeP,rt1000,AM1000,spikeAMP,rtAM1000,sigma);
	mfr1000  = mfr1000 - mean(mfr1000(1:201));
	Amfr1000 = Amfr1000 - mean(Amfr1000(1:201));
	
	for i = 1:size(fr1000,1)
		k = k+1;
		RP1000(k).rt    = rt(i);
		RP1000(k).rv    = vel(i);
		RP1000(k).rd    = den(i);
		RP1000(k).cell  = ii;
		RP1000(k).Fr    = fr1000(i,:);
		RP1000(k).FrO   = O1000(i,:);
	end
	
	for j = 1:size(Afr1000,1)
		g = g+1;
		RA1000(g).rt    = rtAM(j);
		RA1000(g).rv    = velAM(j);
		RA1000(g).rd    = denAM;
		RA1000(g).cell  = ii;
		RA1000(g).Fr    = Afr1000(j,:);
		RA1000(g).FrO   = OM1000(j,:);
	end

end
keyboard
save('AllInfo','RP500','RA500','RP1000','RA1000');

function [mfr1000,Amfr1000,fr1000,Afr1000,rt,rtAM,vel,velAM,den,denAM,a1000,am1000] = get_info1000(spike1000,spikeP,rt1000,spikeAM1000,spikeAMP,rtAM1000,sigma)
if nargin < 8
	dsp = 1;
end
if nargin < 7
	sigma = 15;
end

%% A1000
[A,mfr1000,fr1000,rt,~,~,~,a1000] = do_hamechiz1000(spike1000,spikeP,rt1000,sigma);

values   = [spike1000.stimvalues];
vel      = values(5,:);
vel      = round(vel*1000)/1000;
den      = values(6,:);
den  	 = round(den*1000)/1000;


%% AM1000
[A,Amfr1000,Afr1000,rtAM,~,~,~,am1000] = do_hamechiz1000(spikeAM1000,spikeAMP,rtAM1000,sigma);

values   = [spikeAM1000.stimvalues];
velAM    = values(5,:);
velAM    = round(velAM*1000)/1000;
denAM    = 999;

%%
function [A1000,mfr,fr,rt,mf1,d1,mst,a1000] = do_hamechiz1000(A1000,spikecontrol,rt,sigma)
hh               = (A1000(1).stimvalues);
if size(hh,1)    == 6;
	
	[~,sdf]			 = pa_spk_sdf(A1000,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	ntrials			 = size(sdf,1);
	mf				 = [A1000.stimvalues];
	mf1				 = mf(5,:);
	mf1				 = round(mf1*1000)/1000;
	d1               = NaN(size(mf1));
	%%
	for jj			 = 1:ntrials
		cMF			 = A1000(jj).stimvalues(5); % current trial
		cMF  		 = round(cMF*1000)/1000;
		sel          = mfcntrl1 == cMF;
		mx           = 1900;

		pass         = mean(sdfctrl(sel,1:1400));
		a1000(jj,:)   = sdf(jj,501:mx) - pass;   % subtracting passive from active
	end
	
	mst               = mean(mean((sdf(:,401:1300)))); % mean static firing rate
	
	
	FR			     = NaN(size(a1000,1),2501);
	n			     = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(a1000);
		indx(sel)	 = length(a1000);
		for kk       = 1:size(a1000,1);
			FR(kk,n) = a1000(kk,indx(kk));
		end
	end
	
	fr               = FR(:,300:1000);
	% 	st               = [A1000.stimvalues];
	% 	sel              = st(5,:)>= 32;
	% 	gg = fr(sel,:);
	% 	whos gg fr
	%     mfr              = mean(fr(sel,:));
	
	if size(fr,1) > 1
		mfr              = nanmean(fr);
	elseif size(fr,1) == 1
		mfr              = fr;
	end
	
elseif size(hh,1)    == 7;
	
	[~,sdf]			 = pa_spk_sdf(A1000,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	mfcntrl2		 = mfcntrl(6,:);
	mfcntrl2		 = round(mfcntrl2*1000)/1000;
	ntrials			 = size(sdf,1);
	mf				 = [A1000.stimvalues];
	mf1				 = mf(5,:);
	mf1				 = round(mf1*1000)/1000;
	d1				 = mf(6,:);
	d1				 = round(d1*1000)/1000;
	
	%%
	for jj			 = 1:ntrials
		cMF			 = A1000(jj).stimvalues(5); % current trial
		cMF  		 = round(cMF*1000)/1000;
		cD			 = A1000(jj).stimvalues(6); % current trial
		cD  		 = round(cD*1000)/1000;
		sel          = mfcntrl1 == cMF & mfcntrl2 == cD;
		mx           = 1900;
		%         s		     = sdfctrl(sel,:);
		%         s	         = mean(s);
		%         y		     = sdf(jj,1:mx);
		%         x		     = s(1:mx);
		%         b		     = regstats(y,x,'linear','r');
		%         a1000(jj,:)   = b.r;
		pass         = mean(sdfctrl(sel,1:1400));
		a1000(jj,:)   = sdf(jj,501:mx) - pass;    % subtracting passive from active
	end
	mst               = mean(mean((sdf(:,401:1300)))); % mean static firing rate
	
	FR			     = NaN(size(a1000,1),2501);
	n			     = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(a1000);
		indx(sel)	 = length(a1000);
		for kk       = 1:size(a1000,1);
			FR(kk,n) = a1000(kk,indx(kk));
		end
	end
	fr               = FR(:,300:1000);
	if size(fr,1) > 1
		mfr              = nanmean(fr);
	elseif size(fr,1) == 1
		mfr              = fr;
	end
end

function [mfr500,Amfr500,fr500,Afr500,rt,rtAM,vel,velAM,den,denAM,a500,am500] = get_info500(spike500,spikeP,rt500,spikeAM500,spikeAMP,rtAM500,sigma)
if nargin < 8
	dsp = 1;
end
if nargin < 7
	sigma = 15;
end

%% A500
[A,mfr500,fr500,rt,~,~,~,a500] = do_hamechiz500(spike500,spikeP,rt500,sigma);

values   = [spike500.stimvalues];
vel      = values(5,:);
vel      = round(vel*1000)/1000;
den      = values(6,:);
den  	 = round(den*1000)/1000;


%% AM500
[A,Amfr500,Afr500,rtAM,~,~,~,am500] = do_hamechiz500(spikeAM500,spikeAMP,rtAM500,sigma);

values   = [spikeAM500.stimvalues];
velAM    = values(5,:);
velAM    = round(velAM*1000)/1000;
denAM    = 999;


%%
function [A500,mfr,fr,rt,mf1,d1,mst,a500] = do_hamechiz500(A500,spikecontrol,rt,sigma)
hh               = (A500(1).stimvalues);
if size(hh,1)    == 6;
	
	[~,sdf]			 = pa_spk_sdf(A500,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	ntrials			 = size(sdf,1);
	mf				 = [A500.stimvalues];
	mf1				 = mf(5,:);
	mf1				 = round(mf1*1000)/1000;
	d1               = NaN(size(mf1));
	%%
	for jj			 = 1:ntrials
		cMF			 = A500(jj).stimvalues(5); % current trial
		cMF  		 = round(cMF*1000)/1000;
		sel          = mfcntrl1 == cMF;
		mx           = 1900;
		%         s		     = sdfctrl(sel,:);
		%         s	         = mean(s);
		%         y		     = sdf(jj,1:mx);
		%         x		     = s(1:mx);
		%         b		     = regstats(y,x,'linear','r');
		%         a500(jj,:)   = b.r;
		pass         = mean(sdfctrl(sel,1:mx));
		a500(jj,:)   = sdf(jj,1:mx) - pass;    % subtracting passive from active
	end
	mst              = mean(mean((sdf(:,401:800)))); % mean static firing rate
	
	FR			     = NaN(size(a500,1),2501);
	n			     = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(a500);
		indx(sel)	 = length(a500);
		for kk       = 1:size(a500,1);
			FR(kk,n) = a500(kk,indx(kk));
		end
	end
	fr               = FR(:,700:1400);
	% 	st               = [A500.stimvalues];
	% 	sel              = st(5,:)>= 8;
	% 	gg = fr(sel,:);
	% 	whos gg fr
	%     mfr              = mean(fr(sel,:));
	mfr              = mean(fr);
	
elseif size(hh,1)    == 7;
	
	[~,sdf]			 = pa_spk_sdf(A500,'Fs',1000,'sigma',sigma);
	[~,sdfctrl]		 = pa_spk_sdf(spikecontrol,'Fs',1000,'sigma',sigma);
	mfcntrl			 = [spikecontrol.stimvalues];
	mfcntrl1		 = mfcntrl(5,:);
	mfcntrl1		 = round(mfcntrl1*1000)/1000;
	mfcntrl2		 = mfcntrl(6,:);
	mfcntrl2		 = round(mfcntrl2*1000)/1000;
	ntrials			 = size(sdf,1);
	mf				 = [A500.stimvalues];
	mf1				 = mf(5,:);
	mf1				 = round(mf1*1000)/1000;
	d1				 = mf(6,:);
	d1				 = round(d1*1000)/1000;
	
	%%
	for jj			 = 1:ntrials
		cMF			 = A500(jj).stimvalues(5); % current trial
		cMF  		 = round(cMF*1000)/1000;
		cD			 = A500(jj).stimvalues(6); % current trial
		cD  		 = round(cD*1000)/1000;
		sel          = mfcntrl1 == cMF & mfcntrl2 == cD;
		mx           = 2400;
		%         s		     = sdfctrl(sel,:);
		%         s	         = mean(s);
		%         y		     = sdf(jj,1:mx);
		%         x		     = s(1:mx);
		%         b		     = regstats(y,x,'linear','r');
		%         a500(jj,:)   = b.r;
		pass         = mean(sdfctrl(sel,1:mx));
		a500(jj,:)   = sdf(jj,1:mx) - pass;   % subtracting passive from active
	end
	mst              = mean(mean((sdf(:,401:800)))); % mean static firing rate
	
	FR			     = NaN(size(a500,1),2501);
	n			     = 0;
	for jj           = -500:2000
		n			 = n+1;
		indx		 = round(rt)+jj;
		sel			 = indx<1;
		indx(sel)	 = 1;
		sel			 = indx>length(a500);
		indx(sel)	 = length(a500);
		for kk       = 1:size(a500,1);
			FR(kk,n) = a500(kk,indx(kk));
		end
	end
	fr               = FR(:,700:1400);
	mfr              = mean(fr);
end

