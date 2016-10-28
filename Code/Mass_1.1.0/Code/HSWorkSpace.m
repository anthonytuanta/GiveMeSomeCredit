function [MaxAtt, MinAtt] = HSWorkSpace(Data)
% 
% function HSWorkSpace: generate work space
% 
% Input:
%     Data: the sub-sample;
% 
% Output:
%     MaxAtt: 1 x d vector; upper bounds of work space;
%     MinAtt: 1 x d vector; lower bounds of work space;
% 

[N, D] = size(Data);
MaxA = max(Data, [], 1);
MinA = min(Data, [], 1);

% random spliting values, i.e., s
SplitA = MinA + (MaxA - MinA) .* rand(1, D);
% range, i.e., r
RangeA = 2 .* max((SplitA - MinA), (MaxA - SplitA));

MaxAtt = SplitA + RangeA;
MinAtt = SplitA - RangeA;
