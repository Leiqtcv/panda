function DF = askfilename

% function DF = askfilename
%
% asks for the filename (human style)
%


cTime   = now;
OK = false;
while OK == false
    % ask
    home
    sDF     = input('DataFile (e.g. XX-XX-2010-12-31-0001) > ','s');
    
    % process
    if isempty(sDF)
        
        % input is <CR>
        
        sDF1= input('                         Experimenter > ','s');
        sDF2= input('                              Subject > ','s');
        sDF3= input('            Date (format: 2010-12-31) > ','s');
        sDF4= input('               Exp. no (format: 0002) > ','s');
        
        DF = [sDF1 '-' sDF2 '-' sDF3 '-' sDF4 '.dat'];
    
    elseif numel(sDF) == 5;
        
        % input is like "TG-TG"
        
        tDF = [sDF '-' datestr(cTime ,'yyyy-mm-dd') '-????.dat'];
        [d,str] = dos(['dir ' tDF ' /b']);
        if ~isempty(strfind(str,'File Not Found'))
            cIdx = 0000;
        else
            List = sscanf(str,'%s',[numel('XX-XX-2010-12-31-0001.dat'),inf])';
            disp('Already exist:')
            disp(List)
            Idx = List(:,end-7:end-4);
            cIdx = max(str2num(Idx)) + 1;
        end
        
        DF = [sDF '-' datestr(cTime ,'yyyy-mm-dd') '-' sprintf('%04.0f',cIdx) '.dat'];
    
    else
        
        % all other lengths
        
        if ~strcmpi(sDF(end-3:end),'.dat')
            
            % try to repair
            
            sDF = [sDF '.dat'];
        end
        
        if numel(sDF) ~= numel('XX-XX-2010-12-31-0001.dat');
            
            % input is strangely shaped
            
            disp('Warning! data file name is not according to convention')
        end
        
        DF = sDF;
    end
    
    % check
    disp(['Directory:        [' cd ']'])
    if strcmpi(DF(end-4),'0')
        disp(['CALIBRATION FILE: [' DF ']'])
    else
        disp(['Datafile:         [' DF ']'])
    end
    q = input('OK (<Yes>,no) ? > ','s');
    if isempty(q)
        OK = true;
    elseif strcmpi(q(1),'n')
        OK = false;
    end
end
viewallfigs