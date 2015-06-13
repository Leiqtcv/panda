
%% initialization
% close all
% clear all

%% Data-directory
pa_datadir('KNO\PET');

%% Subject Experiment Information
fname = 'PET_subjects.xlsx';

[NUM,TXT,RAW] = xlsread(fname);

Columns = TXT(1,:); % Columns

%% Sample size


%% Hearing Conditions
hearindx = find(strcmp(Columns,'Hearing')); % find xls column
hearing		= TXT(:,hearindx); % This is text-data
hearing		= hearing(2:end); % remove column name
uhearing	= unique(hearing); % Unique hearing conditions
disp(uhearing);

%% Stimulus Conditions
condindx	= find(strcmp(Columns,'Condition')); % find xls column
stimulus	= TXT(:,condindx); % This is text-data
stimulus	= stimulus(2:end); % remove column name
ustimulus	= unique(stimulus); % Unique stimulus conditions
disp(ustimulus);

%% Subjects
subjectindx	= find(strcmp(Columns,'Subject #')); % find xls column
subject		= NUM(:,subjectindx); % These are numbers
usubject	= unique(subject); % Unique subjects
disp(usubject);
disp('--------------------------------------');
disp('NORMAL-HEARING');
disp('--------------------------------------');

%% Complete Normal-Hearing Audiovisual
selstim		= strcmp(stimulus,'Audiovisual');
selhear		= strcmp(hearing,'Normal');
sel			= selstim & selhear;
% [subject selstim selhear sel]
nsubject		= sum(sel);
nh_av_subjects	= subject(sel);
str			= 'Number of audiovisual experiments';
disp(str)
str = ['performed by normal-hearing subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(nh_av_subjects(ii))];
	disp(str);
end
disp('--------------------------------------');


%% CI-USERS
disp('--------------------------------------');
disp('CI-users');
disp('--------------------------------------');

%% CI audiovisual
selstim		= strcmp(stimulus,'Audiovisual');
selhear		= strcmp(hearing,'Implant');
sel			= selstim & selhear;
% [subject selstim selhear sel]
nsubject		= sum(sel);
ci_av_subjects	= subject(sel);
str			= 'Number of audiovisual experiments';
disp(str)
str = ['performed by implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(ci_av_subjects(ii))];
	disp(str);
end
disp('--------------------------------------');

%% CI visual
selstim		= strcmp(stimulus,'Visual');
selhear		= strcmp(hearing,'Implant');
sel			= selstim & selhear;
% [subject selstim selhear sel]
nsubject		= sum(sel);
ci_v_subjects	= subject(sel);
str			= 'Number of visual experiments';
disp(str)
str = ['performed by implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(ci_v_subjects(ii))];
	disp(str);
end
disp('--------------------------------------');

%% CI control
selstim		= strcmp(stimulus,'Control');
selhear		= strcmp(hearing,'Implant');
sel			= selstim & selhear;
% [subject selstim selhear sel]
nsubject		= sum(sel);
ci_c_subjects	= subject(sel);
str			= 'Number of control experiments';
disp(str)
str = ['performed by implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(ci_c_subjects(ii))];
	disp(str);
end
disp('--------------------------------------');

%% CI, AV, V and C
c1 = intersect(ci_av_subjects,ci_v_subjects);
c2 = intersect(ci_av_subjects,ci_c_subjects);
c = intersect(c1,c2);
nsubject = numel(c);
str			= 'Number of complete AV, V, C experiments';
disp(str)
str = ['performed by implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(c(ii))];
	disp(str);
end
disp('--------------------------------------');


%% PRE-IMPLANTS
disp('--------------------------------------');
disp('PRE-IMPLANTS');
disp('--------------------------------------');

%% PRE visual
selstim		= strcmp(stimulus,'Visual');
selhear		= strcmp(hearing,'Pre-Implant');
sel			= selstim & selhear;
% [subject selstim selhear sel]
nsubject		= sum(sel);
ci_v_subjects	= subject(sel);
str			= 'Number of visual experiments';
disp(str)
str = ['performed by pre-implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(ci_v_subjects(ii))];
	disp(str);
end
disp('--------------------------------------');

%% PRE control
selstim		= strcmp(stimulus,'Control');
selhear		= strcmp(hearing,'Pre-Implant');
sel			= selstim & selhear;
% [subject selstim selhear sel]
nsubject		= sum(sel);
ci_c_subjects	= subject(sel);
str			= 'Number of control experiments';
disp(str)
str = ['performed by pre-implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(ci_c_subjects(ii))];
	disp(str);
end
disp('--------------------------------------');

%% PRE, V and C
c = intersect(ci_v_subjects,ci_c_subjects);
nsubject = numel(c);
str			= 'Number of complete V and C experiments';
disp(str)
str = ['performed by pre-implanted subjects: ' num2str(nsubject)];
disp(str)
for ii = 1:nsubject
	str = ['Subject: ' num2str(c(ii))];
	disp(str);
end
disp('--------------------------------------');

