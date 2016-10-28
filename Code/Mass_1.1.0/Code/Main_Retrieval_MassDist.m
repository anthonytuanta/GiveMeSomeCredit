function Main_Retrieval_MassDist(filepath, Paras)
% calculate squared Euclidean distance matrix (mass space)

% % % % % % % % % % % % % % % % % % % % % % % %
% parameters setting
% % % % % % % % % % % % % % % % % % % % % % % %
datapath = strcat(filepath, 'Data/Retrieval/');
localpath = strcat(filepath, 'Local/Retrieval/');
resultpath = strcat(filepath, 'Results/Retrieval/');

dataname = Paras.dataname;
load(strcat(datapath, dataname, '.mat'));
NumT = Paras.NumT;
NumSub = Paras.NumSub;
HLevel = Paras.HLevel;

rseed = sum(100 * clock);
MassModel = MassTrain(Data, NumT, NumSub, HLevel, rseed);
mtime(1, 1) = MassModel.ElapseTime;
[Mass, mtime(1, 2)] = MassPredict(Data, MassModel);
clear MassModel;

NumInst = size(Mass, 1);

% distance calculation
Pre_Distance = zeros(NumInst, NumInst);
step = 1000;
for i = 1:(NumInst / step)
    disp(['step ', num2str(i * step), '...']);
    Pre_Distance(((i - 1) * step + 1):(i * step), :) = dist2(Mass(((i - 1) * step + 1):(i * step), :), Mass);
end

% time cost
step_value = [1, 4];
reptimes = 100;
step_length = length(step_value);
Time_Distance = cell(step_length, 1);
Time_avgDistance = zeros(step_length, 1);

for step_index = 1:step_length
    
    step = step_value(step_index);
    tc = zeros(reptimes, 1);

    for i = 1:reptimes
        t = cputime;
        x = dist2(Mass(((i - 1) * step + 1):(i *step), :), Mass);
        tc(i) = cputime - t;
    end
    
    Time_Distance{step_index} = tc;
    Time_avgDistance(step_index) = mean(tc);

end

% Save
Paras.rseed = rseed;
Paras.mtime = mtime;
savename = strcat(localpath, 'massdist_', dataname, '_', num2str(NumT), '_', num2str(NumSub), '_', num2str(HLevel), '.mat');
save(savename, 'Pre_Distance', 'Time_Distance', 'Time_avgDistance', 'Paras');
