%
% overloaded function for Matlab display()
%
function display(A)
    fprintf('\t***************************\n');
    if A.connected
        fprintf('\t.connected:\ttrue\n');
    else
        fprintf('\t.connected:\tfalse\n');
    end
    fprintf('\t.baudrate:\t%d\n',A.baudrate);
    fprintf('\t.timeout:\t%d\n',A.timeout);
    fprintf('\t***************************\n');
   
