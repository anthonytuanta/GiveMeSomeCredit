function mse = Measure_MSE(pred, labels)
% Mean Squared Error for Regression
% 
% labels: groundtruth regression value;
% pred: predicted value;

mse = mean((pred - labels) .^ 2);
