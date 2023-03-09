%% Estimate fraction of power in all but the zeroth Hermtie Function in
%% Hermite Function expansion of data with functions of order fIndices

function [hfPower, coeffs] = estimateHFPower(data, HFnSet)
	HFnSet = sort(HFnSet);
    coeffs = zeros(1, HFnSet(end)+1);
	if HFnSet(1)~=0
		HFnSet = [0 HFnSet];
	end
	for i = 1:length(HFnSet)
		idx = HFnSet(i);
        h = hermiteFunction(idx, data);
        coeffs(idx+1) = mean(h);
	end
	numerator = coeffs(1)^2;
    denominator = sum(coeffs.^2);
    hfPower = abs(1 - (numerator/denominator));
    if hfPower < 1e-12
        hfPower = 0;
    end
end
