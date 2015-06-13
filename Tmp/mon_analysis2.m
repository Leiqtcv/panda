function mon_analysis2

close all
% [sall,aall,Par]=schaduw;

% [azC1 azS1 intC1 intS1]=mlreg('jp03','monaural','l',Par);
% [azC2 azS2 intC2 intS2]=mlreg('ie01','monaural','r',Par);
% [azC3 azS3 intC3 intS3]=mlreg('bn01','monaural','r',Par);
% [azC4 azS4 intC4 intS4]=mlreg('po01','monaural','l',Par);
% SupSac=consider('rh01','adapt');
% [azC6 azS6 intC6 intS6]=mlreg('cd01','monaural','l',Par);
% [azC7 azS7 intC7 intS7]=mlreg('sb01','monaural','l',Par);
% [azC8 azS8 intC8 intS8]=mlreg('gk01','monaural','l',Par);
% [azC9 azS9 intC9 intS9]=mlreg('ld01','monaural','l',Par);

% fnames	= {'bn01','cd01','gk01','ie01','jp03','ld01','po01','rh01','sb01','kh01','wa01','ku01','sv01'}; % including Martijn
% d		= {'l';'r';'r';'l';'r';'r';'r';'l';'o';'l';'l';'r';'l'};
% con		= [0 1 0 1 1 1 0 1 1 1 0 0 0];
fnames	= {'bn01','cd01','gk01','ie01','jp03','ld01','po01','rh01','sb01'};
d		= {'l';'r';'r';'l';'r';'r';'r';'l';'r';};
con		= [0 1 0 1 1 1 0 1 1];

n  = numel(fnames);
gain = NaN(n,1);
B = NaN(n,7,2);
for ii = 1:n
	if strcmpi(fnames{ii},'rh01')
		SupSac = consider('rh01','adapt'); %#ok<*NASGU>
		splittom;
		HP		= BB;
		stim	= 'HP';
		% stim = 'BB';
		
	else
		SupSac  = consider(fnames{ii},d{ii});
		sel     = SupSac(:,26)==2;
		stim	= 'HP';
		% stim = 'BB';
		if sum(sel)==0
			sel     = SupSac(:,26)==2;
			stim = 'HP';
			
		end
		HP      = SupSac(sel,:);
	end
	R = HP(:,8);
	T = HP(:,23);
	d(ii)
	switch d{ii}
		case 'r'
			R = -R;
			T = -T;
	end
	I = 90+HP(:,25);
	minI = min(I);
	switch minI
		case 27
			I = I+3;
		case 32
			I = I-2;
		case 29
			I = I+1;
		otherwise
			I = HP(:,27);
			% 		keyboard
			fnames{ii}
			unique(I)
			% 		error('uh-oh');
	end
	
	uI = unique(I);
	nI = numel(uI);
	
	for intIdx = 1:nI
		sel = I==uI(intIdx);
	figure(ii)
		subplot(2,4,intIdx)
	h = plot(T(sel),R(sel),'k.');
	% 	set(h,'MarkerFaceColor',[.7 .7 1],'MarkerEdgeColor','none');
	set(gca,'TickDir','out','Xtick',-80:20:80,'YTick',-80:20:80);
	axis([-90 90 -90 90]);
	axis square
	box off
	drawnow
	xlabel('Stimulus \alpha');
	ylabel('Response \alpha');
	b = regstats(R(sel),T(sel),'linear','beta');
	B(ii,intIdx,:) = b.beta;
	h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
	gain(ii) = b.beta(2);
	if b.beta(1)<0
		plsmn = '-';
	else
		plsmn = '+';
	end
	str = [upper(fnames{ii}(1:2)) ',' stim ': \alpha_T = ' num2str(b.beta(2),2) '\alpha_R' plsmn num2str(abs(b.beta(1)),2)];
	title(str)
	drawnow
	end
	
			sel = I==uI(intIdx);
	figure(ii)
		subplot(2,4,8)
	h = scatter(T,R,70,I,'filled');
	% 	set(h,'MarkerFaceColor',[.7 .7 1],'MarkerEdgeColor','none');
	set(gca,'TickDir','out','Xtick',-80:20:80,'YTick',-80:20:80);
	axis([-90 90 -90 90]);
	axis square
	box off
	drawnow
	xlabel('Stimulus \alpha');
	ylabel('Response \alpha');
	b = regstats(R,T,'linear','beta');
	h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
	gain(ii) = b.beta(2);
	if b.beta(1)<0
		plsmn = '-';
	else
		plsmn = '+';
	end
	str = [upper(fnames{ii}(1:2)) ',' stim ': \alpha_T = ' num2str(b.beta(2),2) '\alpha_R' plsmn num2str(abs(b.beta(1)),2)];
	title(str)
	drawnow
end

