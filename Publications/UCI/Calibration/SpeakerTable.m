% SpeakerTable -- MUX to Speaker assignment tables for the human lab with
%   the chair in the center of the booth. Should calibrate with the
%   mic oriented orthogonal to the horizontal plane (Cn.DirectIncidence= 0)

Cn.DAC1SpkrTable= [    % this must match the current patch panel connections
     1  -180
     2  -160
     3  -140
     4  -120
     5  -100
     6   -80
     7   -60
     8   -50
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
    22    50
    23    60
    24    80
    25   100
    26   120
    27   140
    28   160
    29   990
    30  1010
    31  1020
    32  1030]; % elevations on the vertical hoop are given as 1000 + elevation
Cn.DAC2SpkrTable=  [
    1   -180
    2    -80
    3    -40
    4      0
    5     40
    6     80];
    