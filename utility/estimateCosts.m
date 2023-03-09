%% Estimate cost base on all FastICA cost functions
% For a given standardized signal

function cost = estimateCosts(signal, HFnSet)
	cost = nan(4, 1);
	cost(1) = fPow3(signal);
	cost(2) = fTanh(signal);
	cost(3) = fGaus(signal);
	cost(4) = estimateHFPower(signal, HFnSet);
end
