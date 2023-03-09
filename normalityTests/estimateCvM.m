%% Cramer-von Mises criterion

function [cvm] = estimateCvM(data)
    
    n = length(data);
    y = sort(data);
    f = normcdf(y, mean(y), std(y));
    z = (2*(1:n)-1)./(2*n);
    cvm = 1/(12*n) + sum((z-f).^2);
end