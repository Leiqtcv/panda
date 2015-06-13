function [DAT,Nsample,Nchan,Fs] = pa_fart_tdt_readdata(DatFile,RA16_1)
% DAT = PA_FART_TDT_READDATA(DATFILE,RA16_1)
%
% Read trial data
%

% Dick Heeren / Tom / Denise
% 2012 Modified: Marc van Wanrooij

%% Initialization
Nsample		= RA16_1.ReadTagV('NPtsRead',0,1); % Number of samples read by RA16 module
Fs		= RA16_1.ReadTagV('Freq',0,1); % Sample frequency (Hz) of RA16 module
CurDAT		= cell(1,2);

%% Read data
for ii = 1:2
    CurDAT(ii) = {RA16_1.ReadTagVEX(['Data_' num2str(ii*4)], 0, Nsample, 'F32', 'F64', 1)}; % cell in case # samples change per trial/channel
end
DAT			= cell2mat(CurDAT);

%% Write data
FID			= fopen(DatFile,'a'); % here we update/append the file
fwrite(FID,DAT,'double'); % or 'float'
fclose(FID); % close file

%% Resample
	Nchan	= round(length(DAT)/Nsample); % number of channels
	DAT		= reshape(DAT,Nsample,Nchan); % reshape to samples x channels

