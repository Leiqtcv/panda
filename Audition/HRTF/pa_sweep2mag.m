function [Mag,Freq,Azimuth,Elevation] = sweep2mag(Sweep,Wav,Azimuth,Elevation,chan,NFFT,NSweep,Fs,nBegin,GraphFlag)
% [SPEC,FREQ,TIME] = SWEEP2SPEC(SWEEP,WAV,CHAN,NFFT,NSWEEP,CHAN)
%
% See also READHRTF, GENSWEEP


%% Initialization
if nargin<5
	chan = 1;
end
if nargin<6
	NFFT    = 1024;
end
if nargin<7
	NSweep = 18;
end
if nargin<8
	Fs     = 48828.125;
end
if nargin<9
	nBegin  = ceil(20/1000*Fs);
end
if nargin<10
	GraphFlag = 0;
end
Freq			= (0:(NFFT-1))*Fs/NFFT;

nloc	= size(Sweep,3);
nchan	= size(Sweep,2);
thresh	= 3;
%% FFT & Reshaping
% nBegin = 0;
% Tijd    = NaN(NFFT,nloc);
% Spec    = Tijd;
L       = NaN(1,nloc);

% for each location i
for i = 1:nloc
	if nchan>1
		d           = squeeze(Sweep(:,chan,i)); % obtain the measured Sweep data from channel chan
	else
		d           = squeeze(Sweep(:,i)); % obtain the measured Sweep data from channel chan
	end
	d           = d(101:end); % Remove the first 100 samples, somehow HumanV1 adds 100 extra samples
	% Rough Alignment Method 1
	if length(d)==length(Wav)
		[c,lags]    = xcorr(d,Wav,'coeff');
	else
		[c,lags]    = xcorr(d,Wav,'none');
	end
	[~,indx]    = max(abs(c));
	lag         = lags(indx);
	% 		if GraphFlag
	% 			td = 0:length(d)-1; td = 1000*(td-lag)/Fs;
	% 			tw = 0:length(Wav)-1; tw = 1000*tw/Fs;
	% 			figure(600)
	% 			clf
	% 			plot(tw,Wav,'r-');
	% 			hold on
	% 			plot(td,d,'k-');
	% 			xlim([0 max(td)]);
	% 			ylim([-3 3]);
	% 			horline(rms(d))
	% 			title(i)
	% 		verline(nBegin+NFFT);
	% 		verline(nBegin+2*NFFT);
	% 			drawnow
	% 		end
	L(i)        = lag;
end
L			= L(L<250);
lag			= round(median(L));
% if GraphFlag
% 	%% Check whether lags are correct
% 	stp			= round(std(L)./sqrt(numel(L)));
% 	x			= unique(round(min(L):stp:max(L)));
% 	figure(601)
% 	N			= hist(L,x);
% 	[~,indx]	= max(N);
% 	bar(x,N,1);
% 	verline(round(median(L)));
% 	verline(x(indx));
% end
% Aligmnent Method 2
% If Sweep is too weak, the time delay might be judged incorrectly
% Correct for this:
if lag>250 || lag<1
	lag     = 180;
end
Mag = NaN(NFFT,nloc);
for i = 1:nloc
	if nchan>1
		d           = squeeze(Sweep(:,chan,i)); % obtain the measured Sweep data from channel chan
	else
		d           = squeeze(Sweep(:,i)); % obtain the measured Sweep data from channel chan
	end
	d           = d(101:end); % Remove the first 100 samples, somehow HumanV1 adds 100 extra samples
