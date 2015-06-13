function [S500,S1000,reac500,reac1000] = separate2active(spike)

% mn           = min(length(spike),length(beh));
% spike        = spike(1:mn);
% 
% beh          = beh(:,1:mn);
stmat        = [spike.stimvalues];
ststat       = stmat(3,:);
sel500       = ststat==500;
S500         = spike(sel500);
for ii       = 1:length(S500)
	[m,n]          = size(S500(ii).trial);
	S500(ii).trial = repmat(ii,m,n);
	S500(ii).trial;
end

% reac500      = beh(2,sel500);


sel1000      = ststat==1000;
S1000        = spike(sel1000);
for ii              = 1:length(S1000)
	[m,n]           = size(S1000(ii).trial);
	S1000(ii).trial = repmat(ii,m,n);
	S1000(ii).trial;
end

% reac1000      = beh(2,sel1000);