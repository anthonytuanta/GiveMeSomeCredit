function Main_Anomaly_RandMass(filepath, dataname_all, Paras)
% MassAD method

datapath = strcat(filepath, 'Data/Anomaly/');
resultpath = strcat(filepath, 'Results/Anomaly/');

NumData = size(dataname_all, 2);
myresults_all = zeros(NumData, 4);

NumT = Paras.NumT;
NumSub = Paras.NumSub;
HLevel = Paras.HLevel;
rounds = Paras.rounds;
methodname = Paras.methodname;

for data_index = 1:NumData
    
    dataname = dataname_all{data_index};
    load(strcat(datapath, dataname, '.mat'));
    disp([dataname, ': NumT = ', num2str(NumT), ', NumSub = ', num2str(NumSub), ', HLevel = ', num2str(HLevel)]);
    
    auc = zeros(rounds, 1);
    mtime = zeros(rounds, 2);
    rseed = zeros(rounds, 1);
    
    for r = 1:rounds
        disp(['rounds ', num2str(r), ':']);
        
        rseed(r) = sum(100 * clock);
        MassModel = MassTrain(Data, NumT, NumSub, HLevel, rseed(r));
        mtime(r, 1) = MassModel.ElapseTime;
        [Mass, mtime(r, 2)] = MassPredict(Data, MassModel);
        Score = - mean(Mass, 2);
        clear MassModel;
        clear Mass;
        
        auc(r) = Measure_AUC(Score, ADLabels);
        disp(['auc = ', num2str(auc(r)), '.']);
        
    end
    
    myresults = [mean(auc), var(auc), mean(mtime(:, 1)), mean(mtime(:, 2))];
    myresults_all(data_index, :) = myresults;
    
    savename = strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
        num2str(NumT), '_', num2str(NumSub), '_', num2str(HLevel), '.mat');
    save(savename, 'auc', 'mtime', 'myresults', 'rseed', 'Paras');
    
end
