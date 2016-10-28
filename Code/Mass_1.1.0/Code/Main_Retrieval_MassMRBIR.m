function Main_Retrieval_MassMRBIR(filepath, Paras)
% MassMRBIR method

% % % % % % % % % % % % % % % % % % % % % % % %
% parameters setting
% % % % % % % % % % % % % % % % % % % % % % % %
datapath = strcat(filepath, 'Data/Retrieval/');
localpath = strcat(filepath, 'Local/Retrieval/');
resultpath = strcat(filepath, 'Results/Retrieval/');

methodname = Paras.methodname;
dataname = Paras.dataname;

if ~strcmpi(methodname, 'MassMRBIR')
    error('wrong method name!');
end

NumT = Paras.NumT;
NumSub = Paras.NumSub;
HLevel = Paras.HLevel;

TopPrecision_S = Paras.TopPrecision_S;
effectiveness_S = Paras.effectiveness_S;
NumPR = Paras.NumPR;

query_num = Paras.query_num;
fb_process = Paras.fb_process;
fb_round = Paras.fb_round;
F_num = Paras.F_num;

alpha = Paras.alpha;
iter = Paras.iter;
gamma = Paras.gamma;

% % % % % % % % % % % % % % % % % % % % % % % %
% begin main loop
% % % % % % % % % % % % % % % % % % % % % % % %

load(strcat(datapath, dataname, '.mat'));
load(strcat(localpath, 'pnidx_', dataname, '.mat'));
load(strcat(localpath, 'massgraph_l1_', dataname, '_', num2str(NumT), '_', num2str(NumSub), '_', num2str(HLevel), '.mat'));

[ins_num, class_num] = size(Labels);

Result_BEP = cell(class_num, query_num);
Result_effectiveness = cell(class_num, query_num);
Result_avePrecision = cell(class_num, query_num);
Result_TopPrecision = cell(class_num, query_num);
Result_Time = cell(class_num, query_num);

Result_Precisions = cell(class_num, query_num);
Result_Recalls = cell(class_num, query_num);

for class_index = 1:class_num
    for query_index = 1:query_num
        
        [class_index, query_index]
        p_index = Positive_Index{class_index, query_index};
        n_index = Negative_Index{class_index, query_index};
        query = p_index{1};
        
        BEP = cell(fb_process, fb_round + 1);
        effectiveness = cell(fb_process, fb_round + 1);
        avePrecision = cell(fb_process, fb_round + 1);
        TopPrecision = cell(fb_process, fb_round + 1);
        Time = cell(fb_process, fb_round + 1);
        Curt_Label = Labels(:, class_index);
        
        % Only a Query
        [Query_Score, Query_Time] = CBIR_Query_MRBIR(query, NormWeights, alpha, iter);
        temp_Query_Score = Query_Score;
        temp_Query_Score(query) = [];
        temp_Curt_Label = Curt_Label;
        temp_Curt_Label(query) = [];
        
        Query_BEP = Measure_BEP(temp_Curt_Label, temp_Query_Score);
        Query_effectiveness = Measure_effectiveness(temp_Curt_Label, temp_Query_Score, effectiveness_S);
        Query_avePrecision = Measure_avePrecision(temp_Curt_Label, temp_Query_Score);
        Query_TopPrecision = Measure_TopPrecision(temp_Curt_Label, temp_Query_Score, TopPrecision_S);
        
        for fbp_index = 1:fb_process
            BEP{fbp_index, 1} = Query_BEP;
            effectiveness{fbp_index, 1} = Query_effectiveness;
            avePrecision{fbp_index, 1} = Query_avePrecision;
            TopPrecision{fbp_index, 1} = Query_TopPrecision;
            Time{fbp_index, 1} = Query_Time;
        end
        
        [Result_Precisions{class_index, query_index}, Result_Recalls{class_index, query_index}] = ...
            Measure_PRGraph(temp_Curt_Label, temp_Query_Score, NumPR);
        
        % Relevance Feedback
        for fbp_index = 1:fb_process
            
            p_index_add = p_index{fbp_index + 1};
            n_index_add = n_index{fbp_index + 1};
            
            for fbr_index = 2:fb_round + 1
                
                Relevant_Index = [query, p_index_add(1:(fbr_index - 1) * F_num)];
                Irrelevant_Index = n_index_add(1:(fbr_index - 1) * F_num);
                    [Curt_Score, Time{fbp_index, fbr_index}] = CBIR_MRBIR(Relevant_Index, Irrelevant_Index, NormWeights, alpha, iter, gamma);
                %                     Curt_Score = Curt_Score + 1e-10 * rand(size(Curt_Score, 1), size(Curt_Score, 2));
                temp_Curt_Score = Curt_Score;
                temp_Curt_Score([Relevant_Index, Irrelevant_Index]) = [];
                temp_Curt_Label = Curt_Label;
                temp_Curt_Label([Relevant_Index, Irrelevant_Index]) = [];
                
                BEP{fbp_index, fbr_index} = Measure_BEP(temp_Curt_Label, temp_Curt_Score);
                effectiveness{fbp_index, fbr_index} = Measure_effectiveness(temp_Curt_Label, temp_Curt_Score, effectiveness_S);
                avePrecision{fbp_index, fbr_index} = Measure_avePrecision(temp_Curt_Label, temp_Curt_Score);
                TopPrecision{fbp_index, fbr_index} = Measure_TopPrecision(temp_Curt_Label, temp_Curt_Score, TopPrecision_S);
                
            end
        end
        
        Result_BEP{class_index, query_index} = BEP;
        Result_effectiveness{class_index, query_index} = effectiveness;
        Result_avePrecision{class_index, query_index} = avePrecision;
        Result_Time{class_index, query_index} = Time;
        Result_TopPrecision{class_index, query_index} = TopPrecision;
        
    end
