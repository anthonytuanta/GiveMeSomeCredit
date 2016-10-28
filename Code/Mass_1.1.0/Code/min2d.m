function [MinV, i, j] = min2d(Matrix)
% find minimum in a 2-D matrix

i = 1;
j = 1;
MinV = Matrix(i, j);

for ii = 1:size(Matrix, 1)
    for jj = 1:size(Matrix, 2)
        if Matrix(ii, jj) < MinV
            i = ii;
            j = jj;
            MinV = Matrix(ii, jj);
        end
    end
end
