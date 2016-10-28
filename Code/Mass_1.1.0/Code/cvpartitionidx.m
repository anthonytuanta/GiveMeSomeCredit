function [indp] = cvpartitionidx(Y, ncrossval)
% function [indp] = cvpartitionidx(Y, ncrossval)
% generate the index sets of partitions for n-fold cross validation
% Input -> Y: labels, each partition should have the same proportion of positive and negative samples
%		   ncrossval: number of folds for cross validation
% Output -> indp [nx2-cell]: indp(:, 1) stores indices of training points
%               for each fold, whereas indp(:, 2) stores indices of testing points

%rand('state', sum(100*clock));
% partition the dataset X and Y into ncrossval-folds
indp = cell(ncrossval, 2);
indi = (1:length(Y))';
% indicator vector indic(i) = k means the ith point was in validation set k
indic = ncrossval*ones(length(Y),1);

for i=1:ncrossval-1,
    % notice that indtr_i and indts_i are both relative indices
    [indtr_i, indts_i] = partitionidx(Y(indi), struct('ratio',1/(ncrossval-i+1)));
    indic(indi(indtr_i)) = i;
    % update indi
    indi = indi(indts_i);
end
indic(indi) = ncrossval;

for i=1:ncrossval,
    indp{i, 1} = find(indic~=i);
    indp{i, 2} = find(indic==i);
end

function [idx_tr, idx_ts] = partitionidx(Y, options)
% function [idx_tr,idx_ts] = PartionIdx(Y, options)
% partition the data set into training set and test set by certain ratio
% return the indices of partitions
% Input -> Y (Nx1 label vector)
%          options . ratio: ratio of training data in the whole data set
%                  . number:   number of training data per class in the whoel data set
%                  . useratio (default 1): 1 <-use ratio data, 0<- use number
% Output -> idx_tr, idx_ts: indices of training and test set respectively

if ~exist('options','var'), options = []; end;
if ~isfield(options, 'ratio'),  ratio = 0;    else ratio = options.ratio; end;
if ~isfield(options, 'number'), number = 0;     else number = options.number;   end;
% if ~isfield(options, 'useratio'), useratio = 1; else useratio = options.useratio;  end;
% filtvec is the vector for artistic filter, if Y = [1 1 1 ...], and
% filtvec = [1 1 2 ...], then Y(1) and Y(2) must not be separated into two sets
if ~isfield(options, 'filtvec'), filtvec = [];  else filtvec = options.filtvec; end;
if ~isfield(options, 'shuffle'), shuffle = 0;   else shuffle = options.shuffle; end;
if number <= 0,
    useratio = 1;
else
    useratio = 0;
end;
if number <= 0 && ratio <= 0,
    error('either need to specify ratio or number of samples per class');
end
if useratio && (ratio <= 0 || ratio >= 1),
    warning('Ratio must be between 0 and 1 or an integer larger than 1.\n');
    warning('Forcing ratio to 0.5\n');
    ratio = 0.5;
end


if ~isempty(filtvec),
    if length(filtvec)~=length(Y),
        filtvec = [];
        warning('filtvec must have the same length as Y');
    end
end

% K = max(Y);
labels = unique(Y);
K = length(labels);
% if K<=1,
%     K = 2;
%     Y(find(Y~=1)) = 2;
% end

idx_tr = [];
idx_ts = [];
for j=1:K,
    cind = find(Y==labels(j));
    nj = length(cind);
    % with artist filter, we must treat entries with same filtvec values as a single entry
    if ~isempty(filtvec),
        filtlabel = unique(filtvec(cind));
        nj = length(filtlabel);
    end
    if nj<=1,
        error('only single entry in the class, no split available');
    end
    randind = randperm(nj);
    % index of training samples within the current class
    %trainind = startind(j) - 1 + randind(1:trainsize(j));
    if useratio,     % use fixed ratio for each class for training
        trsize = ceil(nj*ratio);
    else
        trsize = number;
    end
    %    trsize = min(trsize, nj-1);
    trsize = min(trsize, nj);
    trainind = [];
    testind = [];
    if ~isempty(filtvec),
        for i=1:trsize,
            trainind = [trainind;cind(find(filtvec(cind)==filtlabel(randind(i))))];
        end
        for i=trsize+1:nj,
            testind = [testind;cind(find(filtvec(cind)==filtlabel(randind(i))))];
        end
    else
        trainind = cind(randind(1:trsize));
        if trsize<nj,
            testind = cind(randind(trsize+1:nj));
        end
    end
    idx_tr = [idx_tr;trainind(:)];
    idx_ts = [idx_ts;testind(:)];
end

if shuffle,
    ntr = length(idx_tr);
    idx_tr = idx_tr(randperm(ntr));
    nts = length(idx_ts);
    idx_ts = idx_ts(randperm(nts));
end
