function Signal = pa_equalizer(x, filtname)
%  PA_EQUALIZER(X, FILTFILE)
%
%    Equalizing filtering of time sequence.
%
%    SIGNAL - Time sequence
%    FILTFILE - File name of the mat-file containing the filter (default:
%    visaton_equalizer.mat)
%
% See also FIR2, FILTFILT, PA_VISATON_EQUALIZER

% 2013 Marc van Wanrooij

%% Initialization
pandadir ='E:\MATLAB\PANDA';
if ~exist(pandadir,'dir');
	pandadir ='D:\MATLAB\PANDA';
	if ~exist(pandadir,'dir');
		pandadir ='C:\MATLAB\PANDA';
	end
end
if nargin<2
	filtname = [pandadir '\Donders\Setups\supplementary\visaton_equalizer.mat'];
% 	filtname = fcheckexist(filtname);
end
filtname = '/Users/marcw/MATLAB/PandA/Donders/Setups/supplementary/visaton_equalizer.mat';
load(filtname);
Signal      = filtfilt (b, 1, x);
