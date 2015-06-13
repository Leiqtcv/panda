%
% function [str msg]=NN_ini(A,source,orientation,channels,model,stdp,stdt)
% [str msg] = NN_ini(com,'head','elevation',[1 2 3 4 5 6],net,strdp,stdt)
% A           = 232 class
% source      = 'head' or 'eye'
% orientation = 'elvation' or 'azimuth'
% channels    = used ADC inputs
% model       = net 
% stdp        = input scaling (mapminmax)
% stdt        = output scaling (mapminmax)
%
function [str msg] = NN_ini(A,source,orientation,channels,model,stdp,stdt)
    if (strcmp(source,'head'))
        if (strcmp(orientation,'azimuth'))
            %set parameters head/azimuth
            src = 0;
            ori = 0;
        else
            %set parameters head/elevation
            src = 0;
            ori = 1;
        end
    else
        if (strcmp(orientation,'azimuth'))
            %set parameters eye/azimuth
            src = 1;
            ori = 0;
        else
            %set parameters eye/elevation
            src = 1;
            ori = 1;
        end
    end
    
    iw = model.iw{1,1};
    lw = model.lw{2,1};
    bh = model.b{1};
    bo = model.b{2};
    nn = size(iw,2);
    nh = size(iw,1);
    sci(nn) = 0;
    for n=1:nn
        sci(n,1) = (stdp.ymax-stdp.ymin)/(stdp.xmax(n)-stdp.xmin(n));
        sci(n,2) = sci(n,1)*(-stdp.xmin(n))+stdp.ymin;
    end

    sco(1) = (stdt.xmax-stdt.xmin)/(stdt.ymax-stdt.ymin);
    sco(2) = sco(1)*(-stdt.ymin)+stdt.xmin;

    data(1) = cmdNNMod;
    data(2) = src;
    data(3) = ori;
    data(4) = nn;
    data(5) = nh;
    index = 6;
    for i=1:nn
        for n=1:nh
            data(index) = iw(n,i);
            index = index + 1;
        end
    end
    for n=1:nh
        data(index) = lw(n);
        index = index + 1;
    end
    for n=1:nh
        data(index) = bh(n);
        index = index + 1;
    end
    data(index) = bo(1);
    index = index + 1;
    for n=1:nn
        data(index)   = sci(n,1);
        data(index+1) = sci(n,2);
        index = index + 2;
    end
    data(index)   = sco(1);
    data(index+1) = sco(2);
    index = index + 2;
    for n=1:nn
        data(index)   = channels(n);
        index = index + 1;
    end
    data = 1000*data;
    % 
    [str msg] = serialport(3, data, get(A,'timeout'));

