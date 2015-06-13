function pa_micro_close(com)
% PA_MICRO_CLOSE(COM)
%
% Close microcontroller COM port

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com

% Disconnect from instrument object, obj1.
fclose(com);

% Clean up all objects.
delete(com);

