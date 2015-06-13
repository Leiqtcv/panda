function CheckParadigm(pname)
%% This function checks if the parameter files stored in pname are fixed or random condition.
%% Clear Workspace
clear all
close all
clc

%% Initialize pathname
if nargin <1
	pname	= 'C:\Users\mdirkx\Documents\Auditory Scene Analysis\CentralFilter\Data\Rnd\UCI057\';
end

%% Retrieve files in pathname
Fnames	= dir([pname '*.mat']);
len		= length(Fnames);
l		= 1;
cnt     = 1;

for k = 1:len
	fname		= Fnames(k).name;
	load([pname '\' fname])
	D(l:l+15,:)	=	[TrlVal(1).MaskFreq1; (TrlVal(2).MaskFreq1*-1); TrlVal(3).MaskFreq1; (TrlVal(4).MaskFreq1*-1)]; %built matrix from first 4 trials.
	TrlCmpr(cnt,:) = [round(sum(D(l:l+15,:))) cnt];	 %check if sum of one parameter file is zero (fixed) or not zero (random)
	l = l + 16;
	cnt = cnt + 1;
end

%% Retrieve datafiles which are suspiciously fixed
sel				= TrlCmpr(:,1) == 0 & TrlCmpr(:,2) == 0 & TrlCmpr(:,3) == 0 & TrlCmpr(:,4) == 0;
SuspFix			= TrlCmpr(sel,5);
SuspRnd			= TrlCmpr(~sel,5);	
len2			= length(SuspFix);
len3			= length(SuspRnd);
TrlCmprTot = round(sum(D));

if isempty(SuspFix) && sum(TrlCmprTot) ~= 0 %only random
	disp(['This map contains ' num2str(len-len2) '/' num2str(len) ' Random Conditions! :)'])
elseif isvector(SuspFix) && len2 < len && len2 < len3 %Suspicious fixed in random map
	disp(['This map contains ' num2str(len-len2) '/' num2str(len) ' Random Conditions'])
	disp(['Warning: The following ' num2str(len2) ' file(s) is/are probably Fixed:'])
	for m = 1:len2
		disp(Fnames(SuspFix(m)))
	end
	resp = input('Do you want to check these files thoroughly? 0 = No; 1 = Yes');
	if resp == 1
		CheckFilesExtens(SuspFix,Fnames,pname)
	end
elseif isvector(SuspFix) && len2 < len && len2 > len3 %suspicious random in fix map
	disp(['This map contains ' num2str(len-len3) '/' num2str(len) ' Fixed Conditions'])
	disp(['Warning: The following ' num2str(len3) ' file(s) is/are probably Random:'])
	for m = 1:len3
		disp(Fnames(SuspRnd(m)))
	end
elseif sum(TrlCmprTot) == 0
	disp(['This map contains ' num2str(len2) '/' num2str(len) ' Fixed Conditions! :)'])
end

%% Helpers
function CheckFilesExtens(SuspFix, Fnames, pname)

len = length(SuspFix);

m = 1;

for k = 1:len
	load([pname '\' Fnames(SuspFix(k)).name]);
	TrlLen = length(TrlVal);
	for l = 1:TrlLen-1
			Dat(m:m+7,:) = [TrlVal(l).MaskFreq1; (TrlVal(l+1).MaskFreq1*-1)];
			m = m + 8;
	end	
	Sum	= round(sum(Dat));
	if Sum == 0
		disp(['Sorry Bro, ' Fnames(SuspFix(k)).name  ' is definitely a fixed condition'])
	elseif Sum ~= 0
		disp('Sum is not 0, check "Dat" if it is really a random condition')
	end
	resp = input('Do you want to continue to the next file? 0 = No; 1 = Yes');
	
	if resp == 1
		disp(['Continue to ' Fnames(SuspFix(k+1)).name ' ........'])
	else
		keyboard
	end
	pause(1)
end


