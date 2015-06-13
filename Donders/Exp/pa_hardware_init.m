% PA_HARDWARE_INIT
%
% Initializes hardware
%
% 1 Initialize Microcontroller
% 2 Initialize TDT: zBUS, RP2_1, RP2_2, RA16
% Perhaps to be implemented: 3 Test led sky, speakers & dig oputputs

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

fprintf('\tInitialize Hardware\n');

%% Initialize Microcontroller
pa_micro_init; % Do not forget to close com: >> close(com)

%% Initialize TDT
pa_tdt_init;

%% End comment
fprintf('\t------------------------------\n');
fprintf('\tInitializing Hardware FINISHED\n');

