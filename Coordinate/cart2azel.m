function varargout = cart2azel (X,Y,Z)
% CART2AZEL Transform Cartesian to double polar coordinates.
% [AZ,EL,F] = CART2AZEL(X,Y,Z) transforms corresponding elements of data
%     stored in Cartesian coordinates X , Y and Z to double polar
%     coordinates (azimuth AZ and elevation EL).  The arrays X, Y and Z
%     must be the same size (or all can be scalar).
%     AZ and EL are returned in deg.
%
%
% See also AZEL2CART, AZEL2POL, FART2AZEL
%
% MarcW 2007

if nargin==1 && size(X,2)==3
    XYZ = X;
else
    XYZ = [X(:),Y(:),Z(:)];
end
XYZ     = XYZ./norm(XYZ);  % just normalize to make sure

AFE     = rad2deg(asin(XYZ));
AZ      = AFE(:,1);
EL      = AFE(:,3);
F       = AFE(:,2);

%% Output
if nargout == 1
    varargout(1) = {[AZ EL F]};
elseif  nargout == 2
    varargout(1) = {AZ};
    varargout(2) = {EL};
elseif nargout == 3
    varargout(1) = {AZ};
    varargout(2) = {EL};
    varargout(3) = {F};
else
    disp('Wrong number of output arguments');
end