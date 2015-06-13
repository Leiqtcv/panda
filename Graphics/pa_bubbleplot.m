function TOT = pa_bubbleplot(X,Y,colindx,afrnd)
% PA_BUBBLEPLOT(X,Y)
%
% Make a bubbleplot of Y vs X.
%
% PA_BUBBLEPLOT(X,Y)

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@gmail.com

%% Initialization
if nargin<3
	colindx = 1;
end
msmult	= 8;
if nargin<4
	afrnd = 2.5;
end

%% Histogram
X		= round(X/afrnd)*afrnd;
Y		= round(Y/afrnd)*afrnd;
uX		= unique(X);
uY		= unique(Y);
x		= uY;
TOT		= NaN(length(uX),length(x));
for i	= 1:length(uX)
	sel			= X == uX(i);
	r			= Y(sel);
	N			= hist(r,x);
	TOT(i,:)	= N;
end
%% Normalize
TOT		= log10(TOT+1);
mxTOT	= nanmax(nanmax(TOT));
mnTOT	= nanmin(nanmin(TOT));
TOT		= (TOT-mnTOT)./(mxTOT-mnTOT);
mxTOT	= nanmax(TOT,[],2);
mxTOT	= repmat(mxTOT,1,size(TOT,2));
% TOT		= TOT./mxTOT;
[m,n]	= size(TOT);

%% Color map
uTOT = unique(TOT(:));
nm = numel(uTOT);
if colindx==1 % Red
	colmap = flipud(hot(nm));
elseif colindx==2 % Green
	colhot = flipud(hot(nm));
	colmap = colhot;
	colmap(:,1) = colhot(:,3);
	colmap(:,3) = colhot(:,1);
elseif colindx==3 % Blue
	colhot = flipud(hot(nm));
	colmap = colhot;
	colmap(:,1) = colhot(:,2);
	colmap(:,2) = colhot(:,1);
else
	colmap = flipud(gray(nm));
end

%% Plot
for ii = 1:m
	for jj = 1:n
		m		= msmult*TOT(ii,jj);
		indx	= (uTOT==TOT(ii,jj));
		col		= colmap(indx,:);
		if m>0
			if m>2
				plot(uX(ii),x(jj),'ko','MarkerSize',m,'MarkerFaceColor',col,'MarkerEdgeColor','k');
				hold on
			else
				plot(uX(ii),x(jj),'k.','Color',[.9 .9 .9]);
				hold on
			end
		end
	end
end


