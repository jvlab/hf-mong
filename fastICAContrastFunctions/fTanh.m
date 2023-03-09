%% Estimate cost correspoding to "tanh" cost function in FastICA
% Calculates the expected value of log of cosh of 1D dataset "X"
% referenced to normal distribution

function value = fTanh(X)
	value = mean(log(cosh(X))) - 3/8;
end
