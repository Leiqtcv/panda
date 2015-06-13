function [I_mut, psi] = I_mutualinf(probfunc, state, update, varargin)   

% [I_MUT, PSI] = I_MUTUALINF(PROBFUNC, STATE, VARARGIN) computes for every
% possible spacesample combination of x,y,...n dimension the mutual
% information of that particular combination of values for each sample of
% parameters defined in state.
% PROBFUNC: probability function (see edit)
% STATE: the parameter values of each sample(combinations of mu and sigma)
% VARARGIN: variable number of input arguments depending on the number of
% dimensions we are looking at. 
% Example:
%  I_mutualinf(@probfunc_1D, state, xvalues)
%  I_mutualinf(@probfunc_2D, state, xvalues, yvalues)
%  I_mutualinf(@probfunc_4D, state, xvalues, yvalues, zvalues, wvalues)
% I_MUT: mutual information
% PSI: probability of finding the stimulus right of the reference line;
% based upon the function probfunc. 

if(nargin < 4), error('At least one sample-space dimension needs to be specified.'); end;

N = size(state( :,1),1);
M = nargin - 3;     % Number of dimensions in sample space

% Compute size of each dimension
dimension_size = nan(1, M);
for i = 1:M
    dimension_size(i) = length(varargin{i});
end

% Precompute multiplier for sub2ind-alternative
dimension_mult = cumprod([1 dimension_size(1:end-1)]);

% Initiate storage space
psi = nan([N dimension_size]);
jsub = cell(M, 1);
sample = cell(M, 1);

% sum(([4 3 2] - 1) .* dimension_mult) + 1

for j = 1:prod(dimension_size)
    [jsub{:}] = ind2sub(dimension_size, j);

    for k = 1:M            
        sample{k} = varargin{k}(jsub{k}); 
    end

    jind_start = 1 + N * sum(([jsub{:}] - 1) .* dimension_mult);
    jind_stop = N + N * sum(([jsub{:}] - 1) .* dimension_mult);

    psi(jind_start:jind_stop) = probfunc(state(:, :), sample{:});
  
    
end

N = 50000;

y_lines = [100 500];
%samples = [unifrnd(-10, 10, 1, N); unifrnd(-10, 10, 1, N)];
samples = [normrnd(3, 2, 1, N); normrnd(7, 5, 1, N)];


%[x_grid, y_grid] = meshgrid(x_values, y_values);

grid = zeros(length(varargin{1}), length(varargin{2}));

state = state';
% For each line
for s_ind = 1:N
    for y_ind = 1:length(varargin{2})
        frac = (varargin{2}(y_ind) - y_lines(1)) / diff(y_lines);
        x = state(1, s_ind) * frac + state(3, s_ind) * (1 - frac);
        [~, x_ind] = min(abs(varargin{1} - x));
        grid(:, y_ind) = grid(:, y_ind) + max(1 - abs(varargin{1} - x), 0)';
    end

end
grid = ones(length(varargin{1}), length(varargin{2})) - grid; 


h = @(x) -x.*log(x+1e-10)-(1-x).*log(1-x+1e-10); % Create the entropy function 


H_Rx_theta_t = sum(h(psi(1:(N-update),:,:)),1) / (N-update);

H_Rx_t = h(sum(psi(1:(N-update),:,:),1) / (N-update));
 
I_mut = shiftdim(H_Rx_t - H_Rx_theta_t); % Expected information gain/mutual information
% I_mut = I_mut.*grid;
