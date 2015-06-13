function writeexp5(expfile,datdir,theta,phi,id,int,ledon,sndon,dummy,nrdtrials)
% Save known trial-configurations in exp-file
%
%WRITEEXP WRITEEXP(FNAME,DATDIR,THETA,PHI,ID,INT,LEDON,SNDON)
%
% WRITEEXP(FNAME,THETA,PHI,ID,INT,LEDON,SNDON)
%
% Write exp-file with file-name FNAME.
%
%
% See also GENEXPERIMENT
%
% Author: Marcw
expfile = fcheckext(expfile,'.exp');
if nargin<9
    dummy = [];
end
if nargin<10
   nrdtrials = 1;
end
fid                         = fopen(expfile,'w');
nid                         = size(theta,2);
nint                        = size(theta,3);
ntrials                     = size(theta,1);
% dtrials = rnduni(1,ntrials,nrdtrials); % The trial numbers which should contain a dummy movement
% sel     = abs(diff(theta))<30;
% indx    = find(logical([sel;0]));
% % dtrials = indx
% dtrials     = unique(sort([dtrials;indx]));
% ntrials
% nrdtrials   = size(dtrials,1)
% 


% Header of exp-file
fprintf(fid,'%s\n','%');
fprintf(fid,'%s\n',['%% Experiment: C:\Human\' datdir]);
fprintf(fid,'%s\n','%');
fprintf(fid,'%s\t\t%d\t%d\n','ITI',0,0);
if ~isempty(dummy)
    fprintf(fid,'%s\t%d\n','Trials',(ntrials*nid*nint)+nrdtrials);
elseif isempty(dummy)
    fprintf(fid,'%s\t%d\n','Trials',ntrials*nid*nint);
end
fprintf(fid,'%s\t%d\n','Repeats',1);
fprintf(fid,'%s\t%d\t%s\n','Random',0,'% 0=no, 1=per set, 2=all trials');
fprintf(fid,'%s\t\t%s\n','Motor','y');
fprintf(fid,'\n');
% Information Line of body
fprintf(fid,'%s %s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n','%','MOD','X','Y','ID','INT','On','On','Off','Off','Event');
fprintf(fid,'%s\t\t\t%s\t%s\t%s\t%s\t%s\t%s\n','%','edg','bit','Event','Time','Event','Time');
% Body of exp-file
% Create a trial for
% each location
n = 0;
for i               = 1:ntrials
    % each sound
%     for j           = 1:nid
%         % and each intensity
%         for k       = 1:nint
            n = n+1;
            fprintf(fid,'\n');
            fprintf(fid,'%s\n',['% Trial' num2str(i)]);
            fprintf(fid,'%s\n','==>');
            % Button trigger after LED has been fixated
            fprintf(fid,'%s\t\t\t%d\t%d\t%d\t%d\t%d\n','Trg0',1,2,0,0,1);
            
            % fixation LED
            if theta(i)==0
                fprintf(fid,'%s\t%d\t%d\t \t%d\t%d\t%d\t%d\t%d\n','LED',0,12,1,0,0,1,ledon(i));%(i,j,k));
            else
                fprintf(fid,'%s\t\t%d\t%d \t%d\t%d\t%d\t%d\t%d\n','Sky',0,2,100,0,0,0,ledon(i)+800);%(i,j,k));
            end
            
            % Data Acquisition immediately after fixation LED exinction
%             fprintf(fid,'%s\t\t\t\t\t%d\t%d\n','Acq',1,ledon(i,j,k));
            % Sound on
            fprintf(fid,'%s\t%d\t%d\t%d\t%d\t%d\t%d\n',...
                'Snd1',theta(i),phi(i),id(1,i),int(i),1,ledon(i)+sndon(i));
%                 'Snd1',theta(i,j,k),phi(i,j,k),id(i,j,k),int(i,j,k),1,ledon(i,j,k)+sndon(i,j,k));
            % Sound2 on 
            fprintf(fid,'%s\t%d\t%d\t%d\t%d\t%d\t%d\n',...
                'Snd2',theta(i),phi(i)-1,id(2,i),int(i),1,ledon(i)+sndon(i));
%                 'Snd2',theta(i,j,k),phi(i,j,k)-1,000,int(i,j,k),1,ledon(i,j,k)+sndon(i,j,k));
            % Snd2	-30	13	000	50	1	500	
            % Data collection
            fprintf(fid,'%s\t\t\t\t\t%d\t%d\n',...
                'Inp1',1,ledon(i)+sndon(i));
%                 'Inp1',1,ledon(i,j,k)+sndon(i,j,k));
            fprintf(fid,'%s\t\t\t\t\t%d\t%d\n',...
                'Inp2',1,ledon(i)+sndon(i));
%                 'Inp2',1,ledon(i,j,k)+sndon(i,j,k));
            % Inp1					1	500	
            % Inp2					1	500	
            
%             
%             if ~isempty(dummy)
%                 if ismember(n,dtrials)
%                     fprintf(fid,'\n');
%                     fprintf(fid,'%s\n','==>');
%                     fprintf(fid,'%s\t%d\t%d\t \t%d\t%d\t%d\t%d\t%d\n','LED',dummy(i,j,k),12,0,0,0,0,0);
%                 end
%             end
%         end
%     end
end
fclose(fid);
