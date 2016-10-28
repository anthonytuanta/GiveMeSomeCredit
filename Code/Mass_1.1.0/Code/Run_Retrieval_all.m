% the retrieval results

addpath ../Library/libsvm/
addpath ../Library/libs/
set(0, 'RecursionLimit', 5000);

filepath = '../';

% parameters for retrieval
Paras.dataname = 'corel100'; % COREL data set
Paras.query_num = 5; % number of query per class
Paras.fb_round = 5; % number of feedback rounds for each query
Paras.fb_process = 5; % repeat time of the feedback process
Paras.F_num =2; % number of positive/negative feedbacks provided in each round

% parameters for performance measures
Paras.TopPrecision_S = 20; % top-20 precision
Paras.effectiveness_S = 200; % parameter for measuring effectiveness
Paras.NumPR = 10; % parameter for measure PR-curve

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

% parameters for MRBIR
Paras.alpha = 0.99; % alpha used in MRBIR
Paras.iter = 50; % iterations used in MRBIR
Paras.gamma = 0.25; % parameter gamma used in MRBIR


% % % % % % % % % % % % % % % % % % % % %
% Retrieval: step 1
% randomly select query indices and feedback indices
% % % % % % % % % % % % % % % % % % % % %

Retrieval_randidx(filepath, Paras);


% % % % % % % % % % % % % % % % % % % % %
% Retrieval: step 2
% construct distance matrix and graph matrix
% % % % % % % % % % % % % % % % % % % % %

% distance matrix in original space
Main_Retrieval_Dist(filepath, Paras);
% graph matrix in original space
Main_Retrieval_Graph(filepath, Paras);
% distance matrix in mass space
Main_Retrieval_MassDist(filepath, Paras);
% graph matrix in mass space
Main_Retrieval_MassGraph(filepath, Paras);
% distance matrix in hsmass space
Main_Retrieval_HSMassDist(filepath, Paras);
% graph matrix in hsmass space
Main_Retrieval_HSMassGraph(filepath, Paras);


% % % % % % % % % % % % % % % % % % % % %
% Retrieval: step 3
% perform retrieval algorithm
% % % % % % % % % % % % % % % % % % % % %

Paras.methodname = 'HSMassMRBIR'; % MRBIR''
Main_Retrieval_HSMassMRBIR(filepath, Paras);
Paras.methodname = 'MassMRBIR'; % MRBIR'
Main_Retrieval_MassMRBIR(filepath, Paras);
Paras.methodname = 'MRBIR'; % MRBIR
Main_Retrieval_MRBIR(filepath, Paras);

Paras.methodname = 'HSMassQsim'; % Qsim''
Main_Retrieval_MassQsim(filepath, Paras);
Paras.methodname = 'MassQsim'; % Qsim'
Main_Retrieval_MassQsim(filepath, Paras);
Paras.methodname = 'Qsim'; % Qsim
Main_Retrieval_Qsim(filepath, Paras);

Paras.methodname = 'HSMassIR'; % InstR';
Main_Retrieval_MassIR(filepath, Paras);
Paras.methodname = 'MassIR'; % InstR'
Main_Retrieval_MassIR(filepath, Paras);
Paras.methodname = 'InstRank'; % InstR
Main_Retrieval_InstRank(filepath, Paras);


% % % % % % % % % % % % % % % % % % % % %
% Retrieval: step 4
% evaluate the results
% % % % % % % % % % % % % % % % % % % % %

datapath = strcat(filepath, 'Data/Retrieval/');
localpath = strcat(filepath, 'Local/Retrieval/');
resultpath = strcat(filepath, 'Results/Retrieval/');

dataname = 'corel100'; % COREL data set

methodname_all{1} = 'MassMRBIR';
methodname_all{2} = 'MRBIR';
methodname_all{3} = 'MassQsim';
% % enable the following for HSMass
% methodname_all{1} = 'HSMassMRBIR';
% methodname_all{2} = 'HSMRBIR';
% methodname_all{3} = 'HSMassQsim';
methodname_all{4} = 'Qsim';
methodname_all{5} = 'MassIR';
methodname_all{6} = 'InstRank';

NumMethod = length(methodname_all);

fb_round = 5;
NumPR = 10;

BEP = zeros(NumMethod, fb_round + 1); % BEP values
avePrecision = zeros(NumMethod, fb_round + 1); % mean average precision
effectiveness = zeros(NumMethod, fb_round + 1); % effectiveness
time = zeros(NumMethod, fb_round + 1); % pure retrieval time
TopPrecision = zeros(NumMethod, fb_round + 1); % top-20 precision
time_all = zeros(NumMethod, fb_round + 1); % pure retrieval time + distance/graph calculation time

Precisions = zeros(NumMethod, NumPR + 1); % precision values for PR-curve
Recalls = zeros(NumMethod, NumPR + 1); % recall values for PR-curve

for method_Index = 1:NumMethod
    
    methodname = methodname_all{method_Index};
    loadname = strcat(resultpath, 'Results_', methodname, '_', dataname, '.mat');
    load(loadname);
    
    BEP(method_Index, :) = ave_feedback_BEP;
    effectiveness(method_Index, :) = ave_feedback_effectiveness;
    avePrecision(method_Index, :) = ave_feedback_avePrecision;
    time(method_Index, :) = ave_feedback_time;
    TopPrecision(method_Index, :) = ave_feedback_TopPrecision;
    time_all(method_Index, :) = ave_feedback_time_all;
    
    Precisions(method_Index, :) = ave_Precisions;
    Recalls(method_Index, :) = ave_Recalls;
    
end

% t-test
% ttest_MRBIR{1}: ttest results for retrieval with one query
% ttest_MRBIR{2} ~ ttest_MRBIR{end}: ttest results for retrieval in relevance feedback round 1 ~ 'fb_round'
% h_***: paired t-test indicator
% p_***: probability of t-test results
% WDL_***: win/draw/loss counts

methodname1 = methodname_all{1};
methodname2 = methodname_all{2};
ttest_MRBIR = cell(fb_round + 1, 1);
ttest_MRBIR{1} = Main_Retrieval_ttest_query(filepath, dataname, methodname1, methodname2);
for round = 1:fb_round
    ttest_MRBIR{round + 1} = Main_Retrieval_ttest(filepath, dataname, methodname1, methodname2, round);
end

methodname1 = methodname_all{3};
methodname2 = methodname_all{4};
ttest_Qsim = cell(fb_round + 1, 1);
ttest_Qsim{1} = Main_Retrieval_ttest_query(filepath, dataname, methodname1, methodname2);
for round = 1:fb_round
    ttest_Qsim{round + 1} = Main_Retrieval_ttest(filepath, dataname, methodname1, methodname2, round);
end

methodname1 = methodname_all{5};
methodname2 = methodname_all{6};
ttest_InstRank = cell(fb_round + 1, 1);
ttest_InstRank{1} = Main_Retrieval_ttest_query(filepath, dataname, methodname1, methodname2);
for round = 1:fb_round
    ttest_InstRank{round + 1} = Main_Retrieval_ttest(filepath, dataname, methodname1, methodname2, round);
end

savename = strcat(resultpath, 'Results_Retrieval.mat');
save(savename, 'BEP', 'avePrecision', 'effectiveness', 'time', ...
    'TopPrecision', 'time_all', 'Precisions', 'Recalls', 'ttest_MRBIR', ...
    'ttest_Qsim', 'ttest_InstRank', 'dataname', 'methodname_all');
