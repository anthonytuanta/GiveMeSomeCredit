% the regression results

addpath ../Library/libsvm/
addpath ../Library/libs/
set(0, 'RecursionLimit', 5000);

filepath = '../';
t = 0;
dataname_all{t + 1} = 'coil'; t= t + 1; % tic data set
dataname_all{t + 1} = 'wine_white'; t= t + 1; % wine_white data set
dataname_all{t + 1} = 'quake'; t= t + 1; % earth quake data set
dataname_all{t + 1} = 'wine_red'; t= t + 1; % wine_red data set
dataname_all{t + 1} = 'compressive'; t= t + 1;  % concrete data set

% general parameters
Paras.rounds = 20; % rounds of repeat
Paras.folds = 5; % cross validation
Paras.mykernel = 1; % do not calculate kernel in libsvm

% parameters for svm
Paras.toler = 0.01;
Paras.msize = 500;
Paras.glist = power(2, -15:2:5); % gamma list
Paras.clist = [0.1 1 10]; % C list
Paras.elist = [0.01 0.05 0.1]; % epsilon list

% parameters for mass
Paras.NumT = 1000; % number of mass estimations
Paras.NumSub = 8; % subsample size
Paras.HLevel = 1; % level - 1

% parameters for hsmass
Paras.NumTree = 1000; % number of mass estimations
Paras.NumSub = 8; % subsample size
Paras.NumDim = 0; % use full dimension
Paras.SizeLimit = log2(Paras.NumSub) - 1; % leaf size limit
Paras.DepthLimit = Paras.NumSub; % tree depth limit


% % % % % % % % % % % % % % % % % % % % 
% Regression: step 1
% Randomly select training indices and testing indices
% % % % % % % % % % % % % % % % % % % % 

Paras.rounds = 20; % rounds of repeat
Paras.trperc = 2/3; % randomly sample two-thirds of the instances for training and the remaining one-third for testing
Regression_randidx(filepath, dataname_all, Paras);


% % % % % % % % % % % % % % % % % % % % % 
% Regression: step 2
% perform regression algorithm
% % % % % % % % % % % % % % % % % % % % % 

Paras.methodname = 'HSMepSVR'; % SVR''
Main_Regression_HSMassSVR(filepath, dataname_all, Paras);
Paras.methodname = 'RMepSVR'; % SVR'
Main_Regression_RandMassSVR(filepath, dataname_all, Paras);
Paras.methodname = 'epSVR'; % SVR
Main_Regression_SVR(filepath, dataname_all, Paras);


% % % % % % % % % % % % % % % % % % % % % 
% Regression: step 3
% evaluate the results
% % % % % % % % % % % % % % % % % % % % % 

datapath = strcat(filepath, 'Data/Regression/');
localpath = strcat(filepath, 'Local/Regression/');
resultpath = strcat(filepath, 'Results/Regression/');

methodname_all{1} = 'RMepSVR';
% % enable the following for HSMass
% methodname_all{1} = 'HSMepSVR';
methodname_all{2} = 'epSVR';

NumData = length(dataname_all);
NumMethod = length(methodname_all);

result_mse = zeros(NumData, 2 * NumMethod); % mean and std of mse over 20 rounds
result_scc = zeros(NumData, 2 * NumMethod); % mean and std of scc over 20 rounds
result_time = zeros(NumData, NumMethod); % average processing time over 20 rounds

h_mse = zeros(NumData, 1); % paired t-test indicators on mse results
% 1: SVR' (or SVR'') outperforms SVR; -1: SVR outperforms SVR' (or SVR''); 0: no significant different
p_mse = zeros(NumData, 1); % probability of t-test results
h_scc = zeros(NumData, 1); % paired t-test indicators on scc results
% 1: SVR' (or SVR'') outperforms SVR; -1: SVR outperforms SVR' (or SVR''); 0: no significant different
p_scc = zeros(NumData, 1); % probability of t-test results

wdl_mse = zeros(NumData, 3); % win/draw/loss counts on mse results
wdl_scc = zeros(NumData, 3); % win/draw/loss counts on scc results

increase_dim = zeros(NumData, 1); % increase factors of data dimension
increase_time = zeros(NumData, 1); % increase factors of processing time

for data_index = 1:NumData
    
    dataname = dataname_all{data_index};
    load(strcat(datapath, dataname, '.mat'));
    
    i = 1;
    methodname = methodname_all{i};
    NumT = 1000;
    NumSub = 8;
    HLevel = 1;
    load(strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
        num2str(NumT), '_', num2str(NumSub), '_', num2str(HLevel), '.mat'));
    % % enable the following for HSMass
    % NumTree = 1000;
    % NumSub = 8;
    % NumDim = 0;
    % load(strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
    %     num2str(NumT), '_', num2str(NumSub), '_', num2str(NumDim), '.mat'));
    result_mse(data_index, 1) = mean(mse);
    result_mse(data_index, 3) = std(mse);
    result_scc(data_index, 1) = mean(scc);
    result_scc(data_index, 3) = std(scc);
    result_time(data_index, 1) = mean(mtime(:, 1) + mtime(:, 2)) + mean(trtime + tstime);
    
    mse_mass = mse;
    scc_mass = scc;
    
    i = 2;
    methodname = methodname_all{i};
    load(strcat(resultpath, 'Results_', methodname, '_', dataname, '.mat'));
    result_mse(data_index, 2) = mean(mse);
    result_mse(data_index, 4) = std(mse);
    result_scc(data_index, 2) = mean(scc);
    result_scc(data_index, 4) = std(scc);
    result_time(data_index, 2) = mean(trtime + tstime);
    
    mse_svr = mse;
    scc_svr = scc;
    
    % ttest
    [h_mse(data_index), p_mse(data_index)] = ttest(mse_mass, mse_svr);
    if mean(mse_mass) > mean(mse_svr)
        h_mse(data_index) = - h_mse(data_index);
    end
    [h_scc(data_index), p_scc(data_index)] = ttest(scc_mass, scc_svr);
    if mean(scc_mass) < mean(scc_svr)
        h_scc(data_index) = - h_scc(data_index);
    end
    
    % win/draw/loss counts
    wdl_mse(data_index, :) = [length(find(mse_mass < mse_svr)), ...
        length(find(mse_mass == mse_svr)), length(find(mse_mass > mse_svr))];
    
    wdl_scc(data_index, :) = [length(find(scc_mass > scc_svr)), ...
        length(find(scc_mass == scc_svr)), length(find(scc_mass < scc_svr))];
    
    % increase factors
    increase_dim(data_index) = NumT / size(Data, 2);
    increase_time(data_index) = result_time(data_index, 1) / result_time(data_index, 2);
    
end

savename = strcat(resultpath, 'Results_Regression.mat');
save(savename, 'result_mse', 'result_scc', 'result_time', 'h_mse', 'p_mse', ...
    'h_scc', 'p_scc', 'wdl_mse', 'wdl_scc', 'increase_dim', 'increase_time', 'dataname_all', 'methodname_all');
