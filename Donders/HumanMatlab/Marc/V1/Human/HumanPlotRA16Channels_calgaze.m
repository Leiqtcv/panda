%% Calibrate

% GAZE

if exist('GazeCalNetFile','var')==1
    % several network types
    switch GazeCalNetFile
        case {
                'D:\HumanMatlab\Tom\NET\simple.net'
                }
            InC				= [1 2];
            
            In				= CUR_pt(InC,:);
            In				= In./LogHeadRange(InC)';
            GazeCalAz_pt	= sim(GazeNet.AzNet,In);
            GazeCalEl_pt	= sim(GazeNet.ElNet,In);
            In				= CUR_tr(InC,:);
            if ~isempty(In)
                In				= In./repmat(LogHeadRange(InC),size(In,2),[])';
            end
            GazeCalAz_tr	= sim(GazeNet.AzNet,In);
            GazeCalEl_tr	= sim(GazeNet.ElNet,In);
            
            % simulate in micro
            [str msg] = micro_NNSim(com, -1);
            if ~isempty(str)
                vec = str2num(str);
                GazeCalAz_micro	= vec(2);
                GazeCalEl_micro	= vec(3);
            else
                disp('no simulation')
                GazeCalAz_micro	= NaN;
                GazeCalEl_micro	= NaN;
            end
            
            % raw data from micro
            [str msg] = micro_NNSim(com,0);
            if ~isempty(str)
                vec = str2num(str);
                try
                    CUR_micro(InC)	= vec(InC+1);
                catch
                    CUR_micro(InC)	= nan;
                end
                CUR_micro = CUR_micro*LogHeadRange;
            else
                warning('Failed to read simulated data from MicroCtrl')
            end
        case {
                'D:\HumanMatlab\Tom\NET\gazecoil.net'
                }
            InC				= GazeNet.InpChan;
            
            In				= CUR_pt(InC,:);
            In				= In./LogHeadRange(InC)';
            GazeCalAz_pt	= sim(GazeNet.hnetH,In);
            GazeCalEl_pt	= sim(GazeNet.vnetH,In);
            In				= CUR_tr(InC,:);
            if ~isempty(In)
                In				= In./repmat(LogHeadRange(InC),size(In,2),[])';
            end
            GazeCalAz_tr	= sim(GazeNet.hnetH,In);
            GazeCalEl_tr	= sim(GazeNet.vnetH,In);
            
            % simulate in micro
            [str msg] = micro_NNSim(com, -1);
            if ~isempty(str)
                vec = str2num(str);
                GazeCalAz_micro	= vec(2);
                GazeCalEl_micro	= vec(3);
            else
                disp('no simulation')
                GazeCalAz_micro	= NaN;
                GazeCalEl_micro	= NaN;
            end
            
            % raw data from micro
            str = micro_cmd(com,cmdADC,'');
            if ~isempty(str)
                vec = str2num(str);
                try
                    CUR_micro(InC)	= vec(InC+1);
                catch
                    CUR_micro(InC)	= nan;
                end
            else
                warning('Failed to read simulated data from MicroCtrl')
            end
        otherwise
            %warning(['[' GazeCalNetFile '] does not exist.'])
            GazeCalAz_pt = NaN;
            GazeCalEl_pt = NaN;
            GazeCalAz_micro	= NaN;
            GazeCalEl_micro	= NaN;
            GazeCalAz_tr = NaN;
            GazeCalEl_tr = NaN;
    end
else
    GazeCalAz_pt = NaN;
    GazeCalEl_pt = NaN;
    GazeCalAz_micro	= NaN;
    GazeCalEl_micro	= NaN;
    GazeCalAz_tr = NaN;
    GazeCalEl_tr = NaN;
end
