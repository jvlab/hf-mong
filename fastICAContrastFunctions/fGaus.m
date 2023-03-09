%% Estimate cost correspoding to "gaus" cost function in FastICA
% Calculates the expected value of gaussian of 1D dataset "X"
% Referenced to standard normal distribution

function value = fGaus(X)
	value = -mean(exp(-X.^2/2)) + 1/sqrt(2);
end
