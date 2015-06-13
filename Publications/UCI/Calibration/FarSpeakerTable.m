% FarSpeakerTable -- MUX to Speaker assignment tables for the human lab with
%   the chair at the far position. Should calibrate with the
%   mic pointed directly at 0,0 (Cn.DirectIncidence= 1). Note that azimuth
%   is limited to +/-30.

Cn.DAC1SpkrTable= [    % this must match the current patch panel connections
     7   -30
     8   -25
     9   -20
    10   -15
    11   -10
    12  -7.5
    13    -5
    14  -2.5
    15     0
    16   2.5
    17     5
    18   7.5
    19    10
    20    15
    21    20
    22    25
    23    30
    29   995
    30  1005
    31  1010
    32  1015]; % elevations on the vertical hoop are given as 1000 + elevation
Cn.DAC2SpkrTable=  [
    3    -20
    4      0
    5     20];
    