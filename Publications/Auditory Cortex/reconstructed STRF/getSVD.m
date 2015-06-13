function [ev, alfa, p,q]=getSVD(A)
%
%	[ev, alfa, p, q]=getSVD(A);
%
%	ev: eigenvalues
%	inseparability index, alfa=0: separable, alfa=1: inseparable
%	p, q: in case of separability: A=p*q
%
[U,S,V]=svd(A);

ev=diag(S)/max(diag(S));

fac=S(1,1);
S1=zeros(size(A));
S1(1,1)=sqrt(fac);

P=U*S1; p=P(:,1);
Q=S1*V'; q=Q(1,:);

alfa=1-1/(sum(ev.^2));