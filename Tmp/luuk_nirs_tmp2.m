function luuk_nirs_tmp2
close all
% Load mat files
cd('/Users/marcw/DATA/NIRS/OXY3_v14112014'); %#ok<*UNRCH> % contains all relevant data files
d		= dir('nirs0*.mat');

[m,~]	= size(d);
nmbr	= NaN(m,1);
for ii	= 1:m
	fname		= d(ii).name;
	nmbr(ii)	= str2double(fname(5:7));
	
end
unmbr			= unique(nmbr);
nnmbr			= numel(unmbr);
nnmbr
[~,Txt]	= xlsread('subj_analysis_v14112014-all.xlsx');
Txt				= Txt(2:end,:);
for ii = 12:nnmbr
	sel		= nmbr == unmbr(ii);
	fnames	= {d(sel).name};
	nfiles	= numel(fnames);
	disp(ii)
	disp(fnames)
	S		= [];
	So = [];
	T		= [];
	M		= [];
	E		= [];
	for jj = 1:nfiles
		load(fnames{jj});
		S	= [S;nirs.signal]; %#ok<*AGROW>
		So	= [So;nirs.deepchan]; %#ok<*AGROW>
		% 		S	= [S;pa_zscore(nirs.signal)]; %#ok<*AGROW>
		% 		So	= [So;pa_zscore(nirs.deepchan)]; %#ok<*AGROW>
		%% add timings, continuous
		if ~isempty(E)
			e = T(end)*nirs.Fs;
			t = T(end);
			T = [T;nirs.time+t];
			E = [E [nirs.event.sample]+e];
		else
			T = [T;nirs.time];
			E = [E [nirs.event.sample]];
		end
		fname	= fnames{jj};
		fname	= fname(5:end-4);
		sel		= strcmpi(fname,Txt(:,1));
		
		%% Check for interleaved blocks
		modal	= Txt(sel,5);
		if strncmp(modal,'Random',5);
			M = [M {nirs.event.stim}];
		elseif strncmp(modal,'Audiovisual',11);
			a = {nirs.event.stim};
			for kk = 1:size(a,2)
				a {kk} = 'AV';
			end
			M = [M a];
		elseif strncmp(modal,'Auditory',8);
			a = {nirs.event.stim};
			for kk = 1:size(a,2)
				a {kk} = 'A';
			end
			M = [M a];
		elseif strncmp(modal,'Visual',6);
			a = {nirs.event.stim};
			for kk = 1:size(a,2)
				a {kk} = 'V';
			end
			M = [M a];
		else
			M = [M {nirs.event.stim}];
		end
	end
	S = pa_zscore(S);
	So = pa_zscore(So);
	figure(1)
	clf
	ax(1)	= subplot(211);
	t		= 1:length(S);
	t		= t/nirs.fsdown;
	plot(t,S(:,1));
	box off
	set(gca,'TickDir','out');
	
	
	%% Block average
	clear N
	N.event.sample	= E';
	N.event.stim	= M;
	N.Fs			= nirs.Fs;
	N.fsdown		= nirs.fsdown;
	
	figure(7)
	clf
	nchan = size(S,2);
	mod = {'A';'V';'AV'};
	for chanIdx = 1:nchan
		for modIdx	= 1:3
			MU			= pa_nirs_blockavg(N,S(:,chanIdx),mod{modIdx});
			x			= 1:length(MU);
			x			= x/10;
			
			figure(7)
			subplot(122)
			plot(x,nanmean(MU))
			hold on
		end
	end
	for chanIdx = 1:nchan
		for modIdx	= 1:3
			MUo			= pa_nirs_blockavg(N,So(:,chanIdx),mod{modIdx});
			x			= 1:length(MUo);
			x			= x/10;
			
			figure(7)
			subplot(121)
			plot(x,nanmean(MUo))
			hold on
		end
	end
	
	
	%% Hemo
	nirs	= N;
	
	fs		= nirs.Fs;
	fd		= nirs.fsdown;
	R		= S(:,1);
	on		= ceil([nirs.event.sample]*fd/fs);
	off		= on(2:2:end);
	on		= on(1:2:end);
	stim	= nirs.event.stim;
	ustim	= unique(stim);
	nstim	= numel(ustim);
	n		= numel(R);
	HDR		= NaN(3,n);
	for sIdx = 1:nstim
		sel		= strcmp(ustim(sIdx),stim(1:2:end)) | strcmp('AV',stim(1:2:end));
		ons		= on(sel);
		offs	= off(sel);
		N		= length(R);
		bl      = zeros(1, N);
		for kk	= 1:length(ons)
			bl(ons(kk):offs(kk)) = 1;
		end
		hemo		= pa_nirs_hdrfunction(1,bl);
		x = [hemo' hemo'];
		hemo	= removeheartbeat(x,0.1); % heartbeat
		hemo	= removeheartbeat(hemo,0.1,2); % respiration (0.2 Hz)
		hemo	= removeheartbeat(hemo,0.1,[0.05 .2]); % Mayer Wave[0.05 .2]
		hemo	= hemo(:,1);
		flim	= [0.008 .1];
		hemo	= pa_bandpass(hemo,flim,5); % we bandpass between 0.016 and 0.8 Hz to remove noise and cardiac component
		hemo	= hemo./max(hemo);
		HDR(sIdx,:) = hemo';
	end
	
	figure(1)
	ax(2)	= subplot(212);
	t		= 1:length(HDR);
	t		= t/fd;
	for ll = 1:sIdx
		plot(t,HDR(ll,:)+ll*1.2,'-','LineWidth',2)
		hold on
	end
	legend(ustim);
	box off
	set(gca,'TickDir','out','YTick',[]);
	xlabel('Time (min)');
	xlim([0 max(t)]);
	ylabel('X(t) = u(t) \otimes h(\tau) ')
	subplot(211)
	hold on
	plot(t,mean(HDR),'k-');
	title(ii);
	linkaxes(ax,'x');
	
	figure(7)
	drawnow
	
	% 	ustim = ustim([3 2 1]);
	%% GlM\
	figure(2)
	clf
	B = NaN(nchan,3);
	for chanIdx = 1:nchan
		
		x			= HDR';
		y			= S(:,chanIdx);
		[b,dev]		= glmfit(x,y,'normal');
		yo			= So(:,chanIdx);
		[bo,devo]	= glmfit(x,yo,'normal');
		yfit		= glmval(b,x,'identity');
		b			= b(2:end);
		bo			= bo(2:end);
		if str2double(fnames{1}(5:7))>16 && str2double(fnames{1}(5:7))<38
			idx		= [3 2 1];
			b		= b(idx);
			bo		= bo(idx);
		end
		B(chanIdx,:) = b;
		
		figure(2)
		subplot(2,2,chanIdx)
		plot(y,'-','Color',[.7 .7 .7])
		hold on
		plot(yfit,'-')
		box off
		title(b)
		
		%
		% 		cmp = round([dev./max(b) devo./max(bo)]/1000);
		% 		whos B b bo
		% 		if cmp(2)<cmp(1)
		% % 			sel = stat.p<0.05;
		% % 			sel(2) = true;
		% % 			sel(3) = true;
		% %
		% % 			b(~sel) = NaN;
		% % 			whos B b
		% 			B(chanIdx,:) = b;
		% 		else
		% % 			sel = stato.p<0.05;
		% % 			sel(2) = true;
		% % 			sel(3) = true;
		% %
		% % 			bo(~sel) = NaN;
		% 			whos B bo
		% 			B(chanIdx,:) = bo;
		% 		end
		
		% 		keyboard
	end
	nirs.glmbeta	= B;
	BETA(ii).b		= B';
	
	figure(7)
	x			= 1:length(MU);
	x			= x/10;
	bl		= zeros(size(x));
	sel		= x>10 & x<30;
	bl(sel) = 1;
	hemo	= pa_nirs_hdrfunction(1,bl);
	for fIdx = 1:2
		mx = max(B(:));
		mn = min(B(:));
		
		subplot(1,2,fIdx)
		plot(x,mx*hemo,'k-','LineWidth',2);
		plot(x,mn*hemo,'k-','LineWidth',2);
		pa_verline([10 30]);
	end
	drawnow
	title(round([dev./max(b) devo./max(bo)]/1000))
	drawnow
	% 	fname = pa_fcheckext(['nirs' d(ii).name],'.mat');
	
	figure(8)
	subplot(221)
	plot(B(1:2:end,1),B(1:2:end,3),'o');
	hold on
	box off
	axis square;
	
	subplot(222)
	plot(B(1:2:end,1)+B(1:2:end,3),B(1:2:end,1)+B(1:2:end,3)+B(1:2:end,2),'.');
	hold on
	plot(B(1:2:end,1),B(1:2:end,1)+B(1:2:end,3)+B(1:2:end,2),'k.');
	box off
	axis square;
	
	
	subplot(223)
	plot(B(2:2:end,1),B(2:2:end,3),'o');
	hold on
	box off
	axis square;
	
	subplot(224)
	plot(B(2:2:end,1)+B(2:2:end,3),B(2:2:end,1)+B(2:2:end,3)+B(2:2:end,2),'.');
	hold on
	plot(B(2:2:end,1),B(2:2:end,1)+B(2:2:end,3)+B(2:2:end,2),'k.');
	box off
	axis square;
	drawnow
	
	% keyboard
	
	% 			save(fname,'nirs');
	figure(7)
	% 	pause
	
