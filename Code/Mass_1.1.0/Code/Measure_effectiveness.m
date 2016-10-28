function effectiveness = Measure_effectiveness(Labels, Scores, S)
% Effectiveness for Retrieval
% 
% Labels: groundtruth labels;
% Scores: predicted scores;
% S: parameter;

relevant_num = length(find(Labels == 1));
retrived_num = S;
[temp, Index] = sort(-Scores);
Sort_Label = Labels(Index);
Sort_Label_retrived = Sort_Label(1:S, 1);
retrived_relevant_num = length(find(Sort_Label_retrived == 1));

if S >= relevant_num
    effectiveness = retrived_relevant_num / relevant_num;
else
    effectiveness = retrived_relevant_num / retrived_num;
end