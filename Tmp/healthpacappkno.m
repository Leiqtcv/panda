close all
clear all
clc
% function alpha3to2

%% Country code
cd('E:\DATA\FlowingData');
fname	= 'iso36166-1.xlsx';
[~,T] = xlsread(fname);

code = T(:,1:2);
code = code(2:end,:);
ncode = size(code,1);
for row = 1:ncode
	str =code{row,1};
	sel = isletter(str);
	code{row,1} = str(sel);
end
code{2,1} = 'AlandIslands';
code{55,1} = 'Ivoorkust';
code{58,1} = 'Curacao';
code{181,1} = 'Reunion';
code{185,1} = 'SaintBarthelemy';
code{105,1} = 'Iran';
code{183,1} = 'Russia';

countrytoalpha2 = cell2struct(code(:,2),code(:,1));% create library with key alpha3 and value alpha2

%% Applicant
cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Eligible');
d			= dir;
applicant	= {d(3:end).name};
napp		= numel(applicant);

cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Hired');
d			= dir;
hired	= {d(3:end).name};
nhired		= numel(hired);

nationality = cell(napp+nhired,1);
gender = nationality;
for row		= 1:napp
	cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Eligible');
	dname = applicant{row};
	cd(dname);
	[~,T] = xlsread('info.xlsx');
	
	col1 = T(:,1);
	sel = strcmpi(col1,'nationality');
	if sum(sel) && size(T,2)>1
		nationality{row} = T{sel,2};
	end
	
	sel = strcmpi(col1,'gender');
	if sum(sel) && size(T,2)>1
		gender{row} = T{sel,2};
	end
end

for row		= 1:nhired
	cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Hired');
	dname =hired{row};
	cd(dname);
	[~,T] = xlsread('info.xlsx');
	
	col1 = T(:,1);
	sel = strcmpi(col1,'nationality');
	if sum(sel) && size(T,2)>1
		nationality{row+napp} = T{sel,2};
	end
	
	sel = strcmpi(col1,'gender');
	if sum(sel) && size(T,2)>1
		gender{row+napp} = T{sel,2};
	end
end

%%
unat = unique(nationality);
nu = numel(unat);
N = NaN(nu,1);
for row = 1:nu
	sel = strcmpi(unat(row),nationality);
	N(row) = sum(sel);
end
mx = max(N);

%%
col = pa_statcolor(mx+1,[],[],[],'def',6);
col = col(2:end,:);
H = pa_rgb2hex(col);

%% CSS
pa_datadir;
fid = fopen('style.css','w');
n = numel(unat);
for row = 1:n
	if isfield(countrytoalpha2,unat{row})
		lower(unat{row})
		alpha2 = lower(countrytoalpha2.(unat{row}));
		switch N(row)
			case 1
				fill = H{1};
			case 2
				fill = H{2};
				
			case 3
				fill = H{3};
			case 4
				fill = H{4};
			case 5
				fill = H{5};
		end
		
		str = ['.' alpha2 ' { fill: ' fill ' }'];
		fprintf(fid,'%s\n',str);
	end
end
fclose(fid);

pa_datadir;
fid = fopen('style2.css','w');
n = numel(unat);
for row = 1:n
	if isfield(countrytoalpha2,unat{row})
		alpha2 = lower(unat{row});
		switch N(row)
			case 1
				fill = H{1};
			case 2
				fill = H{2};
				
			case 3
				fill = H{3};
			case 4
				fill = H{4};
			case 5
				fill = H{5};
		end
		
		str = ['.' alpha2 ' { fill: ' fill ' }'];
		fprintf(fid,'%s\n',str);
	end
end
fclose(fid);


figure
colormap(col)
colorbar;


%% Gender
ugen = unique(gender);
nu = numel(ugen);
N = NaN(nu,1);
for row = 1:nu
	sel = strcmpi(ugen(row),gender);
	N(row) = sum(sel);
