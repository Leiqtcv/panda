function pa_pet_foneem_allrois_prepost
%% Initialization
close all force hidden
clear all
warning off;
luFlag = false;

%%
files1		= {'gswdro_s06-c-pre.img';'gswdro_s08-c-pre.img';...
	'gswdro_s09-c-pre.img';'gswdro_s10-c-pre.img';...
	'gswdro_s11-c-pre.img';'gswdro_s12-c-pre.img';...
	};
% [Gc,GEc,nc] = getdat(files);
files2 = {'gswdro_s06-v-pre.img';'gswdro_s08-v-pre.img';...
	'gswdro_s09-v-pre.img';'gswdro_s10-v-pre.img';...
	'gswdro_s11-v-pre.img';'gswdro_s12-v-pre.img';...
	};
subject		= [6 8 9 10 11 12];
[Gmu1,GEmu1,namesmu1] = getdat(files1,files2,subject,luFlag);

%% Post
files1 = {'gswdro_s07-c-post.img';'gswdro_s13-c-post.img';...
	'gswdro_s14-c-post.img';'gswdro_s15-c-post.img';...
	'gswdro_s16-c-post.img';...
	};
files2 = {'gswdro_s07-v-post.img';'gswdro_s13-v-post.img';...
	'gswdro_s14-v-post.img';'gswdro_s15-v-post.img';...
	'gswdro_s16-v-post.img';...
	};
subject		= [7 13 14 15 16];
[Gmu2,GEmu2] = getdat(files1,files2,subject,luFlag);
% keyboard

%%
close all
figure(5)
hold on

n		= numel(Gmu1);
b		= [Gmu1; Gmu2]';

if luFlag
	% for 2
	e1 = [Gmu1 - GEmu1(1,:); GEmu1(2,:)-Gmu1];
	e2 = [Gmu2 - GEmu2(1,:); GEmu2(2,:)-Gmu2];
	e = [e1;e2]';
	z = zeros(1,n);
	sel1 = pa_inrange(z,GEmu1)
	sel2 = pa_inrange(z,GEmu2)
else
	% for 1
	e		= [GEmu1(1,:);GEmu2(1,:)]';
	z		= zeros(1,n);
	sel1	= pa_inrange(z,[Gmu1-GEmu1(1,:); Gmu1+GEmu1(1,:)]);
	sel2	= pa_inrange(z,[Gmu2-GEmu2(1,:); Gmu2+GEmu2(1,:)]);
end

col1 = repmat([1 0 0],n,1);
col2 = repmat([0 0 1],n,1);
nnosig1 = sum(sel1);
col1(sel1,:) = repmat([1 1 1],nnosig1,1);
nnosig2 = sum(sel2);
col2(sel2,:) = repmat([1 1 1],nnosig2,1);

whos b e
c{1} = col1;
c{2} = col2;
pa_errorbar2(b,e,'xlabel',namesmu1)
grid on;
xlim([0 n+1])
% ylim([-0.2 0.2]);
rotateticklabel(gca,30);

% keyboard
%%
%%
function [Gmu,GEmu,namesmu] = getdat(files1,files2,subject,luFlag)
cd('E:\DATA\KNO\PET\marsbar-aal');
d			= dir('*.mat');
roinames	= {d.name};
n			= numel(roinames);
names		= roinames;
side		= NaN(1,n);
for ii = 1:n
	name	= roinames{ii};
	name	= name(5:end-8);
	indx	= strfind(name,'_');
	name(indx) = ' ';
	if strcmp(name(end),'L')
		side(ii) = 1;
	elseif strcmp(name(end),'R')
		side(ii) = 2;
	else side(ii) = 0;
	end
	
	names{ii} = name(1:end-2);
end

%%
p			= 'E:\DATA\KNO\PET\swdro files\';
F			= [100 100 100 100 0 51 3 65 7 3 15 13.5 55 70 85 30]; % 2012-07-02

f			= F(subject);
[s,indx]	= sort(f);

loadFlag = true;
fname = files1{1};
fname = fname(14:16);
if~loadFlag
	MU1			= [];
	MU2			= [];
	for ii = 1:n
		roiname		= roinames{ii};
		mu1			= pa_pet_getmeandata(files1,p,roiname);
		MU1			= [MU1 mu1];
		mu2			= pa_pet_getmeandata(files2,p,roiname);
		MU2			= [MU2 mu2];
	end
	cd(p);
	foneem = f;
	save(['petmean' fname],'MU1','MU2','names','foneem','side');
else
	cd(p)
	load(['petmean' fname])
end
%%
t = MU2(indx,:)-MU1(indx,:);
% t = MU1(indx,:);
% t = MU2(indx,:);

% t = bsxfun(@minus, t, mean(t));
% t = bsxfun(@minus, t', mean(t'))';
R = NaN(1,n);
P = R;
G = R;

GE = NaN(2,n);

%%
if luFlag
	for ii = 1:n
		cla
		x = s;
		y = t(:,ii);
		[r,p] = corrcoef(x,y);
		R(ii) = r(2);
		P(ii) = p(2);
		
		x =[ones(size(x));x]';
		b = regress(y,x);
		G(ii) = b(2);
		se = bootstrp(1000, @regress,y,x);
		se = se(:,2);

		
% 		b = linortfit2(x',y);
% 		G(ii) = b(1);
% 	    se = bootstrp(1000, @linortfit2,x',y);
% 		se = se(:,1);


		se = prctile(se,[10 90]);
		GE(:,ii) = se;
	end
else
	for ii = 1:n
		x = s';
		y = t(:,ii);
		[r,p] = corrcoef(x,y);
		
		b = regstats(y,x,'linear',{'beta','tstat'});
		% 	b = linortfit2(x,y);
		R(ii) = r(2);
		P(ii) = p(2);
		G(ii) = b.beta(2);
		
		sg = 0.025/10; % bonferroni conrrection
		sg = 0.025;
		a = tinv(1-sg,numel(x));
		GE(:,ii) = a*b.tstat.se(2)/sqrt(numel(x));
	end
end
sel		= side==1;
sel2	= side==2;
namesmu = names(sel);
whos G
Gmu		= (G(sel)+G(sel2))/2;
GEmu	= (GE(:,sel)+GE(:,sel2))/2;







