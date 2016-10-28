function Main_Regression_HSMassSVR(filepath, dataname_all, Paras)

% % % % % % % % % % % % % % % % % % % % % % % %
% parameters setting
% % % % % % % % % % % % % % % % % % % % % % % %
datapath = strcat(filepath, 'Data/Regression/');
localpath = strcat(filepath, 'Local/Regression/');
resultpath = strcat(filepath, 'Results/Regression/');

methodname = Paras.methodname;
rounds = Paras.rounds; % rounds of testing
folds = Paras.folds; % cv-folds
mykernel = Paras.mykernel; % 1 - input my own kernel; 0 - otherwise;

toler = Paras.toler;
msize = Paras.msize;
glist = Paras.glist;
clist = Paras.clist;
elist = Paras.elist;

NumTree = Paras.NumTree;
NumSub = Paras.NumSub;
NumDim = Paras.NumDim;
SizeLimit = Paras.SizeLimit;
DepthLimit = Paras.DepthLimit;

NumData = size(dataname_all, 2);
myresults_all = zeros(NumData, 6);

% % % % % % % % % % % % % % % % % % % % % % % %
% begin main loop
% % % % % % % % % % % % % % % % % % % % % % % %

for data_index = 1:NumData
    
    dataname = dataname_all{data_index};
    load(strcat(datapath, dataname, '.mat'));
    
    Labels = MinMax_Norm(Labels);
    
    mse = zeros(rounds, 1);
    scc = zeros(rounds, 1);
    cvmse = zeros(rounds, 1);
    trtime = zeros(rounds, 1);
    tstime = zeros(rounds, 1);
    optglist = zeros(rounds, 1);
    optclist = zeros(rounds, 1);
    optelist = zeros(rounds, 1);
    rseed = zeros(rounds, 1);
    mtime = zeros(rounds, 2);
    
    loadname = strcat(localpath, 'randidx_', dataname, '.mat');
    load(loadname, 'randidx_tr', 'randidx_ts');
    
    for r = 1:rounds
        disp(['Round', num2str(r), ':']);
        
        Labels_tr = Labels(randidx_tr(:, r));
        Labels_ts = Labels(randidx_ts(:, r));
        Data_tr = Data(randidx_tr(:, r), :);
        
        rseed(r) = sum(100 * clock);
        Forest = HSForest(Data_tr, NumTree, NumSub, NumDim, SizeLimit, DepthLimit, rseed(r));
        mtime(r, 1) = Forest.ElapseTime;
        [Data_Mass, mtime(r, 2)] = HSEstimation(Data, Forest);
        clear Forest;
        Data_Mass = MinMax_Norm(Data_Mass);
        Data_tr = Data_Mass(randidx_tr(:, r), :);
        Data_ts = Data_Mass(randidx_ts(:, r), :);
        clear Data_Mass;
        
        if  length(glist) == 1 && length(clist) == 1 && length(elist) == 1 % no cross validation
            optglist(r, 1) = glist(1);
            optclist(r, 1) = clist(1);
            optelist(r, 1) = elist(1);
        else % cross validation
            mse0 = zeros(length(glist), length(clist), length(elist));
            for g_index = 1:length(glist)
                g = glist(g_index);
                if mykernel
                    KParas.type = 'rbf';
                    KParas.g = g;
                    Kmodel = ConstKernels(Data_tr, Data_tr, KParas);
                end
                for c_index = 1:length(clist)
                    for e_index = 1:length(elist)
                        c = clist(c_index);
                        e = elist(e_index);
                        disp(['g=', num2str(g), '; c=', num2str(c), '; e=', num2str(e), '...']);
                        
                        if mykernel
                            if (strcmpi(methodname, 'HSMepSVR') || strcmpi(methodname, 'HSOMepSVR'))
                                options = ['-s 3 -t 4 -c ' num2str(c) ' -p ' num2str(e) ' -v ' num2str(folds) ' -e ' num2str(toler) ' -m ' num2str(msize)];
                            else
                                options = ['-s 4 -t 4 -c ' num2str(c) ' -n ' num2str(e) ' -v ' num2str(folds) ' -e ' num2str(toler) ' -m ' num2str(msize)];
                            end
                            mse0(g_index, c_index, e_index) = svmtrain(Labels_tr, [(1:size(Kmodel.K, 1))', Kmodel.K], options);
                        else
                            if (strcmpi(methodname, 'HSMepSVR') || strcmpi(methodname, 'HSOMepSVR'))
                                options = ['-s 3 -g ' num2str(g) ' -c ' num2str(c) ' -p ' num2str(e) ' -v ' num2str(folds) ' -e ' num2str(toler) ' -m ' num2str(msize)];
                            else
                                options = ['-s 4 -g ' num2str(g) ' -c ' num2str(c) ' -n ' num2str(e) ' -v ' num2str(folds) ' -e ' num2str(toler) ' -m ' num2str(msize)];
                            end
                            mse0(g_index, c_index, e_index) = svmtrain(Labels_tr, Data_tr, options);
                        end
                    end
                end
            end
            
            [cvmse(r, 1), optg_index, optc_index, opte_index] = min3d(mse0);
            optglist(r, 1) = glist(optg_index);
            optclist(r, 1) = clist(optc_index);
            optelist(r, 1) = elist(opte_index);
        end
        
        if mykernel
            KParas.type = 'rbf';
            KParas.g = optglist(r, 1);
            trtime(r) = cputime;
            Kmodel = ConstKernels(Data_tr, Data_tr, KParas);
            if (strcmpi(methodname, 'HSMepSVR') || strcmpi(methodname, 'HSOMepSVR'))
                options = ['-s 3 -t 4 -c ' num2str(optclist(r, 1)) ' -p ' num2str(optelist(r, 1)) ' -e ' num2str(toler) ' -m ' num2str(msize)];
            else
                options = ['-s 4 -t 4 -c ' num2str(optclist(r, 1)) ' -n ' num2str(optelist(r, 1)) ' -e ' num2str(toler) ' -m ' num2str(msize)];
            end
            model = svmtrain(Labels_tr, [(1:size(Kmodel.K, 1))', Kmodel.K], options);
            trtime(r) = cputime - trtime(r);
            KParas.type = 'rbf';
            KParas.g = optglist(r, 1);
            tstime(r) = cputime;
            Kmodel = ConstKernels(Data_ts, Data_tr, KParas);
            [pred, perform] = svmpredict(Labels_ts, [(1:size(Kmodel.K, 1))', Kmodel.K], model);
            tstime(r) = cputime - tstime(r);
        else
            if (strcmpi(methodname, 'HSMepSVR') || strcmpi(methodname, 'HSOMepSVR'))
                options = ['-s 3 -g ' num2str(optglist(r, 1)) ' -c ' num2str(optclist(r, 1)) ' -p ' num2str(optelist(r, 1)) ' -e ' num2str(toler) ' -m ' num2str(msize)];
            else
                options = ['-s 4 -g ' num2str(optglist(r, 1)) ' -c ' num2str(optclist(r, 1)) ' -n ' num2str(optelist(r, 1)) ' -e ' num2str(toler) ' -m ' num2str(msize)];
            end
            trtime(r) = cputime;
            model = svmtrain(Labels_tr, Data_tr, options);
            trtime(r) = cputime - trtime(r);
            tstime(r) = cputime;
            [pred, perform] = svmpredict(Labels_ts, Data_ts, model);
            tstime(r) = cputime - tstime(r);
        end
        
        mse(r, 1) = perform(2);
        scc(r, 1) = perform(3);
        myresults = [mean(mse(1:r)), var(mse(1:r)), mean(scc(1:r)), var(scc(1:r)), mean(trtime(1:r)), mean(tstime(1:r))];
        
        savename = strcat(resultpath, 'Results_', methodname, '_', dataname, '_', ...
            num2str(NumTree), '_', num2str(NumSub), '_', num2str(NumDim), '.mat');
        save(savename, 'mse', 'scc', 'cvmse', 'optglist', 'optclist', 'optelist', 'trtime', 'tstime', 'myresults', 'rseed', 'mtime', 'Paras');
    end
    
    myresults_all(data_index, :) = myresults;
    
end

savename = strcat(resultpath, 'Results_All_', methodname, '.mat');
save(savename, 'myresults_all', 'dataname_all');
