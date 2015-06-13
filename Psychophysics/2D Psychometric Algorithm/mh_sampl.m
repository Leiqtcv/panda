function [state] = mh_sampl(N,theta, thetamin, thetamax, propsigma, p_theta)

% MH_SAMPLE(N, THETA, THETAMIN, THETAMAX, PROPSIGMA, P_THETA) defines a
% sample set of length N of parameter values based on a MCMC method using
% theta. 
% N: the number of samples.
% THETA: the starting value of the parameters.
% THETAMIN: the minimum value of the parameters.
% THETAMAX: the maximum value of the parameters.
% PROPSIGMA: the value of sigma used in the Gaussian proposal distribution
% centered around the old parameter value to determine the new parameter
% value i.e. determine the new sample. 
% P_THETA: the probability distribution of the parameters. 

t=1; % Initialize iteration at 1
state = zeros(length(theta),N);
state(:,1) = theta; 

while t < N
    t = t+1;
    
    % Propose a new value for mu and sigma
    new_theta = normrnd(theta, propsigma); 
    % Use a Gaussian to propose new mu's and sigma's
    
    % if the values fall outside of our boundaries thetamin or thetamax,
    % correct for them!
    for j = 1:length(thetamax)
        if(new_theta(j) > thetamax(j))
            new_theta(j) = thetamin(j) + rand; 
        end;
        if(new_theta(j) < thetamin(j)) 
            new_theta(j) = thetamax(j) - rand; 
        end;
    end

    pratio = p_theta(t)/p_theta(t-1);
    alpha = min(1,pratio); % Calculate acceptance ratio
    u = rand;
    if u < alpha
        theta = new_theta; % Proposal becomes new value for mu
    end
   
    % Save state
    state(:,t) = theta;
end