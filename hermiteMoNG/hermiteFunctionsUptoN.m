%% Estimate Hermite Functions upto n, usign recursion rule for fast estimate
%% generated using probabilist's Hermite polynomial

function hf = hermiteFunctionsUptoN(maxN, x)
	if maxN < 0
		error('Maximum n should be non negative');
	end
	numSamples = length(x);
	hf = zeros(maxN+1, numSamples);
	
	n = 0;
	weightFunction = @(x) exp(-x.^2/2);
	normalizingConstant = @(n) 1/sqrt(factorial(n) * sqrt(pi));
	hf(n+1, :) = normalizingConstant(n) * weightFunction(x) .*  hermeval(n, x*sqrt(2));

	n = 1;
	if maxN>0
		hf(n+1, :) = (1/sqrt(0.5*n)) * (x.*hf(n, :));
	end
	for n = 2:maxN
		hf(n+1, :) = (1/sqrt(0.5*n)) * (x.*hf(n, :) - sqrt(0.5*(n-1))*hf(n-1, :));
	end
end