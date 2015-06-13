
function pa_pet_headercheck
% PA_PET_HEADERCHECK(SUBJECT)
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
clear all;

%% Current directory
d = dir;
stimname = {d(3:end).name};
n = numel(stimname);
% fid = fopen('petinfo.txt','w');

d = dir('*.ima'); % early scans
fname = {d.name};
nfiles = numel(fname);
if nfiles==0
	d = dir('*.dcm'); % late scans
	fname = {d.name};
	nfiles = numel(fname);
end
dat = [];
name = [];
mod = [];
for jj = 1:nfiles
	info(jj) = getinfo(fname{jj});
end
info(1)
dat		= unique(char(info.SeriesDate),'rows')
mod		= unique(char(info.Modality),'rows')
width	= unique([info.Width])
height	= unique([info.Height])
bd		= unique([info.BitDepth])
series	= unique(char(info.SeriesDescription),'rows')
if isfield(info,'Units')
	units	= unique(char(info.Units),'rows')
end
id = [info(1).PatientID]
% fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n',fname{1},dat,mod,width,height,bd,series);
% 	plot(0,0);
% 	hold on
% 	axis([-10 10 0 nfiles*2]);
% 	title(stimname{ii});

% fclose(fid);
% keyboard


function info = getinfo(fname)
try
	info	= dicominfo(fname);
	% 	info
	% 	return
	% 	keyboard
catch
	info = 'error';
end