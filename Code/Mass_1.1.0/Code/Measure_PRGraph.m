function [Precisions, Recalls] = Measure_PRGraph(Labels, Scores, NumPR)
% Precision-Recall Graph for Retrieval
% 
% Labels: groundtruth labels;
% Scores: predicted scores;
% NumPR: number of points in PR-graph;

[Sort_PP, Sort_Index] = sort(-Scores);
Sort_Label = Labels(Sort_Index);
total_num = length(Labels);
positive_num = length(find(Labels == 1));
Precisions_All = zeros(positive_num, 1);

cumulate_num = 0;
for i = 1:total_num
    if Sort_Label(i) == 1
        cumulate_num = cumulate_num + 1;
        Precisions_All(cumulate_num) = cumulate_num / i;
    end
end

Recalls = (0:(1 / NumPR):1)';
temp = round(positive_num .* Recalls(2:end));
Precisions = [1; Precisions_All(temp)];
