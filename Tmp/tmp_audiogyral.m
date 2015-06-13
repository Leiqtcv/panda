function tmp_audiogyral
clc
close all hidden;
clear all hidden;

load('DataForMarc');
% keyboard
Y = [];
X = [];
E = [];
for ii = 1:4
	data = DataForMarc(ii).data;
	indx = [1 2 3 4];
	data = data(indx,:);
	roll = DataForMarc(ii).rollAngles;
	m	= repmat(mean(data,2),1,size(data,2));
	data = data-m;
	data = 2*data;
	% 		roll2	= repmat(roll,1,size(data,1));
	% 		Y		= [Y;data(:)];
	% 		X		= [X;roll2(:)];
	% 		exp		= repmat(ii,size(data(:)));
	% 		E		= [E;exp];
	% 		mu		= mean(data);
	% 		sd		= std(data);
	
	mu		= mean(data);
	sd		= std(data);
	Y = [Y;mu(:)];
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
u		= -0.9;
k		= 10;
v		= 0.1;
beta0	= [u k v];

options		= statset('Display','iter');
beta		= nlinfit(X,Y,@modelfun,beta0,options);
for ii = 1:4
	roll	= DataForMarc(ii).rollAngles;
	exp		= repmat(ii,size(roll));

	y		= modelfun(beta,[roll exp]);
% 	y0		= modelfun(beta0,[roll exp]);
	
	subplot(2,2,ii)
	h = plot(roll,y,'r-');
	set(h,'LineWidth',2,'MarkerFaceColor','w');
% 	plot(roll,y0,'k-','Color',[.7 .7 .7],'LineWidth',2);
	
	
end
str = {['u = ' num2str(beta(1),2)];['v = ' num2str(beta(3),2)];['k = ' num2str(beta(2),2)]};
pa_text(0.6,0.1,str);

% return

%% Per subject

Y = [];
X = [];
E = [];
S = [];
for ii = 1:4
	data = DataForMarc(ii).data;
	m	= repmat(mean(data,2),1,size(data,2));
	data = data-m;
	roll = DataForMarc(ii).rollAngles;
	
	roll2	= repmat(roll,1,size(data,1));
	Y		= [Y;data(:)];
	X		= [X;roll2(:)];
	exp		= repmat(ii,size(data(:)));
	sub		= repmat((1:size(data,1)),length(roll),1);
	E		= [E;exp];
	S		= [S;sub(:)];
	mu		= mean(data);
	sd		= std(data);
	
end
X		= [X E S]

for jj = 1:4
	figure(jj+700);
	u		= -0.9;
	k		= 10;
	v		= 0.1;
	beta0	= [u k v];
	sel = X(:,3)==jj;
	beta		= nlinfit(X(sel,:),Y(sel),@modelfun,beta0);
	for ii = 1:4
		sel = X(:,3)==jj & X(:,2)==ii;
		data	= Y(sel,:);
		roll	= X(sel,1);
		exp		= X(sel,2);
		y		= modelfun(beta,[roll exp]);
		subplot(2,2,ii)
		h = plot(roll,y,'r-');
		hold on
		set(h,'LineWidth',2,'MarkerFaceColor','w');
		plot(roll,data,'k.','Color',[.7 .7 .7],'LineWidth',2);
		
		axis square;
		ylim([-15 15]);
		xlim([-150 150]);
		pa_horline;
		pa_verline;
		str = DataForMarc(ii).info;
		title(str);
		box off
	end
	str = {['u = ' num2str(beta(1),2)];['v = ' num2str(beta(3),2)];['k = ' num2str(beta(2),2)]};
	pa_text(0.6,0.1,str);
end
function y = modelfun(beta,x)
theta		= x(:,1);
exp			= x(:,2);
u			= beta(1);
v			= beta(3);
k			= beta(2);
rot			= u*(theta); % linear underestimation
trans		= -(k*cosd(90-abs(theta)));
% thetaworld	= v*sind(theta); % linear underestimation
thetaworld	= v*(theta); % linear underestimation

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


