% BETAPOSTERIORPREDICTIONS
%
% Exercise 5.7
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all
clear all

% Specify known values of prior and actual data
priorA = 100;
priorB = 1;
actualDataZ = 8;
actualDataN = 12;
% Compute posterior parameter values
postA = priorA+actualDataZ;
postB = priorB+actualDataN-actualDataZ;
% Number of flips in a simulated sample should match the actual sample size
simSampleSize = actualDataN;
% Designate an arbitrarily large number of simulated samples
nSimSamples = 10000;
% Set aside a vector in which to store the simulation results
simSampleZrecord = NaN(nSimSamples,1);
for ii = 1:nSimSamples
	% Generate a theta value for the new sample from the posterior
	sampleTheta = random('beta',postA,postB);
	% Generate a sample using sampleTheta
	sampleData = binornd(ones(1,simSampleSize),sampleTheta);
	% Store the number of heads in sampleData
	simSampleZrecord(ii) = sum(sampleData);
end
x = 0:actualDataN;
N = hist(simSampleZrecord,x);
bar(x,N,'FaceColor',[.7 .7 .7]);