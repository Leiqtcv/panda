function tmp
close all
clear all
clc
% function alpha3to2

load('petancova')

%% Get roi
roifiles	= [data.roi];
nroi		= numel(roifiles);
fname = 'mnibrainregion.xls';
pa_datadir;
xlswrite(fname,roifiles');

[~,uroi,nroi] = getroi(data);
fname = 'petbrainregion.xls';
xlswrite(fname,uroi);

function [roi,uroi,nroi,s] = getroi(data)
roi = [data.roi]';
a	= roi;
s	= a;
na	= numel(a);
for ii = 1:na
	b		= a{ii};
	b		= b(5:end-8);
	sel		= strfind(b,'_');
	b(sel)	= ' ';
	s{ii}	= b(end); % side
	if strncmpi(b,'Vermis',6)
		a{ii} = b;
		s{ii} = 'L';
	else
		a{ii}	= b(1:end-2);
	end
end
roi		= a;
uroi	= unique(roi);
nroi	= numel(uroi);
