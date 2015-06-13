function [X,yhat] = LFPremove50hz(x,Fs,method)
% X = LFPREMOVE50HZ(X,FS)
%
% X = LFPREMOVE50HZ(X,T)
%
%
% Remove 50 Hz noise ('brom' or 'line noise') from a signal X, by subtracting a fitted
% sine. Second input argument should be sampling frequency FS (hz) or a
% vector time of length(x) T (s).
%
% 2009 Marc van Wanrooij

if nargin<3
	method = 'sine';
end

if length(Fs)==1
	t = 1:length(x);
	t = t'/Fs;
	t = t(:)';
elseif length(Fs)>1
	t = Fs;
	t = t(:)';
end

switch method
	case 'sine'
		%% Initial Parameters

		%% Initial Parameters
		F			= 50; % Line Noise Frequency		
		% Estimate Phase and Magnitude by FFT
		S			= fft(x);
		M			= abs(S);
		P			= angle(S);
		f			= Fs.*((0:(length(x)-1))/length(x));
		% search for 50 Hz component (line noise)
		[~,indx]	= min(abs(f-F));
		P			= P(indx);
		M			= M(indx);
		A			= M/(length(x)/2);
		DC			= mean(x); % Offset
		beta0		= [A 2*pi*F P DC];
		

		%% Fit
		beta	= nlinfit(t,x',@sinfun,beta0);
		yhat	= sinfun(beta,t);

		%% Remove Fit
		X = x-yhat';
	case 'notch'
		x		= detrend(x);
		Norder	= floor(length(x)/3);
		m		= mod(Norder,2);
		if m
			Norder = Norder-1;
		end
		f		= [47 53];
		f       = f/(Fs/2);
		b		= fir1(Norder,f,'stop');
		X		= filtfilt(b, 1, x);
end