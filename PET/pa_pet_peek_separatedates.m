% cd('E:\Backup\PET\Snijders\2008-10-30\PET\PET4');
% [N,T,R] = xlsread('CIfoneem.xlsx');
% xlswrite('matlabCI',R)


%%


d = dir('*.IMA');
n = numel(d);
for ii = 1:n
	fname = d(ii).name;
	info	= dicominfo(fname);
	if ~exist(info.SeriesDate,'dir')
		mkdir(info.SeriesDate)
	end
	destination = info.SeriesDate;
	movefile(fname,destination);
end
