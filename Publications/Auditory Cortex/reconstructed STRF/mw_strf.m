function mw_strf
%
% function [strf,ACQ12,PhQ12]=strf1(DatFile, corr, hfshift, Nbin, Twindow);
%	Nbin: number of bins per period;
%	DatFile: data of ripplet tests (complete w-Om plane);
% 	corr: optional correction for ripples of 4+8k Hz, (2.5*(4+8k)-0.5)/2.5-> corr=0.2
%	hfshift: if not zero then STRF is shifted towards
%		version 1-'01
%
%       version 4-'06
%

%% Initialization
hfshift = 1; % shift the STRF
cd('E:\MATLAB\PANDA\Publications\Auditory Cortex\reconstructed STRF');
thorfiles	= dir('thor*');
joefiles	= dir('joe*');
files		= [thorfiles' joefiles'];
DatFile		= files(1).name;


%% Load data (mat-file, contains spike, STRF, MTF, PTF)
load(DatFile);
STRF		= pa_spk_ripple2strf(spikeP);
MTF			= STRF.magnitude;
PTF			= unwrap(STRF.phase);
NRM			= STRF.norm;
density		= STRF.density;
velocity	= STRF.velocity;
seldown		= density>0;
selup		= density<0;
selflat		= density == 0;

%% Quadrant 1 = postive O / densities
MQ1		= MTF(:,seldown);
PQ1		= unwrap(PTF(:,seldown));
CplxQ1	= MQ1.*exp(1i*PQ1);

%% Quadrant 2 = negative O < densities
MQ2		= MTF(:,selup);
PQ2		= unwrap(PTF(:,seldown));
CplxQ2	= MQ2.*exp(1i*PQ2);

%% Between quadrants 1 and 2 = O/density=0
MQflat		= MTF(:,selflat);
PQflat		= unwrap(PTF(:,selflat));
CplxQflat	= MQflat.*exp(1i*PQflat);

%% total Q1Q2
MQ12		= MTF;
PQ12		= unwrap(PTF);
NQ12		= NRM;
CplxQ12		= MQ12.*exp(1i*PQ12);

%% STRF
strf		= STRF.strf;
mxscal		= max(abs(strf(:)));
tms			= STRF.time;
xoct		= STRF.frequency;
nvel		= numel(velocity);
% ndens		= numel(density);

%% Plot MTF, PTF, Norm, STRF
close all;
figure(1);

subplot(2,2,1);
imagesc(density,velocity,MQ12);
colorbar;
ylabel('ripple velocity (Hz)');
title([DatFile,'    AC response']);
set(gca,'YDir','normal','TickDir','out');
set(gca,'YTick',velocity,'XTick',density);
axis square;

subplot(2,2,2);
imagesc(density,velocity,NQ12,[0,1]);
colorbar;
ylabel('ripple velocity (Hz)');
title('norm factor');
set(gca,'YDir','normal','TickDir','out');
set(gca,'YTick',velocity,'XTick',density);
axis square;

subplot(2,2,3);
imagesc(density,velocity,PQ12,[-pi,pi]);
ylabel('ripple velocity (Hz)');
xlabel('ripple frequency (cyc/oct)');
title('    phase');
set(gca,'YDir','normal','TickDir','out');
set(gca,'YTick',velocity,'XTick',density);
colorbar;
axis square;

if hfshift~=0
	kshift	= hfshift/(xoct(2)-xoct(1));
	strf	= strf([end-kshift+1:end, 1:end-kshift],:);
end
subplot(2,2,4);
imagesc(tms, xoct,strf,[-mxscal,mxscal]);
ylabel('tonotopy (octaves)');
xlabel('time (ms)');
title('STRF');
set(gca,'YDir','normal','TickDir','out');
colorbar;
axis square;

%%
figure(101)
% for downward ripples (density>0)
col = bone(nvel+1);
subplot(321)
hold on
for ii = 1:nvel
	y = MTF(ii,seldown);
	x = density(seldown);
	plot(x,y,'LineWidth',2,'Color',col(ii,:));
	str = num2str(velocity(ii));
	text(x(1)/2,y(1),str,'HorizontalAlignment','right')
end
box off
axis square;
xlabel('\Omega (cyc/oct)');
ylabel('Magnitude (spikes/s)');
xlim([0 2.5]);
ylim([0 30]);
title(DatFile);

% for downward ripples (density>0)
col = bone(nvel+1);
subplot(322)
hold on
for ii = 1:nvel
	y = PTF(ii,seldown)/pi;
	x = density(seldown);
	plot(x,y,'LineWidth',2,'Color',col(ii,:));
	str = num2str(velocity(ii));
	text(x(1)/2,y(1),str,'HorizontalAlignment','right')
