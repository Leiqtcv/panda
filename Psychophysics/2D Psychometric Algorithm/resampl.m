function [p_theta, weights] = resampl(stimidx, resp, psi_x, p_theta)
    M = size(stimidx, 2);
    
    stimidxm = cell(1, M);
    
    for i = 1:M
        stimidxm{i} = stimidx(i);
    end
   
%     [Imax, ind] = max(I_mut(:));
% 
%     isub = cell(1, M);
%     [isub{:}] = ind2sub(size(I_mut), ind)
    
    if resp == 0;
        weights = 1-psi_x(:, stimidxm{:});
        p_theta = p_theta .* (weights');
    else
        weights = psi_x(:, stimidxm{:});
        p_theta = p_theta.*(weights');
    end

    p_theta = p_theta/sum(p_theta);
