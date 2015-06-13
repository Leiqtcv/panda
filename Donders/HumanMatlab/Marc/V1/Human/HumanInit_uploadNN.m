%% Load NNetwork into microctrl
fprintf('\t***************************');
fprintf('\t\tLoad neural networks and put into Microcontroller\n');
fprintf('\t\tLoad network files\n');

if exist('GazeCalNetFile','var')==1
    if exist(GazeCalNetFile,'file') ==2
        GazeNet = load(GazeCalNetFile,'-mat');
        [d,GazeNetName]=fileparts(GazeCalNetFile);
        if exist('GazeCalNetInputChans','var')~=1
            if (isfield(GazeNet,'hnetG') || isfield(GazeNet,'vnetG'))
                GazeNet.AzNet           = GazeNet.hnetG;
                GazeNet.ElNet           = GazeNet.vnetG;
                GazeCalNetInputChans    = GazeNet.InpChan;
            elseif (isfield(GazeNet,'AzNet') || isfield(GazeNet,'ElNet'))
                GazeCalNetInputChans    = GazeNet.InpChan;
            end
        end
    else
        warning(['[' GazeCalNetFile '] does not exist'])
        GazeNetName = '\itNot Exist\rm';
    end
else
    warning(['variable [GazeCalNetFile] does not exist'])
    GazeNetName = '\itNot Exist\rm';
end


if exist('HeadCalNetFile','var')==1
    if exist(HeadCalNetFile,'file') ==2
        HeadNet = load(HeadCalNetFile,'-mat');
        [d,HeadNetName]=fileparts(HeadCalNetFile);
        if exist('HeadCalNetInputChans','var')~=1
            if (isfield(HeadNet,'hnetH') || isfield(HeadNet,'vnetH'))
                HeadNet.AzNet           = HeadNet.hnetH;
                HeadNet.ElNet           = HeadNet.vnetH;
                HeadCalNetInputChans    = HeadNet.InpChan;
            elseif (isfield(HeadNet,'AzNet') || isfield(HeadNet,'ElNet'))
                HeadCalNetInputChans    = HeadNet.InpChan;
            end
        end
    else
        warning(['[' HeadCalNetFile '] does not exist'])
        HeadNetName = '\itNot Exist\rm';
    end
else
    warning(['variable [HeadCalNetFile] does not exist'])
    HeadNetName = '\itNot Exist\rm';
end

fprintf('\t\tUpload network to Microcontroller\n');
if exist('GazeNet','var')==1
    fprintf('\t\tGaze Azimuth [index: 0]\n');
    [str msg] = micro_NNMod(com, 0, GazeCalNetInputChans, GazeNet.AzNet);
    fprintf('\t\tGaze Elevation [index: 1]\n');
    [str msg] = micro_NNMod(com, 1, GazeCalNetInputChans, GazeNet.ElNet);
end

if exist('HeadNet','var')==1
    fprintf('\t\tHead Azimuth [index: 2]\n');
    [str msg] = micro_NNMod(com, 2, HeadCalNetInputChans, HeadNet.AzNet);
    fprintf('\t\tHead Elevation [index: 3]\n');
    [str msg] = micro_NNMod(com, 3, HeadCalNetInputChans, HeadNet.ElNet);
end

fprintf('\t***************************');
fprintf('\t\tLoad neural networks into Microcontroller DONE\n');