end
box off
axis square;
xlabel('\Omega (cyc/oct)');
ylabel('Phase (\pi)');
xlim([0 2]);
title(DatFile);
%%
% keyboard
% return

%%	Separability
[~,~, cripvel1,cripdens1]	= getSVD(CplxQ1); % SVD on complex of first quadrant
[~,~, cripvel2,cripdens2]	= getSVD(CplxQ2); % SVD on complex of second quadrant
[~,~, cripvelflat]			= getSVD(CplxQflat); % SVD on complex of second quadrant

%%
figure(101)
subplot(3,4,5)
x = density(seldown);
y = abs(cripdens1);
plot(x,y,'k-','MarkerFaceColor','w','LineWidth',2);
hold on
text(x(1)/2,y(1),'Down','HorizontalAlignment','right');
x = -density(selup); % 'Inverted'
y = abs(cripdens2);
plot(x,y,'k--','MarkerFaceColor','w','LineWidth',2);
text(x(1)/2,y(1),{'Up';'(inverted)'},'HorizontalAlignment','right');

box off
axis square;
xlabel('\Omega (cyc/oct)');
ylabel('Magnitude (spikes/s)');
ylim([0 7])
title('Spectral');

subplot(3,4,6)
x = velocity;
y = abs(cripvel1);
plot(x,y,'k-','MarkerFaceColor','w','LineWidth',2);
hold on
x = velocity;
y = abs(cripvel2);
plot(x,y,'k--','MarkerFaceColor','w','LineWidth',2);
plot(velocity,abs(cripvelflat),'k:','MarkerFaceColor','w','LineWidth',2);
box off
axis square;
xlabel('\omega (Hz)');
ylabel('Magnitude (spikes/s)');
xlim([0 50]);
ylim([0 7])
title('Temporal');

subplot(3,4,7)
x = density(seldown);
y = unwrap(angle(cripdens1))/pi;
plot(x,y,'k-','MarkerFaceColor','w','LineWidth',2);
hold on
x = density(seldown);
y = unwrap(angle(cripdens2))/pi; % 'Inverted' & shift
plot(x,y,'k--','MarkerFaceColor','w','LineWidth',2);
box off
axis square;
xlabel('\Omega (cyc/oct)');
ylabel('Phase (\pi)');
xlim([0 2.5]);
ylim([0 2])
title('Spectral');

subplot(3,4,8)
x = velocity;
y = unwrap(angle(cripvel1))/pi;
plot(x,y,'k-','MarkerFaceColor','w','LineWidth',2);
hold on
x = velocity;
y = unwrap(angle(cripvel2))/pi;
plot(x,y,'k--','MarkerFaceColor','w','LineWidth',2);
x = velocity;
y = unwrap(angle(cripvelflat))/pi;
plot(x,y,'k:','MarkerFaceColor','w','LineWidth',2); % Some shifting
box off
axis square;
xlabel('\omega (Hz)');
ylabel('Phase (\pi)');
xlim([0 50]);
title('Temporal');


%% Construct STRF
[~,~, cripvel,cripdens]	= getSVD(CplxQ12); % SVD on complex of first two quadrants

% [cripvel,cripdens] = mehsgrid(cripvel,cripdens);
% Cplx = cripvel.*cripdens;

Cplx = cripvel*cripdens;
% mvel			= abs(cripvel);
% pvel			= unwrap(angle(cripvel));
% mdens			= abs(cripdens);
% pdens			= unwrap(angle(cripdens));
% m				= mvel*mdens;
% [pdens,pvel]	= meshgrid(pdens,pvel);
% p				= pvel+pdens;
% p				= mod(p,2*pi);
% Cplx			= m.*exp(1i*p);
strf			= compstrf(Cplx);
% strf = strf;
if hfshift~=0
	kshift	= hfshift/(xoct(2)-xoct(1));
	strf	= strf([end-kshift+1:end, 1:end-kshift],:);
end

figure
subplot(224)
imagesc(tms,xoct,strf)
set(gca,'YDir','normal','TickDir','out');
axis square;
colorbar;
mx = max(abs(strf(:)));
caxis([-mx mx]);

subplot(221)
imagesc(density,velocity,abs(Cplx))
axis square;
set(gca,'YDir','normal','TickDir','out');
colorbar;

subplot(223)
imagesc(density,velocity,unwrap(angle(Cplx)))
axis square;
set(gca,'YDir','normal','TickDir','out');
colorbar;

return
% figure
% subplot(221)
% plot(density,abs(cripdenstot),'r:','MarkerFaceColor','w','LineWidth',2);
%
% subplot(222)
% plot(density,unwrap(angle(cripdenstot)),'r:','MarkerFaceColor','w','LineWidth',2);

