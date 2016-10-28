function [Mass, ElapseTime] = HSEstimation(TestData, Forest)
% 
% function HSEstimation: estimate test instance mass on half space forest
% 
% Input:
%     TestData: test data; nt x d matrix; nt: # of test instance; d: dimension;
%     Forest: half space forest model;
% 
% Output:
%     Mass: nt x NumTree matrix; mass of test instances;
%     ElapseTime: elapsed time;
% 

NumInst = size(TestData, 1);
Mass = zeros(NumInst, Forest.NumTree);

et = cputime;
for k = 1:Forest.NumTree
    Mass(:, k) = HSMass(TestData, 1:NumInst, Forest.Trees{k, 1}, zeros(NumInst, 1));
end
ElapseTime = cputime - et;
