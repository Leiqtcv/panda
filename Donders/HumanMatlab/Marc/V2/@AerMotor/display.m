%
% overloaded function for Matlab display()
%
function display(A)
    fprintf('\t********************\n');
    fprintf('\t.handle:\t%8d\n',A.handle);
    fprintf('\t.speed:\t\t%8d\n',A.speed);
    fprintf('\t.position:\t%8.2f\n',A.position);
    fprintf('\t.target:\t%8.2f\n',A.target);
    fprintf('\t.error:\t\t%8d\n',A.error);
    fprintf('\t.wait:\t\t%8d\n',A.wait);
    fprintf('\t.busy:\t\t%8d\n',A.busy);
    fprintf('\t********************\n');
