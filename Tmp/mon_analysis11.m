function mon_analysis11
close all
clear all
clf

loadflag = false;
% loadflag = true;

if ~loadflag
	[R,T,trial,mxtrial] = getdata;
	save dat R T trial mxtrial
else
	load('dat')
end

mxtrial = cumsum(mxtrial);
for ii = 1:3
	[ii mxtrial]
	if ii>1
	indx = (mxtrial(ii-1):mxtrial(ii));
	else
	indx = (1:mxtrial(ii));
	end
	
	subplot(211)
	plot(trial(indx)+(ii-1)*3,T(indx),'k-','Color',[.7 .7 .7])
	hold on
	plot(trial(indx)+(ii-1)*3,R(indx),'ko-','MarkerFaceColor','w','LineWidth',2)
	ylim([-90 90]);
	xlim([-15 165]);
	set(gca,'TickDir','out','XTick',0:50:150);
		pa_horline([0 5],'k:');
	pa_verline(max(trial(indx)+(ii-1)*3),'k:');
	pa_verline(min(trial(indx)+(ii-1)*3),'k:');
	box off
	xlabel('Trial number');
	ylabel('Azimuth (deg)');
	
	subplot(212)
	plot(trial(indx)+(ii-1)*3,abs(R(indx)-T(indx)),'k-','Color',[.7 .7 .7])
	hold on
	plot(trial(indx)+(ii-1)*3,smooth(abs(R(indx)-T(indx)),10),'k-','LineWidth',2)
% 	plot(trial(indx)+(ii-1)*3,smooth(R(indx),10),'r-','LineWidth',2)
	ylim([-10 90]);
	xlim([-15 165]);
	set(gca,'TickDir','out','XTick',0:50:150);
	
	box off
	pa_horline([0 5],'k:');
	pa_verline(max(trial(indx)+(ii-1)*3),'k:');
	pa_verline(min(trial(indx)+(ii-1)*3),'k:');
	
	xlabel('Trial number');
	ylabel('Error (deg)');
	
end

pa_datadir;
print('-depsc','-painter',mfilename);

function [R,T,trial,mxtrial] = getdata(fnames)
if nargin<1
	fnames = {'jp0401';'jp0403';'jp0405'};
% 	fnames = {'cd0201';'cd0204';'cd0206'};
% 	fnames = {'gk0301';'gk0303';'gk0305'};
% 	fnames = {'rh0601','rh0603','rh0605'};
% 	fnames = {'sb0301','sb0303','sb0305'};
end
nfiles = numel(fnames);
T = [];
R = [];
trial = [];
for ii = 1:nfiles
	subject = fnames{ii};
	mens(subject(1:end-2),'monaural');
	[Sac,Stim]  = loadmat([subject]);
	BB          = supersac(Sac,Stim);
	BB(:,23)    = -BB(:,23);
	BB(:,8)     = -BB(:,8);
	
	indx = 1:46;
	R = [R;BB(indx,8)];
	T = [T;BB(indx,23)];
	trial = [trial;BB(indx,1)+(ii-1)*50];
	mxtrial(ii) = numel(BB(indx,1))
end

function [E,T] = imp_exp(subject,deaf)
mens(subject(1:end-2),'monaural');
[Sac,Stim]  = loadmat([subject]);
BB          = supersac(Sac,Stim);
if strcmp(deaf,'r')
	BB(:,23)    = -BB(:,23);
	BB(:,8)     = -BB(:,8);
end

%%\
close all
E = BB(:,8)-BB(:,23);
R = BB(:,8);
T = BB(:,23);
trial = BB(:,1);
plot(trial,T,'k-','Color',[.7 .7 .7])
hold on
plot(trial,R,'ko-','MarkerFaceColor','w')

%%
% keyboard


%%
A_T		= unique(BB(:,23));
E		= NaN*ones(size(A_T),5);
T		= NaN*ones(size(A_T),5);
T = BB(:,1);
nT = 5;
E = NaN(nT,1);
for ii = 1:nT
	sel = ismember(T,1:10+(ii-1)*10);
	E(ii) = mean(abs(BB(sel,23) - BB(sel,8)));
end
T = 1:nT;


%%