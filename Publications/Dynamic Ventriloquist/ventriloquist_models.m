function ventriloquist_models
% Updating mean and variance of the likelihood of a Ts distribution
close all
clear all
clc

models2;

function models2
gradflag = 0;
figure

Ts		= -30:15:30; % Ts-in-space
Ds		= -15:15:15; % spatial disparity
Es		= -15:15:15; % Initial Es-in-space

[Ts,Ds,Es] = ndgrid(Ts,Ds,Es);

Ts		= Ts(:);
Ds		= Ds(:);
D		= Ds;
Ds		= Ts+Ds; % Distractor-in-space
Es		= Es(:);

n		= 20;
Ts		= repmat(Ts,n,1);
Ds		= repmat(Ds,n,1);
D		= repmat(D,n,1);
Es		= repmat(Es,n,1);



%% Initial
a	= 1; % gain
c	= 0.5; % integration
b	= 0; % hybrid
De	= Ds-Es;
Te	= Ts-b*Es;
Re	= Te+c*(De-Te);
Re	= a*Re;
Rs	= Re+Es;
uD	= unique(D);
uE	= unique(Es);
nE	= numel(uE);
nD	= numel(uD);
mu	= NaN(nE,nD);
Em	= mu;
Dm	= mu;
for ii = 1:nE
	for jj = 1:nD
		sel = Es==uE(ii) & D==uD(jj);
		x = Ts(sel);
		y = Rs(sel);
		b = regstats(y,x,'linear','beta');
		mu(ii,jj) = b.beta(1);
		Em(ii,jj) = uE(ii);
		Dm(ii,jj) = uD(jj);
	end
end
uE = uE';
uD = uD';
mu = mu';
subplot(121);
imagesc(uE,uD,mu);


a	= 1; % gain
c	= 0.5;
b	= 1;
De	= Ds-Es;
Te	= Ts-b*Es;
Re	= Te+c*(De-Te);
Re	= a*Re;
Rs = Re+Es;
uD	= unique(D);
uE	= unique(Es);
nE	= numel(uE);
nD	= numel(uD);
mu	= NaN(nE,nD);
Em	= mu;
Dm	= mu;
for ii = 1:nE
	for jj = 1:nD
		sel = Es==uE(ii) & D==uD(jj);
		x = Ts(sel);
		y = Rs(sel);
		b = regstats(y,x,'linear','beta');
		mu(ii,jj) = b.beta(1);
		Em(ii,jj) = uE(ii);
		Dm(ii,jj) = uD(jj);

	end
end
uE = uE';
uD = uD';
mu = mu';
subplot(122);
imagesc(uE,uD,mu);


x = -15:15:15;
for ii = 1:2
	subplot(1,2,ii)
	axis square;
	colormap gray;
	% mx = max(abs(B(:)));
	% caxis([-mx mx]);
% 	caxis([0 1]);
	colorbar
	colormap gray
	hold on
	set(gca,'XTick',x,'YTick',x);
	set(gca,'YDir','normal','TickDir','out');
	% xlabel('Eye position (deg)');
	% ylabel('Distracter position (deg)');
end

pa_datadir;
print('-depsc','-painter',mfilename);
