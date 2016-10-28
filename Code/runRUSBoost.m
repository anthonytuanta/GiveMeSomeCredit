function runRUSBoost(X,y,XTest,minLeafSize,outname)
    % X=log(X+0.1);

    t = templateTree('MinLeafSize',minLeafSize);
    tic
    rusTree = fitensemble(X,y,'RUSBoost',5000,t,...
        'LearnRate',0.1,'nprint',5000);
    toc
    [yFit,yScore] = predict(rusTree,X);
    tab = tabulate(y);
    bsxfun(@rdivide,confusionmat(y,yFit),tab(:,2))*100
    
    %plot loss function
    figure;
    tic
    plot(loss(rusTree,X,y,'mode','cumulative'));
    toc
    grid on;
    xlabel('Number of trees');
    ylabel('Test classification error');

    sumYScore=sum(yScore,2);
    prob=yScore(:,2)./sumYScore;
    [xCoord,yCcoord,tTmp,auc] = perfcurve(y,prob,1);
    %print out auc
    fprintf('Train AUC: %f\n',auc);

    % XTest=log(XTest+0.1);
    [yFit,yScore] = predict(rusTree,XTest);

    sumYScore=sum(yScore,2);
    prob=yScore(:,2)./sumYScore;
   
    %output probability for kaggle
    writeOutput(outname,prob);
end