%
% subplot(224)
% plot([-fliplr(velocity) 0 velocity],unwrap(angle(cripveltot)),'r:','MarkerFaceColor','w','LineWidth',2);
% hold on
% title('temporal')
% xlabel('Velocity (Hz)');
% axis square;



% disp(' ');
% disp(' eigenvalues 1-6 for total TF, complex: ')
% disp(num2str(cevtot(1:6)));
% ripvel12=ripveltot(Nwh+2:end); %#ok<*NASGU>     % Nw=length(Wfo); Nwh=floor(Nw/2);
% ripdens12=ripdenstot(Nom+2:end);
% cripvel12=cripveltot(Nwh+2:end);
% cripdens12=cripdenstot(Nom+2:end);
%
% alfaspec=inseparabil(cripdens1, conj(cripdens2));
% alfaspecamp=inseparabil(ripdens1, ripdens2);
% alfatemp=inseparabil(cripvel1, cripvel2);
alfadir=dirpref(sum(sum(MQ2.^2)),sum(sum(MQ1.^2)))  %direction preference
% alfamean=mean([alfaspec alfatemp abs(alfadir)]);


%	ratio of responses to moving ripples (density <> 0) and
%	responses to AM sounds (density = 0)
moveratio(MQ1, MQ2, MQflat);

