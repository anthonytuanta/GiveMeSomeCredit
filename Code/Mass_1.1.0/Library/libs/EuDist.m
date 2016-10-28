function Dist = EuDist(DataVec1, DataVec2)

Dist = zeros(size(DataVec1, 1), size(DataVec2, 1));
for i = 1:size(DataVec1, 1)
    for j = i + 1:size(DataVec2, 1)
        Dist(i, j) = sum((DataVec1(i, :) - DataVec2(j, :)) .^ 2);
        Dist(j, i) = Dist(i, j);
    end
end
