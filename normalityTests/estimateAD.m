%% Anderson Darling test

function [adValue] = estimateAD(data, pValueFlag)
	% pValue Flag false (default), returns statistic
	% if true, returns [-lop(pValue)]
	
	if nargin<2
		pValueFlag = false;
	end
	if pValueFlag
		[~, pValue] = adtest(data);
		if ~pValue
			pValue = 1;
		end
	    adValue = -log(pValue);
	else
		[~, ~, adValue] = adtest(data);
	end
end