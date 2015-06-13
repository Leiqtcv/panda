%
% function [str msg]=micro_NNMod(A,source,orientation,channels,model)
% [str msg] = NNMod(com,id,[1 2 3 4 5 6],net)
% com         = 232 class
% id          = 0..3
% channels    = used ADC inputs
% model       = net 
%
function [str msg] = micro_NNMod(com,id,channels,model)
    micro_globals;
    str = 'ok';
    msg(1)=0;

    iw = model.iw{1,1};
    lw = model.lw{2,1};
    bh = model.b{1};
    bo = model.b{2};
    nn = size(iw,2);
    nh = size(iw,1);
    mm = strcmpi(model.inputs{1}.processFcns,'mapminmax');
    stdp.xmin = model.inputs{1}.processSettings{mm}.xmin;
    stdp.xmax = model.inputs{1}.processSettings{mm}.xmax;
    stdp.ymin = model.inputs{1}.processSettings{mm}.ymin;
    stdp.ymax = model.inputs{1}.processSettings{mm}.ymax;
    mm = strcmpi(model.outputs{2}.processFcns,'mapminmax');
    stdt.xmin = model.outputs{2}.processSettings{mm}.xmin;
    stdt.xmax = model.outputs{2}.processSettings{mm}.xmax;
    stdt.ymin = model.outputs{2}.processSettings{mm}.ymin;
    stdt.ymax = model.outputs{2}.processSettings{mm}.ymax;
    for n=1:nn
        sci(n,1) = (stdp.ymax-stdp.ymin)/(stdp.xmax(n)-stdp.xmin(n));
        sci(n,2) = sci(n,1)*(-stdp.xmin(n))+stdp.ymin;
    end
    sco(1) = (stdt.xmax-stdt.xmin)/(stdt.ymax-stdt.ymin);
    sco(2) = sco(1)*(-stdt.ymin)+stdt.xmin;

    clear data;
    data(1) = 0;
    data(3) = id;
    data(4) = nn;
    data(5) = nh;
    pnt = 6;
    for n=1:size(channels,2)
        data(pnt) = channels(n);
        pnt = pnt + 1;
    end
    data(2) = pnt-1;
%    sum(data(3:pnt-1))
    [str msg] = put_array(com, cmdNNMod, data);             % 0
    for i=1:nn
        clear data;
        data(1) = 10+i;
        pnt = 3;
        for n=1:nh
            data(pnt) = iw(n,i);
            pnt = pnt + 1;
        end
        data(2) = pnt-1;
        [str msg] = put_array(com, cmdNNMod, data);         % 11->16
    end
    clear data;
    data(1) = 2;
    pnt = 3;
    for n=1:nh
        data(pnt) = lw(n);
        pnt = pnt + 1;
    end
    data(2) = pnt-1;
    [str msg] = put_array(com, cmdNNMod, data);             % 2
    clear data;
    data(1) = 3;
    pnt = 3;
    if ~isempty(bh)
        for n=1:nh
            data(pnt) = bh(n);
            pnt = pnt + 1;
        end
    else
        for n=1:nh
            data(pnt) = 0;
            pnt = pnt + 1;
        end
    end
    data(2) = pnt-1;
    [str msg] = put_array(com, cmdNNMod, data);             % 3
    clear data;
    data(1) = 4;
    if ~isempty(bh)
        data(3) = bo(1);
    else
        data(3) = 0;
    end
    pnt = 4;
    for n=1:nn
        data(pnt)   = sci(n,1);
        pnt = pnt + 1;
    end
    for n=1:nn
        data(pnt)   = sci(n,2);
        pnt = pnt + 1;
    end
    data(pnt)   = sco(1);
    data(pnt+1) = sco(2);
    data(2) = pnt;
%    sum(data(3:pnt))
    [str msg] = put_array(com, cmdNNMod, data);             % 4
 

