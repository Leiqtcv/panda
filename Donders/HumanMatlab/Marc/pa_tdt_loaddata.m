% Data inladen
Nsample = RA16_1.ReadTagV('NPtsRead',0,1)
Fsample = RA16_1.ReadTagV('Freq',0,1)
CurDAT = cell(1,2);
c=0;
for ii = 1:2
    CurDAT(ii) = {RA16_1.ReadTagVEX(['Data_' num2str(ii*4)], 0, Nsample, 'F32', 'F64', 1)};
end
NsampWrite	= numel(cell2mat(CurDAT));
saveDAT		= cell2mat(CurDAT);
FID = fopen(DatFile,'a'); % update == append
cnt = fwrite(FID,saveDAT,'double'); % can ok float sijn
fclose(FID);
% H = findobj('tag','LoaddataFART:Fig1');
% figure(H)

figure(100);
subplot(121);hold off
plot(cell2mat(CurDAT(1)).*1618,'k');hold on
plot(cell2mat(CurDAT(2)).*1618,'r')
ylim([-10,10])
title('Button')
legend('Left','Right')
