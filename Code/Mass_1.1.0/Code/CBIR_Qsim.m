function [Score, Time] = CBIR_Qsim(Relevant_Index, Irrelevant_Index, Pre_Distance)
% Qsim method

% Z.-H. Zhou and H.-B. Dai.
% Query-sensitive similarity measure for content-based image retrieval.
% In Proceedings of ICDM, pages 1211-1215, 2006.

Time = 0;
ins_num = size(Pre_Distance, 1);
p_num = length(Relevant_Index);
n_num = length(Irrelevant_Index);
Dist_Positive = zeros(p_num, p_num, ins_num);
Dist_Negative = zeros(p_num, n_num, ins_num);

for q = 1:p_num
    query = Relevant_Index(q);
    for vp = 1:p_num
        view = Relevant_Index(vp);
        tic;
        Dist_Positive(vp, q, :) = Pre_Distance(query, :) .* (Pre_Distance(view, query) + Pre_Distance(view, :)) / 2;
        Time = Time + toc;
    end
    for vn = 1:n_num
        view = Irrelevant_Index(vn);
        tic;
        Dist_Negative(vn, q, :) = Pre_Distance(query, :) ./ ((Pre_Distance(view, query) + Pre_Distance(view, :)) / 2);
        Time = Time + toc;
    end
end

Dist_Pos = reshape(min(Dist_Positive, [], 2), p_num, ins_num);
Dist_Neg = reshape(min(Dist_Negative, [], 2), p_num, ins_num);

tic;
QDist_Pos = mean(Dist_Pos);
QDist_Neg = mean(Dist_Neg);
QDist_Pos_Norm = (QDist_Pos - min(QDist_Pos)) ./ (max(QDist_Pos) - min(QDist_Pos));
QDist_Neg_Norm = (QDist_Neg - min(QDist_Neg)) ./ (max(QDist_Neg) - min(QDist_Neg));

QDist = (QDist_Pos_Norm + QDist_Neg_Norm) / 2;
Score = max(QDist) - QDist;
Time = Time + toc;