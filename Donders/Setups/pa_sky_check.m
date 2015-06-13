function pa_sky_check
% PA_SKY_CHECK
% 
% Luminance measurements of the 'SKY'-LEDs in the hoop set-up on 20 Feb
% 2013, after moving to Huijgens-building

% 2012 Rachel Gross-Hardt, Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com

close all
clear all

%% First measurements:
% complete darkness for intensity 1, room lights on lowest possible intensity for intensity 255
% Illuminance meter:  Preset, absolute, slow response
% While sitting in chair, meter directed at LEDs (center), sharpness adjusted and illuminance measured

%% Intensity 1
x		= 1:7; % Ring 1:7
z		= 0.014;
Y(:,1)	= [0.045;0.046;0.032;0.040;0.026;0.024;0.015]; % spaak 1
Y(:,2)	= [0.044;0.034;0.033;0.039;0.027;0.024;0.017];
Y(:,3)	= [0.036;0.032;0.047;0.041;0.035;0.026;0.019];
Y(:,4)	= [0.040;0.037;0.035;0.040;0.038;0.023;0.019];
Y(:,5)	= [0.076;0.039;0.031;0.041;0.034;0.029;0.025];
Y(:,6)	= [0.034;0.031;0.033;0.029;0.023;0.024;0.020];
Y(:,7)	= [0.031;0.038;0.023;0.037;0.024;0.017;0.014];
Y(:,8)	= [0.031;0.032;0.039;0.015;0.034;0.040;0.018];
Y(:,9)	= [0.036;0.039;0.038;0.038;0.031;0.011;0.018];
Y(:,10) = [0.028;0.021;0.032;0.040;0.027;0.025;0.014];
Y(:,11) = [0.040;0.033;0.034;0.035;0.031;0.025;0.019];
% Y(:,12) = [0.042;0.036;0.042;0.039;0.029;0.037;0.006]; % spaak 12, pre-21-Feb-2013
Y(:,12) = [0.042;0.036;0.042;0.039;0.029;0.037;0.012]; % spaak 12

plotsky(x,Y,z,1,3,1,0);


%% Intensity 255
x = 1:7;
z      = 3.2;
Y(:,1) = [11.3;11.3;8.2;4.8;6.6;5.9;3.5];
Y(:,2) = [10.7;8.4;8.5;9.7;6.7;6.1;4.2];
Y(:,3) = [8.7;8.2;12.1;10.4;8.97;6.5;4.67];
Y(:,4) = [10.2;9.5;9;11.2;9.7;6;4.6];
Y(:,5) = [18.5;10.3;8.1;11.4;9.2;7.6;6];
Y(:,6) = [8.9;9.5;8.8;8.5;7.1;8.1;5.8];
Y(:,7) = [11;13.8;8.1;12.4;8.4;5.5;4.3];
Y(:,8) = [10.6;11.6;14.1;5.4;11.9;13.6;5.8];
Y(:,9) = [12.8;14.3;13.7;13.9;11.6;2.6;4.6];
Y(:,10) = [7.4;5.6;8.6;10.8;6.9;6.8;3.2];
Y(:,11) = [10.7;8.9;9.3;9.8;8.6;6.8;4.6];
% Y(:,12) = [11.7;10.1;11.9;11.2;7.6;9.7;1.3]; % pre-21-Feb-2013
Y(:,12) = [11.7;10.1;11.9;11.2;7.6;9.7;2.9];

plotsky(x,Y,z,2,4,255,0);

pa_datadir;
print('-depsc','-painter',[mfilename '1']);

%% Measured with standard and some LEDs adjusted, intensity = 1
%(distance: 106cm to central fixation LED, up to 183 cm to far left LED)
clear Y
x = 1:7;
Y(:,1) = [0.050;0.045;0.065;0.058;0.043;0.028;0.020];
Y(:,2) = [0.058;0.054;0.047;0.058;0.051;0.026;0.020];
Y(:,3) = [0.111;0.064;0.050;0.064;0.045;0.033;0.026];
Y(:,4) = [0.053;0.049;0.049;0.044;0.030;0.022;0.020];
Y(:,5) = [0.050;0.061;0.037;0.056;0.034;0.020;0.018];
Y(:,6) = [0.043;0.045;0.053;0.042;0.040;0.037;0.020];
Y(:,7) = [0.050;0.055;0.048;0.046;0.034;0.019;0.019];
figure(2)
plotsky(x,Y,0,1,3,1,2);

