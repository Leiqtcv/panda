function pa_bayes_modelheader(fid)
% PA_BAYES_MODELHEADER(FID)
%
% Write header in a JAGS model file with file identifier FID:
%
% model {


% 2014 Marc van Wanrooij
% e: marcvanwanrooij@neural-code.com

fprintf(fid,'%s \r\n','model {');
