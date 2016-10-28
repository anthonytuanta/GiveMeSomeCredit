function results_ttest = Main_Retrieval_ttest_query(filepath, dataname, methodname1, methodname2, Paras)
% paired t-test for retrieval results with one query

resultpath = strcat(filepath, 'Results/Retrieval/');

NumQuery = Paras.query_num;

loadname = strcat(resultpath, 'Results_', methodname1, '_', dataname, '.mat');
load(loadname);
NumClass = size(Result_BEP, 1);

Result_BEP_1 = zeros(NumClass, NumQuery);
Result_effectiveness_1 = zeros(NumClass, NumQuery);
Result_avePrecision_1 = zeros(NumClass, NumQuery);
Result_TopPrecision_1 = zeros(NumClass, NumQuery);

for class_index = 1:NumClass
    for query_index = 1:NumQuery
        temp = Result_BEP{class_index, query_index};
        Result_BEP_1(class_index, query_index) = temp{1, 1};
        temp = Result_effectiveness{class_index, query_index};
        Result_effectiveness_1(class_index, query_index) = temp{1, 1};
        temp = Result_avePrecision{class_index, query_index};
        Result_avePrecision_1(class_index, query_index) = temp{1, 1};
        temp = Result_TopPrecision{class_index, query_index};
        Result_TopPrecision_1(class_index, query_index) = temp{1, 1};
    end
end
Result_BEP_1 = Result_BEP_1(:);
Result_effectiveness_1 = Result_effectiveness_1(:);
Result_avePrecision_1 = Result_avePrecision_1(:);
Result_TopPrecision_1 = Result_TopPrecision_1(:);
clear Result_BEP;
clear Result_effectiveness;
clear Result_avePrecision;
clear Result_TopPrecision;



loadname = strcat(resultpath, 'Results_', methodname2, '_', dataname, '.mat');
load(loadname);

Result_BEP_2 = zeros(NumClass, NumQuery);
Result_effectiveness_2 = zeros(NumClass, NumQuery);
Result_avePrecision_2 = zeros(NumClass, NumQuery);
Result_TopPrecision_2 = zeros(NumClass, NumQuery);

for class_index = 1:NumClass
    for query_index = 1:NumQuery
        temp = Result_BEP{class_index, query_index};
        Result_BEP_2(class_index, query_index) = temp{1, 1};
        temp = Result_effectiveness{class_index, query_index};
        Result_effectiveness_2(class_index, query_index) = temp{1, 1};
        temp = Result_avePrecision{class_index, query_index};
        Result_avePrecision_2(class_index, query_index) = temp{1, 1};
        temp = Result_TopPrecision{class_index, query_index};
        Result_TopPrecision_2(class_index, query_index) = temp{1, 1};
    end
end
Result_BEP_2 = Result_BEP_2(:);
Result_effectiveness_2 = Result_effectiveness_2(:);
Result_avePrecision_2 = Result_avePrecision_2(:);
Result_TopPrecision_2 = Result_TopPrecision_2(:);

% ttest
[h_bep, p_bep] = ttest(Result_BEP_1, Result_BEP_2);
if mean(Result_BEP_1) < mean(Result_BEP_2)
    h_bep = - h_bep;
end

[h_effectiveness, p_effectiveness] = ttest(Result_effectiveness_1, Result_effectiveness_2);
if mean(Result_effectiveness_1) < mean(Result_effectiveness_2)
    h_effectiveness = - h_effectiveness;
end

[h_avePrecision, p_avePrecision] = ttest(Result_avePrecision_1, Result_avePrecision_2);
if mean(Result_avePrecision_1) < mean(Result_avePrecision_2)
    h_avePrecision = - h_avePrecision;
end

[h_TopPrecision, p_TopPrecision] = ttest(Result_TopPrecision_1, Result_TopPrecision_2);
if mean(Result_TopPrecision_1) < mean(Result_TopPrecision_2)
    h_TopPrecision = - h_TopPrecision;
end

WDL_BEP = [length(find(Result_BEP_1 > Result_BEP_2)), ...
    length(find(Result_BEP_1 == Result_BEP_2)), length(find(Result_BEP_1 < Result_BEP_2))];
WDL_eff = [length(find(Result_effectiveness_1 > Result_effectiveness_2)), ...
    length(find(Result_effectiveness_1 == Result_effectiveness_2)), length(find(Result_effectiveness_1 < Result_effectiveness_2))];
WDL_AP = [length(find(Result_avePrecision_1 > Result_avePrecision_2)), ...
    length(find(Result_avePrecision_1 == Result_avePrecision_2)), length(find(Result_avePrecision_1 < Result_avePrecision_2))];
WDL_PAN = [length(find(Result_TopPrecision_1 > Result_TopPrecision_2)), ...
    length(find(Result_TopPrecision_1 == Result_TopPrecision_2)), length(find(Result_TopPrecision_1 < Result_TopPrecision_2))];

results_ttest.h_bep = h_bep;
results_ttest.h_effectiveness = h_effectiveness;
results_ttest.h_avePrecision = h_avePrecision;
results_ttest.h_TopPrecision = h_TopPrecision;
results_ttest.p_bep = p_bep;
results_ttest.p_effectiveness = p_effectiveness;
results_ttest.p_avePrecision = p_avePrecision;
results_ttest.p_TopPrecision = p_TopPrecision;

results_ttest.WDL_BEP = WDL_BEP;
results_ttest.WDL_eff = WDL_eff;
results_ttest.WDL_AP = WDL_AP;
results_ttest.WDL_PAN = WDL_PAN;