end


save('allglmbetas','BETA');

%%
figure(8)
for fi = 1:4
	subplot(2,2,fi)
	axis([-4 4 -4 4])
	pa_unityline;
	pa_horline;
end
%%
y	= [BETA.b];
A	= y(1,2:2:end);
AV	= y(2,2:2:end);
V	= y(3,2:2:end);

figure(9)
clf
subplot(221)
% x		= A(1:end-5);
% y		= V(1:end-5);
x		= A;
y		= V;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end);
y		= V(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','r')
xlim([-1 2]);
ylim([ -1 2]);
set(gca,'XTick',-0.5:0.5:1.5,'YTick',-0.5:0.5:1.5,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A,\DeltaHbO_2]','FontSize',12);
ylabel('\beta[V,\DeltaHbO_2]','FontSize',12);
title([]);
axis square;
pa_errorpatch([10 30],[-1.5 -1.5],[3 3]);
box off
h = pa_text(0.1,0.9,'A');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-')
% pa_regline(bCI.beta,'r-')

subplot(222)
x		= A(1:end-5)+V(1:end-5);
y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
x		= A+V;
y		= A+V+AV;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end)+V(end-4:end);
y		= A(end-4:end)+V(end-4:end)+AV(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','r')
xlim([-1 4]);
ylim([ -1 4]);
set(gca,'XTick',-0.5:0.5:3.5,'YTick',-0.5:0.5:3.5,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A+V,\DeltaHbO_2]','FontSize',12);
ylabel('\beta[A+V+AV,\DeltaHbO_2]','FontSize',12);
title([]);
axis square;
pa_errorpatch([10 30],[-1.5 -1.5],[3 3]);
box off
h = pa_text(0.1,0.9,'B');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-')
% pa_regline(bCI.beta,'r-')


% x		= A(1:end-5)+V(1:end-5);
% y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
% sel =x<1;
% b		= regstats(y(sel),x(sel),'linear','beta');
% plot([0 1],b.beta(2)*[0 1]+b.beta(1),'k-');
% % pa_regline(b.beta,'m-')
% x		= A(1:end-5)+V(1:end-5);
% y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
% sel =x>1;
% b		= regstats(y(sel),x(sel),'linear','beta');
% plot([1 3],b.beta(2)*[1 3]+b.beta(1),'k-');

subplot(223)
% x		= A(1:end-5);
% y		= A(1:end-5)+V(1:end-5)+AV(1:end-5);
x		= A;
y		= A+V+AV;
b		= regstats(y,x,'linear','beta');
plot(x,y,'ko','MarkerFaceColor','w')
hold on
x		= A(end-4:end);
y		= A(end-4:end)+V(end-4:end)+AV(end-4:end);
bCI		= regstats(y,x,'linear','beta');
plot(x,y,'ks','MarkerFaceColor','r')
xlim([-1 2]);
ylim([ -1 2]);
set(gca,'XTick',-0.5:0.5:1.5,'YTick',-0.5:0.5:1.5,'TickDir','out',...
	'TickLength',[0.005 0.025],...
	'FontSize',10,'FontAngle','Italic','FontName','Helvetica'); % publication-quality
xlabel('\beta[A,\DeltaHbO_2]','FontSize',12);
ylabel('\beta[A+V+AV,\DeltaHbO_2]','FontSize',12);
title([]);
axis square;
pa_errorpatch([10 30],[-1.5 -1.5],[3 3]);
box off
h = pa_text(0.1,0.9,'C');
set(h,'FontSize',15,'FontWeight','bold');
text(20,0.5,'After','HorizontalAlignment','center');
text(20,-0.5,'Before','HorizontalAlignment','center');
text(20,0,'Best-fit cHDR','HorizontalAlignment','center');
pa_unityline('k:');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_regline(b.beta,'k-')
% pa_regline(bCI.beta,'r-')


x		= A;
g		= zeros(size(A));
g(end-4:end) = 1;
g		= g+1;
y		= A+V+AV;
[h,p] = ttest(x,y)

x		= A;
g		= zeros(size(A));
g(end-4:end) = 1;
g		= g+1;
y		= V;
[h,p] = ttest(x,y)

x		= A+V;
g		= zeros(size(A));
g(end-4:end) = 1;
g		= g+1;
y		= A+V+AV;
[h,p] = ttest(x,y)

% title('Reference channel subtraction, subject 1, all blocks (A-interleaved)','FontSize',12);

%%
% keyboard
