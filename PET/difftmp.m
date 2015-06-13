% function dicomtmp
close all
clear all
clc

d= 'C:\DATA\KNO\PET\DOESSCHATE\1';
cd(d);
d = dir('*.ima');
load hermes;

PSF = fspecial('gaussian',3,3);
for ii = 1:length(d)
% for ii = 13
    fname = d(ii).name;
    info = dicominfo(fname);
    I = dicomread(info);
    % Blurred = imfilter(I,PSF,'symmetric','conv');
%     sel = I>90;
%     sel1 = sum(sel)>0;
%     I = I(sel1,:);
%     sel2 = sum(sel,2)>0;
%     I = I(:,sel2);
    
%     figure(ii)
%     contourf(I,50);
        imshow(I,'DisplayRange',[]);
%     colormap(c);
%     shading flat;
%     axis square;
    title(ii)
    drawnow
%     pause(1)
end

