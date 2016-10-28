function [Score, Time] = CBIR_MRBIR(Relevant_Index, Irrelevant_Index, NormWeights, alpha, iter, gamma)
% MRBIR method: relevance feedback

% J. He, M. Li, H. Zhang, H. Tong, and C. Zhang.
% Manifold-ranking based image retrieval.
% In Proceedings of ACMMM, pages 9-16, 2004.

Time = 0;
Pos_Score = zeros(size(NormWeights, 1), 1);
Pos_Score(Relevant_Index) = 1;
pos_y = Pos_Score;
Neg_Score = zeros(size(NormWeights, 1), 1);
Neg_Score(Irrelevant_Index) = -1;
neg_y = Neg_Score;

tic;
for i = 1:iter
    Pos_newScore = alpha .* (NormWeights * Pos_Score) + (1 - alpha) * pos_y;
    Pos_Score = Pos_newScore;
    Neg_newScore = alpha .* (NormWeights * Neg_Score) + (1 - alpha) * neg_y;
    Neg_Score = Neg_newScore;
end
Score = Pos_Score + gamma .* Neg_Score;
Time = Time + toc;
