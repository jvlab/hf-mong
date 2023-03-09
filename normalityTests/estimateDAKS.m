%% D'Augostino's K-squared test

function [DAKSValue] = estimateDAKS(data)

	n = length(data);
    
    g1 = moment(data, 3)/(moment(data, 2)^1.5);
    
	numerator = 6*(n-2);
    denominator = (n+1)*(n+3);
    u2g1 = numerator/denominator;
    
	numerator = 36*(n-7)*(n^2+2*n-5);
    denominator = (n-2)*(n+5)*(n+7)*(n+9);
    gamma2g1 = numerator/denominator;
    
	W = sqrt(sqrt(2*gamma2g1 + 4) - 1);
    del = 1/sqrt(log(W));
    alpha = sqrt(2/(W^2 - 1));
    Z1g1 = del * asinh(g1/(alpha*sqrt(u2g1)));
    
    g2 = (moment(data, 4)/moment(data, 2)^2)-3;
    u1g2 = -6/(n+1);
    
	numerator = 24*n*(n-2)*(n-3);
    denominator = (n+1)*(n+1)*(n+3)*(n+5);
    u2g2 = numerator/denominator;

	numerator = 6*(n^2-5*n+2);
    denominator = (n+7)*(n+9);
    p = numerator/denominator;
	numerator = 6*(n+3)*(n+5);
    denominator = n*(n-2)*(n-3);
    q = numerator/denominator;
    gamma1g2 = p*sqrt(q);
    
	p = 8/gamma1g2;
    q = 2/gamma1g2 + sqrt(1 + 4/(gamma1g2^2));
    A = 6 + p*q;
    
    p = (g2-u1g2)/sqrt(u2g2);
    q = sqrt(2/(A-4));
	numerator = 1-(2/A);
    denominator = 1+p*q;
	t = numerator/denominator;
    Z2g2 = sqrt(4.5*A)*(1 - 2/(9*A) - sign(t)*(abs(t))^(1/3));
    
    DAKSValue = Z1g1^2 + Z2g2^2;
end