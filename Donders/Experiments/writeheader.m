function writeheader(fid,datdir,ITI,Ntrls,Rep,Rnd,Mtr)
% WRITEHEADER(FID,DATDIR,ITI,NTRLS,REP,RND,MTR)
%
% Write header in an exp-file with file identifier FID.
%
% DATDIR	- Directory in C:\Human\ where data should be stored
% ITI		- Start and End of Inter Trial Interval (msec), e.g. [0 0]
% NTRLS		- Number of Trials (including repeats) that are played
% REP		- Number of Repeats
% RND		- Random Flag (0 - no, 1 - per repetition set, 2 - all trials)
% MTR		- Motor Flag ('n' - off, 'y' - on)
%
% See also GENEXPERIMENT, FOPEN, and the documentation of the Auditory
% Toolbox

% (c) Marc van Wanrooij 2009

% Header of exp-file
fprintf(fid,'%s\n','%');
fprintf(fid,'%s\n',['%% Experiment: C:\Human\' datdir]);
fprintf(fid,'%s\n','%');
fprintf(fid,'%s\t\t%d\t%d\n','ITI',ITI(1),ITI(2));
fprintf(fid,'%s\t%d\n','Trials',Ntrls);
fprintf(fid,'%s\t%d\n','Repeats',Rep);
fprintf(fid,'%s\t%d\t%s\n','Random',Rnd,'% 0=no, 1=per set, 2=all trials');
fprintf(fid,'%s\t\t%s\n','Motor',Mtr);
fprintf(fid,'\n');
% Information Line of body
fprintf(fid,'%s %s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','%','MOD','X','Y','ID','INT','On','On','Off','Off','Event');
fprintf(fid,'%s\t\t\t%s\t%s\t%s\t%s\t%s\t%s\n','%','edg','bit','Event','Time','Event','Time');
