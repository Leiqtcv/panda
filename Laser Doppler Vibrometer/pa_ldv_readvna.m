function data = pa_ldv_readvna(fname)
% DATA = PA_LDV_READVNA(FNAME)
%
% Read Laser Doppler Vibrometer data from VNA-file FNAME.
%

% 2012 University of Twente
% Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
pa_fcheckexist(fname);
load(fname, '-mat') % Load vna data structure
disp(['Extracting data from: ',fname,''])

%% Channels
F  = 1;    % Force [N] --> input channel (reference)
s  = 2;    % Laser [m/s]
a1 = 3;    % Acceleration location 1 [ms^-2]
a2 = 4;    % Acceleration location 2 [ms^-2]

%% Read data
data.freq   = SLm.fdxvec.';              % Frequency vector
data.t      = SLm.tdxvec.';              % Time vector
data.sample = 'sampletitle';             % Sample measurement title
data.nChan   = size(SLm.clist,2);         % Number of used Channels
data.navg   = SLm.navg.';                % Number of averages

%% Channel 1 - F: Force [N] (ingang + referentie)
data.eu.F		= SLm.scmeas(F).eu_val;      % Engineering unit reference  
data.time.F	= SLm.scmeas(F).tdmeas;      % F in de tijd
data.aspec.F	= SLm.scmeas(F).aspec;    % Autospectrum

%% Channel 2 - s: Laser [m/s]
if numel(SLm.scmeas(s).tdmeas) ~= 0
    data.xfer.s   = SLm.xcmeas(F,s).xfer;  % Overdrachtsinformatie
    data.time.s   = SLm.scmeas(s).tdmeas;  % Versnelling 1 in tijd 
    data.coh.s    = SLm.xcmeas(F,s).coh;   % Coherentie
    data.eu.s		= SLm.scmeas(s).eu_val;  % Engineering unit
    data.aspec.s	= SLm.scmeas(s).aspec;    % Autospectrum
    data.cspec.s	= SLm.xcmeas(F,s).cspec;    % Cross spectrum
end

%% Channel 3 - a1: Acceleration location 1 [ms^-2]
if numel(SLm.scmeas(a1).tdmeas) ~= 0
    data.xfer.a1  = SLm.xcmeas(F,a1).xfer;  % Overdrachtsinformatie
    data.time.a1  = SLm.scmeas(a1).tdmeas;  % Versnelling 1 in tijd 
    data.coh.a1   = SLm.xcmeas(F,a1).coh;   % Coherentie
    data.eu.a1   = SLm.scmeas(a1).eu_val;  % Engineering unit
    data.aspec.a1 = SLm.scmeas(a1).aspec;    % Autospectrum
    data.cspec.a1 = SLm.xcmeas(F,a1).cspec;    % Cross spectrum
end

%% Channel 4 - a2: Acceleration location 2 [ms^-2]
if numel(SLm.scmeas(a2).tdmeas) ~= 0
    data.xfer.a2  = SLm.xcmeas(F,a2).xfer;  % Overdrachtsinformatie
    data.time.a2  = SLm.scmeas(a2).tdmeas;  % Versnelling 1 in tijd 
    data.coh.a2   = SLm.xcmeas(F,a2).coh;   % Coherentie
    data.eu.a2   = SLm.scmeas(a2).eu_val;  % Engineering unit
    data.aspec.a2 = SLm.scmeas(a2).aspec;    % Autospectrum
    data.cspec.a2 = SLm.xcmeas(F,a2).cspec;    % Cross spectrum
end

% Apply engineering units xfer=xfer*EU(response)/EU(reference)
% if SLm.scmeas(p1).eu_on_off==1
%    Hp2p1=Hp2p1/SLm.scmeas(p1).eu_val;
%    Hp3p1=Hp3p1/SLm.scmeas(p1).eu_val;
%   Hp4p1=Hp4p1/SLm.scmeas(p1).eu_val;
% end
% if SLm.scmeas(p2).eu_on_off==1
%    Hp2p1=Hp2p1*SLm.scmeas(p2).eu_val;
% end
% if SLm.scmeas(p3).eu_on_off==1
%    Hp3p1=Hp3p1*SLm.scmeas(p3).eu_val;
% end
% if SLm.scmeas(p4).eu_on_off==1
%    Hp4p1=Hp4p1*SLm.scmeas(p4).eu_val;
% end


%figure(1); hold on; box on;
%l1(1)=plot(freq,abs(Hp1p1),clr(1)); 
%l1(2)=plot(freq,abs(Hp2p1),clr(2)); 
%l1(3)=plot(freq,abs(Hp3p1),clr(3)); 
%l1(4)=plot(freq,abs(Hp4p1),clr(4)); 

%set(l1,'LineWidth',1); set(gca,'YScale','log');
%xlabel('Frequency [Hz]'); ylabel('|H_{pp}| [Pa s m^{-1}]');
%legend('Hp1p1','Hp2p1','Hp3p1','Hp4p1');

%%%%%

%figure(2);  hold on; box on;
%l2(1)=plot(freq,angle(Hp1p1),clr(1)); 
%l2(2)=plot(freq,angle(Hp2p1),clr(2)); 
%l2(3)=plot(freq,angle(Hp3p1),clr(3)); 
%l2(4)=plot(freq,angle(Hp4p1),clr(4)); 

%set(l2,'LineWidth',1);
%xlabel('Frequency [Hz]'); ylabel('\angle H_{pp} [rad]');
%legend('Hp1p1','Hp2p1','Hp3p1','Hp4p1');

%%%%%

%figure(3);  hold on; box on;
%l3=plot(freq,TL,clr(1)); 

%set(l3,'LineWidth',1);
%xlabel('Frequency [Hz]'); ylabel('Transmission loss [-]');