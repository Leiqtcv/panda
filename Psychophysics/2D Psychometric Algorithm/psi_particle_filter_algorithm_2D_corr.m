%% Psi-particle-filter algorithm 2D (no grid sampling)

% The purpose of this script is to extend the 1D Psi Particle filter
% algorithm as mentioned in Kujala et al. (2005). Instead of discretizing
% the prior distribution as a large table (see 1D_Psi_Algorithm), we will
% use a Monte Carlo sample of constant size to approximate the prior
% distribution of parameters at each trial. Thus, there will be a random
% error in each approximated distribution, yielding slightly diferent runs
% for the same data. A Markov Chain Monte Carlo (MCMC) algorithm can be
% used to obtain a sample (set of theta) of N (assumedly) i.i.d. draws
% from the posterior. In order to avoid degeneracy of the particle filter
% into only one particle by means of updating according to weight, a
% certain number of particles is updated by means of a normal distribution
% fitted on the current distribution of particles.
% The script quantifies the mean and standard deviation of the psychometric
% curves of the subject at two different depths (4 parameters)(15-11-2011)

clear all
close all
clc
clf

%% Input parameters

% First of all we describe the parameters of the subject
gen_params = [0 10 20 20]; % Generative parameters [mu0 sigma0 mu1 sigma1]
xvalues = -40:10:100; % possible direction values (mm)
yvalues = 0:50:1000; % possible depth values (mm)

%% Step 1:
% Create a prior distribution of all theta's and obtain an i.i.d.sample
% (set of theta = particles) of size N from the prior distribution using an
% MCMC algorithm like the component wise Metropolis sampler. Do this for
% both the psychometric curve at y0 and at y1.

% Initialize the Metropolis sampler
N = 50000; % maximum number of iterations/particles
% N = 1000;
propsigma = 1; % set standard deviation of our proposal distribution
thetamin = [-10 0 -10 0]; % define minimum for [mu0 sigma0 mu1 sigma1]
thetamax = [30 25 30 25]; % define maximum for [mu0 sigma0 mu1 sigma1]
p_theta = ones(1,N)/N; % Define the prior distribution
theta1 = unifrnd(thetamin(1), thetamax(1)); % Start value for mu
theta2 = unifrnd(thetamin(2), thetamax(2)); % Start value for sigma
theta3 = unifrnd(thetamin(3), thetamax(3)); % Start value for mu
theta4 = unifrnd(thetamin(4), thetamax(4)); % Start value for sigma

theta = [theta1 theta2 theta3 theta4]';
% Start the Metropolis sampler
state = mh_sampl(N,theta,thetamin,thetamax,propsigma,p_theta);

mu = gen_params([1 3]);
sd = gen_params([2 4]);
% pa_ellipseplot(mu,sd,0);

% So now we have obtained a i.i.d. sample of our prior distribution p(theta).
% Remember that the sigma of the proposal distribution and the length of
% our set of samples determine how accurate we sample.

%% Step 2:
% For each trial use a global optimization algorithm to find an x(t+1) that
% maximizes the Monte Carlo approximation of mutual information w.r.t. x as
% well as possible. (see Kujala for explanation)

tic
n_trials = 180;

stim = zeros(2, n_trials);
resp = zeros(1, n_trials);
% Number of particles we choose by means of a distribution
update = 5000;
for t = 1:n_trials
% 	myplot(state,t,thetamin,thetamax, gen_params); % Optional
	t
	[I_mut psi_x] = I_mutualinf(@probfunc_2D, state',update, xvalues, yvalues);
	
	[Imax, ind] = max(I_mut(:));
	[x_ind, y_ind] = ind2sub(size(I_mut), ind);
% 	drawnow
	% saveas(gcf, 'I_mut_t.fig')
	% myObj = VideoWriter('newfile.avi');
	% myObj.FrameRate = 1000;
	
	% Prepare the new file.
	% vidObj = VideoWriter('peaks2.avi')z;
	% open(vidObj);
	%
	% surf(xvalues, yvalues, I_mut'); shading interp
	% hold on
	% plot3(xvalues(x_ind), yvalues(y_ind),Imax, 'k+', 'Markersize', 12)
	%
	% currFrame(t) = getframe;
	% writeVideo(vidObj,currFrame(t));
	
	
	%[I_mut, psi_x] = I_mutualinf_1D(N, x, state); example of the 1D mutual
	%information calculation.
	
	%% Step 3:
	% Run a trial at intensity x(t+1)
	
	% y_ind = find(yvalues == 250);
	
	x_next = xvalues(x_ind);
	y_next = yvalues(y_ind);
	
	stim(1, t) = x_next;
	stim(2, t) = y_next;
	
	resp(t) = probfunc_2D(gen_params, stim(1, t), stim(2, t)) > rand(1,1);
	% Select answer of subject
	
	%% Step 4:
	% Transform our particle set to the posterior distribution p_theta(t+1)
	% using importance resampling (sequential Monte Carlo) with its
	% corresponding weights.
	
	[p_theta, weights] = resampl([x_ind y_ind], resp(t), psi_x, p_theta);
	% myplot(state,t,thetamin,thetamax,gen_mu, gen_sig,p_theta); % Optional
	% Note that this loop is degenerative for the particles. More trials
	% will leave you with only one possible particle!
	[p index] = max(p_theta);
	est_mu0(t) = state(1,index);
	est_sig0(t) = state(2,index);
	est_mu1(t) = state(3,index);
	est_sig1(t) = state(4,index);
	%% Step 5:
	% Avoid degeneracy by running an MCMC algorithm to update each
	% particle on the posterior distribution p_theta(t+1) for L steps,
	% resulting in an i.i.d sample.
	
	state_new = zeros(size(state));
	
	% Update our particles! First  particles are updated according to the
	% weights. The more likely particles are chosen moreover.
	% The last particles are updated according to a normal distribution for mu
	% and a gamma distribution or normal distribution for sigma( normal distribution will give a bias)
	
	state = updatepart(state, weights, update);
end
toc

%% P_theta updaten om te kijken hoe die er uit zou moeten zien!

% for i = 1:50000
%     p_theta_act(i) = 1/50000;
% end
% for j = 1:180
%     if resp(j) == 0;
%             p_theta_act = p_theta_act.*(1-probfunc_2D(state', stim(1,j), stim(2,j)));
%     else p_theta_act = p_theta_act.*(probfunc_2D(state', stim(1,j), stim(2,j)));
%     end
% end

