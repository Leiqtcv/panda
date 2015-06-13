
function t
% PA_PET_ANALYSIS_EXAMPLE(SUBJECT)
%
% Analyse PET data of a single SUBJECT
% SUBJECT should be a number.
%
% See also PA_PET_ORIGINSET, PA_PET_XLSREAD_EXAMPLE, PA_PET_DECAYCORRECT

% 2012 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Clean-up
close all; % clear
clc; % clear screen
clear all
rd = 'E:\DATA\KNO\PET\CI\Ramarakh';
cd(rd);
d = dir;
stimname = {d(3:end).name};
n = numel(stimname);
pa_datadir
	fid = fopen('pettest.txt','w');
for ii = 1:n
	cd(rd);
	cd(stimname{ii});
	
	d = dir('*.ima');
	fname = {d.name};
	nfiles = numel(fname)
	dat = [];
	name = [];
	mod = [];
	for jj = 1:nfiles
		[dat{jj},name{jj},mod{jj}] = getdat(fname{jj});
	end
	u = unique([dat name mod])

	nu = numel(u);
	switch nu
		case 2
			fprintf(fid,'%s\t%s\t%s\t\n',stimname{ii},u{1},u{2});
		case 3
			fprintf(fid,'%s\t%s\t%s\t%s\t\n',stimname{ii},u{1},u{2},u{3});
		case 4
			fprintf(fid,'%s\t%s\t%s\t%s\t%s\t\n',stimname{ii},u{1},u{2},u{3},u{4});
		case 5
			fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t\n',stimname{ii},u{1},u{2},u{3},u{4},u{5});
		case 6
			fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',stimname{ii},u{1},u{2},u{3},u{4},u{5},u{6});
		case 7
			fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',stimname{ii},u{1},u{2},u{3},u{4},u{5},u{6},u{7});
	end
% 	plot(0,0);
% 	hold on
% 	axis([-10 10 0 nfiles*2]);
% 	title(stimname{ii});
	
end
	fclose(fid)
pa_datadir
return
getdat;

function [dat,name,mod] = getdat(fname)
try
	info	= dicominfo(fname);
	keyboard
	dat = info.StudyDate;
	dat = info.SeriesDate;
	% info.AcquisitionDate;
	mod = info.Modality;
	name = info.PatientName.FamilyName;
	
catch
	dat = 'error';
	name = 'error';
	mod = 'error';
end