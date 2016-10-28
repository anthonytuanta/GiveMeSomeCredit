function Retrieval_randidx(filepath, Paras)
% randomly generate query indices and feedback indices

datapath = strcat(filepath, 'Data/Retrieval/');
localpath = strcat(filepath, 'Local/Retrieval/');

dataname = Paras.dataname;
query_num = Paras.query_num;
fb_round = Paras.fb_round;
fb_process = Paras.fb_process;
queryimage_num = 1;

load(strcat(datapath, dataname, '.mat'));

[NumInst, NumClass] = size(Labels);

Positive_Index = cell(NumClass, query_num);
Negative_Index = cell(NumClass, query_num);

for class_index = 1:NumClass
    
    for query_index = 1:query_num
        
        p_index = cell((fb_round + 1), 1);
        n_index = cell((fb_round + 1), 1);
        
        index_pos = find(Labels(:, class_index) == 1)';
        index_neg = setdiff(1:NumInst, index_pos);
        rand_pos = randperm(length(index_pos));
        p_index{1} = index_pos(rand_pos(1:queryimage_num));
        n_index{1} = [];
        index_p = setdiff(index_pos, p_index{1});
        index_n = setdiff(index_neg, n_index{1});
        for rand_index = 1:fb_process
            rand_p = randperm(length(index_p));
            rand_n = randperm(length(index_n));
            p_index{rand_index + 1} = index_p(rand_p);
            n_index{rand_index + 1} = index_n(rand_n);
        end
        Positive_Index{class_index, query_index} = p_index;
        Negative_Index{class_index, query_index} = n_index;
        
    end
end

savename = strcat(localpath, 'pnidx_', dataname, '.mat');
save(savename, 'Positive_Index', 'Negative_Index');
