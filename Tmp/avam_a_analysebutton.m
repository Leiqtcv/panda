%%-- Analyse Audio

function avam_a_analysebutton

clc

filename = 'RG-MH-2015-01-08-0003';

%-- Get Reaction Time via button press--%
[e,c,l]     = pa_readcsv([filename '.csv']); %#ok<*ASGLU>
Nsamples	= c(1,6);					   % # of samples
Nchan		= e(:,8);
fname		= pa_fcheckext(filename,'dat');
dat			= pa_loaddat(fname,Nchan,Nsamples);

btn = squeeze(dat(:,:,4));


% get according sound information
[~,~,cLog]	 = pa_readcsv(filename);
sel = cLog(:,2)==4;
sndid =cLog(sel,11);


% unique sounds
snd = unique(sndid);

sel0 = sndid<100;
sel1 = sndid>100 & sndid < 200;
sel2 = sndid>200 & sndid < 300;
sel3 = sndid>300 & sndid < 500;
sel5 = sndid>500 ;

selall = {sel0;sel1;sel2;sel3;sel5};
RT = [];
for ii = 1:length(selall)
	% select modulation
	sel = selall{ii};
	% check sound
	sn = sndid(sel);
	bt = btn(:,sel);
    
	
	for aa = 1:length(sn)
		% find button response
		sel		= bt(:,aa)>-0.002;		% threshold
		time	= 1:length(bt);
		t		= time(sel);
		RespT	= t(1,1);
		
		% get delay information
		d = 500:100:1500;
		e = 1:1:size(d,2);
   
		keyboard
		s = sn(aa,1);
		r = num2str(s);
		if s >99
			R = r(2:end);
		else
			R = r;
		end
		
		S = str2num(R);
		idx = e == S;
		
		D = d(idx);
		% Get reaction time: Response (ms) - delay of change
		RT(ii,aa) = RespT-D;
        
		
		
	end
	
	%Plot
	tie = {'per. 15';'per. 136';'per. 258';'per. 379';'per. 500'};
	titel = tie{ii};
	figure(1)
	subplot(length(selall),1,ii)
	hist(RT(ii,:),11)
	box off
	axis square
	axis([-400 1000 0 4])
	ylabel(titel)
	if ii == length(selall)
		xlabel('reaction time (ms)')
	end
end
