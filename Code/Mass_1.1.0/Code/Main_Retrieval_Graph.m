function Main_Retrieval_Graph(filepath, Paras)
% calculate L1-norm graph matrix for MRBIR (original space)

% % % % % % % % % % % % % % % % % % % % % % % %
% parameters setting
% % % % % % % % % % % % % % % % % % % % % % % %
datapath = strcat(filepath, 'Data/Retrieval/');
localpath = strcat(filepath, 'Local/Retrieval/');
resultpath = strcat(filepath, 'Results/Retrieval/');

dataname = Paras.dataname;
load(strcat(datapath, dataname, '.mat'));

knn = 200;
omega = 0.05;
NumInst = size(Data, 1);
Weights = zeros(NumInst, NumInst);
Time_Graph = zeros(NumInst, 1);

% Weights calculation & time cost
for i = 1:NumInst
    disp(['step ', num2str(i), '...']);
    t = cputime;
    curt_dist = sum(abs(Data - repmat(Data(i, :), NumInst, 1)), 2);
    [temp, dist_index] = sort(curt_dist);
    dist_index(dist_index == i) = [];
    knn_index = dist_index(1:knn);
    curt_kernel = exp(-curt_dist(knn_index) / omega);
    Time_Graph(i, 1) = cputime - t;
    
    Weights(knn_index, i) = curt_kernel;
    Weights(i, knn_index) = curt_kernel';
end
clear Data;
Time_avgGraph = mean(Time_Graph);

SumWeights = sum(Weights, 1);
Weights = sparse(Weights);
NormDiags = sparse(1:NumInst, 1:NumInst, 1./ sqrt(SumWeights));
NormWeights = NormDiags * Weights * NormDiags;
clear Weights;
clear NormDiags;

% Save
savename = strcat(localpath, 'graph_l1_', dataname, '.mat');
save(savename, 'NormWeights', 'Time_Graph', 'Time_avgGraph', 'Paras');
