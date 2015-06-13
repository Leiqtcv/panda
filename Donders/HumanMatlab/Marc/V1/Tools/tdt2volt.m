function V = tdt2volt(AD,range)

% TDT2VOLT(AD,<RANGE>) converts strange tdt output to volts
%
%       use TDT2VOLT(AD,10) when headstage is set to 10 Volt (DEFAULT).
%       This can also be 0.1 or 1 Volt

%% input & init
if nargin < 2
    range = 10;
end
Factor = 1618;
% V = ones(size(AD))*NaN;

%% main
switch range
    case 10
        Factor = Factor / 1;
    case .1
        Factor = Factor / 100;
    case 1
        Factor = Factor / 10;
end

V = AD.*Factor;

