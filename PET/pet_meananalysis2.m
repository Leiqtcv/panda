function pet_meananalysis
% ANOVATWOWAYJAGSSTZ
%
% Bayesian two-way anova
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

% % Specify data source:
% dataSource = c( 'Ex19.3' )[1]
%
% Specify data source:
% To do:
% Interactions
% Bayes factor
% Estimate phoneme-score for normal-hearing
% Add uncertainty phoneme score

close all
model = 'petancova.txt';

%% THE MODEL.
pa_datadir;
loadflag = true;
% loadflag = false;
loadbrainflag = true;
% if ~exist(model,'file')



%% THE DATA.
% Load the data:
pa_datadir
load('petancova')
nroi		= numel(data);
param		= struct([]);
col			= pa_statcolor(100,[],[],[],'def',8);
dataStruct	= struct('y',[],'x1',[],'x2',[]);
BF			= struct([]);
if loadflag
	
	for roiIdx = 1:nroi
		% 	data
		data(roiIdx).roi
		y		= data(roiIdx).FDG(:);
		x1		= data(roiIdx).group(:); % group
		x2		= data(roiIdx).stim(:); % stimulus
		sel		= y<30; % remove unlikely FDG values, i.e. because of poor scan view
		y(sel)	= NaN;
		x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
		x2names	= {'Rest','Video','Audio-Video'};
		Ntotal	= length(y);
		Nx1Lvl	= length(unique(x1));
		Nx2Lvl	= length(unique(x2));
		
		sel = x2 ~= 3;
		x2 = x2(sel);
		x1 = x1(sel);
		y = y(sel);
		a0			= nanmean(y);
		a1			= accumarray(x1,y,[],@nanmean)-a0;
		a2			= accumarray(x2,y,[],@nanmean)-a0;
		[A1,A2]		= meshgrid(a1,a2);
		linpred		= A1+A2;
		linpred		= linpred+a0;
		subs		= [x1 x2];
		val			= y;
		a1a2		= accumarray(subs,val,[],@nanmean);
		a1a2		= a1a2'-linpred;

		param(roiIdx).b0	= a0;
		param(roiIdx).b1	= a1;
		param(roiIdx).b2	= a2;
		param(roiIdx).b1b2	= a1a2;
		
		if strncmp(data(roiIdx).roi,'MNI_Calcarine',13)
			figure
			subplot(221)
			plot(x1,y,'ko','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
			axis square;
			box off
			set(gca,'TickDir','out','XTick',1:3,'XTickLabel',{'Pre','Post','NH'});
			xlim([0 4]);
			ylabel('Mean FDG');
			
			subplot(222)
			plot(x2,y,'ko','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
			axis square;
			box off
			set(gca,'TickDir','out','XTick',1:2,'XTickLabel',{'Rest','Video'});
			xlim([0 3]);
			ylabel('Mean FDG');
			
						subplot(223)
			sel = x1==1;
			plot(x2(sel),y(sel),'ko','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
			hold on
			x = x2(sel);
			r = y(sel);
			sel = x==1;
			mu(1) = nanmean(r(sel));
			mu(2) = nanmean(r(~sel));
			p = a0+a1(1)+a1a2([1 2])';
			p2 = a0+a1(1)+a2;

			plot([1 2],mu,'ko-','MarkerFaceColor','w');
			plot([1 2],p,'rs-','MarkerFaceColor','w');
			plot([1 2],p2,'bd-','MarkerFaceColor','w');

			axis square;
			box off
			set(gca,'TickDir','out','XTick',1:2,'XTickLabel',{'Rest','Video'});
			xlim([0 3]);
			title('Pre');
			ylabel('Mean FDG');

			subplot(224)
			sel = x1==2;
			plot(x2(sel),y(sel),'ko','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none');
			hold on
			x = x2(sel);
			r = y(sel);
			sel = x==1;
			mu(1) = nanmean(r(sel));
			mu(2) = nanmean(r(~sel));
			p = a0+a1(2);
			p = p+a2;
			p = a0+a1(2)+a1a2([3 4])';
			p2 = a0+a1(2)+a2;

			plot([1 2],mu,'ko-','MarkerFaceColor','w');
			plot([1 2],p,'rs-','MarkerFaceColor','w');
			plot([1 2],p2,'bd-','MarkerFaceColor','w');

			axis square;
			box off
			set(gca,'TickDir','out','XTick',1:2,'XTickLabel',{'Rest','Video'});
			xlim([0 3]);
			title('Post');
			ylabel('Mean FDG');
			print('-depsc','-painter',mfilename 'CS']);
return
		end
	end
	
	pa_datadir
	save petmeananalysis param
end
load petmeananalysis



%%
nroi	= numel(data);
col		= pa_statcolor(100,[],[],[],'def',8);
p		= 'E:\Backup\Nifti\';
fname	= 'gswro_s5834795-d20120323-mPET.img';
nii		= load_nii([p fname],[],[],1);
img		= nii.img;

indx	= 1:5:61;
nindx	= numel(indx);
roi = char([data.roi]);

%% Brain
if ~loadbrainflag
	roifiles = [data.roi];
	
	
	% 	%% he brain contour
	img = roicolourise(p,fname,roifiles,ones(length(roifiles),1),zeros(size(img)));
	IMG = [];
	for zIndx = 1:nindx
		tmp	= squeeze(img(:,:,indx(zIndx)));
		IMG	= [IMG;tmp];
	end
	braincontour = IMG;
	pa_datadir
	save braincontour braincontour
else
	load braincontour;
end


%%
b0flag = true;
b1flag = true;
b2flag = true;
b1b2flag = true;
xiflag = false;
xflag = false;

%% Baseline b0
if b0flag
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).b0;
	end
	img			= repmat(mean(MAP),size(img));
	muimg1		= roicolourise2([data.roi],MAP,img);
	IMG	=		 [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		IMG		= [IMG;tmp];
	end
	figure(701)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',1,1),1,'k');
	axis equal
	caxis([50 100])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Baseline \beta_0')
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
	end
	pa_datadir;
	print('-depsc','-painter',[mfilename '_b0']);
end

%% Group effect bg
if b1flag
	img = zeros(size(img));
	mu = struct([]);
	for jj = 1:3
		MAP = NaN(nroi,1);
		for roiIdx = 1:nroi
			MAP(roiIdx) = param(roiIdx).b1(jj);
		end
		muimg1	= roicolourise2([data.roi],MAP,img);
		muIMG1	= [];
		for zIndx = 1:nindx
			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
		end
		mu(jj).img = muIMG1;
	end
	
	IMG = [mu(1).img mu(2).img mu(3).img];
	figure(702)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',3,1),1,'k');
	axis equal
	caxis([-10 10])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Group effect')
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
	end
	
	x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
	for ii = 1:3
		str = x1names{ii};
		ht = text(0,95*(ii-1)+95/2,str,'Color','k','HorizontalAlignment','center');
		set(ht,'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','middle')
	end
	pa_datadir;
	print('-depsc','-painter',[mfilename '_bg']);
end

%% Stimulus effect bs
if b2flag
	img = zeros(size(img));
	mu = struct([]);
	for jj = 1:2
		MAP = NaN(nroi,1);
		for roiIdx = 1:nroi
			MAP(roiIdx) = param(roiIdx).b2(jj);
		end
		muimg1	= roicolourise2([data.roi],MAP,img);
		muIMG1	= [];
		for zIndx = 1:nindx
			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
		end
		mu(jj).img = muIMG1;
	end
	
	IMG = [mu(1).img mu(2).img];
	figure(703)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',2,1),1,'k');
	axis equal
	caxis([-10 10])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Stimulus effect')
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
	end
	x2names	= {'Rest','Video','Audio-Video'};
	for ii = 1:2
		str = x2names{ii};
		ht = text(0,95*(ii-1)+95/2,str,'Color','k','HorizontalAlignment','center');
		set(ht,'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','middle')
	end
	
	pa_datadir;
	print('-depsc','-painter',[mfilename '_bs']);
end

%% Group-Stimulus interaction effect b1b2
if b1b2flag
	img = zeros(size(img));
	mu = struct([]);
	for jj = 1:6
		MAP = NaN(nroi,1);
		for roiIdx = 1:nroi
			MAP(roiIdx) = param(roiIdx).b1b2(jj);
		end
		muimg1	= roicolourise2([data.roi],MAP,img);
		muIMG1	= [];
		for zIndx = 1:nindx
			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
		end
		mu(jj).img = muIMG1;
	end
	
	IMG = [mu(1).img mu(2).img mu(3).img mu(4).img mu(5).img mu(6).img];
	figure(704)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',6,1),1,'k');
	axis equal
	caxis([-3 3])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Group-stimulus interaction effect')
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
	end
	
	x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
	x2names	= {'Rest','Video','Audio-Video'};
	k = 0;
	for ii = 1:3
		for jj = 1:2
			k = k+1;
			str = {x1names{ii}; x2names{jj}};
			ht = text(0,95*(k-1)+95/2,str,'Color','k','HorizontalAlignment','center');
			set(ht,'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','middle')
		end
	end
	
	
	pa_datadir;
	print('-depsc','-painter',[mfilename '_bgbs']);
end

%% Phoneme score
if xiflag
	img = zeros(size(img));
	mu = struct([]);
	for jj = 1:6
		MAP = NaN(nroi,1);
		for roiIdx = 1:nroi
			MAP(roiIdx) = param(roiIdx).bMetI(jj);
			% 		switch jj
			% 			case {1, 2}
			% 				a = 1./BF(roiIdx).q1a<3;
			% 			case {4, 5}
			% 				a = 1./BF(roiIdx).q1b<3;
			% 			case {7, 8}
			% 				a = 1./BF(roiIdx).q1c<3;
			% 		end
			% 		if a
			% 			MAP(roiIdx) = 0;
			% 		end
		end
		muimg1	= roicolourise2([data.roi],MAP,img);
		muIMG1	= [];
		for zIndx = 1:nindx
			tmp		= squeeze(muimg1(:,:,indx(zIndx)));
			muIMG1	= [muIMG1;tmp]; %#ok<AGROW>
		end
		mu(jj).img = muIMG1;
	end
	
	IMG = [mu(1).img mu(2).img mu(3).img mu(4).img mu(5).img mu(6).img];
	figure(705)
	colormap(col)
	imagesc(IMG')
	hold on
	contour(repmat(braincontour',6,1),1,'k');
	axis equal
	caxis([-1 1])
	colorbar
	set(gca,'YDir','normal');
	axis off
	title('Phoneme interaction slope')
	for ii = 1:nindx
		str = round((indx(ii))*2)-52;
		str = num2str(str);
		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
	end
	
	x1names	= {'Pre-implant','Post-implant','Normal-hearing'};
	x2names	= {'Rest','Video','Audio-Video'};
	k = 0;
	for ii = 1:3
		for jj = 1:3
			k = k+1;
			str = {x1names{ii}; x2names{jj}};
			ht = text(0,95*(k-1)+95/2,str,'Color','k','HorizontalAlignment','center');
			set(ht,'Rotation',90,'HorizontalAlignment','center','VerticalAlignment','middle')
		end
	end
	
	
	pa_datadir;
	print('-depsc','-painter',[mfilename '_xphii']);
end

% %% Phoneme slope
% if xflag
% 	MAP = NaN(nroi,1);
% 	for roiIdx = 1:nroi
% 		MAP(roiIdx) = param(roiIdx).bMet;
% 		% 		switch jj
% 		% 			case {1, 2}
% 		% 				a = 1./BF(roiIdx).q1a<3;
% 		% 			case {4, 5}
% 		% 				a = 1./BF(roiIdx).q1b<3;
% 		% 			case {7, 8}
% 		% 				a = 1./BF(roiIdx).q1c<3;
% 		% 		end
% 		% 		if a
% 		% 			MAP(roiIdx) = 0;
% 		% 		end
% 	end
% 	img			= zeros(size(img));
% 	muimg1		= roicolourise2([data.roi],MAP,img);
% 	IMG	=		 [];
% 	for zIndx = 1:nindx
% 		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
% 		IMG		= [IMG;tmp];
% 	end
% 	figure(706)
% 	colormap(col)
% 	imagesc(IMG')
% 	hold on
% 	contour(repmat(braincontour',1,1),1,'k');
% 	axis equal
% 	caxis([-5 5])
% 	colorbar
% 	set(gca,'YDir','normal');
% 	axis off
% 	title('Phoneme score slope')
% 	for ii = 1:nindx
% 		str = round((indx(ii))*2)-52;
% 		str = num2str(str);
% 		text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
% 	end
%
% 	pa_datadir;
% 	print('-depsc','-painter',[mfilename '_xphi']);
% end

%%
return
%%
% Question 1: Does visual stimulation (2 re 1) activate auditory areas
% in prelingually deaf (1)?
% Question 2: Does auditory stimulation (3 re 2) activate auditory areas in CI-users (2)?
% Question 3: Does plasticity occur after cochlear implantation (2-1)
% Question 4: Does phoneme score matter?
% keyboard

clc

% Bayes factors
figure(601)
q1a = log10(1./[BF.q1a]);
q1b = log10(1./[BF.q1b]);
q1c = log10(1./[BF.q1c]);
x = -10:0.5:10;
figure(700)
subplot(131)
plotPost(q1a')
pa_verline(log10([1/10 1/3 3 10]));
sel = q1a>log10(3);
roi(sel,:)

subplot(132)
plotPost(q1b')
pa_verline(log10([1/10 1/3 3 10]));
sel = q1b>log10(3);
roi(sel,:)

subplot(133)
plotPost(q1c')
pa_verline(log10([1/10 1/3 3 10]));
sel = q1c>log10(3);
roi(sel,:)


%% Image question 1
img = zeros(size(img));
mu = struct([]);
for jj = [1:2 4:5 7:8]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		switch jj
			case {1, 2}
				a = 1./BF(roiIdx).q1a<3;
			case {4, 5}
				a = 1./BF(roiIdx).q1b<3;
			case {7, 8}
				a = 1./BF(roiIdx).q1c<3;
		end
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(2).img-mu(1).img mu(5).img-mu(4).img mu(8).img-mu(7).img;];
figure(701)
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',3,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question1']);



%% Image question 2
q2a = log10(1./[BF.q2a]);
q2b = log10(1./[BF.q2b]);
figure(602)
subplot(121)
plotPost(q2a')
pa_verline(log10([1/10 1/3 3 10]));
sel = q2a>log10(3);
roi(sel,:)

subplot(122)
plotPost(q2b')
pa_verline(log10([1/10 1/3 3 10]));
sel = q2b>log10(3);
roi(sel,:)
img = zeros(size(img));
mu = struct([]);
for jj = [5:6 8:9]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		switch jj
			case {5,6}
				a = 1./BF(roiIdx).q2a<3;
			case {8,9}
				a = 1./BF(roiIdx).q2b<3;
		end
		if a
			MAP(roiIdx) = 0;
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(6).img-mu(5).img mu(9).img-mu(8).img;];
figure(702)
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',2,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question2']);

%% Image question 3
% Bayes factors
disp('---- ROI Question 3 -------');
figure(601)
q3a = log10(1./[BF.q3a]);
q3b = log10(1./[BF.q3b]);
x = -10:0.5:10;
figure(603)
subplot(121)
plotPost(q3a')
pa_verline(log10([1/10 1/3 3 10]));
sel = q3a>log10(3);
roi(sel,:)

subplot(122)
plotPost(q3b')
pa_verline(log10([1/10 1/3 3 10]));
sel = q3b>log10(3);
roi(sel,:)


img = zeros(size(img));
mu = struct([]);
for jj = [1:2 4:5]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		switch jj
			case {1, 4}
				a = 1./BF(roiIdx).q3a<=3;
			case {2, 5}
				a = 1./BF(roiIdx).q3b<=3;
		end
		if a
			MAP(roiIdx) = NaN;
		else
			roi(roiIdx,:)
		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(4).img-mu(1).img mu(5).img-mu(2).img ];
IMG(isnan(IMG)) = 0;
figure(703)
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',2,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question3']);
%% Image question 4
% Bayes factors
disp('---- ROI Question 4 -------');
q4 = log10(1./[BF.q4]);
figure(604)
plotPost(q4')
pa_verline(log10([1/10 1/3 3 10]));
sel = q4>log10(3);
roi(sel,:)


img = zeros(size(img));
mu = struct([]);
MAP = NaN(nroi,1);
for roiIdx = 1:nroi
	MAP(roiIdx) = nanmean(param(roiIdx).Phoneme(:));
	a = 1./BF(roiIdx).q4<3;
	if a
		MAP(roiIdx) = NaN;
	else
		roi(roiIdx,:)
	end
end
muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
muIMG1	= [];
for zIndx = 1:nindx
	tmp		= squeeze(muimg1(:,:,indx(zIndx)));
	muIMG1	= [muIMG1;tmp];
end
IMG = muIMG1;
% IMG = [mu(4).img-mu(1).img mu(5).img-mu(2).img ];
IMG(isnan(IMG)) = 0;
figure(704)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question4']);


%%
return
%%
a = repmat(mu(1).img,1,8);
a = 0
IMG = [mu(1).img mu(2).img mu(4).img mu(5).img mu(6).img  mu(7).img mu(8).img  mu(9).img]-a;

figure(900)
colormap(col)

imagesc(IMG')
hold on
contour(repmat(braincontour,1,8)',1,'k')

axis equal
% 	caxis([-80 80]);
% 	caxis([-1 1])
% caxis([90 100])
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off

%% Question 1: Is there plasticity?
close all
% Let's compare Pre vs Post rest
IMG = mu(4).img-mu(1).img;
figure(901)
subplot(211)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')

IMG = mu(5).img-mu(2).img;
figure(901)
subplot(212)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Video');

%% Question 2: Crossmodal activity?
% Let's compare V vs Rest
IMG = mu(2).img-mu(1).img;
figure(902)
subplot(311)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Pre')

IMG = mu(5).img-mu(4).img;
figure(902)
subplot(312)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Post');

IMG = mu(8).img-mu(7).img;
figure(902)
subplot(313)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('NH');

%% Question 2: Audiovisual activity?
% Let's compare V vs Rest

IMG = mu(6).img-mu(5).img;
figure(903)
subplot(211)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Post');

IMG = mu(9).img-mu(8).img;
figure(903)
subplot(212)
colormap(col)
imagesc(IMG')
hold on
contour(braincontour',1,'k')
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('NH');
%%
keyboard
function [img,indx] = roicolourise(p,files,roi,bf,img)
cd('E:\DATA\KNO\PET\marsbar-aal\');
nroi = numel(roi);
bf	= -log(bf);

% bf = round(bf/max(bf)*50)+50;
% 1-3-10-30-100
% No - Anecdotal - Moderate - Strong - Very - Extreme
levels	= log([1/100 1/100 1/30 1/10 1/3 1 3 10 30 100 100]);

nlevels = numel(levels);
% x		= repmat(bf,1,nlevels);
% x		= abs(bsxfun(@minus,x,levels));
% [~,indx] = min(x,[],2);

% n = numel(bf);
x = NaN(size(bf));
for ii = 2:nlevels-1
	sel = bf>=levels(ii) & bf<levels(ii+1);
	x(sel) = ii;
end
sel		= bf<levels(1);
x(sel)	= 1;
sel		= bf>=levels(end);
x(sel)	= nlevels;
indx	= x;
% indx = round(bf/max(bf)*50)+50;
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	for zIndx = 1:length(z1)
		img(x1(zIndx),y1(zIndx),z1(zIndx)) = indx(kk);
	end
end


function [img,indx] = roicolourise2(roi,indx,img)
p		= 'E:\Backup\Nifti\';
files	= 'gswro_s5834795-d20120323-mPET.img';
cd('E:\DATA\KNO\PET\marsbar-aal\');
nroi = numel(roi);
for kk = 1:nroi
	roiname		= roi{kk};
	roi_obj		= maroi(roiname);
	fname		= [p files];
	[~,~,vXYZ]	= getdata(roi_obj, fname);
	x1 = vXYZ(1,:);
	y1 = vXYZ(2,:);
	z1 = vXYZ(3,:);
	for zIndx = 1:length(z1)
		img(x1(zIndx),y1(zIndx),z1(zIndx)) = indx(kk);
	end
end


function BF = pa_bayesfactor(samplesPost,samplesPrior,sb)
% samplesPost =
eps		= 0.01;
binse	= -100:eps:100;
crit = 0;
% Posterior
[f,xi]		= ksdensity(samplesPost,'kernel','normal');
[~,indk]	= min(abs(xi-crit));

% Prior on Delta
tmp			= samplesPrior;
tmp			= tmp(tmp>binse(1)&tmp<binse(end));
[f2,x2]		= ksdensity(tmp,'kernel','normal','support',[binse(1) binse(end)]);
[~,indk2]	= min(abs(x2-crit));

v1 = f(indk);
v2 = f2(indk2);
% BF = [v1/v2 log(v1)-log(v2)];
BF = v1/v2;

% figure(555+sb)
% clf
% subplot(122)
% plot(x2,f2,'k-');
% hold on
% plot(xi,f,'r-');
% axis square;
% box off
% set(gca,'TickDir','out');
% title(1/BF(1))

function imgcreate(param,img,p,fname,data)
%% Image question 1
img = zeros(size(img));
mu = struct([]);
for jj = [1:2 4:5 7:8]
	MAP = NaN(nroi,1);
	for roiIdx = 1:nroi
		MAP(roiIdx) = param(roiIdx).MAP(jj);
		% 		switch jj
		% 			case {1, 2}
		% 				a = 1./BF(roiIdx).q1a<3;
		% 			case {4, 5}
		% 				a = 1./BF(roiIdx).q1b<3;
		% 			case {7, 8}
		% 				a = 1./BF(roiIdx).q1c<3;
		% 		end
		% 		if a
		% 			MAP(roiIdx) = 0;
		% 		end
	end
	muimg1	= roicolourise2(p,fname,[data.roi],MAP,img);
	muIMG1	= [];
	for zIndx = 1:nindx
		tmp		= squeeze(muimg1(:,:,indx(zIndx)));
		muIMG1	= [muIMG1;tmp];
	end
	mu(jj).img = muIMG1;
end

IMG = [mu(2).img-mu(1).img mu(5).img-mu(4).img mu(8).img-mu(7).img;];
colormap(col)
imagesc(IMG')
hold on
contour(repmat(braincontour',3,1),1,'k');
axis equal
caxis([-10 10])
colorbar
set(gca,'YDir','normal');
axis off
title('Rest')
for ii = 1:nindx
	str = round((indx(ii))*2)-52;
	str = num2str(str);
	text((ii-1)*79+79/2,95,str,'Color','k','HorizontalAlignment','center');
end

pa_datadir;
print('-depsc','-painter',[mfilename 'question1']);
