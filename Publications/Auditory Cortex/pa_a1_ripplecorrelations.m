function pa_a1_ripplecorrelations
close all force
clear all

% fname = 'swdro_s06-c-normal.img';
% fname = pa_fcheckexist([],'*.img');
% pa_pet_grandmeanscale(fname,'display',1);

% fname = 'SCHULTS_MCA_.CT.PET_UMC_LM_BRAIN_CI_(ADULT).2.1.2010.03.26.16.58.50.562500.17878969.IMA';
% info = dicominfo(fname)
d = 'E:\DATA\Cortex\gain selected cells';
cd(d);
fname = 'thor08411';
% fname = 'thor07512';
% fname = 'joe6707c01b00';

R1 = getcorr(fname);
drawnow

return
R2 = getcorra(fname);
drawnow
R3 = getcorra2(fname);
drawnow

sm = getrt(fname);
R4 = getcorra3(fname,sm);

% keyboard
figure
plot(R1(:),R4(:),'r.');
hold on
plot(R1(:),R2(:),'k.');
hold on
% plot(R1(:),R3(:),'b.');
lsline;
axis square;
axis([-1 1 -1 1]);
pa_unityline;

function R = getcorr(fname)
load(fname);

% pa_spk_rasterplot(spikep);

vel		= [spikep.stimvalues];
vel		= vel(5,:);
dens	= [spikep.stimvalues];
dens	= dens(6,:);
VD = [vel; dens]';
uVD = unique(VD,'rows');
nVD = length(uVD);
M = NaN(1000,nVD);
for ii = 1:nVD
	sel = vel== uVD(ii,1) & dens == uVD(ii,2);
	s = spikep(sel);
	m = pa_spk_sdf(s,'display',1);
	m = m(801:1800);
	M(1:length(m),ii) = m;
end

R = NaN(nVD,nVD);
for ii = 1:nVD
	for jj = 1:nVD
		m1 = M(:,ii);
		m2 = M(:,jj);
		sel = ~isnan(m1) & ~isnan(m2);
		r = corrcoef(m1(sel),m2(sel));
		R(ii,jj) = r(2);
	end
end


figure(666)
col = pa_statcolor(64,[],[],[],'def',8);
colormap(col);
% subplot(221)
imagesc(R)
axis square;
set(gca,'XTick',1:nVD,'XTickLabel',uVD(:,1));
set(gca,'YTick',1:nVD,'YTickLabel',uVD(:,2));
mx = max(abs(R(:)));
caxis([-mx mx]);
caxis([-1 1]); 

colorbar;
pa_horline(11*(1:5)+0.5);
pa_verline(11*(1:5)+0.5);
pa_unityline;


function R = getcorra(fname)
load(fname);
sp = S1000;
% figure
% pa_spk_rasterplot(sp);
vel		= [sp.stimvalues];
vel		= vel(5,:);
dens	= [sp.stimvalues];
dens	= dens(6,:);
VD = [vel; dens]';
uVD = unique(VD,'rows');
nVD = length(uVD);
M = NaN(1000,nVD);
for ii = 1:nVD
	sel = vel== uVD(ii,1) & dens == uVD(ii,2);
	s = sp(sel);
	m = pa_spk_sdf(s,'display',1);
	try
		m = m(1301:2300);
	catch
		m = m(1301:end);
	end
	M(1:length(m),ii) = m;
end

R = NaN(nVD,nVD);
for ii = 1:nVD
	for jj = 1:nVD
		m1 = M(:,ii);
		m2 = M(:,jj);
		sel = ~isnan(m1) & ~isnan(m2);
		r = corrcoef(m1(sel),m2(sel));
		R(ii,jj) = r(2);
	end
end

figure(666)
subplot(222)
imagesc(R)
axis square;
set(gca,'XTick',1:nVD,'XTickLabel',uVD(:,1));
set(gca,'YTick',1:nVD,'YTickLabel',uVD(:,2));
mx = max(abs(R(:)));
caxis([-mx mx]);
caxis([-0.7 0.7]); 

colorbar;
pa_horline(11*(1:5)+0.5);
pa_verline(11*(1:5)+0.5);
pa_unityline;

figure(667)
subplot(222)
x = -1.2:0.05:1.2;
hist(R(:),x);
pa_verline(0);
pa_verline(median(R(:)),'r--');
xlim([-0.6 0.6]);

function R = getcorra2(fname)
load(fname);
spike = S1000;

rt		= beh(2,:); %#ok<*NODEF>
sel		= beh(4,:)==1000;
rt		= rt(sel);
n		= length(spike);
for ii	= 1:n
	spike(ii).spiketime = spike(ii).spiketime-rt(ii);
	sel					= spike(ii).spiketime>0;
	spike(ii).spiketime = spike(ii).spiketime(sel);
end
sp = spike;
% figure
% pa_spk_rasterplot(sp);
vel		= [sp.stimvalues];
vel		= vel(5,:);
dens	= [sp.stimvalues];
dens	= dens(6,:);
VD = [vel; dens]';
uVD = unique(VD,'rows');
nVD = length(uVD);
M = NaN(1000,nVD);
for ii = 1:nVD
	sel = vel== uVD(ii,1) & dens == uVD(ii,2);
	s = sp(sel);
	m = pa_spk_sdf(s,'display',1);
	% 	try
	% 	m = m(1301:2300);
	% 	catch
	m = m(1201:end);
	if length(m)>300
		m = m(1:300);
	end
	% 	end
	M(1:length(m),ii) = m;
