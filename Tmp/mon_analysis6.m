function mon_analysis6

close all force hidden
clear all

% alldata

[y,xMet1,xMet2,x1] = getdata;
% x1 = x1;
% x1
% x1 = ones(size(y));

xMet1 = round(xMet1/10)*10;
y = round(y/10)*10;
xMet2 = round(xMet2/10)*10;
x = [xMet1 y];

whos x
[N,ux] = pa_countunique(x);

whos xMet1 y xMet2 N ux Cnt
figure(1)
scatter(ux(:,1),ux(:,2),N.*10,'filled','r');
axis square;
box off;
xlim([-100 100]);
ylim([-100 100]);
pa_unityline('k:');
set(gca,'TickDir','out','Xtick',-90:30:90,'Ytick',-90:30:90);
xlabel('Target azimuth (deg)');
ylabel('Response azimuth (deg)');

pa_datadir;
print('-depsc','-painter',mfilename);

return

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



function [y,x1,x2,s] = getdata

% [azC1 azS1 intC1 intS1]=mlreg2('sw01','adaptplug');
% [azC2 azS2 intC2 intS2]=mlreg2('te01','adaptplug');
% [azC3 azS3 intC3 intS3]=mlreg2('jv03','adaptplug');
% [azC4 azS4 intC4 intS4]=mlreg2('hv01','adaptplug');
fnames	= {'sw01','te01','jv03','hv01'};

n  = numel(fnames);
gain = NaN(n,1);
B = NaN(n,4,2);
y = [];
x1 = [];
x2 = [];
s = [];
for ii = 1:4
	
	SupSac = consider(fnames{ii},'adaptplug');
sel    = SupSac(:,26)==2;
HP     = SupSac(sel,:);
T     = HP(:,23);
R    = HP(:,8);
% I    = HP(:,25);



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
	end
	
	
HSE = 9.7*sin(0.02*T+0.27);
y	= [y;R]; %#ok<*AGROW>
x1	= [x1;T];
x2	= [x2;I];
s = [s;repmat(ii,size(R))];
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
    cd(['E:\DATA\Adaptation\Adaptation Plug 2\' dirname])
elseif nargin==2
    if ~strcmpi(expname,'plug') && ~strcmpi(expname,'owl');
        cd(['E:\DATA\Adaptation\Adaptation Plug 2\' dirname])
    else
        k=strfind(dirname,'-');
        session = dirname(1:k(2)-1);
        cd(['E:\DATA\Adaptation\Adaptation Plug 2\' session '\' dirname])
    end
end

