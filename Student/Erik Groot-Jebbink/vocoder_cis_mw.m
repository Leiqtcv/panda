%% ####algemeen###
% Om fouten te vermijden:
% - Probeer de code 'groen' te maken
% - gebruik 0.5 ipv .5
% - gebruik ii ipv i
%
% - elseif of switch/case
% - initialiseren van matrixen
%
% Waarom wordt er geen gebruik gemaakt van filtfilt?
% Waarom hebben de kanalen geen overlap?
% Pulse rate?

clc;
clear all;
close all;
tic

%%
d = 'E:\MATLAB\PANDA\Student\Erik Groot-Jebbink'; % Directory Marc
cd(d);

[wave,fs]	= wavread('test_wav_kort.wav'); %laad bestand
d			= 0.5*fs; % om frequencies te schalen in filters
t			= (0:length(wave)-1)/fs; %tijds-as

%analyse filter
filter_start	= 400;%hz
filter_eind		= 7000; %hz
analyse_db_oct	= 24;
kanalen			= 8;


% envelope
envelope_db_oct			= 24;
envelope_cuttoff_freq	= 160;

%% Flags
green_wood		= 1; %1 = greenwood 0 = gewoon, lineair
ruis_sinus		= 0; % carrier kiezen, ruis = 0 sinus = 1
toon			= 1; % wel/niet tonen van figuren
speel			= 1;
hilbertFlag		= 0;

%% pre emphasize
% laag doorlaatfilter
a_pre			= [1 -0.95];
b_pre			= 1;

wavepre			= filter(b_pre,a_pre,wave); % MW:  filtfilt?
%% filter bank
w		= NaN(kanalen+1,1);
w(1)	= filter_start; %filter start
if green_wood == 1     %greenwood functie f =165.4(10^2.1x-0.88)
	A					= 165.4;
	j					= 2.1;
	k					= 0.88;
	lengte_cochlea		= 35; %mm
	x					= 0:0.01:lengte_cochlea;
	
	freq_greenwood		= A*(10.^(j*x/lengte_cochlea)-k);
	greenwood_id		= find(freq_greenwood >filter_start & freq_greenwood <filter_eind);
	grootte_interval	= round(length(greenwood_id)/kanalen);
	id = 0;
	for ii = 1:kanalen,
		id = id+grootte_interval;
		w(ii+1) = w(ii)+freq_greenwood(id);
	end
elseif green_wood == 0
	
	w_delta = (filter_eind-filter_start)/(kanalen);
	for ii=1:kanalen,
		w(ii+1) = (w(ii)+w_delta);
	end
end

%filterbank 3de order, stopband ripple 30Db.
a = NaN(kanalen,7);
b = a;
for ii=1:kanalen
	[b(ii,:) a(ii,:)] = cheby2(3,analyse_db_oct,[w(ii)/d w(ii+1)/d]); % kanaal 1 t/m kanalen
end

%% plot filter response
resolutie = 2^12; %2 macht is het beste, want FFT in freqz
f=(0:resolutie-1)*(fs/2)/resolutie;          %frequency as

if toon == 1
	figure(1)
	for ii=1:kanalen,
		h = freqz(b(ii,:), a(ii,:), resolutie, fs);    % kanaal 1 t/m kanalen
		nr		= num2str(ii);
		for jj = 1:2
			subplot(2,1,jj)
			plot(f, abs(h),'k');
			hold on;
		end
	end
	for jj = 1:2
		subplot(2,1,jj)
		xlabel('f (Hz)');
		ylabel('magnitude');
		titel	= 'Response van de filters';
		title(titel);
		xlim([filter_start filter_eind])
		ylim ([0 1.2]);
	end
	set(gca,'XScale','log','XTick',[500 1000 2000 4000 6000],'XTickLabel',[500 1000 2000 4000 6000]);
end

%% filter data per filterband

%filterbank 3de order, stopband ripple 30Db.
out = NaN(kanalen,size(wavepre,1));
for ii = 1:kanalen
	out(ii,:) = filter(b(ii,:), a(ii,:), wavepre(:,1)); % kanaal 1 t/m kanalen
end

%% plot gefilterd signaal

if toon == 1
	figure(2)
	for ii=1:kanalen,
		subplot(kanalen/2,2,ii);
		nr = num2str(ii);
		band_r = num2str(w(ii));
		band_l = num2str(w(ii+1));
		
		plot(t,out(ii,:),'k-');
		hold on;
		ylabel('Amplitude');
	end
	xlabel('t (s)');
end
%% rectify and envelope
switch hilbertFlag
	case 0
		[benv, aenv] = cheby2(8,envelope_db_oct,envelope_cuttoff_freq/d);
		out_rect = abs(out);
		envelope = NaN(size(out_rect));
		for ii	= 1:kanalen,
			envelope(ii,:) = filter(benv, aenv, out_rect(ii,:));
		end
	case 1
		envelope = NaN(size(out));
		for ii	= 1:kanalen,
			envelope(ii,:) = hilbert(out(ii,:));
		end
		envelope = abs(envelope);
end


%% plot rectified, low pass signaal
if toon == 1
	figure(2)
	for ii=1:kanalen,
		subplot(kanalen/2,2,ii);
		nr = num2str(ii);
		band_r = num2str(round(w(ii)));
		band_l = num2str(round(w(ii+1)));
		titel = ['kanaal ' nr ', freq band: ' band_r ' - ' band_l];
		
		plot(t,envelope(ii,:),'r-','LineWidth',2);
		title(titel);
		if ii == kanalen
			xlabel('t (s)');
		end
		ylabel('Amplitude');
	end
end
%% filter ruis en moduleer kanalen op noise of moduleer op sinus.

if ruis_sinus == 0 % moduleer op ruis
	% 	ruis		= wgn(length(wavepre),1,0);
	ruis = randn(1,length(wavepre));
	ruis_out	= NaN(size(ruis));
	for ii = 1:kanalen,
		ruis_out(ii,:) = filter(b(ii,:), a(ii,:), ruis); % kanaal 1 t/m kanalen
	end
	
	simulatie_cis = ruis_out.*envelope;
	
	% sommeer de banden
	simulatie_cis = sum(simulatie_cis,1);
elseif ruis_sinus == 1 % moduleer op sinus
	% genereer random fase
	fase = pi - 2*pi*rand(1,kanalen);
	
	% maak sinus op center freq van banden
	w_mean = NaN(length(w)-1,1);
	sinus = NaN(size(fase,2),size(t,2));
	for ii=1:length(w)-1
		w_mean(ii) = (w(ii)+w(ii+1))/2;
		sinus(ii,:) = sin(2*pi*t*w_mean(ii)+fase(ii));
	end
	
	sinus_out = NaN(size(sinus));
	for ii=1:kanalen,
		sinus_out(ii,:) = filter(b(ii,:), a(ii,:), sinus(ii,:)); % kanaal 1 t/m kanalen
	end
	simulatie_cis = sinus_out.*envelope;
	
	%sommeer de banden
	simulatie_cis = sum(simulatie_cis,1);
end
toc

if speel
	%% luister
	
	% vocoded
	soundsc(simulatie_cis,fs);
	% 'audioplayer' waarschijnlijk beter voor stimulus-presentatie
	
	% origineel
	soundsc(wave,fs);
end