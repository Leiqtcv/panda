function tmp
%% Clear
clear all
close all

%% Load  data
cd('E:\DATA\Ripple\Daisy');
S = load('ripplevariables_basics');
cond = S.cond;
dens = S.dens;
vel = abs(S.vel);
rt = S.rt;
unique(S.ds)

%% 
whos
selrn	= ismember(cond,[3 4]); % right normal-hearing
selln	= ismember(cond,[5 6]); % left normal-hearing
selbn	= ismember(cond,[8 9]); % binaural normal-hearing
selrn	= ismember(cond,[1]); % right normal-hearing
selln	= ismember(cond,[2]); % left normal-hearing
selbn	= ismember(cond,[7]); % binaural normal-hearing

seld	= dens  == 0; % pure amplitude modulations (density = 0 cyc/oct)
selv = vel>2;
sel3000 = rt<2900;

selmn = ismember(cond,[1 2]);

sel		= seld & sel3000 & selv; % select all monaural normal-hearing & AM

rtrn		= sort(rt(selrn & sel));
rtln		= sort(rt(selln & sel));
rtbn		= sort(rt(selbn & sel));

% %% Experimental CDF 
% nrn = numel(rtrn);
% prn = (1:nrn)/nrn; % cumulative probability
% 
% nln = numel(rtln);
% pln = (1:nln)/nln;
% 
% nbn = numel(rtbn);
% pbn = (1:nbn)/nbn;
% 
% plot(rtrn,prn,'r-');
% hold on
% plot(rtln,pln,'b-');
% plot(rtbn,pbn,'k-');



%% Estimated CDF
t = linspace(min(rtbn),max(rtbn),100);
ks1 = ksdensity(rtrn,t,'function','cdf');
ks2 = ksdensity(rtln,t,'function','cdf');
ks3 = ksdensity(rtbn,t,'function','cdf');

h1 = plot(t,ks1,'r-','LineWidth',2);
hold on
h2 = plot(t,ks2,'b-','LineWidth',2);
h3 = plot(t,ks3,'k-','LineWidth',2);

%% Race model
ulrich = ks1+ks2;
sel = ulrich>1;
ulrich(sel) = 1;

gielen = ks1+ks2-ks1.*ks2; % REAL RACE
colonius = max(ks1,ks2); % race model with negative dependencies
% right = ks1;

X = t;
Y = gielen;
E = [colonius; ulrich];
plot(t,gielen,'m-');
[hpatch,hline] = pa_errorpatch(X,Y,E,'k');
set(hline,'Color',[.7 .7 .7]);
alpha(hpatch,0.2);
axis square;
box off
xlim([0 800]);
ylim([0 1]);
xlabel('Reaction time (ms)');
ylabel('Cumulative probability');
legend([h1 h2 h3 hline],{'CI';'HA';'Bimodal';'Race'},'Location','SE');
x = sort(rtbn);
cdf = [t; gielen]';
[h,p] = kstest(x,cdf)

%% Graphics


function [hpatch,hline] = pa_errorpatch(X,Y,E,col)
% PA_ERRORPATCH(X,Y,E)
%
% plots the graph of vector X vs. vector Y with error patch specified by
% the vector E.
%
% PA_ERRORPATCH(...,'ColorSpec') uses the color specified by the string
% 'ColorSpec'. The color is applied to the data line and error patch, with
% the error patch having an alpha value of 0.4.
%
% [HPATCH,HLINE] = PA_ERRORPATCH(...) returns a vector of patchseries and
% lineseries handles in HPATCH and HLINE, respectively.

% (c) 2011 Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
% Check whether
if size(X,1)>1
	X=X(:)';
	if size(X,1)>1
		error('X should be a row vector');
	end
end
if size(Y,1)>1
	Y   = Y(:)';
	if size(Y,1)>1
		error('Y should be a row vector');
	end
end
if size(E,1)>2
	E   = E(:)';
	if size(E,1)>2
		error('E should be a row vector or 2-row matrix');
	end
end
if length(Y)~=length(X)
	error('Y and X should be the same size');
end
if size(E,2)~=size(X,2)
	error('E and X should be the same size');
end
if nargin<4
	col = 'k';
end

%% remove nans
if size(E,1)>1
	sel		= isnan(X) | isnan(Y) | isnan(E(1,:)) | isnan(E(2,:));
	E		= E(:,~sel);
else
	sel		= isnan(X) | isnan(Y) | isnan(E);
	E		= E(~sel);
end
X		= X(~sel);
Y		= Y(~sel);

%% Create patch
x           = [X fliplr(X)];
if size(E,1)>1
	y           = [E(1,:) fliplr(E(2,:))];
else
	y           = [Y+E fliplr(Y-E)];
end
%% Graph
hpatch           = patch(x,y,col);
alpha(hpatch,0.4);
set(hpatch,'EdgeColor','none');
hold on;
hline = plot(X,Y,'k-'); set(hline,'LineWidth',2,'Color',col);
box on;