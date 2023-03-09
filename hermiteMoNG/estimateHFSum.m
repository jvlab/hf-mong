%% Estimate sum of coefficients of all but the zeroth Hermtie Function in
%% Hermite Function expansion of data with functions of order fIndices

function [HFSum, coeffs] = estimateHFSum(data, HFnSet)
	HFnSet = sort(HFnSet);
	if HFnSet(1) == 0
		HFnSet = HFnSet(2:end);
    end
    coeffs = zeros(1, max(HFnSet)+1);
    for i = 1:length(HFnSet)
		idx = HFnSet(i);
        h = hermiteFunction(idx, data);
        coeffs(idx+1) = mean(h);
    end
	HFSum = sum(coeffs);
    if abs(HFSum) < 1e-12
        HFSum = 0;
    end
end
