function [Btn1,Btn2,dBtn1,dBtn2,resp,rt] = pa_fart_tdt_getresponse(DAT,BtnChnL,BtnChnR)

Btn1		= DAT(:,BtnChnL)*1618;
Btn2		= DAT(:,BtnChnR)*1618;
dBtn1		= diff(Btn1);
dBtn2		= diff(Btn2);

ind_answL	= find(dBtn1 > 2);
ind_answR	= find(dBtn2 > 2);

if ismember(max([ind_answL ind_answR]),ind_answL)
    disp('Interval 1')
    resp = 1;
    rt = max([ind_answL ind_answR]); % reactiontime (samples)
elseif ismember(max([ind_answL ind_answR]),ind_answR)
    disp('Interval 2')
    resp = 2;
    rt = max([ind_answL ind_answR]); % reactiontime (samples)
else 
	disp('Uh-Oh');
    resp = NaN;
    rt = NaN;
end

