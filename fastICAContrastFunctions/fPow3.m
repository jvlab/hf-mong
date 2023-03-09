%% Estimate cost correspoding to "pow4" cost function in FastICA
% Calculates the 4th order moment of 1D dataset "X"
% normalized by 4, and referenced to standard normal distribution 

function value = fPow3(X)
	value = mean(X.^4)/4 - 0.75;
end
