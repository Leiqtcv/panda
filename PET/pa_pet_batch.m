% cd('E:\Backup\PET\Snijders\2008-10-30\PET\PET4');
% [N,T,R] = xlsread('CIfoneem.xlsx');
% xlswrite('matlabCI',R)

%%
disp('Clean directory of double files');
pa_pet_cleandir;

try
	cd('CT');
	pa_pet_cleandir;
	cd ..
end

str = input('Move files in CT to CT3_2? y or n: ','s');
if strcmp(str,'y')
	movefile('CT','CT3_2');
end

%%
disp('Create directories');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT1');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT2');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT3');
% [SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT3_2')
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT501');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT601');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('CT');

[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET4');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET5');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET6');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET7');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET602');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET603');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET604');
[SUCCESS,MESSAGE,MESSAGEID] = mkdir('PET');

%%
disp('Move files');

d = dir('*CT*(ADULT).1*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'CT2';
	movefile(source,destination);
end

d = dir('*CT*(ADULT).2*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'CT2';
	movefile(source,destination);
end

d = dir('*CT*(ADULT).3*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'CT3';
	movefile(source,destination);
end

d = dir('*CT*(ADULT).501*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'CT501';
	movefile(source,destination);
end

d = dir('*CT*(ADULT).601*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'CT601';
	movefile(source,destination);
end


d = dir('*PT*(ADULT).4*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET4';
	movefile(source,destination);
end

d = dir('*PT*(ADULT).5*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET5';
	movefile(source,destination);
end

d = dir('*PT*(ADULT).6.*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET6';
	movefile(source,destination);
end

d = dir('*PT*(ADULT).7*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET7';
	movefile(source,destination);
end

d = dir('*PT*(ADULT).602*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET602';
	movefile(source,destination);
end


d = dir('*PT*(ADULT).603*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET603';
	movefile(source,destination);
end

d = dir('*PT*(ADULT).604*');
n = numel(d);
for ii = 1:n
	source = d(ii).name;
	destination = 'PET604';
	movefile(source,destination);
end

%%
%%
disp('Move directories');

try, movefile('CT1','CT'); end
try, movefile('CT2','CT'); end
try, movefile('CT3','CT'); end
try, movefile('CT3_2','CT'); end
try, movefile('CT501','CT'); end
try, movefile('CT601','CT'); end

try, movefile('PET4','PET'); end
try, movefile('PET5','PET'); end
try, movefile('PET6','PET'); end
try, movefile('PET7','PET'); end
try, movefile('PET602','PET'); end
try, movefile('PET603','PET'); end
try, movefile('PET604','PET'); end

try, movefile('PET_*','PET'); end


%% Create images
%%
disp('Create NIFTI images');
try
cd('CT/CT3');
pa_pet_dicom2img;
pa_pet_headercheck;
cd ..
cd ..
catch
	disp('No image file found');
cd ..
cd ..
end

cd('PET/PET4');
pa_pet_dicom2img;
pa_pet_headercheck;
cd ..
cd ..

%% Check directories
disp('Check directories and files');

cd('CT');
d = dir('CT*');
n = numel(d);
for ii =1:n
	dname=d(ii).name;
	cd(dname)
	pa_pet_cleandir;
	fnames = dir('*.ima');
	nfiles = numel(fnames);
	cd ..
	if nfiles==0 || isempty(fnames)
		disp(['Directory ' dname ' is removed']);
		rmdir(dname);
	end
end
cd ..


cd('PET');
d = dir('PET*');
n = numel(d);
for ii =1:n
	dname=d(ii).name;
	cd(dname);
	pa_pet_cleandir;
	fnames = dir('*.ima');
	nfiles = numel(fnames);
	cd ..
	if nfiles==0 || isempty(fnames)
		disp(['Directory ' dname ' is removed']);
		rmdir(dname);
	end
end
cd ..