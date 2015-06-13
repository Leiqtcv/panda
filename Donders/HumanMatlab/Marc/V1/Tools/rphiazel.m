% function azel = rphiazel(R,Phi)
%
%   Coordinate transformation (r,phi) -> (az,el)
%
%   Jeroen Goossens

function ans=rphiazel(R,Phi)

if nargin==1 & size(R,2)==2
  Phi = R(:,2);
  R   = R(:,1);
end

xyz=rphi2xyz(R,Phi);
ans=xyz2azel(xyz(:,1),xyz(:,2),xyz(:,3));

