function TopPrecision = Measure_TopPrecision(Labels, Scores, S)
% Precision @ top-S for Retrieval
% 
% Labels: groundtruth labels;
% Scores: predicted scores;
% S: top-S precision;

[temp, Index] = sort(-Scores);
Sort_Label = Labels(Index);
TopPrecision = length(find(Sort_Label(1:S) == 1)) / S;
