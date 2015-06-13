function [A, msg] = pa_micro_rs232(varargin)
% [A, MSG] = PA_MICRO_RS232
%
% Constructor of class rs232
%

% Dick Heeren
% 2013 Marc van Wanrooij

switch nargin
	case 0
		A.baudrate	= 115200;
		A.timeout	= 1000;     % 1 sec
		A.connected = true;
		A			= class(A, 'rs232');
		[~, msg]	= serialport(0,[A.baudrate,A.timeout]);
	case 2
		A.baudrate	= varargin{1};
		A.timeout	= varargin{2};
		A.connected = false;
		A.connected = true;
		A			= class(A, 'rs232');
		[~, msg]	= serialport(0,[A.baudrate,A.timeout]);
	otherwise
		error('Invalid number of input arguments');
end
