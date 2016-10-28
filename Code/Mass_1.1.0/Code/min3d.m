function [MinV, i, j, k] = min3d(Matrix)
% find minimum in a 3-D matrix

i = 1;
j = 1;
k = 1;
MinV = Matrix(i, j, k);

for ii = 1:size(Matrix, 1)
    for jj = 1:size(Matrix, 2)
        for kk = 1:size(Matrix, 3)
            if Matrix(ii, jj, kk) < MinV
                i = ii;
                j = jj;
                k = kk;
                MinV = Matrix(ii, jj, kk);
            end
        end
    end
end
