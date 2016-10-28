function Main_Anomaly_IFMass(filepath, dataname_all, Paras)
% Isolation Forest method

% F. T. Liu, K. M. Ting, and Z.-H. Zhou.
% Isolation forest.
% In Proceedings of ICDM, pages 413-422, 2008.

datapath = strcat(filepath, 'Data/Anomaly/');
resultpath = strcat(filepath, 'Results/Anomaly/');

NumData = size(dataname_all, 2);
myresults_all = zeros(NumData, 4);

NumTree = Paras.NumTree;
NumSub = Paras.NumSub;
NumDim = Paras.NumDim;
rounds = Paras.rounds;
methodname = Paras.methodname;

for data_index = 1:NumData
    
    dataname = dataname_all{data_index};
    load(strcat(datapath, dataname, '.mat'));
    disp([dataname, ': NumTree = ', num2str(NumTree), ', NumSub = ', num2str(NumSub), ', NumDim = ', num2str(NumDim)]);
    
    if NumDim == 0
        CurtNumDim = size(Data, 2);
    end
    
    auc = zeros(rounds, 1);
    mtime = zeros(rounds, 2);
    rseed = zeros(rounds, 1);
    
    for r = 1:rounds
        disp(['rounds ', num2str(r), ':']);
        
        rseed(r) = sum(100 * clock);
        Forest = IsolationForest(Data, NumTree, NumSub, CurtNumDim, rseed(r));
        mtime(r, 1) = Forest.ElapseTime;
        [Mass, mtime(r, 2)] = IsolationEstimation(Data, Forest);
        Score = - mean(Mass, 2);
        clear Forest;
        clear Mass;
        
        auc(r) = Measure_AUC(Score, ADLabels);
        disp(['auc = ', num2str(auc(r)), '.']);
        
    end
    
    myresults = [mean(auc), var(auc), mean(mtime(:, 1)), mean(mtime(:, 2))];
    myresults_all(data_index, :) = myresults;
    
    savename = strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
        num2str(NumTree), '_', num2str(NumSub), '_', num2str(NumDim), '.mat');
    save(savename, 'auc', 'mtime', 'myresults', 'rseed', 'Paras');
    
end
