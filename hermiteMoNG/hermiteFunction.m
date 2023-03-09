%% Estimate Hermite Function generated using probabilist's Hermite polynomial

function [y] = hermiteFunction(n, x)
	% Hermite function of order n at x 
    weightFunction = @(x) exp(-x.^2/2);
    normalizingConstant = @(n) 1/sqrt(factorial(n) * sqrt(pi));
    y = normalizingConstant(n) * weightFunction(x) .* hermeval(n, x*sqrt(2));
end
