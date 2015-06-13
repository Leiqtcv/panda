close all hidden
clear all hidden

cd('E:\DATA\Test\Auditory Center\MA-MW-2012-09-04');
datfile = 'MA-MW-2012-09-04-0000.dat';
dat = pa_loaddat(datfile,8,5000);
whos dat
btn = squeeze(dat(:,:,4));
[expinfo,chaninfo,mLog]             = pa_readcsv(datfile);

ntrials = size(btn,2);
R = NaN(ntrials,1);
L1 = R;
L2 = R;
W1 = R;
for ii = 1:ntrials
	R(ii) = any(btn(:,ii)>-1.5e-3);
	
	sel30 = mLog(:,1) == ii & mLog(:,7)==30;
	selmov = mLog(:,1) == ii & mLog(:,7)==12;
	if mLog(sel30,5)==2
		L1(ii) = -45;
		L2(ii) = mLog(selmov,6);
		W1(ii) = 1;
	end
	
	if mLog(sel30,5)==3
		L2(ii) = -45;
		L1(ii) = mLog(selmov,6);
	end
	
	% 	figure(1)
	% 	clf;
	% 	subplot(121)
	% 	cla;
	% 	plot(btn(:,ii));
	% 	axis square;
	% 	subplot(122)
	% 	cla;
	% 	axis([-60 0 -1 1]);
	%
	% 	if mLog(sel30,5)==2
	% 		text(-40,0,'1');
	% 		text(mLog(selmov,6),0,'2');
	% 	end
	%
	% 	if mLog(sel30,5)==3
	% 		text(-40,0,'2');
	% 		text(mLog(selmov,6),0,'1');
	% 	end
	% 	axis square;
	
end
D = L1-L2;
% sel = W1==1;
% D(sel) = -D(sel);
% R(sel) = ~R(sel);

L1 = round(D/5)*5;
uL1 = unique(L1);
nL1 = length(uL1);
mR = uL1;
sR = mR;
for ii = 1:nL1
	sel = L1 == uL1(ii);
	mR(ii) = mean(R(sel));
	sR(ii) = std(R(sel))./sum(sel);
end
errorbar(uL1,mR,sR,'ko-','MarkerFaceColor','w','LineWidth',2);
ylim([-0.2 1.2]);
xlabel('Difference Sound 1 - Sound 2 (deg)');
ylabel('Response Probability P(1>2)');
axis square;
pa_horline([0 0.5  1]);
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
