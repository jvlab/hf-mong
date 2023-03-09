%% Kolmogorov Smirnoff test

function [ksValue] = estimateKS(data, pValueFlag)
	% pValueFlag false (default), returns statistic
	% if true, returns [-lop(pValue)]
	
	if nargin<2
		pValueFlag = false;
	end

    [~, pValue, stat] = kstest(data);
	
	if pValueFlag
		ksValue = -log(pValue);
	else
		ksValue = stat;
	end
end