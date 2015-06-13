function aa = pa_audcenter_aa(fname,dname)
% PA_AUDCENTER_AA
%
% Determine audible angle

% (c) Marc van Wanrooij 2012
% e-mail: marcvanwanrooij@neural-code.com

%% Initialization
if nargin<1
% 	dname = 'E:\DATA\Test\Auditory Center\MA-MW-2012-09-04';
% 	fname = 'MA-MW-2012-09-04-0000.dat';
% 	
% 	dname = 'E:\DATA\Test\Auditory Center\RG-MW-2012-10-09';
% 	fname = 'RG-MW-2012-10-09-0001.dat';
	
	dname = 'E:\DATA\Test\Auditory Center\MW-BB-2012-10-23';
	fname = 'MW-BB-2012-10-23-0002.dat';
	
		dname = 'E:\DATA\Test\Auditory Center\RG-MW-2012-10-29';
	fname = 'RG-MW-2012-10-29-0002.dat';
end
cd(dname)

%% Load data
dat		= pa_loaddat(fname,8,5000); % data
btn1	= squeeze(dat(:,:,4)); % button 1 = right
btn2	= squeeze(dat(:,:,8)); % button 2 = left
btn2	= abs(btn2);
[~,~,mLog]             = pa_readcsv(fname); % log-file

%% Response behavior
ntrials = size(btn1,2);
R1		= NaN(ntrials,1); % Response 1
L		= R1; % location moving speaker
R2		= R1; % Response 2
for ii = 1:ntrials
	b1 = btn1(:,ii)-min(btn1(:,ii));
	b2 = btn2(:,ii)-min(btn2(:,ii));
	R1(ii) = any(b1>1.5e-3);
	R2(ii) = any(b2>1.5e-3);
	
	selmov = mLog(:,1) == ii & mLog(:,7)==12;
	L(ii) = mLog(selmov,6);
end

L	= L(3:end);
R1	= R1(3:end);
R2	= R2(3:end);

%% Analysis
L		= round(L/5)*5;
uL		= unique(L);
nL		= length(uL);
mR1		= uL;
sR1		= uL;
mR2		= uL;
sR2		= uL;
nRep	= uL;
xyn		= NaN(nL,4);
for ii = 1:nL
	sel = L == uL(ii);
	mR1(ii)		= mean(R1(sel));
	sR1(ii)		= std(R1(sel));
	
	mR2(ii)		= mean(R2(sel));
	sR2(ii)		= std(R2(sel));
	
	nRep(ii)		= sum(sel);
	percentage	= 100*mR1(ii);
	perfSD		= 100*sR1(ii);
	
	xyn(ii,:) = [ii percentage nRep(ii) perfSD];
end
%% Psychometric function
shape		= 'w'; % w l c g 
x			= 1:0.1:nL;

S			= pfit(xyn(:,1:3),'no plot', 'shape',shape, 'n_intervals', 1); % from psignifit tool
params		= S.params.est;% estimated psychometric function parameters
pf			= 100*psi(shape, params, x); % graph
% keyboard
[~,indx] = min(abs(pf-50));
aa = (x(indx)*5)-5+min(uL); % audible angle threshold
% keyboard
%% Visualization
h = errorbar(1:nL, xyn(:,2), 1.96*xyn(:,4)./sqrt(xyn(:,3)),'ko','MarkerFaceColor','w','MarkerSize',10,'LineWidth',2);
set(h,'Color',[.7 .7 .7]);
hold on
plot(x,pf,'k-','LineWidth',2);
xlabel ('Location moving speaker (deg)');
ylabel ('Right (%)');
axis([x(1) x(end) -20 120]);
axis square;
pa_horline([0 50 100]);
set(gca,'Xtick',1:nL,'XTickLabel',uL);
box off;

title(aa);
pa_verline(x(indx));
