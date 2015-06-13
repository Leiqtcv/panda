function varargout = rect2patch(C,R)

% [rect] = rect2patch(C,R)
% C = centre
% R = 'radius'
if numel(C)<2
    error
end
if numel(R)==1
    R = [R R];
end

if nargout==1
    %% rectangle matrix
    rect = [C(1) C(2) R(1) R(2)];
    varargout(1) = {rect};
else
    %% patch matrix
    X = [C(1) C(1)] + [-R(1) +R(1)];
    X = [X(1) X(1) X(2) X(2)];
    Y = [C(2) C(2)] + [-R(2) +R(2)];
    Y = [Y fliplr(Y)];
    if nargout==2
        varargout(1) = {X};
        varargout(2) = {Y};
    else
        figure;patch(X,Y,'r')
    end
end