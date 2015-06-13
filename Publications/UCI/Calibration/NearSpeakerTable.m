% NearSpeakerTable -- MUX to Speaker assignment tables for the human lab with
%   the chair at the center of the room. Should calibrate with the
%   mic pointed directly at 0,0 (Cn.DirectIncidence= 1). Note that azimuth
%   is limited to +/-40.

Cn.DAC1SpkrTable= [    % this must match the current patch panel connections
     9   -40
    10   -30
    11   -20
    12   -15
    13   -10
    14    -5
    15     0
    16     5
    17    10
    18    15
    19    20
    20    30
    21    40    
    29   990
    30  1010
    31  1020
    32  1030]; % elevations on the vertical hoop are given as 1000 + elevation
Cn.DAC2SpkrTable=  [
    3    -40
    4      0
    5     40];
    