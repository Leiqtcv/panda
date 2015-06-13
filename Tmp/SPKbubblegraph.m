function [TOT,uTar,x] = SPKbubblegraph(Tar,Res,colindx,msmult)
if nargin<3
	colindx = 2;
end
if nargin<4
	msmult	= 7;
end
sel = isnan(Tar) | isnan(Res);
Tar = Tar(~sel);
Res = Res(~sel);
Tar = round(Tar);
uTar	= unique(Tar);
x	= linspace(min(Res),max(Res),40);
TOT = NaN(length(uTar),length(x));
for i	= 1:length(uTar)
	sel = Tar == uTar(i);
	r	= Res(sel);
	N	= hist(r,x);
	TOT(i,:) = N;
end
mxTOT	= nanmax(nanmax(TOT));
TOT		= TOT./mxTOT;
[m,n]	= size(TOT);
k = 0;
for ii = 1:m
	for jj = 1:n
		m		= msmult*TOT(ii,jj);
		c		= 1-TOT(ii,jj)/1.2;
		col		= zeros(3,1);
		if colindx<4
			col(colindx)	= c;
		else
			col = [c c c];
		end
		
		if m>0
			plot(uTar(ii),x(jj),'ko','MarkerSize',m,'MarkerFaceColor',col);
			hold on
		end
		
		if TOT(ii,jj)>0
			k = k+1;
			xx(k) = uTar(ii);
			yy(k) = x(jj);
		end
	end
end
axis square

col		= zeros(3,1);
if colindx<4
	col(colindx)	= 1;
else
	col = [.5 .5 .5];
end
k = convhull(xx,yy);
hold on, plot(xx(k), yy(k),'-','Color',col,'LineWidth',2)