end
M = N(1)+N(3);
F = N(2);
mx = max([M F]);
figure(1)
h = bar([1 2],[M F],'FaceColor',[.7 .7 .7]);
xlim([0 3]);
ylim([0 mx*1.2]);
box off;
str = [num2str(round(F/(M+F)*100)) '% Female '];
title(str);
axis square;
set(gca,'TickDir','out','XTick',[1 2],'XTickLabel',{'Male','Female'});
ylabel('N');
pa_datadir;
print('-depsc','-painter',[mfilename 'gender']);

F/(F+M)*100
keyboard
%% Preference
cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Eligible');
d			= dir;
applicant	= {d(3:end).name};
napp		= numel(applicant);

cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Hired');
d			= dir;
hired	= {d(3:end).name};
nhired		= numel(hired);

preference = NaN(napp+nhired,14);
for row		= 1:napp
	cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Eligible');
	dname = applicant{row}
	cd(dname);
	N = xlsread('info.xlsx');
	N
	if ~isempty(N)
		n = numel(N);
		for ii = 1:n
			preference(row,N(ii)) = 7-ii;
		end
	end

end

for row		= 1:nhired
	cd('C:\Users\Marc van Wanrooij\Dropbox\Projects\HealthPAC 2013\Applications\Hired');
	dname =hired{row};
	cd(dname);
	N = xlsread('info.xlsx');
	if ~isempty(N)
		n = numel(N);
		for ii = 1:n
			preference(row+napp,N(ii)) = 7-ii;
		end
	end
end

%%
close all
col = pa_statcolor(nanmax(preference(:)),[],[],[],'def',5);
% col = col(:,[3 2 1]);
col(1,:) = [1 1 1];
names = [applicant hired];
figure(2)
% imagesc(preference);
x = 1:14;
y = 1:(napp+nhired);
[x,y] = meshgrid(x,y);
whos x y preference
p = preference;
p(isnan(p)) = 0;
colormap(col)
scatter(x(:),y(:),200,p(:),'filled')
% pcolor((1:14),(1:(napp+nhired)),preference);
set(gca,'YDir','normal','XTick',1:14,'TickDir','out','YTick',1:(nhired+napp),'YTickLabel',names);
xlabel('ESR Project #');
colormap(col);
axis square;
box off
% colorbar
caxis([1 nanmax(preference(:))+1]);
[m,n] = size(preference);

% for ii = 1:14
% h = pa_verline(ii,'k-');
% set(h,'Color',[.7 .7 1]);
% end
% for ii = 1:(nhired+napp)
% h = pa_horline(ii,'k-');
% set(h,'Color',[.7 .7 .7]);
% end
grid on
for row = 1:m
	for col = 1:n
		if ~isnan(preference(row,col))
			h = text(col,row,num2str(abs(preference(row,col)-7)),'HorizontalAlignment','center');
			set(h,'Color','w');
		end
	end
end

% Hired = red
sel = strcmpi(names,'Ahmed');
p = abs(preference-7);
x = find(~isnan(p(sel,:)));
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% pa_horline(y,'r');
% pa_verline(x,'r');

sel = strcmpi(names,'Alessia Longo');
p = abs(preference-7);
x = find(~isnan(p(sel,:)));
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% pa_horline(y,'r');
% pa_verline(x,'r');

sel = strcmpi(names,'Bahram Yoosefizonooz');
p = abs(preference-7);
x = find(~isnan(p(sel,:))&p(sel,:)==1);
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% pa_horline(y,'r');
% pa_verline(x,'r');

% sel = strcmpi(names,'Giulia Valeria Elli');
% p = abs(preference-7);
% x = 4;
% y = find(sel);
% patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% % pa_horline(y,'r');
% % pa_verline(x,'r');

sel = strcmpi(names,'Jose Garcia-Uceda');
p = abs(preference-7);
x = 2;
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% pa_horline(y,'r');
% pa_verline(x,'r');
% In gesprek = groen

