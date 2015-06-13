function [BF,cri] = rm_bf(fname,meth,dsp)
if nargin<3
	dsp = 1;
end
if nargin<2
	meth = 2;
end
% fname = [fname '.f32'];
dat		= spikematf(fname,1);
%%
swlen = dat.sweeplength;
stim  = dat.stim;
rept  = stim(2);


N = NaN(length(dat),1);
F = N;
L = N;
B = N;
A = [];
for i = 1:length(dat)
	b = full(mean(dat(i).sweeps));
	a = full([dat(i).sweeps]);
	A = [A;a];
	
	t=1:length(b);
	sel = t>=300 & t<=450;
	N(i) = sum(b(sel)); % number of spikes
	F(i) = dat(i).stim(1);
	L(i) = dat(i).stim(2);
	B(i) = sum(b(~sel));
	
end
ll = swlen- 150;
uF	= round(unique(F));
N	= N*1000/rept/150; % firing rate (spikes/sec)
B   = B*1000/rept/ll;
nrm = nanmean(N);
[mx, indx] = max(N);
cri = mx/(mean(B)+2*std(B));
% B	= B*1000/rept/(max(t)-200); % firing rate (spikes/sec)
% baseline	= nanmean(B)
% sd			= nanstd(B)

sel = L==70;
X(1,:) = F(sel);
Y(1,:) = L(sel);
Z(1,:) = N(sel);
hold on
sel = L==50;
X(2,:) = F(sel);
Y(2,:) = L(sel);
Z(2,:) = N(sel);
sel = L==30;
X(3,:) = F(sel);
Y(3,:) = L(sel);
Z(3,:) = N(sel);
sel = L==10;
X(4,:) = F(sel);
Y(4,:) = L(sel);
Z(4,:) = N(sel);


FavgI = uF;
Interpolfreq = zeros(6*12+1, 1); % N octaves at 1/12th intervals
for k=1:length(Interpolfreq)
	Interpolfreq(k) = FavgI(1)*2^((k-1)/12);
end
spline1 = spline(uF, Z(1,:), Interpolfreq);
spline2 = spline(uF, Z(2,:), Interpolfreq);
spline3 = spline(uF, Z(3,:), Interpolfreq);
spline4 = spline(uF, Z(4,:), Interpolfreq);

C = [spline1 spline2 spline3 spline4]';

%% Best Frequency
if meth==1
	% spline method
	[mx, indx] = max(C,[],2);
	BF = Interpolfreq(indx)/1000;
elseif meth==2
	% mean method
	sC			= sum(Z);
	[mx indx]	= max(sC);
	BF			= uF(indx);
	BFrate		= mx;
	baseline	= min(sC);
	sd			= std(sC);
	sel = sC>(baseline+2*sd);
	signifrate = sC(sel);
	signiffreq = uF(sel);
	% 	[s,indx] = sort(signifrate,'ascend')
	% 	F1 = signiffreq(indx(1));
	% 	F2 = signiffreq(indx(2));
	F1 = signiffreq(1);
	F2 = signiffreq(end);
	
	TWversnel = getbw(F1,F2);
	
	sel = uF<BF;
	
	S = sum(C);
	S = S-2*std(C(:));
	% 	Interpolfreq;
	sel = Interpolfreq<BF;
	f = Interpolfreq(sel);
	s = S(sel);
	[m,indx] = min(abs(s-0.5*mx));
	F1 = f(indx);
	if isempty(s)
		F1 = 125*3/2;
	end
	
	sel = Interpolfreq>BF;
	f = Interpolfreq(sel);
	s = S(sel);
	[m,indx] = min(abs(s-0.5*mx));
	F2 = f(indx);
	if isempty(s)
		F2 = 16000*2*0.5;
	end
	TW1 = getbw(F1,F2);
	TW = TWversnel;
	
elseif meth ==3;
	if max(Z(4,:)) > mean(B) + 2*std(B)
		[~,indx] = max(Z(4,:));
		BF       = X(4,indx);
	elseif max(Z(3,:)) > mean(B) + 2*std(B)
		[~,indx] = max(Z(3,:));
		BF       = X(3,indx);
	elseif max(Z(2,:)) > mean(B) + 2*std(B)
		[~,indx] = max(Z(2,:));
		BF       = X(2,indx);
	elseif max(Z(1,:)) > mean(B) + 2*std(B)
		[~,indx] = max(Z(1,:));
		BF       = X(1,indx);
	else
		BF = 0;		
	end
	
end

if dsp
	Interpolfreq = Interpolfreq(:);
	subplot(221)
	imagesc(X(1,:),Y(:,1),Z);
	axis square;
	
	subplot(224)
	pa_spk_dotplot(A,'markersize',5);
	pa_verline([300 450],'r-');
	pa_horline(cumsum(rept*4*ones(13,1)),'r-')
	
	subplot(222)
	hold on
	plot(uF,sC,'ko-','LineWidth',2);
	set(gca,'Xscale','log');
	axis square
	xlabel('Frequency (Hz)');
	ylabel('Sound Level');
	set(gca,'XScale','log');
	set(gca,'XTick',uF,'XTickLabel',uF);
	xlim([min(uF) max(uF)]);
	title(TW)
	pa_horline(baseline);
	pa_horline(baseline+2*sd);
	pa_verline([F1,F2],'k--');
	
	subplot(223)
	x = log2(uF);
	plot(log2(uF),sC,'k-');
	pa_verline(log2(BF))
	x = linspace(min(x),max(x),100);
	y = normpdf(x,log2(BF),TW/2);
	y = y./max(y);
	y = y*(max(sC)-min(sC));
	y = y+min(sC);
	hold on
	plot(x,y,'r-','LineWidth',2);
	drawnow
end