% keyboard
%%
figure(666);
subplot(131)
x = squeeze(B(:,:,1));
y = squeeze(B(:,:,2));
plot(x,y,'ko'); 
hold on
xlim([-90 90]);
ylim([-0.2 1.2]); 
axis square; 
box off
set(gca,'TickDir','out');
pa_horline(0,'k:');
pa_verline(0,'k:');

plot([-90 0],[0 1],'k:');
plot([90 0],[0 1],'k:');
sel = x>0;
	b = regstats(y(sel),x(sel),'linear','beta');
	h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);
sel = x<0;
	b = regstats(y(sel),x(sel),'linear','beta');
	h = pa_regline(b.beta,'k-'); set(h,'LineWidth',2);

subplot(132)
plot(uI,squeeze(B(:,:,1))','k-'); 
ylim([-90 90]);
xlim([25 65]); 
axis square; 
box off
set(gca,'TickDir','out');

subplot(133)
plot(uI,squeeze(B(:,:,2))','k-'); 
xlim([25 65]); 
ylim([-0.2 1.2]); 
axis square; 
box off
set(gca,'TickDir','out');
%%
return
%%
pa_datadir;
load('monaudio')
hl(isnan(hl)) = 20;


% return
sel		= strcmpi('kh01',names);
hl(sel) = NaN;

a	= char(names);
b	= fnames;
a	= a(:,1:2);
HL	= NaN(n,1);
CON = NaN(n,1);
for ii = 1:n
	sel = strncmpi(a(ii,1:2),b,2);
	idx(ii) = find(sel);
	if sum(sel)
		HL(ii) = hl(sel);
		CON(ii) = con(sel);
		N{ii} = b{sel};
		
	end
end


N = char(N);
N = N(:,1:2);



CON		= con(idx);
gain = gain(idx);
HL		= hl;

% return
HL = pa_dba2dbhl(HL,8000,3);
sel		= strcmpi('po01',names);
HL(sel) = 15;
% HL(end-4:end-1) = NaN;
names((end-4:end-1))
figure(4)
plot(HL(CON==1),gain(CON==1),'ks','MarkerFaceColor','k','MarkerSize',15);
hold on
plot(HL(CON==0),gain(CON==0),'ks','MarkerFaceColor','w','MarkerSize',15);

text(HL(CON==0),gain(CON==0),N(CON==0,:),'VerticalAlignment','middle','HorizontalAlignment','center');
text(HL(CON==1),gain(CON==1),N(CON==1,:),'VerticalAlignment','middle','HorizontalAlignment','center','Color','w');
xlim([-20 75]);
ylim([-0.1 1.1]);
axis square
box off
set(gca,'TickDir','out');
xlabel('Hearing Loss (dB HL)');
ylabel('Azimuth Gain');

pa_datadir;
figure(1)
print('-depsc',[mfilename '_1']);
figure(2)
print('-depsc',[mfilename '_2']);
figure(4)
print('-depsc',[mfilename '_3']);
save('martijnSSD','HL','CON','gain');
% keyboard
return

[azC1 azS1 intC1 intS1]=mlreg('jp03','monaural','l',Par);
[azC2 azS2 intC2 intS2]=mlreg('ie01','monaural','r',Par);
[azC3 azS3 intC3 intS3]=mlreg('bn01','monaural','r',Par);
[azC4 azS4 intC4 intS4]=mlreg('po01','monaural','l',Par);
SupSac=consider('rh01','adapt');
splittom;
az     = HP(:,23); azr    = HP(:,8); int    = HP(:,27); intc   = sinfun(az,Par);
int    = int+intc;
az     = pnorm(az);
azr    = pnorm(azr);
int    = pnorm(int);
X        = [az int];
Y        = azr;
[c,s,T,Pc,Rp,F,Pf,R,Pr,CB]    = linreg(X,Y);
azC5     = c(1); azS5 = s(1);
intC5     = c(2); intS5 = s(2);
[azC6 azS6 intC6 intS6]=mlreg('cd01','monaural','l',Par);
[azC7 azS7 intC7 intS7]=mlreg('sb01','monaural','l',Par);
[azC8 azS8 intC8 intS8]=mlreg('gk01','monaural','l',Par);
[azC9 azS9 intC9 intS9]=mlreg('ld01','monaural','l',Par);
azC=[azC3;azC6;azC8;azC2;azC1;azC9;azC4;azC5;azC7];
intC=[intC3;intC6;intC8;intC2;intC1;intC9;intC4;intC5;intC7];
azS=[azS3;azS6;azS8;azS2;azS1;azS9;azS4;azS5;azS7];
intS=[intS3;intS6;intS8;intS2;intS1;intS9;intS4;intS5;intS7];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% GRAPH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
range=[-0.2 1.2 -0.2 1.2];
h3=plot([-0.2 1.2], [-0.2 1.2], 'k:'); hold on; h4=plot([-0.2 1.2], [1.2 -0.2], 'k:');
h5=plot([0 1],[0 0],'k:'); h6=plot([0 0],[0 1],'k:'); h7=plot([0 1],[1 1],'k:'); h8=plot([1 1],[0 1],'k:'); axis(range)
h1=plot(azC,intC,'ko'); set(h1,'MarkerSize',5,'MarkerFaceColor',[0.2 0.2 0.2]);
% Text
text(azC(1)-0.02,intC(1)-0.06,'BN','HorizontalAlignment','center','FontUnits','points','FontSize',8*1.3858);
text(azC(2),intC(2)-0.06,'CD','HorizontalAlignment','center','FontUnits','points','FontSize',8*1.3858);
text(azC(3)+0.04,intC(3)+0.06,'GK','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(4),intC(4)-0.06,'IE','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(5),intC(5)-0.06,'JP','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(6),intC(6)-0.06,'LD','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(7),intC(7)-0.06,'PO','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(8),intC(8)-0.06,'RH','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(9),intC(9)-0.06,'SB','HorizontalAlignment','center','FontSize',8*1.3858,'FontUnits','points');
text(azC(4)+0.04,intC(4)-0.06,'*','HorizontalAlignment','left','FontSize',8*1.3858,'FontUnits','points');
text(azC(5)+0.04,intC(5)-0.06,'*','HorizontalAlignment','left','FontSize',8*1.3858,'FontUnits','points');
text(azC(7)+0.05,intC(7)-0.06,'*','HorizontalAlignment','left','FontSize',8*1.3858,'FontUnits','points');
text(1+0.03,0,'**','HorizontalAlignment','left');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% BINAURALS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[azC1 azS1 intC1 intS1]=mlreg2('sw01','adaptplug');
[azC2 azS2 intC2 intS2]=mlreg2('te01','adaptplug');
[azC3 azS3 intC3 intS3]=mlreg2('jv03','adaptplug');
[azC4 azS4 intC4 intS4]=mlreg2('hv01','adaptplug');
SupSac=consider('mw07','adapt');
splittom
az     = HP(:,23);
azr    = HP(:,8);
int    = HP(:,27);
az     = pnorm(az);
azr    = pnorm(azr);
int    = pnorm(int);
X        = [az int];
Y        = azr;
[c,s,T,Pc,Rp,F,Pf,R,Pr,CB]    = linreg(X,Y);
azC5     = c(1); azS5 = s(1);
intC5     = c(2); intS5 = s(2);
[azC6 azS6 intC6 intS6]=mlreg2('mt01','adaptplug');
azC=[azC4;azC3;azC6;azC5;azC1;azC2];
intC=[intC4;intC3;intC6;intC5;intC1;intC2];
azS=[azS4;azS3;azS6;azS5;azS1;azS2];
intS=[intS4;intS3;intS6;intS5;intS1;intS2];
tS2 = [azS intS];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% GRAPH %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
h2=plot(azC,intC,'k^','MarkerSize',5,'MarkerFaceColor',[0.9 0.9 0.9]); axis square;
hleg=legend([h1;h2],'Monaural','Binaural'); set(hleg,'FontUnits','points','FontSize',8*1.3858);
tekst(0.5,-0.15,'Azimuth coefficient','HorizontalAlignment','center','FontUnits','points','FontSize',11*1.3858);
tekst(-0.24,0.5,'Intensity coefficient','Rotation',90,'VerticalAlignment','middle','HorizontalAlignment','center','FontUnits','points','FontSize',11*1.3858);
tekst(0.5,-0.25,'k(\alpha_T)','HorizontalAlignment','center','FontUnits','points','FontSize',11*1.3858);
tekst(-0.16,0.5,'m(I_{p/f})','Rotation',90,'VerticalAlignment','middle','HorizontalAlignment','center','FontUnits','points','FontSize',11*1.3858);

set(gca,'XTick',[0 0.2 0.4 0.6 0.8 1],'YTick',[0 0.2 0.4 0.6 0.8 1],'XTickLabel',[0 0.2 0.4 0.6 0.8 1],'YTickLabel',[0 0.2 0.4 0.6 0.8 1]);
set(gca,'FontUnits','points','FontSize',8*1.3858);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% OUTPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pos = get(gca,'Position'); set(gca,'Position',[pos(1)+0.09 pos(2)+0.03 pos(3) pos(4)])
marc
print('-depsc',mfilename);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [azC,azS,intC,intS]=mlreg(subject,direct,side,Par)
% MLREG(SUBJECT,DIRECT,SIDE)
% mulitple linear regression on monaural localization data
% from subject SUBJECT in directory DIRECT. SIDE is good/hearing
% side ('l'=left, 'r'=right).

SupSac  = consider(subject,direct);
sel     = SupSac(:,26)==2;
HP      = SupSac(sel,:);
az      = HP(:,23);
azr     = HP(:,8);
int     = HP(:,25);
if strcmp(side,'l')
	az  = -az;
	azr = -azr;
end

% Head shadow effect
%[sall,aall,Par]=schaduw;

intc   = sinfun(az,Par);
int    = int+intc;
% Normalize
az     = pnorm(az);
azr    = pnorm(azr);
int    = pnorm(int);
% regr.
X        = [az int];
Y        = azr;
[c,s,T,Pc,Rp,F,Pf,R,Pr,CB]    = linreg(X,Y);
azC      = c(1); azS = s(1);
intC     = c(2); intS = s(2);

function [azC,azS,intC,intS]=mlreg2(subject,direct)
% MLREG2(SUBJECT,DIRECT)
% mulitple linear regression on binaural localization data
% from subject SUBJECT in directory DIRECT.
SupSac = consider(subject,direct);
sel    = SupSac(:,26)==2;
HP     = SupSac(sel,:);
az     = HP(:,23);
azr    = HP(:,8);
int    = HP(:,25);
% Normalize
az     = pnorm(az);
azr    = pnorm(azr);
int    = pnorm(int);
% regr.
X        = [az int];
Y        = azr;
[c,s,T,Pc,Rp,F,Pf,R,Pr,CB]    = linreg(X,Y);
azC      = c(1); azS = s(1);
intC     = c(2); intS = s(2);

function mens(dirname,expname)

% MENS(DIRNAME,EXPNAME)
%
%   Jumps to the human data-directory, DIRNAME and EXPNAME are optional
%   parameters:
%
%   cd /data/auditief/marc/data/adaptmold/
%    OR
%   cd /data/auditief/marc/data/adaptmold/DIRNAME
%    OR
%   cd /data/auditief/marc/data/EXPNAME/DIRNAME
%
%   See also AAP, HRTF
%   Ereated by: Marcus
%   Ereated at: 04-10-2002

% First check if

if     nargin==0,
	cd(['E:\DATA\'])
elseif nargin==1
	cd(['E:\DATA\Monaural Localization\' dirname])
elseif nargin==2
	if ~strcmpi(expname,'plug') && ~strcmpi(expname,'owl');
		cd(['E:\DATA\Monaural Localization\' dirname])
	else
		k=strfind(dirname,'-');
		session = dirname(1:k(2)-1);
		cd(['E:\DATA\Monaural Localization\' session '\' dirname])
	end
end

function [SupSac]=consider(subject,exp,wie)
% SUPSAC = CONSIDER(SUBJECT,EXP,WIE)
%
% This function combines all Sac-matrices of one session, and makes use of
% the SUPERSAC-function (thereby adding STIM-information).
% SUBJECT should be the session's name according to convention.
% If the batch-file SPLIT is to be used afterwards (which is standard
% practice), SUPSAC should be written literally as 'SupSac' in the MATLAB
% forum.
% FIRSTSAC is also applied to the SUPSAC-matrix.
% EXPERIMENTER is the name (string) of the experimenter's personal directory on the
% data-disk 'Augustus' or 'R\auditief:' (default: marc).
%
% See also SUPERSAC, MENS
%
% Created by: Marcus
% Created at: 01-01-2002

wd   = cd;
if nargin==1,
	mens(subject)
elseif nargin ==2
	mens(subject,exp)
elseif nargin==3,
	if isunix
		eval(['cd /data/auditief/' wie '/data/' exp '/' subject])
	else
		eval(['cd r:\' wie '\data\' exp '\' subject])
	end
end

w    = what;
file = w.mat;
n    = size(file,1);


for i=1:n,
	matfile=file{i};
	loadstr=['s' num2str(i) '=load([matfile]);'];
	eval(loadstr)
	sacstr=['Sac' num2str(i) '=s' num2str(i) '.Sac;'];
	eval(sacstr)
	stimstr=['Stim' num2str(i) '=s' num2str(i) '.Stim;'];
	eval(stimstr)
end

Sac=Sac1;
Stim=Stim1;
for j=2:n,
	Sacstr1=['Sac' num2str(j) '(:,1)=Sac' num2str(j) '(:,1)+' ...
		' Stim(size(Stim,1),1);'];
	eval(Sacstr1);
	Sacstr=['Sac=[Sac;Sac' num2str(j) '];'];
	eval(Sacstr)
	Stimstr1=['Stim' num2str(j) '(:,1)=Stim' num2str(j) '(:,1)+' ...
		' Stim(size(Stim,1),1);'];
	eval(Stimstr1)
	Stimstr=['Stim=[Stim;Stim' num2str(j) '];'];
	eval(Stimstr)
end

cd(wd)

SupSac=supersac(Sac,Stim);
SupSac=firstsac(SupSac);