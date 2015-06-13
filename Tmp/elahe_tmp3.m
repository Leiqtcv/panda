close all;
clear all; %#ok<CLSCR>
cd('/Users/marcw/DATA/Student/Elahe');


%% The Data
load('graitings'); %load saccade parameters
x		= Graitings(1,:)';
y		= Graitings(2,:)';
% y		= 1./y;
nSubj	= numel(x);


%% The Analysis
[b,dev,stats]		= glmfit(x,y,'gamma','link','identity');
xi					= 10:90;
[yhat,dylo,dyhi]	= glmval(b,xi,'identity',stats);

%% The Graphics
hold on
try
	E = [yhat-dylo yhat+dyhi]';
	Y = yhat';
	X = xi;
	pa_errorpatch(X,Y,E,'r');
catch
	plot(xi,yhat,'-');
	plot(xi,yhat-dylo,'-');
	plot(xi,yhat+dyhi,'-');
end
plot(x,y,'ko','MarkerFaceColor','w');
% axis square;
xlabel('Age (years)');
ylabel({'Impulsivity factor b/C';'1/([mean percept duration] (s^{-1})'});
box off
set(gca,'TickDir','out','Xtick',0:20:100,'YTick',0:0.1:0.4);
xlim([10 90]);
p = stats.p(2); % significance age-dependence
str = ['P = ' num2str(round(p*1000)/1000)];
title(str);
% ylim([0 0.45]);

xi = 0:5:100;
n = numel(xi);
B = stats.s;
B = 1;
for ii = 1:n
	A = 5*yhat(ii);
	xp = 0:0.001:.5;
	p = 10*gampdf(xp,A,B);
	% p = p./max(p);
	% plot(p+xi(ii),xp);
	% hold on
	[~,idx] = max(p);
	Z(ii) = xp(idx);
	P(ii,:) = p;
	
	
end


print('-dfig','-r300',[mfilename 'duration']);






%% The Data
load('graitings'); %load saccade parameters
x		= Graitings(1,:)';
y		= Graitings(2,:)';
y		= 1./y;
nSubj	= numel(x);


%% The Analysis
[b,dev,stats]		= glmfit(x,y,'gamma','link','identity');
xi					= 10:90;
[yhat,dylo,dyhi]	= glmval(b,xi,'identity',stats);

%% The Graphics
hold on
try
	E = [yhat-dylo yhat+dyhi]';
	Y = yhat';
	X = xi;
	pa_errorpatch(X,Y,E,'r');
catch
	plot(xi,yhat,'-');
	plot(xi,yhat-dylo,'-');
	plot(xi,yhat+dyhi,'-');
end
plot(x,y,'ko','MarkerFaceColor','w');
% axis square;
xlabel('Age (years)');
ylabel({'Impulsivity factor b/C';'1/([mean percept duration] (s^{-1})'});
box off
set(gca,'TickDir','out','Xtick',0:20:100,'YTick',0:0.1:0.4);
xlim([10 90]);
p = stats.p(2); % significance age-dependence
str = ['P = ' num2str(round(p*1000)/1000)];
title(str);
% ylim([0 0.45]);

xi = 0:5:100;
n = numel(xi);
B = stats.s;
B = 1;
for ii = 1:n
	A = 5*yhat(ii);
	xp = 0:0.001:.5;
	p = 10*gampdf(xp,A,B);
	% p = p./max(p);
	% plot(p+xi(ii),xp);
	% hold on
	[~,idx] = max(p);
	Z(ii) = xp(idx);
	P(ii,:) = p;
	
	
end


print('-dfig','-r300',[mfilename 'rate']);
