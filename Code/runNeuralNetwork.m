function runNeuralNetwork(X,y,XTest,lambda,outname)
    addpath('./neuralNetwork');
    y=y+1;
    [m, n] = size(X);
    mTest = size(XTest,1);
    % Setup the parameters
    input_layer_size  = n;  %number of features
    hidden_layer_size = 5;   % 5 hidden units
    num_labels = 2;          % binary classification labels, from 1 to 2   
                              % (note that we have mapped "0" to label 1, "1" to 2)

    fprintf('\nInitializing Neural Network Parameters ...\n')
    initial_Theta1 = randInitializeWeights(input_layer_size, hidden_layer_size);
    initial_Theta2 = randInitializeWeights(hidden_layer_size, num_labels);

    % Unroll parameters
    initial_nn_params = [initial_Theta1(:) ; initial_Theta2(:)];

    fprintf('\nTraining Neural Network... \n')

    options = optimset('MaxIter', 200);



    % keep all samples with y=1
    % randomly select 20k samples with y=0
    yesId=find(y==2);
    noId=find(y==1);
    rand('seed',100); %set seed for repetitive check
    noId_sel=randperm(size(noId,1));
    noId_sel=noId_sel(1:20000);
    sel=[yesId; noId(noId_sel)];
    sel_perm=randperm(size(sel,1));
    sel=sel(sel_perm);

    % Create "short hand" for the cost function to be minimized
    costFunction = @(p) nnCostFunction(p, ...
                                       input_layer_size, ...
                                       hidden_layer_size, ...
                                       num_labels, single(X(sel,:)), y(sel), lambda);
    % Now, costFunction is a function that takes in only one argument (the
    % neural network parameters)
    [nn_params, cost] = fmincg(costFunction, initial_nn_params, options);

    % Obtain Theta1 and Theta2 back from nn_params
    Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                     hidden_layer_size, (input_layer_size + 1));
    Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                     num_labels, (hidden_layer_size + 1));
    h1 = sigmoid([ones(m, 1) X] * Theta1');
    h2 = sigmoid([ones(m, 1) h1] * Theta2');
    [Xcoord,Ycoord,Ttmp,auc] = perfcurve(y,h2(:,2),2);
    %print out auc
    fprintf('Train AUC: %f\n',auc);

   
    h1 = sigmoid([ones(mTest, 1) XTest] * Theta1');
    h2 = sigmoid([ones(mTest, 1) h1] * Theta2');

    %output probability for kaggle
    writeOutput(outname,h2(:,2));
end