function MassModel = MassTrain(Data, NumT, NumSub, HLevel, rseed)
%
% function MassTrain: build mass distribution using step function
%
% Input:
%     Data: n x d matrix; n: # of instance; d: dimension;
%     NumT: # of transformed dimension;
%     NumSub: # of sub-sample;
%     HLevel: level of mass calculation;
%     rseed: random seed;
%
% Output:
%     MassModel.NumT: NumT;
%     MassModel.NumSub: NumSub;
%     MassModel.HLevel: HLevel;
%     MassModel.rseed: rseed;
%     MassModel.ElapseTime: elapsed time;
%     MassModel.Dims: index of dimension used for each estimation;
%     MassModel.Splits: splitting points;
%     MassModel.Mass: estimated mass of the sub-samples;
%
% Notice: might crash on data with many instances having the same attribute values on some dimension;
% 

[NumInst, DimInst] = size(Data);

rand('state', rseed);
Dims = zeros(NumT, 1);
Splits = zeros(NumT, NumSub + 1);
Mass = zeros(NumT, NumSub + 2);

et = cputime;
for tidx = 1:NumT

    % randomly select a sub-sample
    if NumSub < NumInst
        [temp, SubRand] = sort(rand(1, NumInst));
        IndexSub = SubRand(1:NumSub);
    else
        IndexSub = 1:NumInst;
    end
    % randomly select a dimension
    [temp, DimRand] = sort(rand(1, DimInst));
    Dims(tidx) = DimRand(1);

    % sort the data
    X = sort(Data(IndexSub, Dims(tidx)));
    UniX = unique(X);

    if length(UniX) ~= length(X)
        BinX = histc(X, UniX);
        NewX = X;
        for i = 1:length(UniX)
            if BinX(i) > 1
                temp = find(X == UniX(i));
                NewX(temp) = X(temp) + 1e-10 * rand(length(temp), 1);
            end
        end
        X = sort(NewX);
    end

    % model: estimated mass
    CurtMass = zeros(1, NumSub);
    for a = 1:NumSub
        CurtMass(a) = MassUnit(X, a, HLevel);
    end
    Mass(tidx, :) = [0, CurtMass, 0];

    % model: splitting points
    CurtSplits = ((X(1:end - 1) + X(2:end)) / 2)';
    Splits(tidx, :) = [(3 * X(1) - X(2)) / 2, CurtSplits, (3 * X(end) - X(end - 1)) / 2];

end

MassModel.ElapseTime = cputime - et;

MassModel.NumT = NumT;
MassModel.NumSub = NumSub;
MassModel.HLevel = HLevel;
MassModel.rseed = rseed;

MassModel.Dims = Dims;
MassModel.Splits = Splits;
MassModel.Mass = Mass;
