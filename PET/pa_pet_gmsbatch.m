

% cd('E:\Backup\Nifti')
% ro_s5512113-d20100511-mPET
% d = dir('wro_s*.img');
d = dir('swro_*.img');
n = numel(d);
for ii = 1:n
	fname = d(ii).name
	pa_pet_grandmeanscale(fname);
end
	
% fname = 'E:\Backup\Nifti\o_s1468337-d20120530-mPET.hdr';
% pa_pet_cutimage(fname,'display',true);
% 
% fname = 'E:\Backup\Nifti\o_s1468337-d20120613-mPET.hdr';
% pa_pet_cutimage(fname,'display',true);
% 
% fname = 'E:\Backup\Nifti\o_s1468337-d20120606-mPET.hdr';
% pa_pet_cutimage(fname,'display',true);

% 
% fname = 'E:\Backup\Nifti\o_s2369736-d20120329-mPET.hdr';
% pa_pet_cutimage(fname,'display',true);
% 
% fname = 'E:\Backup\Nifti\o_s2369736-d20120320-mPET.hdr';
% pa_pet_cutimage(fname,'display',true);
% 
% fname = 'E:\Backup\Nifti\o_s2369736-d20120326-mPET.hdr';
% pa_pet_cutimage(fname,'display',true);

