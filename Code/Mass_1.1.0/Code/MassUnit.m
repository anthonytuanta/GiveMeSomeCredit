function mass = MassUnit(X, a, h)
%
% function MassUnit: estimate mass of point X(a) on data X
%
% Input:
%     X: n x 1 vector; n: # of instance (dimension = 1);
%     (Notice: X should be sorted ascendingly)
%     a: index of data point X(a);
%     h: parameter level for mass estimation;
%
% Output:
%     mass: estimated mass;
%

ps = (X(2:end) - X(1:(end - 1))) ./ (max(X) - min(X));
n = length(X);

if (h <= 1)
    if (n <= 1)
        mass = 0;
    else
        m = 1:(n - 1);
        m(1:(a - 1)) = n - (1:(a - 1))';
        mass = m * ps;
    end
else
    if (n <= 1)
        mass = 0;
    else
        mm = zeros(1, (n - 1));
        for i = 1:(n - 1)
            if i < a
                mm(i) = MassUnit(X((i + 1):n), a - i, h - 1);
            else
                mm(i) = MassUnit(X(1:i), a, h - 1);
            end
        end
        mass = mm * ps;
    end
end
