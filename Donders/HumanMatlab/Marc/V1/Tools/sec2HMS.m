function [timestr] = sec2HMS(seconds)
    h = fix(seconds/3600);
    m = fix((seconds-3600*h)/60);
    s = mod(seconds,60);
    timestr = sprintf('%2dh:%2dm.%2ds',h,m,s);