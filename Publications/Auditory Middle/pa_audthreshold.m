function pa_audmaa(fname,dname)
% PA_AUDMAA
%
% Determine MAA minimum audible angle
if nargin<1
	dname = 'E:\DATA\Test\Auditory Center\MA-MW-2012-09-04';
	fname = 'MA-MW-2012-09-04-0000.dat';
	
	dname = 'E:\DATA\Test\Auditory Center\RG-MW-2012-10-09';
	fname = 'RG-MW-2012-10-09-0001.dat';
	
	dname = 'E:\DATA\Test\Auditory Center\MW-BB-2012-10-23';
	fname = 'MW-BB-2012-10-23-0001.dat';
end
cd(dname)

dat		= pa_loaddat(fname,8,5000);
btn1		= squeeze(dat(:,:,4));
btn2		= squeeze(dat(:,:,8));

btn1 = btn1;
btn2 = abs(btn2);

% btn1 = btn1 - min(btn1);
% btn2 = btn2 - min(btn2);

[expinfo,chaninfo,mLog]             = pa_readcsv(fname);

ntrials = size(btn1,2);
R1 = NaN(ntrials,1);
L = R1;
R2 = R1;
for ii = 1:ntrials
	b1 = btn1(:,ii)-min(btn1(:,ii));
	b2 = btn2(:,ii)-min(btn2(:,ii));
	R1(ii) = any(b1>1.5e-3);
	R2(ii) = any(b2>1.5e-3);
	
	sel30 = mLog(:,1) == ii & mLog(:,7)==30;
	selmov = mLog(:,1) == ii & mLog(:,7)==12;
	
	L(ii) = mLog(selmov,6);
	
	
	% 		figure(1)
	% 		clf;
	% 		subplot(121)
	% 		cla;
	% 		plot(b1,'k-');
	% 		hold on
	% 		plot(b2,'r-');
	%
	% 		axis square;
	%
	% 		subplot(122)
	% 		cla;
	% 		axis([-60 0 -1 1]);
	% 	pause(.1)
	
end

L = L(3:end);
R1 = R1(3:end);
R2 = R2(3:end);


%% Analysis
nWords		= 12; % Number of words in a NVA-list
nChan		= 16; % number of channels in vocoder
maxScore	= 36; % one list contains 12 words with 3 phonemes each
chanArray	= 1:nChan;


L = round(L/5)*5;
uL = unique(L);
nL = length(uL);
mR1 = uL;
sR1 = uL;
mR2 = uL;
sR2 = uL;
nRep = uL;
xyn			= NaN(nL,4);
% m = min(uL);
% uL = uL-m+1;
% L = L-m+1;
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

xyn
%% Psychometric function
shape		= 'w';
x			= 1:0.1:nL;

S			= pfit(xyn(:,1:3),'no plot', 'shape',shape, 'n_intervals', 1); % from psignifit tool
params		= S.params.est;% estimated psychometric function parameters
pf			= 100*psi(shape, params, x); % graph
[~,indx]	= min(abs(pf-80));

%% Visualization
figure
h = errorbar(1:nL, xyn(:,2), 1.96*xyn(:,4)./sqrt(xyn(:,3)),'ko','MarkerFaceColor','w','MarkerSize',10,'LineWidth',2);
set(h,'Color',[.7 .7 .7]);
hold on
plot(x,pf,'k-','LineWidth',2);
xlabel ('Location moving speaker (deg)');
ylabel ('Right (%)');
% axis([0 17 -20 120]);
axis square;
pa_horline([0 50 100]);
set(gca,'Xtick',1:nL,'XTickLabel',uL);
box off;

[~,indx] = min(abs(pf-50));
title((x(indx)*5)-5+min(uL));
pa_verline(x(indx));
return
% sel = W1==1;
% D(sel) = -D(sel);
% R(sel) = ~R(sel);

L = round(L/5)*5;
uL = unique(L);
nL = length(uL);
mR1 = uL;
sR1 = uL;
mR2 = uL;
sR2 = uL;
for ii = 1:nL
	sel = L == uL(ii);
	mR1(ii) = mean(R1(sel));
	sR1(ii) = 1.96*std(R1(sel))./sum(sel);
	
	mR2(ii) = mean(R2(sel));
	sR2(ii) = 1.96*std(R2(sel))./sum(sel);
end

errorbar(uL,mR1,sR1,'ko-','MarkerFaceColor','w','LineWidth',2);
hold on
errorbar(uL,mR2,sR2,'ko-','MarkerFaceColor','w','LineWidth',2);
whos uL mR1 mR2
plot(uL,mR1+mR2,'ro:');
ylim([-0.2 1.2]);
xlabel('Difference Sound 1 - Sound 2 (deg)');
ylabel('Response Probability P(1>2)');
axis square;
pa_horline([0 0.5 ]);
pa_verline(0);
box off;

%
%
% selsnd1 = mLog(:,5)==2;
% sel30	= mLog(:,7)==30;
%
% sum(selsnd1)
% sum(sel30)
% sum(selsnd1 & sel30)
%
%
% mLog(1:12,[1:2 5 6 7])
