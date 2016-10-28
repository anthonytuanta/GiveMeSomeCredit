function mass = HSMass(Data, CurtIndex, Tree, mass)
% 
% function HSMass: estimate the mass and depth of test instances on a half space tree
% 
% Input:
%     Data: n x d matrix; n: # of instance; d: dimension;
%     CurtIndex: index of current data instance;
%     Tree: a half space tree;
%     mass: n x 1 vector; previously estimated mass;
% 
% Output:
%     mass: currently estimated mass;
%     depth: currently estimated depth;
% 

if Tree.NodeStatus == 0
    
    if Tree.Size < 2
        mass(CurtIndex) = Tree.Depth;
    else
        mass(CurtIndex) = Tree.Depth + log2(Tree.Size);
    end
    return;
    
else
    
    LeftCurtIndex = CurtIndex(Data(CurtIndex, Tree.SplitAttribute) < Tree.SplitPoint);
    RightCurtIndex = setdiff(CurtIndex, LeftCurtIndex);
    
    if ~isempty(LeftCurtIndex)
        mass = HSMass(Data, LeftCurtIndex, Tree.LeftChild, mass);
    end
    if ~isempty(RightCurtIndex)
        mass = HSMass(Data, RightCurtIndex, Tree.RightChild, mass);
    end
    
end
