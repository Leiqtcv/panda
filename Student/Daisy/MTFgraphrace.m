function MTFgraphrace
%% Clear
clear all
close all

%% Load  data


subplot(121)
getdata([5 6],[3 4]);
title('Bimodal race');

subplot(122)
getdata(1,2);
title('Binaural race');

pa_datadir;
print('-depsc','-painter',[mfilename]);

function h = getdata(c1,c2)
cd('E:\DATA\Ripple\Daisy');
S		= load('ripplevariables_basics');
cond	= S.cond;
dens	= S.dens;
vel		= S.vel;

rt = S.rt;
%%
% vel = abs(vel);
sel3000 = rt<1500 & rt>150;

sel		= sel3000; % select all monaural normal-hearing & AM
rt		= rt(sel);
vel		= vel(sel); % pool negative & positive data for now
dens	= dens(sel);
cond = cond(sel);
%% Determine mean and std reaction time for every velocity
uvel	= unique(vel);
nvel	= numel(uvel);
udens	= unique(dens);
ndens	= numel(udens);

muRT = NaN(nvel,ndens);
sdRT = NaN(nvel,ndens);
r = 100:10:2000;
Race = NaN(nvel,ndens);
for ii = 1:nvel
	for jj = 1:ndens
		disp('-----------------');
		disp([uvel(ii) udens(jj)]);
		sel		= vel == uvel(ii) & dens == udens(jj) & ismember(cond,c1);
		RT1		= rt(sel);
		[P1,RT1] = getcdf(RT1,r);


		sel		= vel == uvel(ii) & dens == udens(jj) & ismember(cond,c2);
		RT2		= rt(sel);
		[P2,RT2] = getcdf(RT2,r);

		
		Gielen = P1+P2-P1.*P2;
		Gielen = max(P1,P2);
		[monGielen,monR] = moncdf(Gielen,r);
		Race(ii,jj) = 1000./interp1(monGielen,monR,0.5);
		

		
		
	end
end
muRT = Race;


% muRT = sdRT.^2;
%% Graphics
for ii = 1:nvel
	muRT(ii,:) = smooth(muRT(ii,:),3);
end
for ii = 1:ndens
	muRT(:,ii) = smooth(muRT(:,ii),3);
end
% sel = uvel==0 & udens==0;
muRT(uvel==0,udens==0) = 0;



x = 1:nvel;
xi = 1:.1:nvel;
y = 1:ndens;
yi = 1:.1:ndens;
[x,y] = meshgrid(x,y);
x = x';
y = y';
[xi,yi] = meshgrid(xi,yi);
xi = xi';
yi = yi';
muRT = interp2(x',y',muRT',xi',yi'); muRT = muRT';


hold on

imagesc(muRT'-100);
hold on
contour(muRT',5-pa_oct2bw(1,0:.1:2),'k-');
set(gca,'XTick',(1:nvel)*size(muRT,1)/nvel-size(muRT,1)/nvel/2,'XTickLabel',uvel,'YTick',(1:ndens)*size(muRT,2)/ndens-size(muRT,2)/ndens/2,'YTickLabel',udens);
axis square;
caxis([0.8 3.8]-100)
axis([.5 size(muRT,1)+.5 .5 size(muRT,2)+.5]);
xlabel('Velocity (cycles/s)');
ylabel('Density (cycles/oct)');
% colormap jet
colormap hsv



function [moncdf,monrt] = monrt(cdf,rt)
urt = unique(rt);
nrt = numel(urt);
monrt = NaN(nrt,1);
moncdf = monrt;
for kk = 1:nrt
	sel = rt==urt(kk);
	if sum(sel)>1
		moncdf(kk) = mean(cdf(sel));
		monrt(kk) = mean(rt(sel));
	else
		moncdf(kk) = cdf(sel);
		monrt(kk) = rt(sel);
	end
	
end
function [moncdf,monrt] = moncdf(cdf,rt)
ucdf = unique(cdf);
ncdf = numel(ucdf);
moncdf = NaN(ncdf,1);
monrt = moncdf;
for kk = 1:ncdf
	sel = cdf==ucdf(kk);
	if sum(sel)>1
		moncdf(kk) = mean(cdf(sel));
		monrt(kk) = mean(rt(sel));
	else
		moncdf(kk) = cdf(sel);
		monrt(kk) = rt(sel);
	end
end

function [cdf,rt] = getcdf(rt,r)
rt		= sort(rt);
cdf		= (1:length(rt))/length(rt);
[cdf,rt] = monrt(cdf,rt);
if numel(cdf)==1
	cdf = r;
	sel = r<rt;
	cdf(sel) = 0;
	sel = r>rt;
	cdf(sel) = 1;
	
elseif numel(cdf)==0;
	cdf = zeros(size(r));
else
	cdf		= interp1(rt,cdf,r,'cubic');
	
end
if numel(rt)>0
sel		= r<min(rt);
cdf(sel) = 0;
sel		= r>max(rt);
cdf(sel) = 1;
end