function tmp_audiogyral2

%% Initialization
clc
close all hidden;
clear all hidden;

k		= 17;
v		=0;
beta0	= [k v];


%% Load
load('DataForMarc');
figure(666)
getdat(DataForMarc,beta0)

B = [];
for ii= 1:4
figure(ii)
indx = ii;
beta = getdatsingle(DataForMarc,beta0,indx)
B = [B;beta];
end
% keyboard
%%
figure
bar(B')
%%
function getdat(DataForMarc,beta0)
%% Analysis
Y = [];
X = [];
E = [];
for ii = 1:4
	data = DataForMarc(ii).data;
% 	indx = [1 2 3 4];
% 	data = data(indx,:);
	
	roll = DataForMarc(ii).rollAngles;
	data = bsxfun(@minus,data',mean(data,2)')';
	
	% 			roll2	= repmat(roll,1,size(data,1));
	% 			Y		= [Y;data(:)];
	% 			X		= [X;roll2(:)];
	% 			exp		= repmat(ii,size(data(:)));
	% 			E		= [E;exp];
	% 			mu		= mean(data);
	% 			sd		= std(data);
	
	mu		= mean(data);
	sd		= std(data);
	
	Y = [Y;mu(:)]; %#ok<*AGROW>
	X = [X;roll(:)];
	exp		= repmat(ii,size(mu(:)));
	E = [E;exp];
	
	subplot(2,2,ii)
	plot(roll,data,'Color',[.7 .7 .7]);
	hold on
	h = errorbar(roll,mu,sd,'ko-');
	set(h,'LineWidth',2,'MarkerFaceColor','w');
	axis square;
	ylim([-15 15]);
	xlim([-150 150]);
	pa_horline;
	pa_verline;
	str = DataForMarc(ii).info;
	title(str);
	box off
	

end

X		= [X E];
options		= statset('Display','iter');
beta		= nlinfit(X,Y,@modelfun,beta0,options);
for ii = 1:4
	roll	= DataForMarc(ii).rollAngles;
	exp		= repmat(ii,size(roll));
	y		= modelfun(beta,[roll exp]);
	
	subplot(2,2,ii)
	h = plot(roll,y,'r-');
	set(h,'LineWidth',2,'MarkerFaceColor','w');
end
str = {['Rotation = ' num2str(beta(2),2) ' deg'];['Translation = ' num2str(beta(1),1) ' deg']};
pa_text(0.6,0.1,str);

function beta = getdatsingle(DataForMarc,beta0,indx)
%% Analysis
Y = [];
X = [];
E = [];
for ii = 1:4
	data = DataForMarc(ii).data;
% 	indx = [1 2 3 4];
	data = data(indx,:);
	
	roll = DataForMarc(ii).rollAngles;
	data = bsxfun(@minus,data',mean(data,2)')';
	
	% 			roll2	= repmat(roll,1,size(data,1));
	% 			Y		= [Y;data(:)];
	% 			X		= [X;roll2(:)];
	% 			exp		= repmat(ii,size(data(:)));
	% 			E		= [E;exp];
	% 			mu		= mean(data);
	% 			sd		= std(data);
	
	mu		= data;
	
	Y = [Y;mu(:)]; %#ok<*AGROW>
	X = [X;roll(:)];
	exp		= repmat(ii,size(mu(:)));
	E = [E;exp];
	
	subplot(2,2,ii)
	plot(roll,data,'Color',[.7 .7 .7]);
	hold on
	axis square;
	ylim([-15 15]);
	xlim([-150 150]);
	pa_horline;
	pa_verline;
	str = DataForMarc(ii).info;
	title(str);
	box off
	

end

X		= [X E];
options		= statset('Display','iter');
beta		= nlinfit(X,Y,@modelfun,beta0,options);
for ii = 1:4
	roll	= DataForMarc(ii).rollAngles;
	exp		= repmat(ii,size(roll));
	y		= modelfun(beta,[roll exp]);
	
	subplot(2,2,ii)
	h = plot(roll,y,'r-');
	set(h,'LineWidth',2,'MarkerFaceColor','w');
end
str = {['Rotation = ' num2str(beta(2),2) ' deg'];['Translation = ' num2str(beta(1),1) ' deg']};
pa_text(0.6,0.1,str);

function y = modelfun(beta,x)
theta		= x(:,1);
exp			= x(:,2);
u			= -1;
v			= beta(2);
k			= beta(1);
rot			= u*(theta); % linear underestimation
trans		= -(k*cosd(90-abs(theta)));
% trans		= -(k*abs(theta));

thetaworld	= v*sind(theta); % linear underestimation
% thetaworld	= v*(theta); % linear underestimation

y = NaN(length(x),1);
T			= abs(trans); % remove direction
o			= T.*sind(theta);
a			= T.*cosd(theta);
thetaprime	= theta+rot;

%% Head-fixed task AMP, head-fixed speaker
sel = exp==1;
odprime		= a(sel).*tand(thetaprime(sel));
oprime		= o(sel)-odprime;
oprime		= -oprime; % introduce direction
y(sel)		= oprime;

%% World-fixed task AEV, head-fixed speaker
sel			= exp==3;
oworld		= a(sel)./tand(90-thetaworld(sel));
oworld		= o(sel)-oworld;
oworld		= -oworld;
y(sel)		= oworld;


%% Head-fixed task AMP, world-fixed speaker
sel			= exp==2;
oprime		= T(sel).*tand(thetaprime(sel));
oprime		= -oprime;
y(sel)		= oprime;

%% World-fixed task AEV, world-fixed speaker
sel			= exp==4;
oworld		= T(sel).*tand(thetaworld(sel));
oworld			= -oworld;
y(sel)		= oworld;