% 		t			= 1:length(d);
% 		ti			= t*Fs/48828;
% 		d			= interp1(t,d,ti,'cubic');
	nOnset      = lag+nBegin;
	indx        = nOnset + 2*NFFT + (1:(NFFT*NSweep));
	data        = d(indx);
	
	if GraphFlag==1
		td = 0:length(d)-1; td = 1000*(td-lag)/Fs;
		tw = 0:length(Wav)-1; tw = 1000*tw/Fs;
		figure(600);
		clf;
		plot(tw,Wav,'r-');
		hold on;
		plot(td,d,'k-');
		xlim([0 max(td)]);
		ylim([-3 3]);
		horline(rms(d));
		title(i);
		verline(nBegin+NFFT);
		verline(nBegin+2*NFFT);
		drawnow;
	end
	data        = reshape(data, NFFT, NSweep);
	
	%% Correct for errors in Time	
	if GraphFlag==1
		meandata    = mean(data,2)';
		mudata		= repmat(meandata',1,NSweep);
		stddata		= std(data,0,2);
		deltadata	= data-mudata;
		
		
		figure(602);
		clf;
		subplot(221);
		for jj = 1:size(data,2)
			plot(deltadata(:,jj)+0.05*jj,'k-');
			hold on;
			dd		= deltadata(:,jj);
			dff		= abs(dd)-thresh*stddata;
			if any(dff>0)
				plot(deltadata(:,jj)+0.05*jj,'r-','LineWidth',2);
			end
		end
		xlim([1 length(deltadata)]);
		xlabel('Time');
		ylabel('Amplitude / Trial');
		title(i);
		box on;
		
		subplot(222);
		pcolor(deltadata');
		shading flat;
		xlabel('Time');
		ylabel('Trial');
		box on;
		colorbar
	end
	
	meandata    = mean(data,2)';
	mudata		= repmat(meandata',1,size(data,2));
	stddata		= std(data,0,2);
	deltadata	= data-mudata;
	
	sel			= (abs(deltadata) - thresh*repmat(stddata,1,size(data,2))) >0; % remove sweep when any part exceeds the threshold
	sel			= ~logical(sum(sel));
	data		= data(:,sel);
	
	%% Spectrum
	Spec		= NaN(size(data));
	for jj		= 1:size(data,2)
		x			= data(:,jj)-mean(data(:,jj));
		nfft        = 2^(nextpow2(length(x)));
		Spec(:,jj)  = abs(fft(x,nfft));
	end
	Mag(:,i)   = mean(Spec,2);
	
	if GraphFlag==1
		%% Frequency
		data		= Spec(2:513,:);
		meandata    = mean(data,2)';
		stddata		= std(data,0,2)';
		mudata		= repmat(meandata',1,size(data,2));
		deltadata	= data-mudata;
		sel			= Freq>2500 & Freq<15000;
		x			= Freq(sel);
		y			= deltadata(sel,:)';
		s			= stddata(sel);
		
		figure(602);
		subplot(223);
		for jj = 1:size(y,1)
			plot(x,smooth(y(jj,:))+.1*jj,'k-');
			hold on;
			
			dd		= abs(y(jj,:));
			dff		= abs(dd)-thresh*s;
			if any(dff>0)
				plot(x,smooth(y(jj,:))+.1*jj,'r-','LineWidth',2);
			end
		end
		xlabel('Frequency');
		ylabel('Magnitude / Trial');
		xlim([min(x) max(x)]);
		box on;
		
		subplot(224)
		pcolor(y);
		shading flat;
		xlabel('Frequency');
		ylabel('Trial');
		box on;
		
		drawnow;
		pause
	end
end
% NumUniquePts	= ceil((NFFT+1)/2);
% Spec			= Spec(1:NumUniquePts,:);

%% Average over location repetition
Locations	= [Azimuth Elevation];
uLoc		= unique(Locations,'rows');
M			= NaN(size(Mag,1),size(uLoc,1));
muall		= mean(Mag,2);
for ii = 1:size(uLoc,1)
	sel		= Azimuth == uLoc(ii,1) & Elevation == uLoc(ii,2);
	m		= Mag(:,sel);
	mu		= mean(m,2);
	M(:,ii) = mu;
	
	if GraphFlag==2
		MUall	= repmat(muall,1,size(m,2));
		m	= m./MUall;
		m	= hsmooth(m);
		mu2 = mean(m,2);
		figure(603)
		clf
		subplot(121)
		plot(Freq(1:513),m,'k-','Color',[.7 .7 .7]);
		hold on
		plot(Freq(1:513),mu2,'k-');
		x = [1000 2000 4000 8000 16000];
		set(gca,'Xtick',x,'XTickLabel',x/1000);
		axis square
		xlim(minmax(x));
		
		subplot(122)
		mu2		= repmat(mu2,1,size(m,2));
		m		= m-mu2;
		plot(Freq(1:513),m,'k-','Color',[.7 .7 .7]);
		hold on
		x = [1000 2000 4000 8000 16000];
		set(gca,'Xtick',x,'XTickLabel',x/1000);
		xlim(minmax(x));
		ylim([-4 4])
		horline
		axis square
		pause
	end
	
end

%% Output
Mag			= M;
Azimuth		= uLoc(:,1);
Elevation	= uLoc(:,2);