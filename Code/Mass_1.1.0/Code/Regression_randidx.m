function Regression_randidx(filepath, dataname_all, Paras)
% randomly generate indices for training and testing

datapath = strcat(filepath, 'Data/Regression/');
localpath = strcat(filepath, 'Local/Regression/');

NumData = length(dataname_all);
rounds = Paras.rounds;
trperc = Paras.trperc;

for data_index = 1:NumData
    
    dataname = dataname_all{data_index};
    load(strcat(datapath, dataname, '.mat'));
    [NumInst, DimInst] = size(Data);
    NumTrInst = ceil(NumInst * trperc);
    
    randidx_tr = zeros(NumTrInst, rounds);
    randidx_ts = zeros((NumInst - NumTrInst), rounds);
    for r = 1:rounds
        temp = randperm(NumInst);
        randidx_tr(:, r) = temp(1:NumTrInst);
        randidx_ts(:, r) = temp((NumTrInst + 1):end);
    end
    savename = strcat(localpath, 'randidx_', dataname, '.mat');
    save(savename, 'randidx_tr', 'randidx_ts');
    
end
