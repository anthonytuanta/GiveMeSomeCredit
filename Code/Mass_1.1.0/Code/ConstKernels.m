function Kmodel = ConstKernels(X1, X2, KParas)
% 
% function ConstKernels: construct kernels
% 
% Input:
%     X1: n1 x d matrix; n1: # of instance; d: dimension;
%     X2: n2 x d matrix; n2: # of instance; d: dimension;
%     KParas: parameters
%     Kmodel.type: kernel type: rbf, linear, poly, sigmoid or Gaussian;
%     KParas.gamma: parameter gamma for rbf, poly, or sigmoid kernel;
%     KParas.coef0: parameter coefficient for poly or sigmoid kernel;
%     KParas.degree: parameter degree for poly kernel;
%     KParas.bandwidth: parameter bandwidth for Gaussian kernel;
% 
% Output:
%     Kmodel: kernel model
%     Kmodel.K: n1 x n2 kernel matrix;
%     Kmodel.type: kernel type: rbf, linear, poly, sigmoid or Gaussian;
%     Kmodel.g: parameter gamma for rbf, poly, or sigmoid kernel;
%     Kmodel.coef0: parameter coefficient for poly or sigmoid kernel;
%     Kmodel.degree: parameter degree for poly kernel;
%     Kmodel.bandwidth: parameter bandwidth for Gaussian kernel;
% 

if strcmpi(KParas.type, 'rbf')
    
    Kmodel.K = exp(- KParas.g .* dist2(X1, X2));
    Kmodel.gamma = KParas.g;
    
elseif strcmpi(KParas.type, 'linear')
    
    Kmodel.K = X1 * X2';
    
elseif strcmpi(KParas.type, 'poly')
    
    Kmodel.K = (KParas.g .* (X1 * X2') + coef0) .^ degree;
    Kmodel.gamma = KParas.g;
    Kmodel.coef0 = KParas.coef0;
    Kmodel.degree = KParas.degree;
    
elseif strcmpi(KParas.type, 'sigmoid')
    
    Kmodel.K = tanh(KParas.g .* (X1 * X2') + coef0);
    Kmodel.gamma = KParas.g;
    Kmodel.coef0 = KParas.coef0;
    
elseif strcmpi(KParas.type, 'Gaussian')
    
    Kmodel.K = exp(- dist2(X1, X2) / (2 * (KParas.bandwidth) ^2));
    Kmodel.bandwidth = KParas.bandwidth;
    
else
    error('Wrong kernel type.');
end

Kmodel.type = KParas.type;
