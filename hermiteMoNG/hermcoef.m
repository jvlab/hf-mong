function coefs = hermcoef(nrange)
%
% function coefs = hermcoef(nrange)
% calculates coefficients of Hermite polynomials
% Hermite polynomials are orthogonal with respect to a Gaussian of unit variance
% and are monic (leading term=1)
%
% seems numerically stable up to at least max(nrange)=50
%
% nrange: order(s) to calculate
% coefs: array of coefficients, one polynomial per row
%    constant term is in the first column
%
% the first polynomial coefficient is calculated non-recursively; subsequent coeffs
% are calculated recursively
%
%   See also HERMEVAL.
%
nlo=min(nrange);
nhi=max(nrange);
%
allcoefs=zeros(nhi-nlo+1,nhi+1);
%non-recursive part
k=[0:floor(nlo/2)];
cnz=gamma(1+nlo)./((-2).^k)./gamma(1+k)./gamma(1+nlo-2*k);
inz=1+[mod(nlo,2):2:nlo];
allcoefs(1,inz)=round(fliplr(cnz));
%recursive part
for n=(nlo+1):nhi
    allcoefs(n-nlo+1,[2:nhi+1])=allcoefs(n-nlo,[1:nhi]);
    allcoefs(n-nlo+1,[1:nhi])=round(allcoefs(n-nlo+1,[1:nhi])-[1:nhi].*allcoefs(n-nlo,[2:nhi+1]));
end
% coefs=zeros(length(nrange),nhi+1);
coefs=allcoefs(nrange-nlo+1,:);
end
