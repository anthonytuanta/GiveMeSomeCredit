function Tree = HSTree(Data, CurtIndex, MaxAtt, MinAtt, CurtDepth, Paras)
% 
% function HSTree: build half space tree
% 
% Input:
%     Data: n x d matrix; n: # of instance; d: dimension (the whole data set);
%     MaxAtt: 1 x d vector; upper bounds of work space;
%     MinAtt: 1 x d vector; lower bounds of work space;
%     CurtIndex: index of current data instance;
%     CurtDepth: current tree depth;
%     Paras.IndexDim: sub-dimension index;
%     Paras.NumDim:  # of sub-dimension;
%     Paras.SizeLimit: leaf size limitation;
%     Paras.DepthLimit: maximun depth limitation;
% 
% Output:
%     Tree: a half space tree model
%     Tree.NodeStatus: 1: inNode, 0: exNode;
%     Tree.SplitAttribute: splitting attribute;
%     Tree.SplitPoint: splitting point;
%     Tree.LeftChild: left child tree which is also a half space tree model;
%     Tree.RightChild: right child tree which is also a half space tree model;
%     Tree.Size: node size, i.e., mass;
%     Tree.Depth: node depth;
% 

Tree.Depth = CurtDepth;

if CurtDepth >= Paras.DepthLimit || length(CurtIndex) <= Paras.SizeLimit
    
    Tree.NodeStatus = 0;
    Tree.SplitAttribute = [];
    Tree.SplitPoint = [];
    Tree.LeftChild = [];
    Tree.RightChild = [];
    Tree.Size = length(CurtIndex);
    return;
    
else

    Tree.NodeStatus = 1;
    % randomly select a split attribute
    [temp, rindex] = max(rand(1, Paras.NumDim));
    Tree.SplitAttribute = Paras.IndexDim(rindex);
    Tree.SplitPoint = (MaxAtt(Tree.SplitAttribute) + MinAtt(Tree.SplitAttribute)) / 2;
    
    % instance index for left child and right children
    LeftCurtIndex = CurtIndex(Data(CurtIndex, Tree.SplitAttribute) < Tree.SplitPoint);
    RightCurtIndex = setdiff(CurtIndex, LeftCurtIndex);
    
    % bulit left child tree
    temp = MaxAtt(Tree.SplitAttribute);
    MaxAtt(Tree.SplitAttribute) = Tree.SplitPoint;
    Tree.LeftChild = HSTree(Data, LeftCurtIndex, MaxAtt, MinAtt, CurtDepth + 1, Paras);
    
    % bulit right child tree
    MaxAtt(Tree.SplitAttribute) = temp;
    MinAtt(Tree.SplitAttribute) = Tree.SplitPoint;
    Tree.RightChild = HSTree(Data, RightCurtIndex, MaxAtt, MinAtt, CurtDepth + 1, Paras);
    
    Tree.Size = [];
    
end
