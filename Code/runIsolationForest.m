function runIsolationForest(X,y,XTest,numSub,outname)
%This uses code from Mass Estimation package provided at 
%https://sourceforge.net/projects/mass-estimation/
%numSub: number of subsamples
    addpath('Mass_1.1.0/Code');
    addpath('Mass_1.1.0/Library/libs');
    addpath('Mass_1.1.0/Library/libsvm');
    
    [m,curtNumDim]=size(X);
    mTest = size(XTest,1);

    set(0, 'RecursionLimit', 5000);
    % parameters for iForest
    numTree = 100; % number of isolation trees
    numDim = 0; % do not perform dimension sampling

    %Get the constant that later be used to convert scores to probabilities
    C=2*(log(m-1)+0.5772156649)-(2*(m-1)/m);
 
    prob=[];
    probTest=[];
    for r=1:10
        disp(['rounds ', num2str(r), ':']);
        rseed(r) = sum(100 * clock);
        Forest = IsolationForest(X, numTree, numSub, curtNumDim, rseed(r));
        mtime(r, 1) = Forest.ElapseTime;
        [Mass, mtime(r, 2)] = IsolationEstimation(X, Forest);
        score = - mean(Mass, 2);

        [MassTest, mtime(r, 2)] = IsolationEstimation(XTest, Forest);
        scoreTest = - mean(MassTest, 2);
        clear Forest;
        clear Mass;
        %convert scores to probabilities
        %based on cs.nju.edu.cn/zhouzh/zhouzh.files/publication/icdm08b.pdf
        prob= [prob power(2,(score./C))];
        probTest= [probTest power(2,(scoreTest./C))];
    end
    prob=mean(prob,2);
    [Xcoord,Ycoord,Ttmp,auc] = perfcurve(y,prob,1);
    %print out auc
    fprintf('Train AUC: %f\n',auc);
    
    probTest=mean(probTest,2);

    %output probability for kaggle
    writeOutput(outname,probTest);
end