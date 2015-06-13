function [num] = rand_num(range)
%
% function [num] = rand_num(range)
% num is a random integer in the range[low high], 
%
% num = rand_num([1 12];
num = range(1)+fix(rand*(range(2)-range(1)+1));