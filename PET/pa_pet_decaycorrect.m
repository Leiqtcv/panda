function pa_pet_decaycorrect(files,t1,t2,FDG)

%% Initialization

%% Difference
thresh		= 200;

%% Load
dat		= struct([]);
nfiles	= length(files);
for ii	= 1:nfiles
	file		= files{ii};
	nii			= load_nii(file, [], 1); % load the scan
	view_nii(nii);
	dat(ii).img = nii.img;
end

%% Non-adjusted graphs
all = [dat.img];
mx  = max(all(:));
x	= 0:mx/1000:mx;
col = hot(nfiles+3);
figure
for ii	= 1:nfiles
	N	= hist(dat(ii).img(:),x);
	subplot(311)
	plot(x,N,'k-','LineWidth',2,'Color',col(ii,:));
	hold on
end
ylim([0 3200]);
xlim([100 20000]);
f		= round(pa_oct2bw(200,0:1:9));
set(gca,'Xscale','log','XTick',f,'XTickLabel',f);
xlabel('Non-adjusted activity (counts)');
ylabel('Number of voxels');

%% Adjust for time
for ii		= 1:nfiles
	e		= etime(t2(ii,:),t1(ii,:));
	dat(ii).tc = pa_pet_decayfun([FDG(ii) e],dat(ii).img);
end

%% Time-adjusted graphs
all = [dat.tc];
mx  = max(all(:));
x	= 0:mx/1000:mx;
col = hot(nfiles+3);
for ii = 1:nfiles
	N	= hist(dat(ii).tc(:),x);
	subplot(312)
	plot(x,N,'k-','LineWidth',2,'Color',col(ii,:));
	hold on
end
ylim([0 3200]);
xlim([100 20000]);
f		= round(pa_oct2bw(200,0:1:9));
set(gca,'Xscale','log','XTick',f,'XTickLabel',f);
xlabel('Time-adjusted activity (counts)');
ylabel('Number of voxels');

%% First-adjusted graph
beta0		= [100 1];
Control		= dat(1).tc;
dat(1).cc	= pa_pet_decayfun(beta0,Control);
for ii = 2:nfiles
	sel		= Control>thresh;
	beta	= nlinfit(dat(ii).tc(sel),Control(sel),@(beta,X)pa_pet_decayfun(beta,X),beta0);
	dat(ii).cc	= pa_pet_decayfun(beta,dat(ii).tc);
end

%% Control-adjusted graphs
all = [dat.cc];
mx  = max(all(:));
x	= 0:mx/1000:mx;
col = hot(nfiles+3);
for ii = 1:nfiles
	N	= hist(dat(ii).cc(:),x);
	subplot(313)
	plot(x,N,'k-','LineWidth',2,'Color',col(ii,:));
	hold on
end
ylim([0 5000]);
xlim([100 20000]);
f		= round(pa_oct2bw(200,0:1:9));
set(gca,'Xscale','log','XTick',f,'XTickLabel',f);
xlabel('Time-adjusted activity (counts)');
ylabel('Number of voxels');
pa_verline(thresh);

%% First-adjusted graph
beta0	= [100 1];
Control = dat(1).img;
dat(1).cc	= pa_pet_decayfun(beta0,Control);
for ii = 2:nfiles
	sel		= Control>thresh;
	beta	= nlinfit(dat(ii).img(sel),Control(sel),@(beta,X)pa_pet_decayfun(beta,X),beta0);
	dat(ii).cc	= pa_pet_decayfun(beta,dat(ii).img);
end

%% Save
for ii	= 1:nfiles
	file		= files{ii};
	[pathstr,fname] = fileparts(file);

	nii			= load_nii(file, [], 1); % load the scan
	nii.img		= dat(ii).cc;

	fname = ['d' fname];
	save_nii(nii, [pathstr filesep fname]); % save the scan, give it a unique name
end
