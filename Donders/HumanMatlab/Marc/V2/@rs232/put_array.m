%
function [str msg] = put_array(A, cmd, data)
    str = sprintf('$%d;',cmd);
    for (i=1:size(data,2)-1)
        str = sprintf('%s%f ',str,data(i));
    end
    str = sprintf('%s%f\n',str,data(i+1));

    [str msg] = query2(A, str);
 
        

        

 