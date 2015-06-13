clear all
close all
%
% pa_datadir;
% cd HDF5
%
% %% Display  h5
% % h5disp('sa18jun09.h5');
%
% %%
% info = h5info('sa18jun09.h5')

% numTrials = length(info.Groups)

Freqs = pa_oct2bw(100,0:1/3:7+1/3);
nFreq = numel(Freqs);
dur = 1000;
int = pa_oct2bw(0.01,-5:4);
nInt = numel(int);
n = 0;
for ii = 1:nFreq
	for jj = 1:nInt
		n = n+1;
		Freq = Freqs(ii);
		
		[stm,Fs] = pa_gentone(Freq, dur, 'display',0);
		fname = ['snd' num2str(n,'%03d') '.wav'];
		pa_datadir;
		pa_writewav(stm,fname,int(jj));
	end
end

for jj = 1:nInt
	n = n+1;
	
	stm = pa_gensweep;
	fname = ['snd' num2str(n,'%03d') '.wav'];
	pa_datadir;
	pa_writewav(stm,fname,int(jj));
end