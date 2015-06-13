%% Calibrate

% HEAD

if exist('HeadCalNetFile','var')==1
    % several network types
    switch HeadCalNetFile
        case {
                'D:\HumanMatlab\Tom\NET\simple.net'
                }
            InC				= [1 2];
            
            In				= CUR_pt(InC,:);
            In				= In./LogHeadRange(InC)';
            HeadCalAz_pt	= sim(HeadNet.AzNet,In);
            HeadCalEl_pt	= sim(HeadNet.ElNet,In);
            In				= CUR_tr(InC,:);
            if ~isempty(In)
                In				= In./repmat(LogHeadRange(InC),size(In,2),[])';
            end
            HeadCalAz_tr	= sim(HeadNet.AzNet,In);
            HeadCalEl_tr	= sim(HeadNet.ElNet,In);
            
            % simulate in micro
            [str msg] = micro_NNSim(com, -1);
            if ~isempty(str)
                vec = str2num(str);
                HeadCalAz_micro	= vec(4);
                HeadCalEl_micro	= vec(5);
            else
                disp('no simulation')
                HeadCalAz_micro	= NaN;
                HeadCalEl_micro	= NaN;
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
                'D:\HumanMatlab\Tom\NET\headcoil.net'
                }
            InC				= HeadNet.InpChan;
            
            In				= CUR_pt(InC,:);
            In				= In./LogHeadRange(InC)';
            
            HeadCalAz_pt	= sim(HeadNet.AzNet,In);
            HeadCalEl_pt	= sim(HeadNet.ElNet,In);
            
            In				= CUR_tr(InC,:);
            if ~isempty(In)
                In				= In./repmat(LogHeadRange(InC),size(In,2),[])';
            end
            HeadCalAz_tr	= sim(HeadNet.AzNet,In);
            HeadCalEl_tr	= sim(HeadNet.ElNet,In);
            
            % if exist('HFtemp','var')~=1
            %     HFtemp = figure;
            %     HAXtemp1 = subplot(211);
            %     HAXtemp2 = subplot(212);
            %     BUFt = nan(100,1);
            %     BUFin = nan(100,3);
            %     BUFazel = nan(100,2);
            %     tmpcnt = 0;
            % end
            %
            % if tmpcnt <= 100
            %     tmpcnt = tmpcnt + 1;
            %     BUFt(tmpcnt) = tmpcnt;
            %     BUFin(tmpcnt,:) = In(:,end);
            %     BUFazel(tmpcnt,1) = HeadCalAz_tr(end);
            %     BUFazel(tmpcnt,2) = HeadCalEl_tr(end);
            %     BUF2azel(tmpcnt,1) = HeadCalAz_pt(end);
            %     BUF2azel(tmpcnt,2) = HeadCalEl_pt(end);
            % else
            %     tmpcnt = tmpcnt + 1;
            %     BUFt(1:99) = BUFt(2:100);
            %     BUFin(1:99,:) = BUFin(2:100,:);
            %     BUFazel(1:99,:) = BUFazel(2:100,:);
            %     BUFt(100) = tmpcnt;
            %     BUFin(100,:) = In(:,end);
            %     BUFazel(100,1) = HeadCalAz_tr(end);
            %     BUFazel(100,2) = HeadCalEl_tr(end);
            %     BUF2azel(tmpcnt,1) = HeadCalAz_pt(end);
            %     BUF2azel(tmpcnt,2) = HeadCalEl_pt(end);
            % end
            % plot(BUFt,BUFin,'.','parent',HAXtemp1)
            % plot(BUFt,BUFazel,'.','parent',HAXtemp2)


            % simulate in micro
            [str msg] = micro_NNSim(com, -1);
            if ~isempty(str)
                vec = str2num(str);
                HeadCalAz_micro	= vec(4);
                HeadCalEl_micro	= vec(5);
            else
                disp('no simulation')
                HeadCalAz_micro	= NaN;
                HeadCalEl_micro	= NaN;
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
                CUR_micro = CUR_micro*LogHeadRange;

            else
                warning('Failed to read simulated data from MicroCtrl')
            end
            
           
            
            
        case {
                'linearfit'
                }
            HeadCalAz_pt = CUR_pt(1)*9;
            HeadCalEl_pt = CUR_pt(2)*9;
            HeadCalAz_tr = CUR_tr(1,:)*9;
            HeadCalEl_tr = CUR_tr(2,:)*9;
            HeadCalAz_micro = NaN;
            HeadCalEl_micro = NaN;
        otherwise
            %warning(['[' HeadCalNetFile '] does not exist.'])
            HeadCalAz_pt = NaN;
            HeadCalEl_pt = NaN;
            HeadCalAz_micro	= NaN;
            HeadCalEl_micro	= NaN;
            HeadCalAz_tr = NaN;
            HeadCalEl_tr = NaN;
    end
else
    HeadCalAz_pt = NaN;
    HeadCalEl_pt = NaN;
    HeadCalAz_micro	= NaN;
    HeadCalEl_micro	= NaN;
    HeadCalAz_tr = NaN;
    HeadCalEl_tr = NaN;
end