end

R = NaN(nVD,nVD);
for ii = 1:nVD
	for jj = 1:nVD
		m1 = M(:,ii);
		m2 = M(:,jj);
		sel = ~isnan(m1) & ~isnan(m2);
		r = corrcoef(m1(sel),m2(sel));
		R(ii,jj) = r(2);
	end
end

figure(666)
subplot(223)

imagesc(R)
axis square;
set(gca,'XTick',1:nVD,'XTickLabel',uVD(:,1));
set(gca,'YTick',1:nVD,'YTickLabel',uVD(:,2));
mx = max(abs(R(:)));
caxis([-mx mx]);
caxis([-0.7 0.7]); 
colorbar;
pa_horline(11*(1:5)+0.5);
pa_verline(11*(1:5)+0.5);
pa_unityline;

figure(667)
subplot(223)
x = -1.2:0.05:1.2;
hist(R(:),x);
pa_verline(0);
pa_verline(median(R(:)),'r--');
xlim([-0.6 0.6]);

function R = getcorra3(fname,sm)
load(fname);
spike = S1000;

rt		= beh(2,:); %#ok<*NODEF>
sel		= beh(4,:)==1000;
rt		= rt(sel);
n		= length(spike);

sigma = 5;
winsize		= sigma*5;
t			= -winsize:winsize;
window		= normpdf(t,0,sigma);
N = NaN(2500,length(spike));
for ii	= 1:n
	% 	spike(ii).spiketime = spike(ii).spiketime-rt(ii);
	s = pa_spk_timing_struct2mat(spike);
	nsamples = length(s);
	
	winsize		= sigma*5;
	winsize		= [winsize nsamples+winsize-1]; %#ok<AGROW>
	
	convspike	= conv(s(ii,:),window);
	convspike	= convspike(winsize(1):winsize(2))*1000;
	t = 1:length(convspike);
	
% 	rt(ii)
	if rt(ii)>0
		zro = repmat(mean(convspike),1,rt(ii));
		m = [zro sm];
	elseif rt(ii)<0
		m = sm(-rt(ii):end);
	else
		m = sm;
	end
	l = length(convspike);
	
	if m<l
		zro = repmat(mean(convspike),1,-rt(ii));
		m = [sm zro];
	end
	nrm = convspike./m(1:l);
	t2 = (1:length(m))+rt(ii);
	
% 	figure(1)
% 	cla
% 	subplot(211)
% 	cla;
% 	plot(t,convspike,'k-');
% 	hold on
% 	plot(t2,m,'r-');
% 	pa_verline(1300);
% 	title(ii)
% 	xlim([0 2500]);
% 	
% 	subplot(212)
% 	cla;
% 	plot(nrm);
% 	xlim([0 2500]);
% 	
% 	pause
% % 	pause(.1)
% drawnow
	
		N(1:length(nrm),ii) = nrm;

end
% keyboard
sp = spike;
vel		= [sp.stimvalues];
vel		= vel(5,:);
dens	= [sp.stimvalues];
dens	= dens(6,:);
VD = [vel; dens]';
uVD = unique(VD,'rows');
nVD = length(uVD);
M = NaN(1000,nVD);
for ii = 1:nVD
	sel = vel== uVD(ii,1) & dens == uVD(ii,2);
% 	sum(sel)
	m = nanmean(N(:,sel),2);
% 	whos m
	
	m = m(1301:end);
	if length(m)>800
		m = m(1:800);
	end
	% 	end
	M(1:length(m),ii) = m;
end
% return
R = NaN(nVD,nVD);
for ii = 1:nVD
	for jj = 1:nVD
		m1 = M(:,ii);
		m2 = M(:,jj);
		
% 		figure(2)
% 		cla
% 		plot(m1,'k');
% 		hold on
% 		plot(m2,'r-');
% 		drawnow
% 		title(ii)
% % 		pause;
		
		sel = ~isnan(m1) & ~isnan(m2);
		r = corrcoef(m1(sel),m2(sel));
		R(ii,jj) = r(2);
	end
end

figure(666)
subplot(224)

imagesc(R)
axis square;
set(gca,'XTick',1:nVD,'XTickLabel',uVD(:,1));
set(gca,'YTick',1:nVD,'YTickLabel',uVD(:,2));
mx = max(abs(R(:)));
caxis([-mx mx]);
caxis([-0.7 0.7]); 
colorbar;
pa_horline(11*(1:5)+0.5);
pa_verline(11*(1:5)+0.5);
pa_unityline;

figure(667)
subplot(224)
x = -1.2:0.05:1.2;
hist(R(:),x);
pa_verline(0);
pa_verline(median(R(:)),'r--');
xlim([-0.6 0.6]);

function sm = getrt(fname)
load(fname);
spike	= S1000;
rt		= beh(2,:); %#ok<*NODEF>
sel		= beh(4,:)==1000;
rt		= rt(sel);
n		= length(spike);
for ii	= 1:n
	spike(ii).spiketime = spike(ii).spiketime-rt(ii);
	sel					= spike(ii).spiketime>0;
	spike(ii).spiketime = spike(ii).spiketime(sel);
end
[m,sdf]		= pa_spk_sdf(spike,'sigma',5,'Fs',1000);
% m = smooth(m)';
figure
plot(m)
pa_verline(1300);
sm = m;