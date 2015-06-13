close all hidden;
clear all hidden;
clc;

%% names
cd('E:\DATA\KNO\PET\marsbar-aal');
d			= dir('*.mat');
roinames	= {d.name};
n			= numel(roinames);
names		= roinames;
side		= NaN(1,n);
for ii = 1:n
	 name	= roinames{ii};
	 name	= name(5:end-8);
	 indx	= strfind(name,'_');
	 name(indx) = ' ';
	 if strcmp(name(end),'L')
		 side(ii) = 1;
	 elseif strcmp(name(end),'R')
		 side(ii) = 2;
	 else side(ii) = 0;
	 end
	 
	 names{ii} = name(1:end-2);
end
keep names

p			= 'E:\DATA\KNO\PET\swdro files\';
cd(p)
load('petmean')
whos

sel = side==1;
sel2 = side==2;

ns		= sum(sel);
names	= names(sel);

MU1 = (MU1(:,sel)+MU1(:,sel2))/2;
MU2 = (MU2(:,sel)+MU2(:,sel2))/2;

whos



sel			= strncmpi('Cerebelum',names',5);
names		= char(names');
n = numel(foneem);
categories = cell(1,1);
for ii = 1:n
	categories{ii} = num2str(foneem(ii));
end
ratings		= MU1';

names		= names(~sel,:);
ratings		= ratings(~sel,:);

keep names categories ratings

 %%
subplot(221)
boxplot(ratings,'orientation','horizontal','labels',categories)

stdr = std(ratings);
sr = ratings./repmat(stdr,length(ratings),1);
[coefs,scores,variances,t2] = princomp(sr);
whos scores coefs variances

subplot(222)
plot(scores(:,1),scores(:,2),'+')
xlabel('1st Principal Component')
ylabel('2nd Principal Component')

subplot(224)
plot(scores(:,2),scores(:,3),'+')
xlabel('2nd Principal Component')
ylabel('3rd Principal Component')
% gname(names)

percent_explained = 100*variances/sum(variances);
subplot(223)
pareto(percent_explained)
xlabel('Principal Component')
ylabel('Variance Explained (%)')

%%
[st2, index] = sort(t2,'descend'); % Sort in descending order.
extreme = index(1)
names(extreme,:)

%%
figure
subplot(221)
biplot(coefs(:,1:2), 'scores',scores(:,1:2),... 
'varlabels',categories);
% axis([-.26 1 -.51 .51]);
% gname(names)
subplot(222)
biplot(coefs(:,2:3), 'scores',scores(:,2:3),... 
'varlabels',categories);

subplot(223)
biplot(coefs(:,3:4), 'scores',scores(:,3:4),... 
'varlabels',categories);

figure
biplot(coefs(:,1:3), 'scores',scores(:,1:3),...  
'varlabels',categories,'obslabels',names);