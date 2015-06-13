
clc
close all hidden;
clear all hidden;



sd = [4 3.8 2.8];
p = [10 30 50];
g = [0.8 0.95 1];
for ii = 1:3
	x = -60:0.1:60;
	y = p(ii)*2*(rand(size(x))-0.5);
	sbox(ii) = std(y);
	indx	= min(x):max(x);
	N		= hist(y,indx);
	N		= N./sum(N)/1;
	y		= normpdf(x,0,sbox(ii));
	
	r		= g(ii)*30+sd(ii)*randn(size(x));
	indx	= min(x):max(x);
	R		= hist(r,indx);
	R		= R./sum(R)/1;
	r		= normpdf(x,g(ii)*30,sd(ii));
	
	subplot(3,1,ii)
	plot(indx,N,'g-','LineWidth',2)
	hold on
	plot(x,y,'g:','LineWidth',2)
	plot(indx,R,'b-','LineWidth',2);
	plot(x,r,'b:','LineWidth',2)
	% axis off
	pa_verline(30,'k-');
end

figure
plot(p,sbox)
mean(sbox./p)


%% Something



s		= 0:.1:20;
sp		= 5:.1:40;
[s,sp] = meshgrid(s,sp);
S		= s.^2;
SP		= sp.^2;

G		= 1 - S./SP;

figure
caxis([0 50]);
contourf(s,G,sp,0:2.5:50);
cax = caxis;
hold on
axis square
axis([0 10 0 1]);
cax = caxis
col = colormap;
% indx = 0:length(col)-1;
indx = linspace(cax(1),cax(2),length(col));
for ii = 1:3
	[mn,idx] = min(abs(indx-0.5783*p(ii)));
	plot(sd(ii),g(ii),'ko','MarkerFaceColor',col(idx,:),'MarkerSize',15,'MarkerEdgeColor','w');
% 	text(sd(ii),g(ii),num2str(0.5783*p(ii),2));
end
colorbar;


sd = [2 2.5 2];
p = [10 30 50];
g = [0.9 0.97 1];
for ii = 1:3
	[mn,idx] = min(abs(indx-0.5783*p(ii)));
	plot(sd(ii),g(ii),'ko','MarkerFaceColor',col(idx,:),'MarkerSize',15,'MarkerEdgeColor','w');
% 	text(sd(ii),g(ii),num2str(0.5783*p(ii),2));
end
colorbar;
ylim([0.7 1]);
xlim([0 7]);
xlabel('\sigma_R');
ylabel('Gain');
axis square;

return
alpha = -120:120;
s = -4*sind(alpha);
subplot(121)

%% head task, head-fixed
plot(alpha,s,'k-','LineWidth',2);

%% world task, head-fixed
plot(alpha,s,'k-','LineWidth',2);

a = cosd(alpha).*s;

axis square;
hold on
% subplot(122)
plot(alpha,a,'r-','LineWidth',2);
axis square;
axis([-130 130 -13 13]);
set(gca,'XTick',-120:30:120,'YTick',-12:3:12);
grid on

subplot(122)
plot(s,a,'r-','LineWidth',2);
axis square;
axis([-13 13 -13 13]);
set(gca,'XTick',-120:30:120,'YTick',-12:3:12);
grid on

% %% Initialization
% f0     = 250; % base frequency (Hz)
% N 		= 128; % # components
% fNr 	= 0:1:N-1; % every frequency step
% f   	= f0 * 2.^(fNr/20); % frequency vector (Hz)
% dur 	= 1; % sound's duration (s)
% Fs		= 44100; % sample frequency (Hz)
% ns		= round(dur*Fs); % number of time samples
% t 		= (1:ns)/Fs; % time vector (s);
%
% %% Sum carriers, in a for-loop
% snd 	= 0;
% for i = 1:N
% 	phi 		= 2*pi*rand(1); % random phase between 0-2pi
% 	carrier		= sin( 2*pi * f(i) * t + phi );
% 	snd			= snd+carrier;
% end
% snd 	= snd/N;
%
% plot(snd)
% wavplay(snd)