function [Score, Time] = CBIR_Query_MRBIR(query, NormWeights, alpha, iter)
% MRBIR method: one query

% J. He, M. Li, H. Zhang, H. Tong, and C. Zhang.
% Manifold-ranking based image retrieval.
% In Proceedings of ACMMM, pages 9-16, 2004.

Time = 0;
Score = zeros(size(NormWeights, 1), 1);
Score(query) = 1;
y = Score;

tic;
for i = 1:iter
    newScore = alpha .* (NormWeights * Score) + (1 - alpha) * y;
    Score = newScore;
end
Time = Time + toc;
