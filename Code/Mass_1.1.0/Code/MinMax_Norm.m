function NormData = MinMax_Norm(Data)
% min-max normalize data to interval [0, 1]

[n, d] = size(Data);
NormData = zeros(n, d);
MaxAtt = max(Data, [], 1);
MinAtt = min(Data, [], 1);

for i = 1:d
    if MaxAtt(i) <= MinAtt(i)
        NormData(:, i) = 0;
    else
        NormData(:, i) = (Data(:, i) - MinAtt(i)) / (MaxAtt(i) - MinAtt(i));
    end
end
