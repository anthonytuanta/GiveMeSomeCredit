function runLogisticRegression(X,y,XTest,lambda,outname)
    addpath('./logisticRegression');
    m = size(X,1);
    mTest = size(XTest,1);

    % Add intercept term to x and X_test
    X = [ones(m, 1) X];

    % Initialize fitting parameters
    initial_theta = zeros(size(X, 2), 1);

    % Set Options
    options = optimset('GradObj', 'on', 'MaxIter', 1000);

    % Optimize
    [theta, J, exit_flag] = ...
        fminunc(@(t)(costFunctionReg(t, X, y, lambda)), initial_theta, options);
    %compute UAC for training set
    p=sigmoid(X*theta);
    [Xcoord,Ycoord,Ttmp,auc] = perfcurve(y,p,1);
    %print out auc
    fprintf('Train AUC: %f\n',auc);

    XTest = [ones(mTest, 1) XTest];
    %output probability for kaggle
    pTest=sigmoid(XTest*theta);
    writeOutput(outname,pTest);
end