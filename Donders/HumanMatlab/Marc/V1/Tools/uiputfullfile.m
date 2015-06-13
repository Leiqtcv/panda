function [FULLFILE, FILTERINDEX]=uiputfullfile(FILTERSPEC, TITLE)

% function [FULLFILE, FILTERINDEX]=uiputfullfile(<FILTERSPEC>, <TITLE>)
%
%   [FILENAME, PATHNAME, FILTERINDEX] = uiputfile(FILTERSPEC, TITLE);
%   FULLFILE=[PATHNAME,FILENAME];
%
% tomg Mar 2007


if nargin<2
    TITLE='';
end
if nargin<1
    FILTERSPEC='*.*';
end


[FILENAME, PATHNAME, FILTERINDEX] = uiputfile(FILTERSPEC, TITLE);

FULLFILE=[PATHNAME,FILENAME];