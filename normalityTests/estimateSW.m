%% Shapiro Wilk statistic

function swValue = estimateSW(data)
	
    data = sort(data);
    n = length(data);
    a = [];
    i = 1:n;
    mi = norminv((i-0.375)/(n+0.25));
    u = 1/sqrt(n);
    m = mi.^2;
    
    polyCoef_1  =  [-2.706056 , 4.434685 , -2.071190 , -0.147981 , 0.221157 , mi(n)/sqrt(sum(m))];
    polyCoef_2  =  [-3.582633 , 5.682633 , -1.752461 , -0.293762 , 0.042981 , mi(n-1)/sqrt(sum(m))];
    a(n) = polyval(polyCoef_1, u);
    a(1) = -a(n);
    a(n-1) = polyval(polyCoef_2, u);
    a(2) = -a(n-1);
    eps = (sum(m)-2*(mi(n)^2)-2*(mi(n-1)^2))/(1-2*(a(n)^2)-2*(a(n-1)^2));
    a(3:n-2) = mi(3:n-2)./sqrt(eps);
    
    ax = a.*data;
    KT = sum((data-mean(data)).^2);
    b = sum(ax)^2;
    swValue = 1-b/KT;
end