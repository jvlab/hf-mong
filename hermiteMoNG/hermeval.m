function yvals = hermeval(nrange,xvals,coefs)
% function yvals = hermeval(nrange,xvals,coefs)
% evaluates a Hermite polynomial at a range of values.
% Hermite polynomials are orthogonal with respect to a Gaussian of unit variance
% and are monic (leading term=1)
%
% also, does a simple asymptotic (only valid for x<<2*sqrt(n))
%
% nrange: order(s) to calculate
% xvals: arguments of the polynomials
% coefs: if supplied and not a string, the coefficients
%    as calculated by hermcoef(nrange).  No checking is done.
%         if coefs='asymp0', then a simple asymptotic formula is used
%         better asymptotics are certainly available
% yvals: resulting values
%    size(yvals,1)=nrange(2)-nrange(1)+1
%    size(yvals,2)=length(xvals)
%
%   See also HERMCOEF.
%
if (nargin<=2)
   coefs=[];
end
if (isnumeric(coefs))
    if (isempty(coefs))
        coefs=hermcoef(nrange);
    end
    yvals=zeros(size(coefs,1),length(xvals));
    for np=1:size(coefs,1)
        yvals(np,:)=polyval(fliplr(coefs(np,:)),xvals);
    end
else
    switch coefs
        case 'asymp0'
            for np=1:length(nrange)
                n=nrange(np);
                freq=sqrt(n+1);
                phase=n*pi/2;
                env=sqrt(2)*(n/exp(1))^(n/2);
                yvals(np,:)=env*cos(xvals*freq-phase).*exp(xvals.^2/4);
            end
    end
end
return
