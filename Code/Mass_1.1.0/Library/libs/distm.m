function n2 = distm(x, c, M)
%   Calculates mahalanobis distance between two sets of points.
%
%   x: N1 by D matrix, samples in rows
%   c: N2 by D matrix, samples in rows
%   M: D by D matrix
%   n2(i,j) = (x(i,:) - c(j,:))*M*(x(i,:) - c(j,:))';
%

[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);
dimm = size(M,1);
if dimx ~= dimc || dimx ~= dimm,
    error('Data dimension does not match dimension of centres');
end

term1 = sum((x*M).*x,2)*ones(1, ncentres); % diag(x*M*x') = sum((x*M).*x,2)
term2 = -(c*M*x')'; % = -x*M'*c'
term3 = -x*M*c';
term4 = ones(ndata,1)*(sum((c*M).*c,2))';
n2 = term1 + term2 + term3 + term4;

% Rounding errors occasionally cause negative entries in n2
if any(any(n2<0))
  n2(n2<0) = 0;
end
%n2 = sqrt(n2);
