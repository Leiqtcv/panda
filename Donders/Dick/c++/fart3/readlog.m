fid = fopen('C:\dick\c++\fart3\log.txt','rt');
C = textscan(fid,'%s %f %f %f %f','Delimiter',';','CollectOutput',1);
fclose(fid);
C{1} 
%
C{2}