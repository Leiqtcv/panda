function pa_prior_sound_block_figure1

% Subtract Bias (Offset, which can be different for various blocks/sessies
% This removes noise (artificial variation when data is combined, e.g. in
% one set you start from +10 and another time you start at +3, when
% combining sets, the responses will be distributed largely. But when the
% offset is 0 in both, the distribution of responses can be combined, no
% artificial variation.

%% Initialization
close all
clear all


subjects	= {'MW';'LJ';'HH';'RO';'RG'};
nsubjects	= length(subjects);
gain		= NaN(5,3);
s = NaN(nsubjects,3);
s2 = s;
gain2 = gain;
S1 = [];
S2 = [];
S3 = [];
for ii = 1:nsubjects
	subject = subjects{ii};
	[s1,s2,s3]	= getgain(subject);
	S1 = [S1;s1];
	S2 = [S2;s2];
	S3 = [S3;s3];
end
figure(1)
X = S1(:,24);
Y = S1(:,9);
sel = abs(X)<11;
X = X(sel);
Y = Y(sel);
Y = Y-mean(Y);
Y = 0.8*Y;
subplot(131)
[TOT,uX,uY] = pa_bubbleplot(X,Y,4,5);
axis([-30 30 -30 30]); 
axis square;
b = regstats(Y,X,'linear','beta');
pa_regline(b.beta);
pa_unityline('k-');

X = S2(:,24);
Y = S2(:,9);
sel = abs(X)<11;
X = X(sel);
Y = Y(sel);
Y = Y-mean(Y);
Y = 0.9*Y;
subplot(132)
[TOT,uX,uY] = pa_bubbleplot(X,Y,4,5);
axis([-30 30 -30 30]); 
axis square;
b = regstats(Y,X,'linear','beta');
pa_regline(b.beta);
pa_unityline('k-');

X = S3(:,24);
Y = S3(:,9);
sel = abs(X)<11;
X = X(sel);
Y = Y(sel);
Y = Y-mean(Y);
subplot(133)
[TOT,uX,uY] = pa_bubbleplot(X,Y,4,5);
axis([-30 30 -30 30]); 
axis square;
b = regstats(Y,X,'linear','beta');
pa_regline(b.beta);
pa_unityline('k-');


return
pa_datadir;
print('-depsc','-painter',mfilename);

function [S1,S2,S3] = getgain(subject)

switch subject
	case 'MW'
		fnames = {'RG-MW-2011-12-02-0001';'RG-MW-2011-12-02-0002';'RG-MW-2011-12-02-0003';'RG-MW-2011-12-02-0004';...
			'RG-MW-2011-12-02-0005';'RG-MW-2011-12-02-0006';'RG-MW-2011-12-02-0007';'RG-MW-2011-12-02-0008';...
			'RG-MW-2011-12-08-0001';'RG-MW-2011-12-08-0002';'RG-MW-2011-12-08-0003';'RG-MW-2011-12-08-0004';...
			'RG-MW-2012-01-11-0001';'RG-MW-2012-01-11-0002';'RG-MW-2012-01-11-0003';'RG-MW-2012-01-11-0004';...
			'RG-MW-2012-01-12-0005';'RG-MW-2012-01-12-0006';'RG-MW-2012-01-12-0007';'RG-MW-2012-01-12-0008';...
			'RG-MW-2012-01-19-0001';'RG-MW-2012-01-19-0002';'RG-MW-2012-01-19-0003';'RG-MW-2012-01-19-0004';...
			};
		conditions = [3 2 3 1,...
			3 2 1 3,...
			2 3 1 3,...
			2 3 1 3,...
			3 1 3 2,...
			1 3 3 2
			];
	case  'LJ'
		fnames = {    'RG-LJ-2011-12-14-0001';'RG-LJ-2011-12-14-0002';'RG-LJ-2011-12-14-0003';'RG-LJ-2011-12-14-0004';...
			'RG-LJ-2011-12-14-0005';'RG-LJ-2011-12-14-0006';'RG-LJ-2011-12-14-0007';'RG-LJ-2011-12-14-0008';...
			'RG-LJ-2011-12-21-0001';'RG-LJ-2011-12-21-0002';'RG-LJ-2011-12-21-0003';'RG-LJ-2011-12-21-0004';...
			'RG-LJ-2011-12-21-0005';'RG-LJ-2011-12-21-0006';'RG-LJ-2011-12-21-0007';'RG-LJ-2011-12-21-0008';...
			'RG-LJ-2012-01-10-0001';'RG-LJ-2012-01-10-0002';'RG-LJ-2012-01-10-0003';'RG-LJ-2012-01-10-0004';...
			'RG-LJ-2012-01-10-0005';'RG-LJ-2012-01-10-0006';'RG-LJ-2012-01-10-0007';'RG-LJ-2012-01-10-0008';...
			'RG-LJ-2012-01-17-0001';'RG-LJ-2012-01-17-0002';'RG-LJ-2012-01-17-0003';'RG-LJ-2012-01-17-0004';...
			};
		conditions = [
			2 3 1 3,...
			1 2 3 3,...
			3 1 3 2 ...
			3 2 1 3 ...
			2 3 1 3 ...
			3 3 1 2 ...
			3 2 3 1 ...
			];
	case 'RO'
		fnames = {
			'RG-RO-2011-12-12-0001';'RG-RO-2011-12-12-0002';'RG-RO-2011-12-12-0003';'RG-RO-2011-12-12-0004';...
			'RG-RO-2011-12-12-0005';'RG-RO-2011-12-12-0006';'RG-RO-2011-12-12-0007';'RG-RO-2011-12-12-0008';...
			'RG-RO-2012-01-11-0001';'RG-RO-2012-01-11-0002';'RG-RO-2012-01-11-0003';'RG-RO-2012-01-11-0004';...
			'RG-RO-2012-01-11-0005';'RG-RO-2012-01-11-0006';'RG-RO-2012-01-11-0007';'RG-RO-2012-01-11-0008';...
			'RG-RO-2012-01-18-0001';'RG-RO-2012-01-18-0002';'RG-RO-2012-01-18-0003';'RG-RO-2012-01-18-0004';...
			'RG-RO-2012-01-18-0005';'RG-RO-2012-01-18-0006';'RG-RO-2012-01-18-0007';'RG-RO-2012-01-18-0008';...
			};
		conditions = [
			3 2 1 3,...
			1 3 2 3,...
			3 1 3 2 ...
			3 2 1 3 ...
			2 3 1 3 ...
			3 1 3 2 ...
			];
	case 'HH'
		fnames = {
			'RG-HH-2011-11-24-0001';'RG-HH-2011-11-24-0002';'RG-HH-2011-11-24-0003';'RG-HH-2011-11-24-0004';...
			'RG-HH-2011-12-12-0001';'RG-HH-2011-12-12-0002';'RG-HH-2011-12-12-0003';'RG-HH-2011-12-12-0004';...
			'RG-HH-2012-01-09-0001';'RG-HH-2012-01-09-0002';'RG-HH-2012-01-09-0003';'RG-HH-2012-01-09-0004';...
			'RG-HH-2012-01-09-0005';'RG-HH-2012-01-09-0006';'RG-HH-2012-01-09-0007';'RG-HH-2012-01-09-0008';...
			'RG-HH-2012-01-13-0001';'RG-HH-2012-01-13-0002';'RG-HH-2012-01-13-0003';'RG-HH-2012-01-13-0004';...
			'RG-HH-2012-01-13-0005';'RG-HH-2012-01-13-0006';'RG-HH-2012-01-13-0007';'RG-HH-2012-01-13-0008';...
			};
		conditions = [
			3 2 3 1,...
			1 3 3 2,...
			2 3 1 3 ...
			3 3 1 2 ...
			2 3 1 3 ...
			3 1 2 3 ...
			];
	case 'RG'
		fnames = {
			'MW-RG-2011-12-08-0001';'MW-RG-2011-12-08-0002';'MW-RG-2011-12-08-0003';'MW-RG-2011-12-08-0004';...
			'MW-RG-2011-12-08-0005';'MW-RG-2011-12-08-0006';'MW-RG-2011-12-08-0007';'MW-RG-2011-12-08-0008';...
			'MW-RG-2012-01-12-0001';'MW-RG-2012-01-12-0002';'MW-RG-2012-01-12-0003';'MW-RG-2012-01-12-0004';...
			'MW-RG-2012-01-12-0005';'MW-RG-2012-01-12-0006';'MW-RG-2012-01-12-0007';'MW-RG-2012-01-12-0008';...
			};
		conditions = [
			2 2 3 1,...
			3 3 1 3,...
			3 2 3 1 ...
			2 3 1 3 ...
			];
end

%% Pool data
col = ['r';'g';'b';];
for ii = 1:3
	sel         = conditions == ii;
	condfnames  = fnames(sel);
	nsets       = length(condfnames);
	SS			= [];
	for jj = 1:nsets
		fname		= condfnames{jj};
		pa_datadir(['Prior\' fname(1:end-5)]);
		load(fname); %load fnames(ii) = load('fnames(ii)');
		SupSac  = pa_supersac(Sac,Stim,2,1);
		SS		= [SS;SupSac]; %#ok<AGROW>
	end
switch ii
	case 1
		S1 = SS;
	case 2
		S2 = SS;
	case 3
		S3 = SS;
end
end



function [TOT,uX,uY] = pa_bubbleplot(X,Y,colindx,afrnd)
% PA_BUBBLEPLOT(X,Y)
%
% Make a bubbleplot of Y vs X.
%
% PA_BUBBLEPLOT(X,Y)

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@gmail.com

%% Initialization
if nargin<3
	colindx = 4;
end
msmult	= 15;
if nargin<4
	afrnd = 2.5;
end

%% Histogram
X		= round(X/afrnd)*afrnd;
Y		= round(Y/afrnd)*afrnd;
uX		= unique(X);
uY		= unique(Y);
x		= uY;
TOT		= NaN(length(uX),length(x));
for i	= 1:length(uX)
	sel			= X == uX(i);
	r			= Y(sel);
	N			= hist(r,x);
	TOT(i,:)	= N;
end
%% Normalize
% TOT		= log10(TOT+1);
mxTOT	= nanmax(nanmax(TOT));
mnTOT	= nanmin(nanmin(TOT));
TOT		= (TOT-mnTOT)./(mxTOT-mnTOT);
mxTOT	= nanmax(TOT,[],2);
mxTOT	= repmat(mxTOT,1,size(TOT,2));
TOT		= TOT./mxTOT;
[m,n]	= size(TOT);

%% Color map
uTOT = unique(TOT(:));
nm = numel(uTOT);
if colindx==1 % Red
	colmap = flipud(hot(nm));
elseif colindx==2 % Green
	colhot = flipud(hot(nm));
	colmap = colhot;
	colmap(:,1) = colhot(:,3);
	colmap(:,3) = colhot(:,1);
elseif colindx==3 % Blue
	colhot = flipud(hot(nm));
	colmap = colhot;
	colmap(:,1) = colhot(:,2);
	colmap(:,2) = colhot(:,1);
else
	colmap = flipud(gray(nm));
end

%% Plot
for ii = 1:m
	for jj = 1:n
		m		= msmult*TOT(ii,jj);
		indx	= (uTOT==TOT(ii,jj));
		col		= colmap(indx,:);
		if m>0
			if m>2
				plot(uX(ii),x(jj),'ko','MarkerSize',m,'MarkerFaceColor',col,'MarkerEdgeColor',col);
				hold on
			else
				plot(uX(ii),x(jj),'k.','Color',[.9 .9 .9]);
				hold on
			end
		end
	end
end


