% This batch script analyses the Verbal Fluency PET dataset available from the SPM site:
% http://www.fil.ion.ucl.ac.uk/spm/data/fluency/
% as described in the manual Chapter 31.

% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Guillaume Flandin
% $Id: verbal_fluency_batch.m 30 2008-05-20 11:16:55Z guillaume $

%% Path containing data
%--------------------------------------------------------------------------
data_path = 'C:\DATA\KNO\PET_fluency';

%% Set Matlab path
%--------------------------------------------------------------------------
% addpath('C:\work\spm5');

%% Initialise SPM defaults
spm('Defaults','fMRI');
spm_jobman('initcfg'); % useful in SPM8 only


%% WORKING DIRECTORY (useful for .ps only)
clear jobs
jobs{1}.util{1}.cdir.directory = cellstr(data_path);
spm_jobman('run',jobs);

%% SINGLE SUBJECT
clear jobs
jobs{1}.util{1}.md.basedir = cellstr(data_path);
jobs{1}.util{1}.md.name = 'single';
jobs{2}.stats{1}.factorial_design.des.fblock.fac.name = 'Word';
f = spm_select('FPList', fullfile(data_path,'p1'), '^.*snrp1.*\.img$');
jobs{2}.stats{1}.factorial_design.des.fblock.fsuball.fsubject.scans = cellstr(f);
jobs{2}.stats{1}.factorial_design.des.fblock.fsuball.fsubject.conds = [1 2 1 2 1 2 1 2 1 2 1 2];
jobs{2}.stats{1}.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
jobs{2}.stats{1}.factorial_design.cov.c = [1:12]';
jobs{2}.stats{1}.factorial_design.cov.cname = 'Time';
jobs{2}.stats{1}.factorial_design.globalc.g_mean = [];
jobs{2}.stats{1}.factorial_design.globalm.gmsca.gmsca_yes.gmscv = 50;
jobs{2}.stats{1}.factorial_design.globalm.glonorm = 2;
jobs{2}.stats{1}.factorial_design.dir = cellstr(fullfile(data_path,'single'));

jobs{2}.stats{2}.fmri_est.spmmat = cellstr(fullfile(data_path,'single','SPM.mat'));
spm_jobman('run',jobs);

%% MULTIPLE SUBJECTS: SUBJECT AND CONDITION DESIGN
clear jobs
jobs{1}.util{1}.md.basedir = cellstr(data_path);
jobs{1}.util{1}.md.name = 'subject-condition';
jobs{2}.stats{1}.factorial_design.des.fblock.fac(1).name = 'Subject';
jobs{2}.stats{1}.factorial_design.des.fblock.fac(1).variance = 0;
jobs{2}.stats{1}.factorial_design.des.fblock.fac(2).name = 'Word';
c = repmat([1 2;2 1],3,6);
for i=1:5
	f = spm_select('FPList', fullfile(data_path,sprintf('p%d',i)), '^.*snrp.*\.img$');
	jobs{2}.stats{1}.factorial_design.des.fblock.fsuball.fsubject(i).scans = cellstr(f);
	jobs{2}.stats{1}.factorial_design.des.fblock.fsuball.fsubject(i).conds = c(i,:);
end
jobs{2}.stats{1}.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
jobs{2}.stats{1}.factorial_design.des.fblock.maininters{2}.fmain.fnum = 2;
jobs{2}.stats{1}.factorial_design.masking.tm.tmr.rthresh = 0.8;
jobs{2}.stats{1}.factorial_design.globalc.g_mean = [];
jobs{2}.stats{1}.factorial_design.globalm.glonorm = 3;
jobs{2}.stats{1}.factorial_design.dir = cellstr(fullfile(data_path,'subject-condition'));

jobs{2}.stats{2}.fmri_est.spmmat = cellstr(fullfile(data_path,'subject-condition','SPM.mat'));
save(fullfile(data_path,'sc_design.mat'),'jobs');
spm_jobman('run',jobs);

%% MULTIPLE SUBJECTS: SUBJECT AND TIME DESIGN
load(fullfile(data_path,'sc_design.mat'));
jobs{1}.util{1}.md.name = 'subject-time';
jobs{2}.stats{1}.factorial_design.des.fblock.fac(2).name = 'repl';
jobs{2}.stats{1}.factorial_design.dir = cellstr(fullfile(data_path,'subject-time'));
jobs{2}.stats{2}.fmri_est.spmmat = cellstr(fullfile(data_path,'subject-time','SPM.mat'));
spm_jobman('run',jobs);

%% MULTIPLE SUBJECTS: SUBJECT BY CONDITION DESIGN
load(fullfile(data_path,'sc_design.mat'));
jobs{1}.util{1}.md.name = 'multiple';
jobs{2}.stats{1}.factorial_design.des.fblock.fac(1).ancova = 1;
%jobs{2}.stats{1}.factorial_design.des.fblock.fac(1).variance = 1; % Unequal variance
jobs{2}.stats{1}.factorial_design.des.fblock.maininters = {};
jobs{2}.stats{1}.factorial_design.des.fblock.maininters{1}.inter.fnums = [1 2]';
jobs{2}.stats{1}.factorial_design.dir = cellstr(fullfile(data_path,'multiple'));

jobs{2}.stats{2}.fmri_est.spmmat = cellstr(fullfile(data_path,'multiple','SPM.mat'));
spm_jobman('run',jobs);

clear jobs
jobs{1}.stats{1}.con.spmmat = cellstr(fullfile(data_path,'multiple','SPM.mat'));
for i=eye(5)
	jobs{1}.stats{1}.con.consess{find(i)}.tcon.name = sprintf('Subject %d: Gen > Shad',find(i));
	jobs{1}.stats{1}.con.consess{find(i)}.tcon.convec = kron(i',[-1 1]);
end
jobs{1}.stats{1}.con.consess{6}.tcon.name = 'All: Gen > Shad';
jobs{1}.stats{1}.con.consess{6}.tcon.convec = repmat([-1 1],1,5);

jobs{1}.stats{2}.results.spmmat = cellstr(fullfile(data_path,'multiple','SPM.mat'));
jobs{1}.stats{2}.results.conspec(1).contrasts = Inf;
jobs{1}.stats{2}.results.conspec(1).threshdesc = 'FWE';
jobs{1}.stats{2}.results.conspec(2).contrasts = 6;
jobs{1}.stats{2}.results.conspec(2).threshdesc = 'FWE';
jobs{1}.stats{2}.results.conspec(2).mask.contrasts = 1:5;
jobs{1}.stats{2}.results.conspec(2).mask.thresh = 0.05;
jobs{1}.stats{2}.results.conspec(2).mask.mtype = 0;
%Conjunction analysis is delayed as it requires an interactive step
%jobs{1}.stats{2}.results.conspec(3).contrasts = 1:5;
%jobs{1}.stats{2}.results.conspec(3).threshdesc = 'FWE';
spm_jobman('run',jobs);
