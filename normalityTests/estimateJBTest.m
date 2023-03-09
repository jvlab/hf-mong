%% Jarque-Bera test

function [jbValue] = estimateJBTest(data, pValueFlag)
	% pValueFlag false (default), returns statistic
	% if true, returns [-lop(pValue)]
	
	if nargin<2
		pValueFlag = false;
	end
	if pValueFlag
	    [~, pValue] = jbtest(data, pValueFlag);
		if ~pValue
			pValue = 1;
		end
		jbValue = -log(pValue);
	else
		[~, ~, jbValue] = jbtest(data);
	end
end