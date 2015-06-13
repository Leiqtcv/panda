close all
clear all
clc
warning off

pa_pet_backupdir;

sub = dir;
nsub = numel(sub); % -2

ctname = {'CT','CT_LD_WB__30___B31f_3','CT_LD_WB__30___B31f_4'};
petname = {'PET','PET_WB_4','PET_WB_5'};

values.PatientAddress = '';
values.RequestingPhysician = '';

ctflag = true;
petflag = true;

%% Anonymize CT scans

if ctflag
	for ii = 3:nsub
		ii
		dname = sub(ii).name; % for every subject
		if ~strcmp(dname,'Misc')
			cd(dname)
			session = dir;
			nsession = numel(session); % -2
			for jj = 3:nsession % for every session
				sessionname = session(jj).name;
				if ~strcmp(sessionname,'Misc') % except some miscellaneous data
					cd(sessionname);
					if exist(ctname{1},'dir')
						cd(ctname{1})
						
						cd('CT3') % anonymize the CT3-data set
						fnames = dir('*.IMA'); % which contains only IMA files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['CT-' id '-' dat '-' img '.IMA'];
							str = ['E:\Backup\anonPET\' id '\' dat '\CT\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						cd .. % and return to the initial directory
						
						cd ..
					elseif exist(ctname{2},'dir')
						cd(ctname{2})
						
						fnames = dir('*.dcm'); % which contains only dcm files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['CT-' id '-' dat '-' img  '.dcm'];
							str = ['E:\Backup\anonPET\' id '\' dat '\CT\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						
						cd .. % and return to the initial directory
					elseif exist(ctname{3},'dir')
						cd(ctname{3})
						
						fnames = dir('*.dcm'); % which contains only dcm files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['CT-' id '-' dat '-' img  '.dcm'];
							str = ['E:\Backup\anonPET\' id '\' dat '\CT\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						
						cd .. % and return to the initial directory
					else
						disp('Uh-Oh')
						dir
					end
					cd ..
				end
			end
			cd ..
		end
	end
end


%% Anonymize PET scans

if petflag
	for ii = 3:nsub
		ii
		dname = sub(ii).name; % for every subject
		if ~strcmp(dname,'Misc')
			cd(dname)
			session = dir;
			nsession = numel(session); % -2
			for jj = 3:nsession % for every session
				sessionname = session(jj).name;
				if ~strcmp(sessionname,'Misc') % except some miscellaneous data
					cd(sessionname);
					fdname = ['E:\Backup\PET\' dname '\' sessionname '\' petname{1}];
					if exist(fdname,'dir')
						cd(petname{1})
						
						if exist('PET4','dir')
						cd('PET4') % anonymize the PET4-data set
						fnames = dir('*.IMA'); % which contains only IMA files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['PET-' id '-' dat '-' img '.IMA'];
							str = ['E:\Backup\anonPET\' id '\' dat '\PET\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						cd .. % and return to the initial directory
						else
						cd('PET6') % anonymize the PET4-data set
						fnames = dir('*.IMA'); % which contains only IMA files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['PET-' id '-' dat '-' img '.IMA'];
							str = ['E:\Backup\anonPET\' id '\' dat '\PET\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						cd .. % and return to the initial directory
							
						end
						
						cd ..
					elseif exist(petname{2},'dir')
						cd(petname{2})
						
						fnames = dir('*.dcm'); % which contains only dcm files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['PET-' id '-' dat '-' img  '.dcm'];
							str = ['E:\Backup\anonPET\' id '\' dat '\PET\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						
						cd .. % and return to the initial directory
					elseif exist(petname{3},'dir')
						cd(petname{3})
						
						fnames = dir('*.dcm'); % which contains only dcm files
						nfiles = numel(fnames);
						values.StudyInstanceUID		= dicomuid;
						values.SeriesInstanceUID	= dicomuid;
						for kk = 1:nfiles
							fname = fnames(kk).name;
							info	= dicominfo(fname);
							id = info.PatientID;
							dat = info.SeriesDate;
							img = num2str(info.InstanceNumber);
							anonfname = ['PET-' id '-' dat '-' img  '.dcm'];
							str = ['E:\Backup\anonPET\' id '\' dat '\PET\'];
							if ~exist(str,'dir');
								mkdir(str);
							end
							dicomanon(fname,[str anonfname],'keep',...
								{'PatientID','PatientAge', 'PatientSex', 'StudyDescription'},...
								'update', values);
							info	= dicominfo([str anonfname]);
						end
						
						cd .. % and return to the initial directory
					else
						disp('Uh-Oh')
						dir
					end
					cd ..
				end
			end
			cd ..
		end
	end
end
