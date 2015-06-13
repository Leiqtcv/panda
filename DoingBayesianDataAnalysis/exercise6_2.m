close all
clear all
pTheta = [50:-1:1 , ones(1,50) , 1:50 , 50:-1:1 , ones(1,50) , 1:50];
pTheta = pTheta/sum(pTheta);

width = 1/length(pTheta);
Theta = width/2:width:1-width/2;
post = BernGrid(Theta,pTheta, [ones(1,15) zeros(1,5)]);