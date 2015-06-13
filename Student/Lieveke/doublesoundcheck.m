close all
clear all
clc

cd('C:\DATA\Head Related Transfer Functions\Doublesoundcheck');
fname			= 'doublesndchck';
cd('C:\DATA\Head Related Transfer Functions\Dblsndchck2');
fname			= 'doublesndchck2';

wavfile			= 'snd100.wav';
wav				= wavread(wavfile);
	Fs     = 48828.125;
N0samples   = ceil(50/1000*Fs);
T           = 0.15; % sec
N           = ceil(T*Fs); % samples
NEnvelope   = 500; % samples

fname			= fcheckext(fname,'.hrtf');
nbytesperfloat      = 4;
fid             = fopen(fname,'r');
% First determine number of samples
fseek(fid,0,'eof');
nbytes          = ftell(fid);
frewind(fid)
hrtf         = fread(fid,inf,'float');
fclose(fid);

% Some Reshaping
ntrials = 180;
nsample = nbytes/nbytesperfloat/ntrials;
hrtf             = reshape(hrtf,nsample,ntrials);

csvfile             = fcheckext(fname,'.csv');
[exp,chan,mlog]     = readcsv(csvfile);

sel		= ismember(mlog(:,5),2);


mlog	= mlog(sel,[7 10]);
for ii = 1:size(mlog,1)
	d = hrtf(:,ii);	
	d = d(101:end);
	[c,lags]    = xcorr(d,wav,'coeff');
	[~,indx] = max(c);
	Tonset(ii) = 1000*lags(indx)/Fs;
	
% 	clf
% 	subplot(311)
% 	plot(wav,'k-')
% 	xlim([1 length(wav)]);
% 	
% 	subplot(312)
% 	plot(d,'r-');
% 	xlim([1 length(d)]);
% 	title(mlog(ii,1));
% 	verline(lags(indx)+N0samples+NEnvelope);
% 	verline(lags(indx)+N0samples+N-NEnvelope);
% 
% 	subplot(313)
% 	plot(lags,c,'k-');
% 	xlim([min(lags) max(lags)]);
% 	title(Tonset(ii))
% 	drawnow
% 	pause
	
end
figure(99)
subplot(131)

plot(mlog(:,1),Tonset-min(Tonset),'ko');
ylabel('Tonset (ms)');
xlabel('Speaker nr');
axis square

ulog	= unique(mlog,'rows');
LVL		= NaN(size(ulog,1),1);
for ii = 1:size(ulog,1)
	sel = mlog(:,1) == ulog(ii,1) & mlog(:,2) == ulog(ii,2);
	muT(ii)		= mean(Tonset(sel));
	indx = (round(muT(ii))+N0samples+NEnvelope+200):(round(muT(ii))+N0samples+N-NEnvelope);
	
% 	figure(2)
% 	clf
% 	plot(mean(hrtf(indx,sel),2))
% 	ylim([-15 15]);
% 	grid on
% 	drawnow
	
	mu = mean(hrtf(indx,sel),2);
	LVL(ii) = 20*log10(rms(mu));
end

uloc = unique(ulog(:,1));
for ii = 1:length(uloc)
	sel = ulog(:,1)==uloc(ii);
	
	x = ulog(sel,2);
	y = LVL(sel);
	x1 = [x ones(size(x))];
	
	b = regress(y,x1);
	
	
	B(ii,:) = (1.4457-b(2))/b(1);
	T(ii) = mean(muT(sel));
	figure(99)
	subplot(132)
	plot(x,y,'ko-')
	hold on
	axis square
	xlabel('Given Int');
	ylabel('Measured Power');
end
figure(99)
subplot(133)
plot(uloc,B,'ko')
axis square

T = T-min(T);
Tn = T*Fs/1000
