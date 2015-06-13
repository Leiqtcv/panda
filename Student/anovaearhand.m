close all hidden;
clear all hidden;

cd('E:\DATA\Test\Lateralization')

fname = 'temporaldata.mat';
load(fname);

whos
a   = M.matrix;
% 
% whos a
% rerh = squeeze(a(1,:,:));
% lelh = squeeze(a(3,:,:));
% x = rerh(:);
% y = lelh(:);
% [h,p]= ttest(x,y)
% plot(x,y,'ko');
% axis square;
% box off
% pa_unityline;
% lsline
% 
% return
% a = 1./a;
b = mean(squeeze(mean(a,1)));
% for ii = 1:numel(b)
% 	a(:,:,ii) = a(:,:,ii)-b(ii);
% end
% bsxfun(@minus,a,b)
% return

s   = M.subject;
mf  = 1./M.modulation;
cd   = M.condition;


cond    = {'ReRh','ReLh','LeRh','LeLh'};
ncond   = numel(cond);

y11 = [a(:,:,1) a(:,:,2) a(:,:,3) a(:,:,4) a(:,:,5) a(:,:,6) a(:,:,7) a(:,:,8)];
g11 = [s(:,:,1) s(:,:,2) s(:,:,3) s(:,:,4) s(:,:,5) s(:,:,6) s(:,:,7) s(:,:,8)];
g12 = [mf(:,:,1) mf(:,:,2) mf(:,:,3) mf(:,:,4) mf(:,:,5) mf(:,:,6) mf(:,:,7) mf(:,:,8)];
g13 = [cd(:,:,1) cd(:,:,2) cd(:,:,3) cd(:,:,4) cd(:,:,5) cd(:,:,6) cd(:,:,7) cd(:,:,8)];


y   = [y11(2,:) y11(3,:) y11(4,:) y11(1,:)];
g1  = [g11(2,:) g11(3,:) g11(4,:) g11(1,:)];
g2  = ([g12(2,:) g12(3,:) g12(4,:) g12(1,:)]);
% g3  = [repmat(1,size(g13(2,:))) repmat(2,size(g13(3,:))) repmat(3,size(g13(4,:))) repmat(4,size(g13(1,:)))]
g3  = [repmat(2,size(g13(2,:))) repmat(1,size(g13(3,:))) repmat(1,size(g13(4,:))) repmat(2,size(g13(1,:)))]; % ear
g4  = [repmat(1,size(g13(2,:))) repmat(2,size(g13(3,:))) repmat(1,size(g13(4,:))) repmat(2,size(g13(1,:)))]; % hand

% sel = g2<(1./8);
% y = y(sel);
% g1 = g1(sel);
% g2 = g2(sel);
% unique(1./g2)
% g3 = g3(sel);
% g4 = g4(sel);
% [p,table,stats,terms] = anovan(y,{g1 g2 g3 g4},'model',[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1; 0 1 1 0; 0 1 0 1; 0 0 1 1; 0 1 1 1],'random',1,'continuous',2,'varnames',{'subject';'velocity';'ear';'hand'})
[p,table,stats,terms] = anovan(y,{g1 g2 g3 g4},'model','full','random',1,'continuous',2,'varnames',{'subject';'velocity';'ear';'hand'})
% [p,table,stats,terms] = anovan(y,{g1 g2 g3 g4},'model','interaction','random',1,'varnames',{'subject';'velocity';'ear';'hand'})
% [p,table,stats,terms] = anovan(y,{g2 g3},'model','full','continuous',[1],'varnames',{'velocity';'condition'})
% [p,table,stats,terms] = anovan(y,{g2 g3},'model','interaction','varnames',{'velocity';'condition'})
return
figure(4)
c1 = multcompare(stats,'dimension',[3 4])

figure(5)
c1 = multcompare(stats,'dimension',[3 4 1])

% figure(6)
% c1 = multcompare(stats,'dimension',[2 3 4])

