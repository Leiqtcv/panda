cd E:\Backup\anonPET


sub = dir;
nsub = numel(sub);

for ii = 3:nsub
	subname = sub(ii).name;
	cd(subname)
	
	session = dir;
	nsession = numel(session);
	for jj = 3:nsession
		
		sessionname = session(jj).name;
		cd(sessionname)
		
% 		%% CT
% 		cd('CT')
% 		pa_pet_dicom2img;
% 		d = dir('*.IMA');
% 		if numel(d)==0
% 			d = dir('*.dcm');
% 		end
% 		fname = d(1).name;
% 		info	= dicominfo(fname);
% 		id = info.PatientID;
% 		dat = info.SeriesDate;
% 		newfname = ['E:\Backup\Nifti\s' id '-d' dat '-mCT']
% 		
% 		d = dir('*.hdr');
% 		fname = d.name;
% 		movefile(fname,[newfname '.hdr']);
% 		d = dir('*.img');
% 		fname = d.name;
% 		movefile(fname,[newfname '.img']);
% 
% 		cd ..
		
		%% PET
		cd('PET');
		pa_pet_dicom2img;
		d = dir('*.IMA');
		if numel(d)==0
			d = dir('*.dcm');
		end
		fname = d(1).name;
		info	= dicominfo(fname);
		id = info.PatientID;
		dat = info.SeriesDate;
		newfname = ['E:\Backup\Nifti\s' id '-d' dat '-mPET']
		keyboard
% 		d = dir('*.hdr');
% 		fname = d.name;
% 		movefile(fname,[newfname '.hdr']);
% 		d = dir('*.img');
% 		fname = d.name;
% 		movefile(fname,[newfname '.img']);
		
		
		
		
		% 		d = dir('*.hdr');
		% 		fname = d.name;
		% 		info = analyze75info(fname,'ByteOrder','ieee-le')
		% 		info = spm_vol(fname)
		
		% 		newfname =
		% delete('*.hdr');
		% delete('*.img');
		
		cd ..
		
		cd ..
% 		return
	end
	
	
	cd ..
	
end

