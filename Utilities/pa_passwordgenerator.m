function psswrd = pa_passwordgenerator
% PASSWORD = PA_PASSWORDGENERATOR

% 2013 Marc van Wanrooij
% e-mail: m.vanwanrooij@donders.ru.nl

nchars = randi([8 13],1,1);
nletters = randi([nchars-4 nchars-1],1,1);
nnumbers = nchars-nletters;

isletter = false;
while ~isletter
indx = randi(56,1,nletters);
isletter = ~any(ismember(indx,26:51));
% isletter = true
end
l = char(64+indx)';
n = num2str(randi([0 9],1,nnumbers)');

indx = randperm(nchars);
a = [l; n]';
psswrd = a(indx);
% 
% char(65:65+25)
% char(65+26:65+32)
