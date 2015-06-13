%Psychometric function with logistic regression
%Input: X,XMEAN,alpha,beta
%Output: estimated response data (proportion of one of two alternative
%responses)

%  theta[i,j] <- 0.5+0.5/(1+exp(-( -alpha[i] + x[i,j]-xmean[i] )/beta[i]))

function [rprop] = psychfunc2AFC(X,XMEAN,alpha,beta)
rprop=zeros(1,length(X));
for i=1:length(X)
    rprop(i) = 0.5+0.5./(1+exp(-((X(i) - XMEAN)-alpha)./beta));
end
end