close all
clear all
clc;

animal =1;
k = 0;

if animal ==1;
	cfg.DispFlag	= 1;
	cfg.sponwin		= [1 300];
	cfg.tbin		= 1;
	cfg.hfshift		= 0;
	f32 = 'E:\DATA\Cortex\Tonotopy\JoeData\';
	xcl = 'E:\DATA\Cortex\Tonotopy';
	cd(xcl);
	[NUMERIC,TXT,RAW] = xlsread('Joe-data.xlsx');
	TXT = TXT(2:end,:);
	sel = strcmpi(TXT(:,3),'tonerough');
	NUMERIC = NUMERIC(2:end,:);
	x = NUMERIC(sel,5);
	y = NUMERIC(sel,6);
	z = NUMERIC(sel,1);
	cd(f32)
	files = TXT(sel,1);
	BF	= NaN(length(files),1);
	nrm = BF;
	figure(99);
	colormap jet
	c	= colormap;
	ls	= log10(logspace(log10(200),log10(12000),64));
	BF = [];
	length(files);
	Tmax = [];
	VO = [];
	for i =1:length(files)
		fname = files{i};
		if length(fname)>13
			DatFile = fname(1:6);
		elseif length(fname)==13
			DatFile= fname(1:5);
		end
		dname = [f32 DatFile,'experiment'];
		cd(dname);
		
		fname = [fname '.f32'];
		
		if exist(fname,'file')
			[bf,cri] = rm_bf(fname,2,1);
			pause
			df = abs(ls-log10(bf));
			[mn,indx] = min(df);
			%         [bf(i) x(i) y(i)]
			if cri > 2;
				% 				figure(99)
				% 				subplot(221)
				% 				plot(x(i)+0.4*rand(1),y(i)+0.4*rand(1),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
				% 				hold on;
				
				k = k+1;
				VO(k,1) = x(i);
				VO(k,2) = y(i);
				VO(k,3) = bf;
				VO(k,4) = z(i);
				
				% 				subplot(222)
				% 				plot(x(i)+0.4*rand(1),round(z(i)/1000),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
				% 				hold on;
			else
				disp('Uh-oh');
				disp(fname);
			end
		end
		
		
	end
	figure(99)
	subplot(221)
	axis square
	grid on
	xlabel('Anterior-posterior (mm)');
	ylabel('lateral-medial (mm)');
	colorbar
	colorbar('YTickLabel',{'Low frequency','High frequency'},'YTick',[1,65]);
	N = sum(nrm>=1);
	xlim([2 7]);
	ylim([-6 -0]);
	
	figure(99)
	subplot(222)
	axis square
	grid on
	xlabel('Anterior-posterior (mm)');
	ylabel('up-down (mm)');
	colorbar
	colorbar('YTickLabel',{'Low frequency','High frequency'},'YTick',[1,65]);
	N = sum(nrm>=1);
	xlim([2 7]);
	% 	ylim([-6 -0]);
	
	% 	keyboard
	%% !
	sel = ~isnan(VO(:,1)) & ~isnan(VO(:,2));
	VO	= VO(sel,:);
	
	x	= VO(:,1);
	y	= VO(:,2);
	bf	= VO(:,3);
	
	xy		= [x y];
	uxy		= unique(xy,'rows');
	n		= length(uxy);
	muBF	= NaN(n,1);
	N = muBF;
	for ii = 1:n
		sel = x == uxy(ii,1) & y == uxy(ii,2);
		muBF(ii)	= mean(bf(sel));
		N(ii) = sum(sel);
	end
	
	pxy		= uxy;
	pBF = muBF;
	pN = N;
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (-6:0.5:-1)';
	x2		= repmat(1.5,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy = [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (-6:0.5:-1)';
	x2		= repmat(7,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (2:0.5:6.5)';
	y2		= repmat(-6.5,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (2:0.5:6.5)';
	y2		= repmat(-0.5,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	[uxy,indx]	= sortrows(uxy,[1,2]);
	muBF		= muBF(indx);
	[v,c] = voronoin(uxy);
	figure(101)
	subplot(121)
	for j = 1:length(c)
		if all(c{j}~=1)   % If at least one of the indices is 1,then it is an open region and we can't patch that.
			hold on
			patch(v(c{j},1),v(c{j},2),muBF(j)); % use color i.
		end
	end
	hold on
	axis square;
	colorbar;
	xlim([2 7]);
	xlabel('Anterior-posterior');
	ylabel('Lateral-medial');
		for j = 1:length(pN)
		str = {['N =' num2str(pN(j))];['F = ' num2str(round(pBF(j)))]}
					h = text(pxy(j,1),pxy(j,2),str); 
					set(h,'Color','w','HorizontalAlignment','center');
	end
	%%
	sel = ~isnan(VO(:,1)) & ~isnan(VO(:,2));
	VO	= VO(sel,:);
	
	x	= VO(:,1);
	y	= round(VO(:,4)/1000);
	bf	= VO(:,3);
	
	xy		= [x y];
	uxy		= unique(xy,'rows');
	n		= length(uxy);
	muBF	= NaN(n,1);
	for ii = 1:n
		sel = x == uxy(ii,1) & y == uxy(ii,2);
		muBF(ii)	= mean(bf(sel));
	end
	
	pxy		= uxy;
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (20:5:50)';
	x2		= repmat(1.5,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy = [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (20:5:50)';
	x2		= repmat(7,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (2:0.5:6.5)';
	y2		= repmat(20,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (2:0.5:6.5)';
	y2		= repmat(50,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	[uxy,indx]	= sortrows(uxy,[1,2]);
	muBF		= muBF(indx);
	[v,c] = voronoin(uxy);
	figure(101)
	subplot(122)
	for j = 1:length(c)
		if all(c{j}~=1)   % If at least one of the indices is 1,then it is an open region and we can't patch that.
			hold on
			patch(v(c{j},1),v(c{j},2),muBF(j)); % use color i.
		end
	end
	hold on
	axis square;
	uxy		= pxy;
	
	
	%% 3D
	figure(102)
	sel = ~isnan(VO(:,1)) & ~isnan(VO(:,2));
	VO	= VO(sel,:);
	
	x	= VO(:,1);
	y	= VO(:,2);
	z	= round(VO(:,4)/1000);
	bf	= VO(:,3);
	figure;
	xyz		= [x y z];
	uxyz	= unique(xyz,'rows');
	n		= length(uxyz);
	muBF	= NaN(n,1);
	colormap jet
	c	= colormap;
	ls	= log10(logspace(log10(200),log10(12000),64));
	
	for ii = 1:n
		sel = x == uxyz(ii,1) & y == uxyz(ii,2) & z == uxyz(ii,3);
		muBF(ii)	= logmean(bf(sel));
		df = abs(ls-log10(muBF(ii)));
		[mn,indx] = min(df);
		plot3(uxyz(ii,1),uxyz(ii,2),uxyz(ii,3),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
		hold on
		
	end
	grid on
	axis square
	xlabel('x');
	ylabel('y');
	zlabel('z');
	
end

%%
if animal == 2;
	f32 = 'E:\DATA\Cortex\Tonotopy\ThorData\';
	f32rm = 'E:\DATA\Cortex\Tonotopy\Data\';
	xcl = 'E:\DATA\Cortex\Tonotopy\';
	cd(xcl);
	
	[NUMERIC,TXT,RAW]=xlsread('thor-data.xlsx');
	TXT = TXT(2:end,:);
	sel = strcmpi(TXT(:,3),'tonerough');
	x = NUMERIC(sel,5);
	y = NUMERIC(sel,6);
	z = NUMERIC(sel,2);
	
	cd(f32)
	files = TXT(sel,1);
	
	BF	= NaN(length(files),1);
	nrm = BF;
	figure(99);
	colormap jet
	c	= colormap;
	ls	= log10(logspace(log10(200),log10(12000),64));
	
	length(files)
	
	% for i = 1:length(files)
	for i = 1:length(files)
		% 	for i = [19 26:28 33 42 44 47 48 58 59 60 62 64:68 71:74 86:91 97:100 103 106 107 109:111]
		fname = files{i};
		if length(fname)<15
			cd(f32)
			cd(fname(1:7))
		else
			cd(f32rm)
			cd(fname(1:end-5))
		end
		fname = [fname '.f32'];
		fname
		if exist(fname,'file')
			[bf,cri] = rm_bf(fname,3,0);
			%             nrm(i) = 1;
			df = abs(ls-log10(bf));
			[mn,indx] = min(df);
			if cri>=2;
				figure(99)
				subplot(121)
				plot(x(i)+0.4*rand(1),y(i)+0.1*rand(1),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
				hold on;
				
				
				subplot(122)
				plot(x(i)+0.1*rand(1),-z(i)/1000,'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
				hold on;
				
				k = k+1;
				VO(k,1) = x(i);
				VO(k,2) = y(i);
				VO(k,3) = bf;
				VO(k,4) = z(i);
				
			
			end
		else
			disp('Uh-oh');
			disp(fname);
		end
	end
	figure(99)
	subplot(121)
	axis square
	grid on
	xlabel('Anterior-posterior (mm)');
	ylabel('lateral-medial (mm)');
	colorbar;
	colorbar('YTickLabel',{'Low frequency','High frequency'},'YTick',[1,65]);
	N = sum(nrm>=1);
	xlim([0 7]);
	ylim([1 -6]);
	
	
	subplot(122)
	axis square
	grid on
	xlabel('x (mm)');
	ylabel('z (mm)');
	colorbar
	colorbar('YTickLabel',{'Low frequency','High frequency'},'YTick',[1,65]);
	N = sum(nrm>=1);
	xlim([0 7]);
	ylim([-25 5]);
	
	%% !
	% 	keyboard
	sel = ~isnan(VO(:,1)) & ~isnan(VO(:,2));
	VO	= VO(sel,:);
	
	x	= VO(:,1);
	y	= VO(:,2);
	bf	= VO(:,3);
	
	xy		= [x y];
	uxy		= unique(xy,'rows');
	n		= length(uxy);
	muBF	= NaN(n,1);
	N = muBF;
	for ii = 1:n
		sel = x == uxy(ii,1) & y == uxy(ii,2);
		muBF(ii)	= mean(bf(sel));
		N(ii) = sum(sel);
	end
	
	pxy		= uxy;
	pBF = muBF;
	pN = N;
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (-6:0.5:2)';
	x2		= repmat(-2.5,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy = [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (-6:0.5:2)';
	x2		= repmat(7,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (-2:0.5:7)';
	y2		= repmat(-6,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (-2:0.5:7)';
	y2		= repmat(2,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	[uxy,indx]	= sortrows(uxy,[1,2]);
	muBF		= muBF(indx);
% 	N = N(indx);
	[v,c] = voronoin(uxy);
	figure(101)
	subplot(121)
	for j = 1:length(c)
		if all(c{j}~=1)   % If at least one of the indices is 1,then it is an open region and we can't patch that.
			hold on
			patch(v(c{j},1),v(c{j},2),muBF(j)); % use color i.
		end
	end
	hold on
	axis square;
% 	keyboard
	for j = 1:length(pN)
		str = {['N =' num2str(pN(j))];['F = ' num2str(round(pBF(j)))]}
					h = text(pxy(j,1),pxy(j,2),str); 
					set(h,'Color','w','HorizontalAlignment','center');
	end
	
	% 	plot(uxy(:,1),uxy(:,2),'o');
	colorbar;
	xlim([-2.5 7]);
	ylim([-6 2])
	xlabel('Anterior-posterior');
	ylabel('Lateral-medial');
	%%
	sel = ~isnan(VO(:,1)) & ~isnan(VO(:,2));
	VO	= VO(sel,:);
	
	x	= VO(:,1);
	y	= round(VO(:,4)/1000);
	bf	= VO(:,3);
	
	xy		= [x y];
	uxy		= unique(xy,'rows');
	n		= length(uxy);
	muBF	= NaN(n,1);
	for ii = 1:n
		sel = x == uxy(ii,1) & y == uxy(ii,2);
		muBF(ii)	= mean(bf(sel));
	end
	
	pxy		= uxy;
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (20:5:50)';
	x2		= repmat(1.5,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy = [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	y2		= (20:5:50)';
	x2		= repmat(7,size(y2));
	bf2		= repmat(100,size(y2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (2:0.5:6.5)';
	y2		= repmat(20,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	
	y		= uxy(:,2);
	x		= uxy(:,1);
	x2		= (2:0.5:6.5)';
	y2		= repmat(50,size(x2));
	bf2		= repmat(100,size(x2));
	x		= [x; x2];
	y		= [y; y2];
	muBF	= [muBF; bf2];
	uxy		= [x y];
	
	[uxy,indx]	= sortrows(uxy,[1,2]);
	muBF		= muBF(indx);
	[v,c] = voronoin(uxy);
	figure(101)
	subplot(122)
	for j = 1:length(c)
		if all(c{j}~=1)   % If at least one of the indices is 1,then it is an open region and we can't patch that.
			hold on
			patch(v(c{j},1),v(c{j},2),muBF(j)); % use color i.
		end
	end
	hold on
	axis square;
	uxy		= pxy;
	
	
	%% 3D
	figure(102)
	sel = ~isnan(VO(:,1)) & ~isnan(VO(:,2));
	VO	= VO(sel,:);
	
	x	= VO(:,1);
	y	= VO(:,2);
	z	= round(VO(:,4)/1000);
	bf	= VO(:,3);
	figure;
	xyz		= [x y z];
	uxyz	= unique(xyz,'rows');
	n		= length(uxyz);
	muBF	= NaN(n,1);
	colormap jet
	c	= colormap;
	ls	= log10(logspace(log10(200),log10(12000),64));
	
	for ii = 1:n
		sel = x == uxyz(ii,1) & y == uxyz(ii,2) & z == uxyz(ii,3);
		muBF(ii)	= logmean(bf(sel));
		df = abs(ls-log10(muBF(ii)));
		[mn,indx] = min(df);
		plot3(uxyz(ii,1),uxyz(ii,2),uxyz(ii,3),'o','Color',c(indx,:),'MarkerFaceColor',c(indx,:),'MarkerSize',5);
		hold on
		
	end
	grid on
	axis square
	xlabel('x');
	ylabel('y');
	zlabel('z');
	
end

