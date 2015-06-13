function BernMetropolisTemplate
% BERNMETROPOLISTEMPLATE
%
% Use this program as a template for experimenting with the Metropolis
% algorithm applied to a single parameter called theta, defined on the
% interval [0,1].
%
% Original in R:	Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% Modified to Matlab code: Marc M. van Wanrooij

close all

%% Specify the data, to be used in the likelihood function.
% This is a vector with one component per flip,
% in which 1 means a "head" and 0 means a "tail".
myData = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0];

%% Exercise 7.3B
% myData		= [ones(1,8) zeros(1,4)]; % 8 heads, 4 tail

%% Specify the length of the trajectory, i.e., the number of jumps to try:
trajLength = 55556; % arbitrary large number
% Initialize the vector that will store the results:
trajectory = zeros(1,trajLength);
% Specify where to start the trajectory:
trajectory(1) = 0.50; % arbitrary value
% Specify the burn-in period:
burnIn = ceil(0.1*trajLength); % arbitrary number, less than trajLength
% Initialize accepted, rejected counters, just to monitor performance:
nAccepted = 0;
nRejected = 0;
% % Specify seed to reproduce same random walk:
% set.seed(47405)


% Now generate the random walk. The 't' index is time or trial in the walk.
for t = 1:(trajLength-1)
	currentPosition = trajectory(t);
	% Use the proposal distribution to generate a proposed jump.
	% The shape and variance of the proposal distribution can be changed
	% to whatever you think is appropriate for the target distribution.
	proposedJump = 0.1*randn(1);
	
	% Compute the probability of accepting the proposed jump.
	p = targetRelProb(currentPosition+proposedJump,myData)./targetRelProb(currentPosition,myData);
	probAccept = min(1,p);
	% Generate a random uniform value from the interval [0,1] to
	% decide whether or not to accept the proposed jump.
	if rand(1) < probAccept
		% accept the proposed jump
		trajectory(t+1) = currentPosition+proposedJump;
		% increment the accepted counter, just to monitor performance
		if t > burnIn
			nAccepted = nAccepted+1;
		end
	else
		% reject the proposed jump, stay at current position
		trajectory(t+1) = currentPosition;
		% increment the rejected counter, just to monitor performance
		if t>burnIn
			nRejected = nRejected+1;
		end
	end
end

% Extract the post-burnIn portion of the trajectory.
acceptedTraj = trajectory(burnIn+1:length(trajectory));

% End of Metropolis algorithm.

%% Graphics
% Display the posterior.
figure;
plotPost(acceptedTraj ,'xlim',[0,1],'xlab','\theta');

% Display rejected/accepted ratio in the plot.
% Get the highest point and mean of the plot for subsequent text positioning:
densMax		= max(ksdensity(acceptedTraj));
meanTraj	= mean(acceptedTraj);
sdTraj		= std(acceptedTraj);
if meanTraj>0.5
  xpos = 0.1;
  xadj = 'left';
else
  xpos = 0.9; 
  xadj = 'right';
end
str = ['$$N_{pro} = ' num2str(length(acceptedTraj)) ', {N_{acc} \over N_{pro}} = ' num2str(nAccepted/length(acceptedTraj),3) '$$'];
text(xpos,0.75*densMax,str,'Interpreter','Latex','HorizontalAlignment',xadj,'FontSize',12);
str = ['$$N_{pro} = ' num2str(length(acceptedTraj)) ', {N_{acc} \over N_{pro}} = ' num2str(nAccepted/length(acceptedTraj),3) '$$'];
text(xpos,0.75*densMax,str,'Interpreter','Latex','HorizontalAlignment',xadj,'FontSize',12);

% Evidence for model, p(D).
% ------------------------------------------------------------------------
% Compute a,b parameters for beta distribution that has the same mean
% and stdev as the sample from the posterior. This is a useful choice
% when the likelihood function is Bernoulli.
% See equation 5.6
a = meanTraj*((meanTraj*(1-meanTraj)/sdTraj^2)-1);
b = (1-meanTraj)*((meanTraj*(1-meanTraj)/sdTraj^2)-1);

%% Exercise 7.4B
% a = 1;
% b = 1;

%% Exercise 7.4C
% a = 10;
% b = 10;

% For every theta value in the posterior sample, compute dbeta(theta,a,b) /
% likelihood(theta)*prior(theta). This computation assumes that likelihood
% and prior are proper densities, i.e., not just relative probabilities.
% This computation also assumes that the likelihood and prior functions
% were defined to accept a vector argument, not just a single-component
% scalar argument.
% Do these steps seem strange? There is some mathematical magic going on
% here, explained in Kruschke, J. K. (2011). Doing Bayesian Data Analysis:
%					A Tutorial with R and BUGS. Academic Press / Elsevier.
% p 137, section 7.3.3

wtdEvid = betapdf(acceptedTraj,a,b)./(likelihood(acceptedTraj,myData).*prior(acceptedTraj));
pData	= 1/mean(wtdEvid);

% Display p(D) in the graph
if meanTraj > 0.5
	xpos = 0.1; 
	xadj = 'left';
else
	xpos = 0.9;
	xadj = 'right';
end
str = ['p(D) = ' num2str(pData,3)];
text(xpos,0.9*densMax,str,'HorizontalAlignment',xadj)

%% Exercise 7.4A
% figure
% plot(wtdEvid,'k-');
% axis square
% box off
% set(gca,'TickDir','out');

%% To save graph
print('-depsc','-painter',mfilename);

function pDataGivenTheta = likelihood(theta,data)
% Define the Bernoulli likelihood function, p(D|theta).
% The argument theta could be a vector, not just a scalar.
z				= sum(data == 1);
N				= length(data);
pDataGivenTheta = theta.^z.*(1-theta).^(N-z);
% The theta values passed into this function are generated at random,
% and therefore might be inadvertently greater than 1 or less than 0.
% The likelihood for theta > 1 or for theta < 0 is zero:
sel						= theta>1 | theta<0;
pDataGivenTheta(sel)	= 0;


function pTheta = prior(theta)
% Define the prior density function. For purposes of computing p(D),
% at the end of this program, we want this prior to be a proper density.
% The argument theta could be a vector, not just a scalar.
pTheta = ones(1,length(theta)); % uniform density over [0,1]
%% Exercise 7.3B
% pTheta		= (cos(4*pi*theta)+1).^2;
%% For kicks, here's a bimodal prior. To try it, uncomment the next line.
% pTheta = betapdf(min([2*theta;2*(1-theta)]),2,2)
%% The theta values passed into this function are generated at random,
% and therefore might be inadvertently greater than 1 or less than 0.
% The prior for theta > 1 or for theta < 0 is zero:
sel = theta>1 | theta<0;
pTheta(sel) = 0;


function pThetaGivenDataU = targetRelProb(theta,data)
% Define the relative probability of the target distribution,
% as a function of vector theta. For our application, this
% target distribution is the unnormalized posterior distribution.
pThetaGivenDataU =  likelihood(theta,data) .* prior(theta);


