    vel = 10; %16;              
    dens = 0; %1.8;             % Ripple frequency (cyc/oct)
    mod = 100;              % Modulation depth (%)
    durstat = 1000;         % Duration static (Target fixed+random)
    durrip = 1000;          % Duration ripple (Target changed)
    F0      = 250;          % Carrier Frequency
    Nfreq   = 126;          % Number of components
    PhiF0   = pi/2;         % Ripple phase at F0
    Rate = 20000;           % Sample Rate
%
 SampleRate = 25000; 
%
tic;
    RippleError = 0;
    Nrip        = (durrip/1000)*SampleRate; Nrip = round(Nrip);
    Nstat       = (durstat/1000)*SampleRate; Nstat = round(Nstat);
    durtot      = durrip+durstat;
    Ntot        = (durtot/1000)*SampleRate; Ntot = round(Ntot);
    Time        = ((1:Ntot)-1)/SampleRate;
    mod         = mod/100;
    % According to Depireux et al. (2001)
    Phi = pi - 2*pi*rand(1,Nfreq);     % Random ripple phase
    Phi(1)  = PhiF0;                       % Ripple phase at F0
    FreqNr  = 0:1:Nfreq-1;
    Freq    = F0 * 2.^(FreqNr/20);
    Oct     = FreqNr/20;
    % octaves above the ground frequency
                                % semitones kleiste stap tussen 2 
                                   % opeenvolgende tonen
                                   % 72 semitones is gelijk aan 6 octaven
    normSTIM(1) = 0;
    % generating the ripple
    % amplitudes completely dynamic without static
    %

    % => 0.273808
    a = 2*pi*vel;
    b = 2*pi*dens;
    
    sina = sin(a*Time);  % 40000
    cosa = cos(a*Time);
    sinb = sin(b*Oct);   % 126
    cosb = cos(b*Oct);
    RAWamp(Nfreq,Ntot) = 0; % 126*40000

    for i=1:Nfreq
        RAWamp(i,:) = 1 + mod*(sina(:)*cosb(i)+cosa(:)*sinb(i));
    end

    RAWamp(:,1:Nstat) = 1;

    carr(Nfreq,Ntot) = 0;
    for i=1:Nfreq
        carr(i,:) = sin(2*pi* Freq(i) .* Time(:) + Phi(i));
    end

    stim = RAWamp.*carr; 
    
    STIM = sum(stim);
    Mx1  = max(STIM);
    Mx2  = abs(min(STIM));
    mx   = max(Mx1,Mx2);
    STIM = STIM/(1.05*mx); % normalized to an absolute peak of about 0.95

    rms_stat=norm(STIM(1:Nstat)/sqrt(Nstat));
    
    rms_rip=norm(STIM(Nstat+1:Nstat+Nrip)/sqrt(Nrip));
    ratio=rms_stat/rms_rip;

    normSTIM=[STIM(1:Nstat) ratio*STIM(Nstat+1:Nstat+Nrip)];

    sound(normSTIM, SampleRate); 
toc;