function [FULLFILE, FILTERINDEX]=uigetfullfile(FILTERSPEC, TITLE)

% function [FULLFILE, FILTERINDEX]=uigetfullfile(<FILTERSPEC>, <TITLE>)
%
%   [FILENAME, PATHNAME, FILTERINDEX] = uigetfile(FILTERSPEC, TITLE);
%   FULLFILE=[PATHNAME,FILENAME];
%
% tomg Mar 2007


if nargin<2
    TITLE='';
end
if nargin<1
    FILTERSPEC='*.*';
end


[FILENAME, PATHNAME, FILTERINDEX] = uigetfile(FILTERSPEC, TITLE);

FULLFILE=[PATHNAME,FILENAME];