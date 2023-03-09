%% First derivative of sum of non-zero coefficients measure

function [dHFdy] = firstDerivativeHFSum(x, nList)

	samples = length(x);
	continuousFlag = false;
	
	if (length(unique(diff(nList))) == 1) && (min(nList) == 0)
		continuousFlag = true;
	end
	nCount = length(nList);
	nAll = unique([(nList-1) nList (nList+1)]);
	nAll = nAll(nAll>=0);
	nAllCount = length(nAll);
	nAllMax = max(nAll);

	indexPosition = cell(nAllMax+1, 1);
	hFunction = zeros(nAllCount, samples);
	
	if continuousFlag
		hFunction = hermiteFunctionsUptoN(nAllMax, x);
		indexPosition = num2cell(1:nAllCount);
	else
		for iter = 1:nAllCount
			indexPosition{nAll(iter)+1} = iter;
			hFunction(iter, :) = hermiteFunction(nAll(iter), x);
		end	
	end
	dHFdy = zeros(1, samples);
	for iter = 1:nCount
		n = nList(iter);
		if n == 0
			continue;
		end
		hfIdx = [indexPosition{n-1+1} indexPosition{n+1+1}];
		dHFdy = dHFdy + firstDerivativeHF(hFunction(hfIdx, :), n);
	end
	clear y nList hFunction
end
