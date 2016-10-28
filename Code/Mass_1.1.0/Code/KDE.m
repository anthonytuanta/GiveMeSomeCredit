function D = KDE(Xtr, Xts, Paras)
% 
% function KDE: kernel density estimation (a.k.a Parzen window method)
% 
% Input:
%     Xtr: ntr x d matrix; ntr: # of training instance; d: dimension;
%     Xts: nts x d matrix; nts: # of testing instance; d: dimension;
%     Paras.type: kernel type: rbf, linear, poly, sigmoid or Gaussian;
%     Paras.bandwidth:  parameter bandwidth for Gaussian kernel;
%     Paras.gamma: parameter gamma for rbf, poly, or sigmoid kernel;
%     Paras.coef0: parameter coefficient for poly or sigmoid kernel;
%     Paras.degree: parameter degree for poly kernel;
% 
% Output:
%     D: estimated density;
%

% KDE based on Gaussian kernel;

KParas.type = Paras.type;
KParas.bandwidth = Paras.bandwidth;
Kmodel = ConstKernels(Xts, Xtr, KParas);

K = Kmodel.K;
D = mean(K, 2) / (Paras.bandwidth * sqrt(2 * pi));
