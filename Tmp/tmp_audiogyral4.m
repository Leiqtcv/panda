function tmp_audiogyral2

%% Initialization
clc
close all hidden;
clear all hidden;

k		=0;
v		=0;
beta0	= [k v];


%% Load
load('DataForMarc');
figure(666)
getdat(DataForMarc,beta0)

% %%
% figure
% bar(B')
%%
function getdat(DataForMarc,beta0)
%% Analysis
Y = [];
X = [];
E = [];
for ii = 1:2
	data = DataForMarc(ii).data;

	roll = DataForMarc(ii).rollAngles;
	data = bsxfun(@minus,data',mean(data,2)')';
	
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
beta		= nlinfit(X,Y,@modelfun1,beta0(1),options);
for ii = 1:2
	roll	= DataForMarc(ii).rollAngles;
	exp		= repmat(ii,size(roll));
	y		= modelfun1(beta,[roll exp]);
	
	subplot(2,2,ii)
	h = plot(roll,y,'r-');
	set(h,'LineWidth',2,'MarkerFaceColor','w');
end
str = {['Translation = ' num2str(beta(1),1) ' deg']};
pa_text(0.6,0.1,str);

%% Analysis
Y = [];
X = [];
E = [];
for ii = 3:4
	data = DataForMarc(ii).data;

	roll = DataForMarc(ii).rollAngles;
	data = bsxfun(@minus,data',mean(data,2)')';
	
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
beta		= nlinfit(X,Y,@modelfun2,beta0,options);
for ii = 3:4
	roll	= DataForMarc(ii).rollAngles;
	exp		= repmat(ii,size(roll));
	y		= modelfun2(beta,[roll exp]);
	
	subplot(2,2,ii)
	h = plot(roll,y,'r-');
	set(h,'LineWidth',2,'MarkerFaceColor','w');
end
str = {['Rotation = ' num2str(beta(2),2) ' deg'];['Translation = ' num2str(beta(1),1) ' deg']};
pa_text(0.6,0.1,str);


function y = modelfun1(beta,x)
theta		= x(:,1);
exp			= x(:,2);
t			= beta(1); % maximum translation (deg)
T		= (t*cosd(90-abs(theta))); % as a function of theta
% T = t.*theta;
y			= NaN(length(x),1);

o			= T.*sind(-theta);
a			= T.*cosd(-theta);

%% Head-fixed task AMP, head-fixed speaker
sel			= exp==1;
odprime		= a(sel).*tand(0);
oprime		= o(sel)
y(sel)		= oprime;
% y(sel)		= trans(sel).*sind(-theta(sel));
% y(sel) = -T(sel);

%% Head-fixed task AMP, world-fixed speaker
sel			= exp==2;
oprime		= T(sel).*tand(0);
y(sel)		= oprime;
% y(sel)		= trans(sel).*tand(-theta(sel));
% y(sel) = -T(sel)./tand(90-theta(sel));

function y = modelfun2(beta,x)
theta		= x(:,1);
exp			= x(:,2);
v			= beta(2);
k			= beta(1);
trans		= -(k*cosd(90-abs(theta)));
thetaworld	= v*sind(theta); % linear underestimation

y			= NaN(length(x),1);
T			= trans; % remove direction
o			= T.*sind(theta);
a			= T.*cosd(theta);

%% World-fixed task AEV, head-fixed speaker
sel			= exp==3;
oworld		= a(sel)./tand(90-thetaworld(sel));
oworld		= o(sel)-oworld;
oworld		= -oworld;
y(sel)		= oworld;

%% World-fixed task AEV, world-fixed speaker
sel			= exp==4;
oworld		= T(sel).*tand(thetaworld(sel));
oworld			= -oworld;
y(sel)		= oworld;
