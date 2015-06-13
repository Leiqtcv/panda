function pa_akaike_test

close all
clear all
s		= 5;
nrep	= 5; % number of repetitions
nrow	= 700;
x		= (1:nrow)';

%% Simulate
freq		= [4 8 16 32 8];
nfreq = numel(freq)
P		= struct([]);
for fIdx = 1:nfreq
	f		= freq(fIdx);
	rate	= sin(2*pi*f*x/1000); % acoustic modulation
	rate	= pa_sigmoid([5 2],rate); % non-linearity
	rate	= rate+0*rand(size(rate));
	rate	= rate/max(rate);
	rate	= 0.03*rate+0.01;
	plot(rate+fIdx*0.03)
	hold on

end

lambda	= repmat(rate,1,nrep);
spike	= poissrnd(lambda);

S		= struct([]);
for ii = 1:nrep
	S(ii).spiketime = find(spike(:,ii))';
end

S
% [time, r, regularity] = BayesRR(X);
sdf		= pa_spk_sdf(spike','Fs',1000,'sigma',s);
sdf70	= pa_spk_sdf(spike','Fs',1000,'sigma',70);
P		= sdf;
P70		= sdf70;

for ii = 1:2
	figure(1)
	subplot(2,2,ii)
	plot(x,rate*1000,'k-');
	hold on
	ylabel('Firing rate (spikes/s)');
	xlabel('Time (ms)');
	xlim([0 500]);
	plot(x,sdf,'r-')
	plot(x,sdf70,'b-')
	ylim([0 100]);
% 	plot(time,r*1000/ncol,'b.-');
	
	legend('Actual P','Random Sample P','Smoothed Random P');
	figure(3)
	subplot(2,2,ii)
	pa_spk_rasterplot(S);
	xlabel('Time (ms)');
	xlim([0 500]);
end
figure(1)
%
% X = (1./diff([S.spiketime]*1000))/ncol;
% figure(6667)
% plot(smooth(X,10))

M = struct([]);
for modIdx = 1:2
	%% Bottom-up rate
	
	%% + Top-down rate
	switch modIdx
		case 1
			mod		= x;
			mod		= 1+2*mod/max(x);
			Arate	= rate.*mod;
		case 2
			mod		= x;
			mod		= mod/max(x)/20;
			Arate	= rate+mod;
	end
	%% Generate spikes
	lambda	= repmat(Arate,1,nrep); % for NCOL trials
	spike	= poissrnd(lambda);
	t = 1:length(lambda);
	S = struct([]);
	for ii = 1:nrep
		S(ii).spiketime = find(spike(:,ii))';
	end
	
	%%
	
% 	X = sort([S.spiketime]);
% T = zeros(nrow,1);
% T(X) = 1;
% X = T;
% figure
% T = cumsum(ones(nrow,1));
% 	X		= pa_spk_sdf(spike','Fs',1000,'sigma',s);
% 
% b = X'/1000;
% b = b-min(b);
% b = b/max(b);
% % plot(T,b,'.')
% B = glmfit(T',[b ones(size(b))],'binomial','link','logit')
% pred = pa_logistic(B(1)+B(2)*T);
% hold on
% plot(T,pred,'k-');
% return
%%
	% 	X = sort([S.spiketime]+0.1*rand(size([S.spiketime])));
	% 	[time, r, regularity] = BayesRR(X);
	sdf		= pa_spk_sdf(spike','Fs',1000,'sigma',s);
	sdf70 =	 pa_spk_sdf(spike','Fs',1000,'sigma',70);
	A = sdf;
	A70 = sdf70;
	
	figure(1)
	subplot(2,2,2+modIdx)
	plot(x,Arate*1000,'k-');
	hold on
	ylabel('Firing rate (spikes/s)');
	xlabel('Time (ms)');
	xlim([0 500]);
	
	plot(x,sdf,'r-')
	plot(x,sdf70,'b-')
	legend('Actual A','Random Sample A','Smoothed Random A');
	
	ylim([0 100]);
	
	figure(2)
	subplot(2,1,modIdx)
	plot(P,'k-');
	hold on
	plot(A,'r-');
	
	figure(3)
	subplot(2,2,modIdx+2)
	pa_spk_rasterplot(S);
	xlabel('Time (ms)');
	xlim([0 500]);
	
	M(modIdx).A70 = A70;
	M(modIdx).P70 = P70;
	M(modIdx).P = P;
	M(modIdx).A = A;
	M(modIdx).t = [S.spiketime];
	
end


%% AIC
minfac = 1e-6;
str = {'Multiplicative','Additive'};
for modIdx = 1:2
	A70 = M(modIdx).A70(100:600);
	P70 = M(modIdx).P70(100:600);
	TD		= A70./P70;
	multpred	= TD.*P(100:600)/1000/nrep;
	TD		= A70-P70;
	addpred	= (TD+P(100:600))/1000/nrep;
	
	A = M(modIdx).A(100:600);
	Error = [mean(abs(A-addpred))-mean(abs(A-multpred))]
	C = [pa_pearson(A,addpred)-pa_pearson(A,multpred)]
% 	disp(
	t		= M(modIdx).t;
	sel		= t>100 & t<600;
	t		= t(sel)-100;
	multpred = multpred(t);
	multpred(multpred<minfac) = minfac;
	addpred = addpred(t);
	addpred(addpred<minfac) = minfac;
	Pspike1	= sum(-2*log(multpred));
	Pspike2	= sum(-2*log(addpred));
	figure(1)
	subplot(2,2,2+modIdx)
% 	t = (1:length(addpred))+100;
% 	plot(t,addpred,'k-','Color',[.7 .7 .7],'LineWidth',2);
	title({str{modIdx};['Mult AIC: ' num2str(Pspike1,5) ', Add AIC: ' num2str(Pspike2,5)]});
	
		figure(4)
	subplot(2,3,modIdx)
	P = M(modIdx).P;
	A = M(modIdx).A;
	b = regstats(A,P,'linear','beta');
	plot(P,A,'.');
	axis square;
	lsline
	title(b.beta)

	subplot(2,3,modIdx+3)
	P = 1:length(M(modIdx).P);
	A = M(modIdx).A;
	b = regstats(A,P,'linear','beta');
	plot(P,A,'.');
	axis square;
	lsline
	title(b.beta)
	
	x1 = M(modIdx).P;
	x2 = (1:length(M(modIdx).P))/length(M(modIdx).P);
	x3 = x1.*x2;
	y = M(modIdx).A';
	x = [x1;x2; x3]'; % add
% 	y = zscore(y);
% 	x = zscore(x);
	b = regstats(y,x,'linear','beta');
% 	b.beta

		
	subplot(2,3,(modIdx-1)*3+3)
	plot3(x1,x3,y,'.')
% end

end