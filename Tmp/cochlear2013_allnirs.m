%% Run pa_nirs_parameters_LR 
% To get al parameters once, stored in -param.mat

%By Marc van Wanrooij, 2013

%% Clean all
clear all
close all
clc

%% Phoneme
pa_datadir;
p					= 'E:\DATA\NIRS\Hai Yin\';
cd(p)
[N,T] = xlsread('subjectdates.xlsx');

p = N(:,6);
sel = p~=100;
p = p(sel);

%%
ds = {'E:\DATA\NIRS\Hai Yin\HH-01-2011-11-16';'E:\DATA\NIRS\Hai Yin\HH-02-2011-11-29';...
	'E:\DATA\NIRS\Hai Yin\HH-03-2011-12-14';'E:\DATA\NIRS\Hai Yin\HH-04-2012-02-13';...
	'E:\DATA\NIRS\Hai Yin\HH-05-2012-01-17'};

fnames = {'OG-HH-01-2011-11-16-';'OG-HH-02-2011-11-29-';'OG-HH-03-2011-12-14-';...
	'OG-HH-04-2012-02-13-';'OG-HH-05-2012-01-17-';};
M = NaN(5,3,2);
for ii = 1:5
	cd(ds{ii})
	d = dir('*param*');
	fname = d.name;
	load(fname)
	whos
	for jj = 1:3
		for kk = 1:2
			x = param(jj).chan(kk).mu;
			[~,indx] = max(abs(x));
			indx = 200;
			M(ii,jj,kk) = abs(x(indx));
% 			M(ii,jj,kk) = param(jj).chan(kk).mu
			
subplot(121)
plot(param(jj).chan(kk).mu)
pa_verline(indx);
pa_horline(x(indx))

drawnow
% pause
		end
	
	end
end
col     = pa_statcolor(3,[],[],[],'def',1);
col
figure;
mrk = ['o';'s'];
for ii = 1:2
	VO = squeeze(M(:,1,ii));
	plot(VO,p,['k' mrk(ii)],'MarkerFaceColor',col(1,:))
	hold on
	AO = squeeze(M(:,2,ii));
	plot(AO,p,['k' mrk(ii)],'MarkerFaceColor',col(2,:))
	AVO = squeeze(M(:,3,ii));
	plot(AVO,p,['k' mrk(ii)],'MarkerFaceColor',col(3,:))
end
axis square;
box off;
ylim([-10 110]);
xlim([-0.1 0.7])
   set(gca,'TickDir','out','XTick',0:0.2:0.6,'YTick',0:20:100);
%     pa_verline(10,'k:');
%     pa_verline(30,'k:');
%     pa_horline(0,'k:');
    ylabel('Phoneme score (%)');
    xlabel('Relative O_2Hb HHb concentration (\muM)'); % What is the correct label/unit

pa_datadir;
print('-depsc','-painter',mfilename);