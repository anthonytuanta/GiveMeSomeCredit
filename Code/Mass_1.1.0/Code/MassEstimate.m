function datamass = MassEstimate(X, h)
%
% function MassEstimate: estimate mass of data in X
%
% Input:
%     X: n x 1 vector; n: # of instance (dimension = 1);
%     (Notice: X should be sorted ascendingly)
%     h: parameter level for mass estimation;
%
% Output:
%     mass: estimated mass;
%

datamass = zeros(length(X), 1);
for a = 1:length(X)
    datamass(a) = MassUnit(X, a, h);
end
