function [state_new] = updatepart(state, weights, update)

state_new = zeros(size(state));

% Select particles with largest weights

% Numbr of particles to update according to weight
num_part_weight = size(state, 2) - update;

% First order weights and compute normalized cumsum
[sorted_weights, sorted_indices] = sort(weights);
cum_weights = cumsum(sorted_weights);
nrm_cum_weights = cum_weights / cum_weights(end);

% Select normalized particle-weights to keep and sort them
to_keep = sort(rand(num_part_weight, 1));

% Walk through the list and copy particles to keep
j = 1;  % Index into sorted_weights

for i = 1:length(to_keep)
    while(nrm_cum_weights(j) < to_keep(i))
        j = j + 1;
    end

    state_new(:, i) = state(:, sorted_indices(j));
end

% Fit normal distribution to particles
mu = cell(size(state, 1), 1);
sigma = cell(size(state, 1), 1);

for i = 1:size(state, 1)
    [mu{i} sigma{i}] = normfit(state_new(i, 1:num_part_weight));
end

% FIXME: We might want to make this flexible: a normal distribution is now assumed!
% [mmu,smu] = normfit(state_new(1,1:length(state)-update));
% [msig,ssig] = normfit(state_new(2,1:length(state)-update));
% [msig,ssig] = gamfit(state_new(2,1:length(state)-update));

for i = length(state)-update:length(state)
    for j = 1:size(state, 1)
        state_new(j,i) = normrnd(mu{j},sigma{j});

        % FIXME: These are magic values:
        if(j == 2 || j == 4)
            while state_new(j, i) < 0
                state_new(j, i) = normrnd(mu{j}, sigma{j});
            end
        end
    end
end