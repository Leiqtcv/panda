function [phi, theta]=stphases2(Sphi1, Sphi2, Tphi1, Tphi2)
%
% function [phi, theta]=STphases2(Sphi1, Sphi2, Tphi1, Tphi2);
%   25-2-04
%
Xhi1=angle(exp(1i*(Sphi1+Tphi1)));
Xhi2=-angle(exp(1i*(Sphi2+Tphi2)));      % quadrant 4, see Fig. 7 in Depireux

disp(['phase 1: ',num2str(Xhi1),' * phase 2: ',num2str(Xhi2)]);

phi=angle(exp(1i*(Xhi2+Xhi1)/2));			% spectral
theta=angle(exp(1i*(Xhi2-Xhi1)/2));		% temporal

if abs(phi)>pi/2,
   phi=angle(exp(1i*(pi-phi)));
   theta=angle(exp(1i*(pi-theta)));
end


