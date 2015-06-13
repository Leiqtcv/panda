function [agol,bgol]= golay(npts)
% GOLAY.M -- Generate a pair of Golay codes
% each of length npts.
%
% USAGE: [acode bcode]= golay(npts)

m= log(npts)/log(2);

agol= [1 1 1 -1];
bgol= [1 1 -1 1];

for loop= 2:m-1,
	dum= agol;
	agol= [dum bgol];
	bgol= [dum -bgol];
end
