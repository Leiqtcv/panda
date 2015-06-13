clear all
close all


method = [];
calfile = 'bosecal.mat';
filedir = 'E:\DATA\TDT Audiogram\';
	
L = [];
R = [];
for ii = [1:17 19]
	strr = [filedir 'sub' num2str(ii) '_rightear.mat'];
		strl = [filedir 'sub' num2str(ii) '_leftear.mat'];
[fl,tl,fr,tr] = pa_tdt_bose_audiogram(strl,strr,calfile,method);

L = [L;tl];
R = [R;tr];
end

F = fl;

T = [R;L];

mu = nanmedian(T);
sd = nanstd(T);
y = prctile(T,[15 50 85]);

figure
semilogx(F,mu,'ko-','MarkerFaceColor','w','LineWidth',2,'Color','k')
hold on
errorbar(F,y(2,:),y(2,:)-y(1,:),y(3,:)-y(2,:),'ko-','MarkerFaceColor','w','LineWidth',2,'Color','k');
box off
axis square;
freq = unique(F);
mn = min(freq);
mx = max(freq);
xlim([pa_oct2bw(mn,-1),pa_oct2bw(mx,1)]);
set(gca,'XTick',freq,'XTickLabel',freq/1000);
xlabel('Frequency (kHz)');
if ~isempty(method)
	ylabel('Threshold (dB HL)');
else
	ylabel('Threshold (dBA)');
end
ylim([-20 90]);
set(gca,'YDir','reverse');
pa_horline([0 20]);

pa_datadir;
cd('E:\MATLAB\PANDA\Donders\Setups')
save audioavg F y method 