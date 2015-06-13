function pa_bose_qc2_calibration(dname,fname,varargin)
% PA_BOSE_QC2_CALIBRATION
%
% Determine calibration parameters of the Bose Quiet Comfort 2 headphones.
%
% See also AUDIOGRAM, PA_PLOT_BOSE_QC2_CALIBRATION

% 2013 Marc van Wanrooij
% Calibration performed by Michiel Dirkx, Maarten van de Kraan

%% Initialization
close all hidden

if nargin<1 % if nothing specified look in mfile's folder
	w		= which(mfilename);
	dname	= fileparts(w);
	dname = [dname '\Audiogram'];
end
dspFlag       = pa_keyval('display',varargin);
if isempty(dspFlag)
	dspFlag	= true;
end
prntFlag       = pa_keyval('print',varargin);
if isempty(prntFlag)
	prntFlag	= false;
end
if prntFlag % it does not make sens to print when nothing is shown
	dspFlag = true; % so put on a show
end
cd(dname);

if nargin<2 % search for the xlsx-file, or give input
	d = dir('*.xlsx');
	fname = d(1).name;
	fname2 = d(2).name;
end

calleft		= getcal(fname);
calright	= getcal(fname2);

%% Save
save bosecal calleft calright

if dspFlag
	plotcal(fname,0);
	plotcal(fname2,3);
	if prntFlag
		print('-depsc','-painter',mfilename);
	end
end

function cal = getcal(fname)

%% Data
N		= xlsread(fname);
freq	= N(1,2:end);
pa4		= N(2:end-1,1);
lvl		= N(2:end-1,2:end);
sel		= pa4>=20 & pa4<=60;
pa4		= pa4(sel);
lvl		= lvl(sel,:);

% if ~isempty(strfind(fname,'left'))
% 	sel = freq==16000;
% 	lvl(:,sel) = NaN;
% end

mu		= nanmean(lvl);
lvl		= bsxfun(@minus,lvl,mu);
nFreq	= numel(freq);
pa4		= repmat(pa4,1,nFreq);
lvl		= lvl(:);
pa4		= pa4(:);
b		= regstats(lvl,pa4,'linear','beta');

%% Save
cal.freq	= freq;
cal.beta	= b.beta;
cal.mu		= mu;

function plotcal(fname,sb)

%% Data
N		= xlsread(fname);
freq	= N(1,2:end);
pa4		= N(2:end-1,1);
lvl		= N(2:end-1,2:end);

%% Visualization
nFreq	= numel(freq);
col		= jet(nFreq);
subplot(2,3,1+sb)
for ii = 1:nFreq
	plot(pa4,lvl(:,ii),'ko-','MarkerFaceColor',col(ii,:))
	hold on
end

sel = pa4>=20 & pa4<=60;
pa4 = pa4(sel);
lvl = lvl(sel,:);
if ~isempty(strfind(fname,'left'))
	sel = freq==16000;
	lvl(:,sel) = NaN;
end
nPA4	= numel(pa4);
col		= jet(nPA4);

subplot(2,3,2+sb)
for ii = 1:nPA4
	semilogx(freq,lvl(ii,:),'ko-','MarkerFaceColor',col(ii,:));
	hold on
end

%% Remove mean over frequency and regress
mu		= nanmean(lvl);
lvl		= bsxfun(@minus,lvl,mu);
nFreq	= numel(freq);
pa4		= repmat(pa4,1,nFreq);
lvl		= lvl(:);
pa4		= pa4(:);
b		= regstats(lvl,pa4,'linear','beta');

subplot(2,3,3+sb)
plot(pa4,lvl,'ko','MarkerFaceColor','w');
hold on
pa_regline(b.beta);

%% labels
subplot(2,3,1+sb)
axis square
box off
xlabel('PA4 (dB)');
ylabel('Sound level (dBA)');
% legend(num2str(freq'));
title('Bose Quiet Comfort 2 Head Phones');
ylim([0 130]);
pa_verline([20 60]);
set(gca,'XTick',0:25:125,'YTick',0:25:125)

subplot(2,3,2+sb)
xlabel('Frequency (kHz)');
ylabel('Sound level (dBA)');
axis square
box off
set(gca,'XTick',freq,'XTickLabel',freq/1000);
xlim([62.5 32000]);
ylim([0 130]);
set(gca,'YTick',0:25:125)

% legend(num2str(pa4));

subplot(2,3,3+sb)
axis square
box off
xlabel('PA4 (dB)');
ylabel('Sound level - mean (dBA)');
title('Bose Quiet Comfort 2 Head Phones');
axis([10 70 -30 30]);
set(gca,'XTick',0:25:125,'YTick',0:25:125)

