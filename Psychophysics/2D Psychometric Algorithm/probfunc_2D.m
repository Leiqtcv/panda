function p = probfunc_2D(particle, x, y)
    
% PROBFUNC_2D(PARTICLE, X, Y) computes the probability of a response right
% of the reference line for particular combinations of x and y values. 
% PARTICLE: 1x4 array of parameter values. Actually one sample which
% specifies mu0, sigma0, mu1 and sigma1. 
% X: scalar indicating the x location for which to compute the probability
% Y: scalar indicating the y location for which to compute the probability
% P: probability of subject responding the (x,y) location being right of 
% the reference line. 
    
   % Assumptions about the experimental setup
    y0 = 100;
    y1 = 500;
    
    % Interpolate mu at y
    mu0 = particle(:, 1);
    mu1 = particle(:, 3);    

    mu = mu0 + (y - y0) / (y1 - y0) * (mu1 - mu0);
    
    % Interpolate sigma at y
    sigma0 = particle(:, 2);
    sigma1 = particle(:, 4);
    sigma = sigma0 + (y - y0) / (y1 - y0) * (sigma1 - sigma0);
    
    % Compute probability    
    isneg = sigma < 0;
%     p = nan(size(sigma));
    p(isneg) = 1 - normcdf(x, mu(isneg), -sigma(isneg));
    p(~isneg) = normcdf(x, mu(~isneg), sigma(~isneg));

    %p = normcdf(x, mu, sigma);

end
