% cd('E:\Backup\PET\Snijders\2008-10-30\PET\PET4');
% [N,T,R] = xlsread('CIfoneem.xlsx');
% xlswrite('matlabCI',R)


%%


d = dir;
n = numel(d);
for ii = 3:n
	dname = d(ii).name;
	cd(dname)
	pa_pet_cleandir;
	cd ..
end
