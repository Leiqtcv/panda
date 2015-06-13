%% Test spike

close all
clear all

pa_datadir;
fname = 'all_predic-corr';
load(fname);


%%
close all
den = [outALL.den];
vel = [outALL.vel];
sel = ALLCORR<0;
N = hist3([vel(sel);den(sel)]',[10 10]);
imagesc(N)
colorbar
% pa_verline(unique(vel(sel)))

%%
sel = den<0;
% ALLCORR(sel) = -1*ALLCORR(sel);
% 
X = [ALLCORR(:) TSMTF(:)];
X = X.^2;
whos den
close all
% plot(TSMTF,ALLCORR,'.');
% %%
C{1} = -1:0.05:1;
C{2} = -1:0.05:1;
[N,C] = hist3(X,C);
% N = log(N+1);
col = pa_statcolor(64,[],[],[],'def',6);
col = col(:,[3 2 1]);
colormap(col);
imagesc(C{1},C{2},N);
axis square
box off
set(gca,'YDir','normal','TickDir','out');
pa_horline(0,'k:');
pa_verline(0,'k:');
pa_unityline('k:');
pa_revline('k:');
xlabel('Trial similarity');
ylabel('Prediction correlation');
colorbar;
caxis([0 50])
% clabel('Number');



y = ALLCORR';
x = TSMTF';
y = y.^2;
x = x.^2;
[m,indx] = max((y));
whos m indx x
indx = sub2ind(size(y),indx,1:122);
whos indx
[m;y(indx);m-y(indx)]
hold on
plot(x(indx),y(indx),'ks','MarkerFaceCOlor','w');

%%
% clear all
pa_datadir;
load('Voc_TS_CORR');
% load('TS_VOC');
whos

hold on
	col = pa_statcolor(6,[],[],[],'def',2);

for ii = 1:6
	str= ['y = R' num2str(ii) '.^2'''];
	eval(str)
	str= ['x = TS' num2str(ii) '.^2'''];
	eval(str)
plot(x,y,'ko','MarkerFaceCOlor',[.6 .6 .6]);
end

axis([0 1 0 1]);
axis square
box off
set(gca,'YDir','normal','TickDir','out');
% pa_horline(0,'k:');
% pa_verline(0,'k:');
pa_unityline('k:');
% pa_revline('k:');
xlabel('Trial similarity');
ylabel('Prediction correlation');
colorbar;
caxis([0 50])
print('-depsc','-painter',mfilename);

max(N(:))