sel = strcmpi(names,'Ruibin Zhang');
p = abs(preference-7);
xi = 14;
n = numel(xi);
for row = 1:n
x = xi(row);
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
% pa_horline(y,'b');
% pa_verline(x,'b');
end


sel = strcmpi(names,'Doaa Amin RM');
p = abs(preference-7);
xi = 14;
n = numel(xi)
for row = 1:n
x = xi(row);
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
% pa_horline(y,'b');
% pa_verline(x,'b');
end


%%
rej = {'Ruibin Zhang','Kamalaker Reddy Dadi','Maryam Saidi','Subramoniam Aiyappan','Valentina Piserchia'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 11;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end

%%
rej = {'Kamalaker Reddy Dadi','Lima Manuel'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 5;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end

for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 6;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end

maybe = {'Leslie Guadron'};
nmaybe = numel(maybe);
for ii = 1:nmaybe
	sel = strcmpi(names,maybe{ii});
	p = abs(preference-7);
	xi = 5;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
end

maybe = {'Anna Geuzenbroek'};
nmaybe = numel(maybe);
for ii = 1:nmaybe
	sel = strcmpi(names,maybe{ii});
	p = abs(preference-7);
	xi = 6;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
end

maybe = {'Antonella Pomante'};
nmaybe = numel(maybe);
for ii = 1:nmaybe
	sel = strcmpi(names,maybe{ii});
	p = abs(preference-7);
	xi = 12;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% 		pa_horline(y,'g');
% 		pa_verline(x,'g');
end

maybe = {'Sigrid Dupan'};
nmaybe = numel(maybe);
for ii = 1:nmaybe
	sel = strcmpi(names,maybe{ii});
	p = abs(preference-7);
	xi = 8;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
% 		pa_horline(y,'g');
% 		pa_verline(x,'g');
end

rej = {'Huihui Zhang';'Elena Manfrini';'Yacine Benhamou';'Henrike Greuel';'Maryam Saidi';'Shahid Ismail';'Vijay Korat';'Elena Manfrini';'Maria Susano';'Yacine Benhamou'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 12;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end

rej = {'Huihui Zhang';'Elena Manfrini';'Yacine Benhamou';'Henrike Greuel';'Maryam Saidi';'Shahid Ismail';'Vijay Korat';'Elena Manfrini';'Maria Susano';'Yacine Benhamou'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 13;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end

sel = strcmpi(names,'Elahe Arani');
p = abs(preference-7);
xi = 4;
n = numel(xi);
for row = 1:n
x = xi(row);
y = find(sel);
patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'r');
end



rej = {'Vijay Korat','Piotr Faba','Maryam Saidi','Amjad Hashemi'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 9;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end

rej = {'Vijay Korat','Piotr Faba','Maryam Saidi','Amjad Hashemi'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 10;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'b');
end


rej = {'Alejandro Osses','Benson Hsu','Carmen Kohl','Chiara Maffei'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 10;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'g');
end
rej = {'Alejandro Osses','Benson Hsu','Carmen Kohl','Chiara Maffei'};
nrej = numel(rej);
for ii = 1:nrej
	sel = strcmpi(names,rej{ii});
	p = abs(preference-7);
	xi = 9;
		x = xi;
		y = find(sel);
		patch([x-0.5 x-0.5 x+0.5 x+0.5],[y-0.5 y+0.5 y+0.5 y-0.5],'g');
end

%%
hold on
hiredproj = [1 2 3 4 5 6 8 12 14];
bar(hiredproj,repmat(napp+nhired+1,numel(hiredproj),1))
%%

ylim([0 napp+nhired+1]);
pa_datadir;
print('-depsc','-painter',['prefs']);

%%
pa_datadir
fname ='applicant_overview';
[status,message] = xlswrite(fname,names',1,'A2');
[status,message] = xlswrite(fname,1:14,1,'B1');
[status,message] = xlswrite(fname,abs(preference-7),1,'B2');

