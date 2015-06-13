close all
clear all

%% Bimodal localization
n		= 1000; % Go to infinity
RMS		= NaN(n,1);
resptype = 1; % What type of response do you expect/want to model
for ii	= 1:n
	ntar	= 20; % number of targets
	tar		= pa_rndval(-75,75,[ntar,1]); % randomly chosen stimulus locations
	switch resptype
		case 1 % chance performance = randomly chosen response = percept
			res		= pa_rndval(-75,75,[ntar,1]); 
		case 2 % null response = no percept
			res		= zeros(ntar,1);
		case 3 % unilateral response = dominant percept
			res		= repmat(60,ntar,1);
		case 4 % lateralized response = bistable percept
			res		= 70*2*((tar>1)-0.5); 
		case 5 % unity-line response = localized percept
			res		= tar; 
	end
	res			= res+5*randn(ntar,1); % add some variabilty
	RMS(ii)		= rms(tar-res);
end

%% graphics
hist(RMS,0:120);
xlabel('RMS (deg)');
p = round(prctile(RMS,[5 50 95]));
title(p);
axis square;
box off
set(gca,'TickDir','out');
return

%% Example for  Dunn, Perreau, Gantz, Tyler: Benefits of Localization and Speech
% Perception
close all
clear all
n = 1000; % Go to infinity
RMS = NaN(n,1);
for ii = 1:n
	loc = linspace(-54,54,8); % target location
	nsounds = 16;
	nrep = 6;
	% speaker number
	tar = pa_rndval(1,8,[nsounds*nrep,1]); % random target
	res = pa_rndval(1,8,[nsounds*nrep,1]); % chance response
	% res = repmat(8,size(res));
	% location
	tar = loc(tar);
	res = loc(res);
	
	RMS(ii) = rms(tar-res);
end



% plot(tar,res,'.')
% axis square;
% axis([-60 60 -60 60]);
% title(RMS)

hist(RMS,20:80);
xlabel('RMS (deg)');