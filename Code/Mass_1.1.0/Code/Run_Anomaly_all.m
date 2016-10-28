% % the anomaly detection results

addpath ../Library/libsvm/
addpath ../Library/libs/
set(0, 'RecursionLimit', 5000);

clear;
filepath = '../';
t = 0;
% dataname_all{t + 1} = 'http'; t = t + 1; % Http data set
dataname_all{t + 1} = 'cover'; t = t + 1; % ForestCover data set
% dataname_all{t + 1} = 'mulcross'; t = t + 1;  % Mulcross data set
% dataname_all{t + 1} = 'smtp'; t = t + 1; % Smtp data set
% dataname_all{t + 1} = 'shuttle'; t = t + 1; % Shuttle data set


% % % % % % % % % % % % % % % % % % % % %
% Anomaly Detection: step 1
% perform anomaly detection algorithm
% % % % % % % % % % % % % % % % % % % % %

% general parameters
Paras.rounds = 10; % rounds of repeat

% parameters for mass
Paras.NumT = 100; % number of mass estimations
Paras.NumSub = 256; % subsample size
Paras.HLevel = 1; % level - 1
Paras.methodname = 'RandMass'; % MassAD
Main_Anomaly_RandMass(filepath, dataname_all, Paras);

% parameters for iForest
Paras.NumTree = 100; % number of isolation trees
Paras.NumSub = 256; % subsample size
Paras.NumDim = 0; % do not perform dimension sampling
Paras.methodname = 'IFMass'; % iForest
Main_Anomaly_IFMass(filepath, dataname_all, Paras);

% parameters for HSMass
Paras.NumTree = 100; % number of mass estimations
Paras.NumSub = 256; % subsample size
Paras.NumDim = 0; % use full dimension
Paras.SizeLimit = log2(Paras.NumSub) - 1; % leaf size limit
Paras.DepthLimit = Paras.NumSub; % tree depth limit
Paras.methodname = 'HSMass';
Main_Anomaly_HSMass(filepath, dataname_all, Paras);


% % % % % % % % % % % % % % % % % % % % %
% Anomaly Detection: step 2
% evaluate the results
% % % % % % % % % % % % % % % % % % % % %

datapath = strcat(filepath, 'Data/Anomaly/');
localpath = strcat(filepath, 'Local/Anomaly/');
resultpath = strcat(filepath, 'Results/Anomaly/');

methodname_all{1} = 'RandMass';
% % enable the following for HSMass
% methodname_all{1} = 'HSMass';
methodname_all{2} = 'IFMass';

NumData = length(dataname_all);
NumMethod = length(methodname_all);

result_auc = zeros(NumData, 2 * NumMethod); % mean and std of auc over 10 rounds
result_mtime = zeros(NumData, NumMethod); % average processing time over 10 rounds
result_trtime = zeros(NumData, NumMethod); % average traning time over 10 rounds
result_tstime = zeros(NumData, NumMethod); % average testing time over 10 rounds

h_auc = zeros(NumData, 1); % paired t-test indicators on auc results
% 1: Mass outperforms iForest; -1: iForest outperforms Mass; 0: no significant different
p_auc = zeros(NumData, 1); % probability of t-test results

wdl_auc = zeros(NumData, 3); % win/draw/loss counts on auc results

for data_index = 1:NumData

    dataname = dataname_all{data_index};
    load(strcat(datapath, dataname, '.mat'));

    i = 1;
    methodname = methodname_all{i};
    NumT = 100;
    NumSub = 256;
    HLevel = 1;
    load(strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
        num2str(NumT), '_', num2str(NumSub), '_', num2str(HLevel), '.mat'));
    % % enable the following for HSMass
    % NumTree = 100;
    % NumSub = 256;
    % NumDim = 0;
    % load(strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
    %     num2str(NumTree), '_', num2str(NumSub), '_', num2str(NumDim), '.mat'));
    result_auc(data_index, 1) = mean(auc);
    result_auc(data_index, 3) = std(auc);
    result_mtime(data_index, 1) = mean(mtime(:, 1) + mtime(:, 2));
    result_trtime(data_index, 1) = mean(mtime(:, 1));
    result_tstime(data_index, 1) = mean(mtime(:, 2));

    auc_mass = auc;

    i = 2;
    methodname = methodname_all{i};
    NumTree = 100;
    NumSub = 256;
    NumDim = 0;
    load(strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
        num2str(NumTree), '_', num2str(NumSub), '_', num2str(NumDim), '.mat'));
    result_auc(data_index, 2) = mean(auc);
    result_auc(data_index, 4) = std(auc);
    result_mtime(data_index, 2) = mean(mtime(:, 1) + mtime(:, 2));
    result_trtime(data_index, 2) = mean(mtime(:, 1));
    result_tstime(data_index, 2) = mean(mtime(:, 2));

    auc_if = auc;

    % ttest
    [h_auc(data_index), p_auc(data_index)] = ttest(auc_mass, auc_if);
    if mean(auc_mass) < mean(auc_if)
        h_auc(data_index) = - h_auc(data_index);
    end

    % win/draw/loss counts
    wdl_auc(data_index, :) = [length(find(auc_mass < auc_if)), ...
        length(find(auc_mass == auc_if)), length(find(auc_mass > auc_if))];

end

savename = strcat(resultpath, 'Results_Anomaly.mat');
save(savename, 'result_auc', 'result_mtime', 'result_trtime', 'result_tstime', ...
    'h_auc', 'p_auc', 'wdl_auc', 'dataname_all', 'methodname_all');
