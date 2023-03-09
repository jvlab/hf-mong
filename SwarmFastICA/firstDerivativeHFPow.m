%% First derivative of power of non-zero coefficients measure

function [dHFdy] = firstDerivativeHFPow(x, nList)
	% Assumes x is whitened
	samples = length(x);
	continuousFlag = false;
	if (length(unique(diff(nList))) == 1) && (min(nList) == 0)
		continuousFlag = true;
	end
	nCount = length(nList);
	nAll = unique([(nList-1) nList (nList+1)]);
	nAll = nAll(nAll>=0);
	nAllCount = length(nAll);
	nMax = max(nAll);

	indexPosition = cell(nMax+1, 1);
	hFunction = zeros(nAllCount, samples);
	
	if continuousFlag
		hFunction = hermiteFunctionsUptoN(max(nAllCount), x);
		indexPosition = num2cell(1:nAllCount);
	else
		for iter = 1:nAllCount
			indexPosition{nAll(iter)+1} = iter;
			hFunction(iter, :) = hermiteFunction(nAll(iter), x);
		end	
	end
	
	sumAdA = zeros(1, samples);
	a = zeros(nCount, 1);
	dHFdW = zeros(nCount, samples);
	for iter = 1:nCount
		n = nList(iter);
		hfIdx = [indexPosition{n+1+1}];
		if n > 0
			hfIdx = [indexPosition{n-1+1} indexPosition{n+1+1}];
		end
		a(iter) = mean(hFunction(indexPosition{n+1}, :));
		dHFdW(iter, :) = firstDerivativeHF(hFunction(hfIdx, :), n);
		sumAdA = sumAdA + a(iter)*dHFdW(iter, :);
	end

	totalPower = sum(a.^2);
	pos0 = indexPosition{0+1};

	numerator = (a(pos0) * dHFdW(pos0, :) * totalPower) ...
		- (a(pos0)^2 * sumAdA);
		
	denominator = totalPower^2;
	dHFdy = -2*numerator/denominator;
	
	clear y nList hFunction a dAdW
end
