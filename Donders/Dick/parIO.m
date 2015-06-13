%
%       parIO
%
%-> create
%
disp('--------------------------------------------------');
par = digitalio('parallel','LPT1');
disp(par);
%
%-> par information
%
disp('--------------------------------------------------');
info = daqhwinfo(par);
disp(info);
%
%-> each port information
%
disp('--------------------------------------------------');
for p=info.Port
    disp(p);
end
%
%-> bit 0..7  output
%-> bit 8..10 input
%
disp('--------------------------------------------------');
addline(par,0:7,'out')
addline(par,8:10,'in')
%
%-> turn bit 0 on for 2 seconds (trigger TDT3)
%
disp('--------------------------------------------------');
putvalue(par.Line(1),1);
pause(2);
putvalue(par.Line(1),0);
%
%-> read button (input bit 0)
%
cnt  = 0;
flag = 0;
while cnt < 10
    bar = getvalue(par.Line(9));
    if bar ~= flag
        if bar == 0
            cnt = cnt + 1;
            fprintf('Count = %d\n',cnt);
        end
        flag = bar;
    end
end
