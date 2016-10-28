function [Score, Time] = CBIR_InstSim(Relevant_Index, Irrelevant_Index, Pre_Distance)
% InstRank method

% G. Giacinto and F. Roli.
% Instance-based relevance feedback for image retrieval.
% In Advances in NIPS, pages 489-496, 2005.

Time = 0;
Dis_Positive = Pre_Distance(Relevant_Index, :);
Dis_Negative = Pre_Distance(Irrelevant_Index, :);
tic;
Dis_minPos = min(Dis_Positive, [], 1);
Dis_minNeg = min(Dis_Negative, [], 1);
Score = Dis_minNeg ./ (Dis_minPos + Dis_minNeg);
Time = Time + toc;