function [N,ux] = pa_countunique(x)
% [N,UX] = PA_COUNTUNIQUE(X)
%
% Count the number N of unique occurrences UX in vector X
%

% 2013, Marc van Wanrooij
% e-mail: marcvanwanrooij@neural-code.com
[n,m] = size(x);
if m>n
	x = x';
end

ux		= unique(x,'rows'); % unique values of x
[n,m]	= size(ux);
n		= max([n m]);
N		= NaN(n,1);
for ii	= 1:n
	N(ii) = sum( x(:,1)==ux(ii,1) & x(:,2)==ux(ii,2) );
end



% x = min(ux(:,1)):max(ux(:,1));
% y = min(ux(:,2)):max(ux(:,2));
% x = 0:100;
% y = 0:100;
% [x,y] = meshgrid(x,y);
% 
% Cnt = zeros(size(x));
% n = numel(x);
% for ii = 1:n
% 	sel = ux(:,1)==x(ii) & ux(:,2)==y(ii);
% 	if sum(sel)
% 	Cnt(ii) = N(sel);
% 	end
% end
% 	
