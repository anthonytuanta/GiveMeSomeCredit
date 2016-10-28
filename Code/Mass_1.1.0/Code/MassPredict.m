function [TestMass, ElapseTime] = MassPredict(TestData, MassModel)
% 
% function MassPredict: estimate test instance mass using step function
% 
% Input:
%     TestData: test data; nt x d matrix; nt: # of test instance; d: dimension;
%     MassModel: trained mass estimation model;
% 
% Output:
%     TestMass: nt x NumT matrix; mass of test instances;
%     ElapseTime: elapsed time;
% 

NumInst = size(TestData, 1);
TestMass = zeros(NumInst, MassModel.NumT);

splits = MassModel.Splits;
et = cputime;
for tidx = 1:MassModel.NumT
    X = TestData(:, MassModel.Dims(tidx));
    [temp, bins] = histc(X, [-inf, splits(tidx, :), inf]);
    mass = MassModel.Mass(tidx, :);
    TestMass(:, tidx) = mass(bins);
end
ElapseTime = cputime - et;
