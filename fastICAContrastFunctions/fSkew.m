%% Estimate cost correspoding to "skew" cost function in FastICA
% Calculates the 3rd order moment of 1D dataset "X"

function value = fSkew(X)
	value = mean(X.^3);
end
