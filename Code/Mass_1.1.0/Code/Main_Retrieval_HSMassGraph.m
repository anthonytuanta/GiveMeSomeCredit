function Main_Retrieval_HSMassGraph(filepath, Paras)
% calculate L1-norm graph matrix for MRBIR (mass space)

% % % % % % % % % % % % % % % % % % % % % % % %
% parameters setting
% % % % % % % % % % % % % % % % % % % % % % % %
datapath = strcat(filepath, 'Data/Retrieval/');
localpath = strcat(filepath, 'Local/Retrieval/');
resultpath = strcat(filepath, 'Results/Retrieval/');

dataname = Paras.dataname;
load(strcat(datapath, dataname, '.mat'));
NumTree = Paras.NumTree;
NumSub = Paras.NumSub;
NumDim = Paras.NumDim;

loadname = strcat(localpath, 'hsmassdist_', dataname, '_', num2str(NumTree), '_', num2str(NumSub), '_', num2str(NumDim), '.mat');
load(loadname, 'Paras');
rseed = Paras.rseed;
SizeLimit = Paras.SizeLimit;
DepthLimit = Paras.DepthLimit;
Forest = HSForest(Data, NumTree, NumSub, NumDim, SizeLimit, DepthLimit, rseed);
mtime(1, 1) = Forest.ElapseTime;
[Mass, mtime(1, 2)] = HSEstimation(Data, Forest);
clear Forest;

knn = 200;
omega = 25;
NumInst = size(Mass, 1);
Weights = zeros(NumInst, NumInst);
Time_Graph = zeros(NumInst, 1);

% Weights calculation & time cost
for i = 1:NumInst
    disp(['step ', num2str(i), '...']);
    t = cputime;
    curt_dist = sum(abs(Mass - repmat(Mass(i, :), NumInst, 1)), 2);
    [temp, dist_index] = sort(curt_dist);
    dist_index(dist_index == i) = [];
    knn_index = dist_index(1:knn);
    curt_kernel = exp(-curt_dist(knn_index) / omega);
    Time_Graph(i, 1) = cputime - t;
    
    Weights(knn_index, i) = curt_kernel;
    Weights(i, knn_index) = curt_kernel';
end
clear Mass;
Time_avgGraph = mean(Time_Graph);

SumWeights = sum(Weights, 1);
Weights = sparse(Weights);
NormDiags = sparse(1:NumInst, 1:NumInst, 1./ sqrt(SumWeights));
NormWeights = NormDiags * Weights * NormDiags;
clear Weights;
clear NormDiags;

% Save
Paras.rseed = rseed;
Paras.mtime = mtime;
savename = strcat(localpath, 'hsmassgraph_l1_', dataname, '_', num2str(NumTree), '_', num2str(NumSub), '_', num2str(NumDim), '.mat');
save(savename, 'NormWeights', 'Time_Graph', 'Time_avgGraph', 'Paras');
