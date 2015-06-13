% PA_MICRO_INIT
%
% Initializes Microcontroller, checks and opens graphical monitor
%
% See also PA_MICRO_GLOBALS

% 2013 Marc van Wanrooij
% original: Dick Heeren
% e: marcvanwanrooij@neural-code.com


%% Global variables
pa_micro_globals;

%% Initialize Micro
timeout		= 100;
[com msg]	= rs232(115200,timeout);
ok			= false;
if msg(1) == 0
	ok = true; 
end
fprintf('\t***************************');
fprintf('\t\tInitialize Microcontroller\n');
if (~ok)
	error(sprintf('Initialize: error (%d)\n',msg(1))); %#ok<SPERR>
else
    fprintf('\t\tInitialize rs232: OK\n');
end

[info msg] = pa_micro_cmd(com, cmdInfo, '');
if (msg(1) == 0)
    fprintf('\t\tProgram name/version micro: %s\n',info);
else
	disp(['info [' info '] msg [' num2str(msg)  ']']);
	error('Reset micro controller and try again');
end
fprintf('\t***************************');
fprintf('\t\tInitialize Micro DONE\n');

fprintf('\t***************************');
fprintf('\t\tOpen IO bits monitor\n');
pa_micro_iobits_monitor
fprintf('\t***************************');
fprintf('\t\tOpen IO bits monitor DONE\n');