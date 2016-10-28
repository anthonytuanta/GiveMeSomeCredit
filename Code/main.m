%This script is to handle GiveMeSomeCredit Competittion by Kaggle
%Link : https://www.kaggle.com/c/GiveMeSomeCredit
%Author : Anthony Ta

clear all;

%load training data
data=loadTrainingData('../Data/cs-training.csv');

disp('overall view of data');
minData=min(data(:,2:end))
maxData=max(data(:,2:end))
meanData=nanmean(data(:,2:end))
stdData=nanstd(data(:,2:end))
X=data(:,2:end);
y=data(:,1);
disp('y');
tabulate(y)

%uncomment to display histogram of each feature
%displayData(data);

%% ==============load test data =======================================
dataTest=loadTestData('../Data/cs-test.csv');
XTest=dataTest(:,2:end);

%% ==============normalize features =================================
[X,mu,sigma]=featureNormalize(X);
m = size(X,1);

mTest = size(XTest,1);
XTest=XTest-repmat(mu,mTest,1);
XTest=XTest./repmat(sigma,mTest,1);

%% ==============logistic regression with regularization===============
% Set regularization parameter lambda to 1.01,1,100
lambda=[0.01,1,100];
for i=1:length(lambda)
    outname = ['../Result/out_regress_lambda' num2str(lambda(i)) '_aftercleaning.csv'];
    runLogisticRegression(X,y,XTest,lambda(i),outname);
end

%% ================neural network =========================================
for i=1:length(lambda)
    outname = ['../Result/out_neuralnet_lambda' num2str(lambda(i)) '_aftercleaning.csv'];
    runNeuralNetwork(X,y,XTest,lambda(i),outname);
end


%% =================use RUSBoost ====================================
minLeafSize=[2 50 100 300 5000];
for i=1:length(minLeafSize)
    outname = ['../Result/out_rusboost_minleaf' num2str(minLeafSize(i)) '_aftercleaning.csv'];
    runRUSBoost(X,y,XTest,minLeafSize(i),outname);
end


%% ================Isolattion Forest ==============================
numSub=[128 256 512 1024];
for i=1:length(numSub)
    outname = ['../Result/out_itree_numsub' num2str(numSub(i)) '_aftercleaning.csv'];
    runIsolationForest(X,y,XTest,numSub(i),outname);
end