%% Measured with standard and some LEDs adjusted, intensity = 255
%(distance: 106cm to central fixation LED, up to 183 cm to far left LED)
clear Y
x = 1:1:7;
Y(:,1) = [13.36;11.51;16.66;14.8;10.85;7.03;4.86];
Y(:,2) = [15.48;14.02;12.50;14.72;12.88;6.43;4.82];
Y(:,3) = [29.12;16.21;12.86;16.7;11.51;8.13;6.36];
Y(:,4) = [13.39;12.40;12.46;10.97;7.46;5.45;4.95];
Y(:,5) = [12.6;15.62;9.55;14.27;8.33;5.1;4.21];
Y(:,6) = [10.93;11.4;13.66;10.58;10.36;9.74;5.2];
Y(:,7) = [13.42;14.46;12.45;11.6;8.4;4.53;4.55];
figure(2)
plotsky(x,Y,0,2,4,1,2);

pa_datadir;
print('-depsc','-painter',[mfilename '2']);

%% Intensity curve for fixation LED
% Distance 106cm
figure(3)
x = [1;5;10;30;50;80;100;130;150;170;200;230;250;255];
I = [0.020;0.101;0.200;0.600;0.996;1.588;1.980;2.564;2.950;3.333;3.905;4.470;4.844;4.930];
plot(x,I,'k-o','MarkerFaceColor','w','LineWidth',2)
% axis square
box off
title('Intensity Curve Fixation LED')
xlabel('Intensity')
ylabel('Luminance (cd/m2)')
xlim([0 256]);
axis square;
b = regstats(I,x);
h = pa_regline(b.beta,'r-');
str = ['L = ' num2str(b.beta(2),2) ' x I_{EXP} + ' num2str(b.beta(1),2)];
title(str);

pa_datadir;
print('-depsc','-painter',[mfilename '3']);

function plotsky(x,Y,z,sb1,sb2,int,spoke)
n		= size(Y,2);
col		= hot(n+2);
muY		= mean(Y,2);

subplot(2,2,sb1)
plot(0,z,'ko','MarkerFaceColor','w','LineWidth',2,'MarkerSize',8)
hold on
for ii	= 1:n
	plot(x,Y(:,ii),'ko-','MarkerFaceColor',col(ii,:),'Color',[.7 .7 .7]);
end
plot(x,muY,'k-','LineWidth',2);
xlabel('Ring')
ylabel('Luminance (cd/m2)')
title (['Intensity: ' num2str(int) ' au'])
box off
axis square;
xlim([min(x)-2 max(x)+1]);
pa_text(0.1,0.9,char(64+sb1));

%% Grid
indx = 1:size(Y,2);
% Y = bsxfun(@rdivide, Y, muY); % normalize
Y = Y/10
subplot(2,2,sb2)
n		= numel(Y);
[R,S]	= meshgrid(x,indx+spoke);
[az,el] = pa_sky2azel(R,S);
plot(az,el,'k-','Color',[.7 .7 .7]);
hold on


[S,R] = meshgrid(indx+spoke,x);
[az,el] = pa_sky2azel(R,S);
plot(az,el,'k-','Color',[.7 .7 .7]);

col = hot(15);
for ii = 1:n
	plot(az(ii),el(ii),'ko','MarkerSize',ceil(Y(ii)*5),'MarkerFaceColor',col(S(ii),:),'Color',[.7 .7 .7]);
end
axis([-60 60 -60 60]);
axis square;
box off;
xlabel('Azimuth (deg)');
ylabel('Elevation (deg)');
pa_text(0.1,0.9,char(64+sb2));






