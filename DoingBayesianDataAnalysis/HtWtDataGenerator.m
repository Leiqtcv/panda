function [Data,male,height,weight] = HtWtDataGenerator(nSubj,rndsd)
% Random height, weight generator for males and females. Uses parameters from
% Brainard, J. & Burmaster, D. E. (1992). Bivariate distributions for height and
% weight of men and women in the United States. Risk Analysis, 12(2), 267-275.
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

if nargin<1
	nSubj = 5;
end
if nargin<2
	rndsd = [];
end
% Specify parameters of multivariate normal (MVN) distributions.
% Men:
HtMmu		= 69.1;
HtMsd		= 2.87;
lnWtMmu		= 5.14;
lnWtMsd		= 0.17;
Mrho		= 0.42;
Mmean		= [HtMmu , lnWtMmu];
Msigma		= [HtMsd^2,Mrho*HtMsd*lnWtMsd;Mrho*HtMsd*lnWtMsd,lnWtMsd^2];
% Women cluster 1:
HtFmu1		= 63.11;
HtFsd1		= 2.76;
lnWtFmu1	= 5.06;
lnWtFsd1	= 0.24;
Frho1		= 0.41;
prop1		= 0.46;
Fmean1		= [HtFmu1 , lnWtFmu1];
Fsigma1		= [HtFsd1^2,Frho1*HtFsd1*lnWtFsd1;Frho1*HtFsd1*lnWtFsd1,lnWtFsd1^2];

% Women cluster 2:
HtFmu2		= 64.36;
HtFsd2		= 2.49;
lnWtFmu2	= 4.86;
lnWtFsd2	= 0.14;
Frho2		= 0.44;
Fmean2		= [HtFmu2,lnWtFmu2];
Fsigma2		= [HtFsd2^2,Frho2*HtFsd2*lnWtFsd2;Frho2*HtFsd2*lnWtFsd2,lnWtFsd2^2];

% Randomly generate data values from those MVN distributions.
if ~isempty(rndsd)
	stream = RandStream('mt19937ar','Seed',rndsd); % MATLAB's start-up settings
	RandStream.setGlobalStream(stream);
end
Data = zeros(nSubj,3);
% colnames(datamatrix) = {'male','height','weight'}; %???
male	= 1;
height	= 2;
weight	= 3;
for ii = 1:nSubj
	% Flip coin to decide sex
	sex = binornd(1,0.5,1);
	if sex % male
		datum = mvnrnd(Mmean,Msigma,1);
	else % female
		Fclust = binornd(1,prop1,1);
		if Fclust == 0 
			datum = mvnrnd(Fmean1,Fsigma1,1);
		else
			datum = mvnrnd(Fmean2,Fsigma2,1);
		end
		
	end
	Data(ii,:) = [sex , round([datum(1),exp(datum(2))])];
end
