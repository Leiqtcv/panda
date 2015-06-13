function f = pa_faculty (n)
% F = FACULTY(N)
%
% Recursive function to compute faculty

% (c) 2011 Marc van Wanrooij
% E-mail: marcvanwanrooij@gmail.com

if (n < 0)
  f = nan;
elseif (n==0)
  f = 1;
else 
  f = n*pa_faculty(n-1);
end;