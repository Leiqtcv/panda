close all
clear all
pa_datadir

%% read data
cd('/Users/marcw/DATA/Student/Ahmed');
[N,T,R] = xlsread('pitchcal.xlsx');
SL	= N(:,3); % sound level (dBA, fast, 1s)
t	= N(:,1); % time (s)
sel =~isnan(SL);
SL = SL(sel);
t = t(sel);

%% Determine onsets of sounds
dSL = [0;diff(SL)];
sel = dSL>8 & t>40 & t<2680;
ton = find(sel);
dSL = sel;

%% Graph
figure(2)
plot(t,SL,'k-');
hold on
pa_verline(t(ton),'r-');
xlim([min(t) max(t)]);

%% Determine sound level for every sound presentation
n = numel(ton);
mu = NaN(n,1);
for ii = 1:n
	idx = ton(ii)+3:ton(ii)+7;
	mu(ii) = mean(SL(idx));
end
figure(3)
subplot(131);
plot(mu,'ko-','MarkerFaceColor','w');
axis square;
box off

%%
expint = 0:10:100; % (%)
freq = 1:15; % (kHz)
[expint,freq] = meshgrid(expint,freq);

d = [1;diff(mu)]<0;
d = find(d);
n = numel(d);
S = NaN(11,15);
for ii = 1:n+1
	if ii == 1
	idx = 1:(d(ii)-1);
	elseif ii==n
	idx = d(ii-1):(d(ii)-1);
	else
		idx = d(ii-1):(d(ii-1)+6);
	end
	m = mu(idx);
	nm = numel(m);
	whos m S
	S(end-nm+1:end,ii) = m;
end

figure(3)
subplot(132)
whos expint S
plot(expint(ii,:)+ii*10,S(:,ii)','o-','MarkerFaceColor','w');
col = pa_statcolor(15,[],[],[],'def',6);
for ii = 1:15
plot(expint(ii,:),S(:,ii)','ko-','MarkerFaceColor',col(ii,:));
hold on
end
xlabel('Exp file Intensity');
ylabel('Sound Level (dBA)');
axis square;
box off


%% Interpolation
for ii = 1:15
	x = S(:,ii);
	y = expint(ii,:)';
sel = isnan(x) | isnan(y);
x = x(~sel);
y = y(~sel);
yi = interp1(x,y,55);
Y(ii) = round(yi);
end

figure(3)
subplot(133)
semilogx((1:15),Y,'ko-','MarkerFaceColor','w');
set(gca,'XTick',(1:15));
box off
xlim([0.5 30]);
ylim([20 70]);
axis square
save cal Y
%%
return
%%
figure
plot(d)
% for ii = 1:15
% 	idx = (ii-1)*10+1
% 	d	= 1;
% 	while d>0
% 		idx = idx+1
% 		d = mu(idx)-mu(idx-1);
% 	end
% end
%%
figure
%%
return
%%
HRTF = pa_readhrtf('pitchcal.hrtf');

%%
DC = squeeze(HRTF(:,2,:));
AC = squeeze(HRTF(:,1,:));

%%
%%

subplot(212)
plot(AC)