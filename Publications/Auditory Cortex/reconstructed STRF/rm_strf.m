function [strf,ACQ12,PhQ12]=strf1(DatFile, corr, hfshift, Nbin, Twindow)
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
if nargin < 5
	Twindow = 300:2500; % start of sound + 100 ms offset to end at 2500 ms
end;
if nargin < 4
	Nbin = 32; % 32 bins for period histogram
end;
if nargin < 3
	hfshift = 1; % shift the STRF
end;
if nargin < 2
	corr = 0; % ???
end;
if nargin<1
% 	if no datafile then take best cell Joe67
	cd('E:\MATLAB\PANDA\Publications\Auditory Cortex\reconstructed STRF');
	thorfiles	= dir('thor*');
	joefiles	= dir('joe*');
	files		= [thorfiles' joefiles'];
	DatFile		= files(1).name
end

%% Load data (mat-file, contains spike, STRF, MTF, PTF)
load(DatFile);
SRwindow	= 1:Twindow(1); % Window of spontaneous rate
CompDelay	= 250;  %ignore first 250 ms after stimulus onset

% % [Stim Spk]	= apestim(DatFile);
% spiketim = [spikeP.spiketime];
% SRcor		= mean(mean(Spk(:,SRwindow)')); %#ok<*UDIM>
% disp(['spontaneous rate: ',num2str(1000*SRcor),' spikes/s'])
% 
% % Zoek het auditieve target
% for j = 1:Stim(1,2)
% 	if Stim(1,j*9-6)==2, snr = j*9+2; end
% end
% 
% StimA = Stim(:,snr);
% [w,O]		  = stimtorippar(StimA);
% [DC,AC,norm,ACP] = ripparams(Spk-SRcor, w, Nbin, Twindow,CompDelay,corr);
STRF = pa_spk_ripple2strf(spikeP);

% keyboard
% extracting and sorting of velocity and ripple frequency
% w: velocity (Hz), O: ripple frequency
% Wlo		= min(w); 
% Whi		= max(w);
% Olo		= min(O); 
% Ohi		= max(O);
% Ifo		= O==Ohi;		% indices at omega = maxomega
% Wfo		= w(Ifo);				% velocity series
% Ifw		= w==Wlo;
% Ofw		= O(Ifw);
% Ofwo	= sort(Ofw);		% sorted omega's, low to high
% Ostep	= Ofwo(2)-Ofwo(1);
% Nw		= length(Wfo); 
% Nwh		= floor(Nw/2);
% No		= (Ohi-Olo)/Ostep+1;
% AC2		= zeros(No,Nw); % magnitude
% norm2	= zeros(No,Nw); % norm-factor
% Ph2		= zeros(No,Nw); % phase
% k1		= 1;

% sorting of response
% Ofwo: sorted omegas, low to high, low: >=0
% Wfoo: sorted velocities, low to high, high=-low

% for k = k1:No
% 	FixOm			= Olo+(k-1)*Ostep;
% 	Ifo				= find(O==FixOm);
% 	Wfo				= w(Ifo);
% 	AC1				= AC(Ifo);  
% 	DC1				= DC(Ifo);
% 	norm1			= norm(Ifo);
% 	Ph1				= ACP(Ifo);
% 	[Wfoo,Ifo]		= sort(Wfo);
% 	AC2(k,:)		= AC1(Ifo); 
% 	DC2(k,:)		= DC1(Ifo);
% 	norm2(k,:)		= norm1(Ifo);
% 	Ph2(k,:)		= Ph1(Ifo);
% end


% rearrange matrix, O=sign(w)*O and w=sign(w)*w;
% quadrant 1, Q1, gets positive O
% quadrant 2, Q2, gets negative O

% % omega and velocity arrays
% Ofwo=0.1*Ofwo;
% Ostep=Ofwo(2)-Ofwo(1);
% Wstep=Wfoo(2)-Wfoo(1);
% Olow=Ofwo(k1); Wlow=Wfoo(Nwh+2);
% O12=[-fliplr(Ofwo(k1:No)),Ofwo];
% w12=Wfoo(Nwh+2:Nw);
% No2=length(O12);

MTF			= STRF.magnitude;
PTF			= STRF.phase;
NRM			= STRF.norm;
density		= STRF.density;
velocity	= STRF.velocity;
Nw          = numel(velocity);
Nwh         = floor(Nw/2);
Nw          = unique(sort(abs(density)));
Nom         = Nw(2:end);

%% Quadrant 1 = postive O / densities
sel		= density>0;
MQ1		= MTF(:,sel);
PQ1		= PTF(:,sel);
NQ1		= NRM(:,sel);
CplxQ1	= MQ1.*exp(1i*PQ1);

%% Quadrant 2 = negative O < densities
sel		= density<0;
MQ2		= MTF(:,sel);
PQ2		= PTF(:,sel);
NQ2		= NRM(:,sel);
CplxQ2	= MQ2.*exp(1i*PQ2);

%% Between quadrants 1 and 2 = O/density=0
sel		= density==0;
MQflat		= MTF(:,sel);
PQflat		= PTF(:,sel);
NQflat		= NRM(:,sel);
CplxQflat	= MQflat.*exp(1i*PQflat);

%% total Q1Q2
MQ12		= MTF;
PQ12		= PTF;
NQ12		= NRM;
CplxQ12		= MQ12.*exp(1i*PQ12);

%% STRF
strf		= STRF.strf;
mxscal		= max(abs(strf(:)));
tms			= STRF.time;
xoct		= STRF.frequency;

% % some parameters
% % Transfer Function
% maxnorm=max(max(normQ12));
% s2=size(normQ12,1)*size(normQ12,2);
% mediannorm=median(reshape(normQ12,s2,1));
% [~,k1]=max(max(ACQ12));
% [maxtf,k2]=max(ACQ12(:,k1));
% bestOm=O12(k1); bestW=sign(bestOm+.0001)*w12(k2);
% %prefdir=sum(sum(ACQ2))/sum(sum(ACQ1));
% Cindex=dirpref(sum(sum(ACQ2)),sum(sum(ACQ1)));  %direction preference
% 
% % STRF
% [~,ktime]=max(max(strf));
% [~,kx]=max(strf(:,ktime));
% %tmax=tms(ktime)+500/(Nw-1)/Wstep;
% tmax=tms(ktime);
% xmax=xoct(kx);
% bffac=0.25;
% bf1=bffac*2^xmax; bf2=bffac*2^(xmax+xoct(end));
% 
% disp(' ');
% disp(['best normfactor: ',num2str(maxnorm)]);
% disp(['median normfactor: ',num2str(mediannorm)]);
% disp(' ');
% disp(['response magnitude: ',num2str(maxtf)]);
% disp(['best velocity: ',num2str(bestW)]);
% disp(['best omega:    ',num2str(bestOm)]);
% disp(['direction preference (up/down): ',num2str(Cindex)]);
% 
% disp(' ');
% disp(['latency excitatory response: ',num2str(tmax)]);
% disp(['BF (oct): ',num2str(xmax)]);
% disp(['possible BFs (kHz): ',num2str(bf1),', ',num2str(bf2)]);

% colorplots

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


%%	Separability
[~, alfa1, ~,ripdens1]				= getSVD(MQ1); % SVD on Amplitude of first quadrant
[cev1,calfa1, cripvel1,cripdens1]	= getSVD(CplxQ1); % SVD on complex of first quadrant
[~,alfa2, ~,ripdens2]				= getSVD(fliplr(MQ2));  % SVD on Amplitude of second quadrant
[cev2,calfa2, cripvel2,cripdens2]	= getSVD(fliplr(CplxQ2)); % SVD on complex of second quadrant
[cevflat,calfaflat, cripvelflat,cripdensflat]	= getSVD(CplxQflat); % SVD on complex of second quadrant


figure(2)
subplot(221)
hold on
plot(density(density>0),abs(cripdens1),'k-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(-density(density<0),fliplr(abs(cripdens2)),'k--','MarkerFaceColor','w','LineWidth',2);
title('Magnitude - spectral')
axis square;
xlabel('Density (cyc/oct)');

subplot(222)
hold on
plot(density(density>0),unwrap(angle(cripdens1)),'k-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(-density(density<0),fliplr(unwrap(angle(cripdens2))),'k--','MarkerFaceColor','w','LineWidth',2);
title('Phase - spectral')
axis square;
xlabel('Density (cyc/oct)');

subplot(223)
plot(velocity,abs(cripvel1),'k-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(velocity,abs(cripvel2),'k--','MarkerFaceColor','w','LineWidth',2);
plot(velocity,abs(cripvelflat),'k:','MarkerFaceColor','w','LineWidth',2);
title('Magnitude- temporal')
xlabel('Velocity (Hz)');
axis square;

subplot(224)
plot(velocity,unwrap(angle(cripvel1)),'k-','MarkerFaceColor','w','LineWidth',2);
hold on
plot(velocity,unwrap(angle(cripvel2)),'k--','MarkerFaceColor','w','LineWidth',2);
plot(velocity,unwrap(angle(cripvelflat)),'k:','MarkerFaceColor','w','LineWidth',2);
title('Phase - temporal')
xlabel('Velocity (Hz)');
axis square;


%% Quadrants 3 and 4
MQ34		= rot90(MQ12,2);
CplxQ34		= conj(rot90(CplxQ12,2));
s			= size(MQ12,2);
z = zeros(1,s);
% z = CplxQflat';
ACtotal		= [MQ34; z; MQ12];
Cplxtotal	= [CplxQ34; z; CplxQ12];
[~, alfatot, ripveltot,ripdenstot]			= getSVD(ACtotal);   % SVD on Amplitude of total
[cevtot, calfatot, cripveltot, cripdenstot] = getSVD(Cplxtotal);  % SVD on complex of total

%%
[cev,calfa, cripvel,cripdens]	= getSVD(CplxQ12); % SVD on complex of second quadrant

[v,d] = meshgrid(cripvel,cripdens);
cripvel
c = sqrt(d.*v);

whos c v d
strf = compstrf(c',5,11);
whos strf

if hfshift~=0
	kshift	= hfshift/(xoct(2)-xoct(1));
	strf	= strf([end-kshift+1:end, 1:end-kshift],:);
end

figure
subplot(224)
imagesc(strf)
set(gca,'YDir','normal','TickDir','out');
axis square;
colorbar;

subplot(223)
imagesc(density,velocity,unwrap(angle(c))')
axis square;
set(gca,'YDir','normal','TickDir','out');
colorbar;

subplot(221)
imagesc(density,velocity,abs(c'))
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