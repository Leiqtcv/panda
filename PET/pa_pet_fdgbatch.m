

cd('E:\Backup\Nifti')
p					= 'E:\Backup\Nifti\';
cd(p)
[N,T] = xlsread('subjectdates.xlsx');
N
id = N(:,1);
dates = T(2:end,10:14);
ndates =  size(dates,2);
nsub = numel(id);
files = struct([]);
for ii = 1:nsub
	for jj = 1:ndates
		dat = dates{ii,jj};
		if ~isempty(dat) && ~strcmp(dat,'XXX');
			c = datevec(dat,'dd-mm-yyyy');
			fname = ['wro_s' num2str(id(ii),'%07i') '-d' num2str(c(1),'%04i') num2str(c(2),'%02i') num2str(c(3),'%02i') '-mPET.img'];
			FDG = N(ii,jj+15);
			pa_pet_fdgcorrect(fname,FDG);
% 			files(ii,jj).name = fname;
		end
		
	end
end


% d = dir('wro_s*.img');
% n = numel(d);
% for ii = 1:n
% 	fname = d(ii).name;
% 	pa_pet_fdgcorrect(fname);
% end
	


