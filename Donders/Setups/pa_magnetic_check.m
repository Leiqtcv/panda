clear all
close all

cd('E:\MATLAB\PANDA\Donders\Setups\supplementary');

fname		= 'magFCheck-min30-2013-02-21.dat';
[e,c,l]		= pa_readcsv(fname);
sel = l(:,5)==1 & l(:,6)~=0
loc = l(sel,[6 7]);
indx = find(ismember(loc(:,1),[3 9]));

nSamples	= c(1,6);
nChan		= size(c,1);

pos = [95 90 40 30 20 10];
n = numel(pos);
col = jet(n);
% col = col(

for ii = 1:n
	
	fname		= ['magFCheck-min' num2str(pos(ii)) '-2013-02-21.dat'];
	
	dat			= pa_loaddat(fname,nChan,nSamples);
	H			= 1000*squeeze(dat(:,:,1));
	V			= 1000*squeeze(dat(:,:,2));
	F			= 1000*squeeze(dat(:,:,3));
	B 		= 1000*squeeze(dat(:,:,4));
	figure(1)
	subplot(221)
	plot(H(1:100:end),V(1:100:end),'k.','Color',col(ii,:))
	hold on
	xlabel('X');
	ylabel('Y');
	
	subplot(222)
	plot(H(1:100:end),F(1:100:end),'k.','Color',col(ii,:))
	hold on
	xlabel('X');
	ylabel('Z');
	
	subplot(223)
	plot(V(1:100:end),F(1:100:end),'k.','Color',col(ii,:))
	hold on
	xlabel('Y');
	ylabel('Z');
	
	subplot(224)
	plot3(H(1:100:end),V(1:100:end),F(1:100:end),'k.','Color',col(ii,:))
	hold on
	xlabel('X');
	ylabel('Y');
	zlabel('Z');
	
	figure(2)
	subplot(221)
	plot(H(:,indx),'k-','Color',col(ii,:))
	hold on
	xlabel('X');
	axis equal;
	
	subplot(222)
	plot(V(:,indx),'k-','Color',col(ii,:))
	hold on
	xlabel('Y');
	axis equal;
	
	subplot(223)
	plot(F(:,indx),'k-','Color',col(ii,:))
	hold on
	xlabel('Z');
	axis equal;
	
	subplot(224)
	plot(B(:,indx),'k-','Color',col(ii,:))
	hold on
	xlabel('B');
	axis equal;
	
	figure(3)
	subplot(131)
	plot(mean(H(:,indx),2),'k-','Color',col(ii,:),'LineWidth',2)
	hold on
	xlabel('X');
	axis equal;
	ylim([-0.5 0.1]);
	
	subplot(132)
	plot(mean(V(:,indx),2),'k-','Color',col(ii,:),'LineWidth',2)
	hold on
	xlabel('Y');
	axis equal;
	ylim([-0.5 0.1]);
	
	subplot(133)
	plot(mean(F(:,indx),2),'k-','Color',col(ii,:),'LineWidth',2)
	hold on
	xlabel('Z');
	axis equal;
	ylim([-3.1 -2.5]);
	
	
end
figure(1)
subplot(221)
legend(num2str(pos'))
for ii = 1:4
	subplot(2,2,ii)
	axis equal;
end
grid on
axis equal;

%%
figure(3)


%%
figure
indx = 2000:2500;
for ii = [1:n]
	
	fname		= ['magFCheck-min' num2str(pos(ii)) '-2013-02-21.dat'];
	
	dat	= pa_loaddat(fname,nChan,nSamples);
	
	H	= 1000*squeeze(dat(:,:,1));
	V	= 1000*squeeze(dat(:,:,2));
	F	= 1000*squeeze(dat(:,:,3));
	B 	= 1000*squeeze(dat(:,:,4));
	nT	= size(H,2);
	
	muH = mean(H(indx,:));
	muV = mean(V(indx,:));
	muF = mean(F(indx,:));
	subplot(221)
	plot(muH,muV,'ko','MarkerFaceColor',col(ii,:));
	axis([-4 4 -4 4]);
	hold on
	axis equal;
	box off
	
	subplot(222)
	plot(muH,muF,'ko','MarkerFaceColor',col(ii,:));
	axis([-4 4 -4 4]);
	hold on
	axis equal;
	box off
	
	subplot(223)
	plot(muV,muF,'ko','MarkerFaceColor',col(ii,:));
	axis([-4 4 -4 4]);
	hold on
	axis equal;
	box off
	
	subplot(224)
	plot3(muH,muV,muF,'ko','MarkerFaceColor',col(ii,:));
% 	axis([-4 4 -4 4]);
	hold on
	axis equal;
	box off
	
	if ii==1
		muX = muH;
		muY = muV;
		muZ = muF;
	else
		x = muH-muX;
		y = muV-muY;
		
		sel = x>0.3;
		x = muX(sel);
		y = muY(sel);
		subplot(221)
		plot(x,y,'k-','LineWidth',2);
		hold on
		
		x = muX(sel);
		y = muZ(sel);
		subplot(222)
		plot(x,y,'k-','LineWidth',2);
		hold on

		x = muY(sel);
		y = muZ(sel);
		subplot(223)
		plot(x,y,'k-','LineWidth',2);
		hold on
		
				x = muX(sel);
		y = muY(sel);
		z = muZ(sel);
		subplot(224)
		plot3(x,y,z,'k-','LineWidth',2);
		hold on
grid on
	end
	
	
	drawnow
end

pa_datadir;
print('-depsc','-painter',mfilename);
