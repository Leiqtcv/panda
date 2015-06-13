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
	N	= N./max(N);
	sel = N>0;
	ms	= N(sel);
	r	= x(sel);
	if colindx
		for j = 1:length(r)
			c				= 1-ms(j)/1.2;
			col				= zeros(3,1);
			if colindx<4
			col(colindx)	= c;
			else
				col = [c c c];
			end
			m				= ms(j)*msmult;
			if m<=0
				m =0.1;
			end
			plot(uTar(i),r(j),'ko','MarkerFaceColor',col,'Color','k','MarkerSize',m);
			hold on
		end
	end
end
TOT = TOT./nanmax(nanmax(TOT));