end

% Evaluation BEP, EFF, AP, TP and Time
temp_BEP_class = zeros(class_num, fb_round + 1);
temp_effectiveness_class = zeros(class_num, fb_round + 1);
temp_avePrecision_class = zeros(class_num, fb_round + 1);
temp_time_class = zeros(class_num, fb_round + 1);
temp_TopPrecision_class = zeros(class_num, fb_round + 1);

for class_index = 1:class_num
    
    temp_BEP_query = zeros(query_num, fb_round + 1);
    temp_effectiveness_query = zeros(query_num, fb_round + 1);
    temp_avePrecision_query = zeros(query_num, fb_round + 1);
    temp_time_query = zeros(query_num, fb_round + 1);
    temp_TopPrecision_query = zeros(query_num, fb_round + 1);
    
    for query_index = 1:query_num
        
        temp_result_BEP = Result_BEP{class_index, query_index};
        temp_result_effectiveness = Result_effectiveness{class_index, query_index};
        temp_result_avePrecision = Result_avePrecision{class_index, query_index};
        temp_result_time = Result_Time{class_index, query_index};
        temp_result_TopPrecision = Result_TopPrecision{class_index, query_index};
        
        temp_BEP = zeros(fb_process, fb_round + 1);
        temp_effectiveness = zeros(fb_process, fb_round + 1);
        temp_avePrecision = zeros(fb_process, fb_round + 1);
        temp_time = zeros(fb_process, fb_round + 1);
        temp_TopPrecision = zeros(fb_process, fb_round + 1);
        
        for fbp_index = 1:fb_process
            for fbr_index = 1:fb_round + 1
                
                temp_BEP(fbp_index, fbr_index) = temp_result_BEP{fbp_index, fbr_index};
                temp_effectiveness(fbp_index, fbr_index) = temp_result_effectiveness{fbp_index, fbr_index};
                temp_avePrecision(fbp_index, fbr_index) = temp_result_avePrecision{fbp_index, fbr_index};
                temp_time(fbp_index, fbr_index) = temp_result_time{fbp_index, fbr_index};
                temp_TopPrecision(fbp_index, fbr_index) = temp_result_TopPrecision{fbp_index, fbr_index};
                
            end
        end
        
        temp_BEP_query(query_index, :) = mean(temp_BEP, 1);
        temp_effectiveness_query(query_index, :) = mean(temp_effectiveness, 1);
        temp_avePrecision_query(query_index, :) = mean(temp_avePrecision, 1);
        temp_time_query(query_index, :) = mean(temp_time, 1);
        temp_TopPrecision_query(query_index, :) = mean(temp_TopPrecision, 1);
        
    end
    
    temp_BEP_class(class_index, :) = mean(temp_BEP_query, 1);
    temp_effectiveness_class(class_index, :) = mean(temp_effectiveness_query, 1);
    temp_avePrecision_class(class_index, :) = mean(temp_avePrecision_query, 1);
    temp_time_class(class_index, :) = mean(temp_time_query, 1);
    temp_TopPrecision_class(class_index, :) = mean(temp_TopPrecision_query, 1);
    
end

ave_feedback_BEP = mean(temp_BEP_class, 1);
ave_feedback_effectiveness = mean(temp_effectiveness_class, 1);
ave_feedback_avePrecision = mean(temp_avePrecision_class, 1);
ave_feedback_time = mean(temp_time_class, 1);
ave_feedback_TopPrecision = mean(temp_TopPrecision_class, 1);

Time_Graph_Query = Time_avgGraph + Paras.mtime(2) / ins_num;
Time_add = zeros(1, fb_round + 1);
Time_add(1) = Time_Graph_Query;
ave_feedback_time_all = ave_feedback_time + Time_add;

% Evalution of PR-Graph for retrieval only using query image
sum_Precisions = zeros(NumPR + 1, 1);
sum_Recalls = zeros(NumPR + 1, 1);
for class_index = 1:class_num
    for query_index = 1:query_num
        sum_Precisions = sum_Precisions + Result_Precisions{class_index, query_index};
        sum_Recalls = sum_Recalls + Result_Recalls{class_index, query_index};
    end
end
ave_Precisions = sum_Precisions ./ (class_num * query_num);
ave_Recalls = sum_Recalls ./ (class_num * query_num);

% Save
Paras.methodname = methodname;
Paras.dataname = dataname;
Paras.TopPrecision_S = TopPrecision_S;
Paras.effectiveness_S = effectiveness_S;
Paras.NumPR = NumPR;
Paras.query_num = query_num;
Paras.fb_process = fb_process;
Paras.fb_round = fb_round;
Paras.F_num = F_num;

Paras.alpha = alpha;
Paras.iter = iter;
Paras.gamma = gamma;

savename = strcat(resultpath, 'Results_', methodname, '_', dataname, '.mat');
save(savename, 'Paras', 'Result_BEP', 'Result_effectiveness', ...
    'Result_avePrecision', 'Result_Time', 'Result_TopPrecision', 'ave_feedback_BEP', ...
    'ave_feedback_effectiveness', 'ave_feedback_avePrecision', 'ave_feedback_time', 'ave_feedback_time_all', ...
    'ave_feedback_TopPrecision', 'Result_Precisions', 'Result_Recalls', 'ave_Precisions', 'ave_Recalls');
