function pa_pet_dicom2img(fnames)

% PA_PET_DICOM2IMG(FNAMES)
%
% Convert dicom files FNAMES to Analyze image files.
%
% This requires SPM8.
%
% See also SPM

% 2013 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Default Initialization
% Works for UMC Radboud Hearing & Implants, Donders Institute
if nargin<1
	d = dir('*.ima'); % early scans
	n = numel(d);
	if n==0;
	d = dir('*.dcm'); % later scans
	n = numel(d);
	end		
	for ii = 1:n
		fname = d(ii).name;
		if ii == 1
			fnames = fname;
		else
			fnames = char(fnames,fname);
		end
	end
end

%% SPM Conversion
spm_get_defaults;
hdr		= spm_dicom_headers(fnames);
spm_dicom_convert(hdr);