%
%	derive constant phase, and slopes of phase with vel and om
%
wwind=1:3; omwind=1:3;
disp(' ');
[bvel1, Rvel1, cvel1]=sloper(w12(wwind)',unwrap(angle(cripvel1(wwind))));
bvel1=bvel1/(2*pi);
disp(['temporal 1: slope ',num2str(-bvel1*1000),' ms',...
	' * R ',num2str(Rvel1),...
	' * intercept ',num2str(cvel1)]);

[bvel2, Rvel2, cvel2]=sloper(w12(wwind)',unwrap(angle(cripvel2(wwind))));
bvel2=bvel2/(2*pi);
disp(['temporal 2: slope ',num2str(-bvel2*1000),' ms',...
	' * R ',num2str(Rvel2),...
	' * intercept ',num2str(cvel2)]);

[bdens1, Rdens1, cdens1]=sloper(om(omwind),unwrap(angle(cripdens1(omwind))));
bdens1=bdens1/(2*pi);
disp(['spectral 1: slope ',num2str(bdens1),' oct',...
	' * R ',num2str(Rdens1),...
	' * intercept ',num2str(cdens1)]);

[bdens2, Rdens2, cdens2]=sloper(-om(omwind),unwrap(angle(cripdens2(omwind))));
bdens2=bdens2/(2*pi);
disp(['spectral 2: slope ',num2str(bdens2),' oct',...
	' * R ',num2str(Rdens2),...
	' * intercept ',num2str(cdens2)]);

[Sphi, Tphi]=stphases2(cdens1,cdens2,cvel1,cvel2);
disp(['temporal phase: ',num2str(Tphi),' * spectral phase: ',num2str(Sphi)]);
disp(' ');
disp(num2str(-bvel1*1000));
disp(num2str(-bvel2*1000));
disp(num2str(bdens1));
disp(num2str(bdens2));
disp(num2str(Tphi));
disp(num2str(Sphi));

%
% best omega's and velocities from separated curves
%
[~,k1]=max(abs(cripdens1)); bestdens1=om(k1);
[~,k1]=max(abs(cripdens2)); bestdens2=om(k1);
[~,k1]=max(abs(cripdens12)); bestdens12=om(k1);
[~,k1]=max(abs(cripvel1)); bestvel1=w12(k1);
[~,k1]=max(abs(cripvel2)); bestvel2=w12(k1);
[~,k1]=max(abs(cripvel12)); bestvel12=w12(k1);
disp(' ');
disp('parameters derived from separated curves ');
disp('best density 1, 2 and 1-2; best velocity 1, 2 and 1-2: ');
disp(num2str(bestdens1));
disp(num2str(bestdens2));
disp(num2str(bestdens12));
disp(num2str(bestvel1));
disp(num2str(bestvel2));
disp(num2str(bestvel12));

%
%	anova stats of magnitude, test order in matrix
%
p1=anova2(ACQ1); p2=anova2(ACQ2);
disp(' ');
disp('ANOVA p values for spectral 1, temporal 1, spectral 2, temporal 2: ');
disp(num2str(p1(1))); disp(num2str(p1(2)));
disp(num2str(p2(1))); disp(num2str(p2(2)));

%
% plots of separated curves
%

figure(2);
set(2,'name','svd');
clf;
subplot(3,2,1);
%plot(om,abs(cripdens1),om,abs(cripdens2),om,abs(cripdens12));
plot(om,abs(cripdens1),'k-',om,abs(cripdens2),'k--','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);
subplot(3,2,2);
plot(om,unwrap(angle(cripdens1))/pi,'k-',om,unwrap(angle(cripdens2))/pi,'k--','linewidth',1.5);


subplot(3,2,3);
%plot(w12,abs(cripvel1),w12,abs(cripvel2),w12,abs(cripvel12));
plot(w12,abs(cripvel1),'k-',w12,abs(cripvel2),'k--','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);
subplot(3,2,4);
plot(w12,unwrap(angle(cripvel1))/pi,'k-',w12,unwrap(angle(cripvel2))/pi,'k--','linewidth',1.5);

subplot(3,2,5);
imagesc(ACtotal);
set(gca,'YDir','normal','TickDir','out');

subplot(3,2,6);
plot(om,angle(cripdens1.*cripdens2)/pi,om,angle(cripvel1./cripvel2)/pi);

set(gcf,'Position',[400  400  420  560]);

figure(3);
clf;
subplot(3,2,1);
plot(om,abs(cripdens1),'k','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);

subplot(3,2,2);
plot(w12,abs(cripvel1),'k','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);

subplot(3,2,3);
plot(-om,abs(cripdens2),'k','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);

subplot(3,2,4);
plot(w12,abs(cripvel2),'k','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);

subplot(3,2,5);
plot(om,abs(cripdens12),'k','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);

subplot(3,2,6);
plot(w12,abs(cripvel12),'k','linewidth',1.5);
h=get(gca,'Ylim');
set(gca,'YLim',[0 h(2)]);
set(gcf,'Position',[38  560  350  390]);

figure(4);
clf;
subplot(2,2,1);
plotfitphase(w12,angle(cripvel1)',wwind(1),wwind(end));
subplot(2,2,2);
plotfitphase(w12,angle(cripvel2)',wwind(1),wwind(end));
subplot(2,2,3);
plotfitphase(om,angle(cripdens1),omwind(1),omwind(end));
subplot(2,2,4);
plotfitphase(-om,angle(cripdens2),omwind(1),omwind(end));

set(gcf,'Position',[10   120   450   350]);

%subplot(2,1,1);
%imagesc(O12,w12,DCQ12);
%title('   DC components');
%set(gca,'YDir','normal','TickDir','out');
%set(gca,'YTick',w12,'XTick',O12,'XTickLabel',' ');
%colorbar('vert');
%ylabel('ripple velocity (Hz)');
%title([DatFile,'    DC response']);

%subplot(2,1,2);
%plot(O12,DCm);

function r=moveratio(mag1,mag2,mag0) %#ok<*STOUT>

ave1=mean(mean(mag1)); ave2=mean(mean(mag2)); ave0=mean(mag0);
r12=mean([ave1 ave2])/ave0;
r1=ave1/ave0; r2=ave2/ave0;

disp(' ');
disp('moving-versus-AM ratios 1, 2, 1-2: ');
disp(num2str(r1))
disp(num2str(r2))
disp(num2str(r12))


function strf = compstrf(cplxq12,nw,no)
%  STRF = COMPSTRF(CPLXQ12,NW,NO)
%
% Obtain spectrotemporal receptive field STRF from the complex transfer
% function for quadrants 1 and 2 CPLXQ12, for w>0, entire omega range.

% Huib Versnel, version 26-7-'00
if nargin < 3
	no=1;
end;
if nargin < 2
	nw=1;
end;
s				= size(cplxq12,2);
stat			= zeros(1,s);
cplxq34			= conj(rot90(cplxq12,2));
cplxtotal		= [cplxq34;stat;cplxq12];
cplxtot1		= conj(rot90(fftshift(cplxtotal(2:end,2:end)),2));
cplxstrf		= ifft2(cplxtot1*(nw*no));	%inverse Fourier transform
strf			= real(fliplr(cplxstrf).');



function [ev, alfa, p, q] = getSVD(A)
%
%	[ev, alfa, p, q]=getSVD(A);
%
%	ev: eigenvalues
%	inseparability index, alfa=0: separable, alfa=1: inseparable
%	p, q: in case of separability: A=p*q
%
[U,S,V] = svd(A);
ev		= diag(S)/max(diag(S)); % eigen values = standard deviation = diagonal of S

fac		= S(1,1); % 1st
S1		= zeros(size(A));
S1(1,1) = sqrt(fac);

P		= U*S1;
p		= P(:,1);
Q		= S1*V';
q		= Q(1,:);

alfa	= 1-1/(sum(ev.^2));