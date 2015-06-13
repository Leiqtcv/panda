function tmp
%% Initialization
% Clear
close all
clear all
% Variables
AZ = -90:1:90;
AZ = AZ';
n = 100;
EL = NaN(length(AZ),n);
for ii = 1:length(AZ)
	mx = abs(round(abs(AZ(ii))-90))
	if mx>0
	y = linspace(-mx,mx,n)
	else 
		y = zeros(1,n);
	end
	EL(ii,:) = y;
end
AZ = repmat(AZ,1,n);
% AZ2 = EL;
% EL = AZ;
% AZ = AZ2;
R = 1;

% figure
% plot(AZ,EL,'.');
% 
% return
X                   = R*sind(AZ); % Left-right
Y                   = R*sind(EL); % Up-Down

signZ               = sign(cosd(AZ).*cosd(EL));
absZ                = abs(sqrt(R.^2-X.^2-Y.^2));
Z                   = signZ .* absZ;
X = [X;X];
Y = [Y;Y];
Z = [Z;-Z];
AZ = [AZ;AZ];
EL = [EL;EL];
% Z = sqrt(R.^2-X.^2-Y.^2);

% C = hot(numel(AZ));
% k = 5;
% n = 2^k-1;
% theta = pi*(-n:2:n)/n;
% phi = (pi/2)*(-n:2:n)'/n;
% X = cos(phi)*cos(theta);
% Y = cos(phi)*sin(theta);
% Z = sin(phi)*ones(size(theta));
% % colormap([0 0 0;1 1 1])
% C = hadamard(2^k); 
% whos C
% 
% plot3(X,Y,Z,'k.');
% hold on
% whos C Z
surf(X,Y,Z,AZ)
shading flat
axis([-1 1 -1 1 -1 1]);
axis square;
grid off
camlight('headlight')
view(2);
% colormap hot
colormap cool

lighting phong
material dull
axis off
colorbar

pa_datadir;
% print('-dpng','elevation');
% print('-depsc','-painter','elevation');

print('-dpng','azimuth');
print('-depsc','-painter','azimuth');
