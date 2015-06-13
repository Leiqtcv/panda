function LFPcheckmissingtrial(session,n)
% LFPCHECKMISSINGTRIAL
%
% Check which trial (if any) is missing from LFP files
%
% This is done by checking the end of the stimulus sound in the LFP files
% with the stimulus end as indicated by the dam-files
% AND
% by checking the time difference between two consecutive trials in the LFP
% files
%
% Marc van Wanrooij

if nargin<2
n		= 255;
end
if nargin<1
	session = 'Thor-2010-02-16-0003';
end

T		= zeros(n,1);
dam		= damfileread([session '.dam']);

for i = 1:n;
	rt = (dam(i).stim.values(3)+dam(i).stim.values(4))/2;
	rt2 = (dam(i+1).stim.values(3)+dam(i+1).stim.values(4))/2;
	fname = [session '-' num2str(i) '.mat'];
	load(fname);
	plot(data(:,2))
% 	verline(rt);
% 	verline(rt2,'r-');
% 	pause
	drawnow
	t = fix(abstime);
	t = t(4)*60*60+t(5)*60+t(6); %time in sec
	T(i) = t;
end
dT	= diff(T);
m	= mean(dT);
mn	= min(dT);

figure
hist(dT,0:1:15)
indx = find(dT>mn*2);
if ~isempty(indx)
	indx = indx+1;
	str = ['Missing trial: ' num2str(indx)'];
	title(str)
end
