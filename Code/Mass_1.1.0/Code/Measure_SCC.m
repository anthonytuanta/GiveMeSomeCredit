function scc = Measure_SCC(pred, labels)
% Squared Correlation Coefficient for Regression
% 
% labels: groundtruth regression value;
% pred: predicted value;

term1 = length(labels) * sum(pred .* labels) - sum(pred) * sum(labels);
term2 = length(labels) * sum(pred.^2) - (sum(pred))^2;
term3 = length(labels) * sum(labels.^2) - (sum(labels))^2;

scc = (term1) ^2 / (term2 * term3);
