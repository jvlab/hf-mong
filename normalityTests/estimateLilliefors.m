%% Lilliefors test

function [lillieforsValue] = estimateLilliefors(data, pValueFlag)
	% pValueFlag false (default), returns statistic
	% if true, returns [-lop(pValue)]
	
	if nargin<2
		pValueFlag = false;
	end

    [~, pValue, lfValue] = lillietest(data);

	if pValueFlag
		lillieforsValue = lfValue;
	else
		lillieforsValue = -log(pValue);
	end
end