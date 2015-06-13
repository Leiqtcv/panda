function A4_ruw_signaal

close all
clear all

datfile = 'MW-RG-2012-01-12-0006';
nchan   = 8;
nsample = 1500;
dat     = pa_loaddat(datfile,nchan,nsample);

H = squeeze(dat(:,:,1));
V = squeeze(dat(:,:,2));
Z = squeeze(dat(:,:,3));

subplot(221)
plot(H);

subplot(222)
plot(V);

subplot(223)
plot(Z);

subplot(224)
plot(H,V);  

mx=max(H(:));
mn=min(H(:));
for ii = 1:62
    figure(666)
    clf
    plot(H(:,ii));
    ylim([mn mx]);
    drawnow
    pause
end
return
%% HV
[H,V] = pa_loadraw(datfile,2,nsample);
figure
subplot(221)
plot(H);

subplot(222)
plot(V);

subplot(223)
plot(H,V);

figure
plot(diff(H));
v = diff(H);
figure
rg_getpower(v,1000,'display',1);
pa_verline(50);