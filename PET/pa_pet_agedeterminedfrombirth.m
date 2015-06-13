p					= 'E:\Backup\Nifti\';
cd(p)
[N,T,R] = xlsread('subjectdates.xlsx');

implantdate = T(2:end,14)
birthdate = T(2:end,7)

n = numel(implantdate);
age = NaN(n,1);
for ii = 1:n
	
	if ~strcmp(implantdate{ii},'XXX') && ~isempty(implantdate{ii}) && ~strcmp(birthdate{ii},'XXX')
		implantn	= datenum(implantdate{ii},'dd-mm-yyyy');
		birthn		= datenum(birthdate{ii},'dd-mm-yyyy');
		
		age(ii) = floor((implantn-birthn)/365)
	end
end

[N(:,1) age]