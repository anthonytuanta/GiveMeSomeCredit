function Forest = HSForest(Data, NumTree, NumSub, NumDim, SizeLimit, DepthLimit, rseed)
%
% function HSForest: build half space forest
%
% Input:
%     Data: n x d matrix; n: # of instance; d: dimension;
%     NumTree: # of half space trees;
%     NumSub: # of sub-sample;
%     NumDim: # of sub-dimension;
%     SizeLimit: leaf size limitation;
%     DepthLimit: maximun depth limitation;
%     rseed: random seed;
%
% Output:
%     Forest.Trees: a half space forest model;
%     Forest.NumTree: NumTree;
%     Forest.NumSub: NumSub;
%     Forest.NumDim: NumDim;
%     Forest.SizeLimit: SizeLimit;
%     Forest.DepthLimit: DepthLimit;
%     Forest.ElapseTime: elapsed time;
%     Forest.rseed: rseed;
%

[NumInst, DimInst] = size(Data);
Forest.Trees = cell(NumTree, 1);

Forest.NumTree = NumTree;
Forest.NumSub = NumSub;
Forest.NumDim = NumDim;
Forest.SizeLimit = SizeLimit;
Forest.DepthLimit = DepthLimit;
Forest.rseed = rseed;
rand('state', rseed);

% parameters for function HSTree
Paras.NumDim = NumDim;
Paras.SizeLimit = SizeLimit;
Paras.DepthLimit = DepthLimit;

et = cputime;
for i = 1:NumTree
    
    if NumSub < NumInst % randomly selected sub-samples
        [temp, SubRand] = sort(rand(1, NumInst));
        IndexSub = SubRand(1:NumSub);
    else
        IndexSub = 1:NumInst;
    end
    if ((NumDim < DimInst) && (NumDim > 0)) % randomly selected sub-dimensions
        [temp, DimRand] = sort(rand(1, DimInst));
        IndexDim = DimRand(1:NumDim);
    else
        IndexDim = 1:DimInst;
        Paras.NumDim = DimInst;
    end
    [MaxAtt, MinAtt] = HSWorkSpace(Data(IndexSub, :)); % generate work space
    
    Paras.IndexDim = IndexDim;
    
    Forest.Trees{i} = HSTree(Data, IndexSub, MaxAtt, MinAtt, 0, Paras); % build a half space tree
    
end

Forest.ElapseTime = cputime - et;
