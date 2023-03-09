%% Second derivative of power of non-zero coefficients measure

function ddHFddy = secondDerivativeHFPow(y, nList)
	
	[dim, samples] = size(y);
	continuousFlag = false;
	
	if (length(unique(diff(nList))) == 1) && (min(nList) == 0)
		continuousFlag = true;
	end
	nCount = length(nList);
	nAll = unique([(nList-2) (nList-1) nList (nList+1) (nList+2)]);
	nAll = nAll(nAll>=0);
	nAllCount = length(nAll);
	nMax = max(nAll);

	indexPosition = cell(nMax+1, 1);
	hFunction = zeros(nAllCount, samples);

	if continuousFlag
		hFunction = hermiteFunctionsUptoN(max(nAllCount), y);
		indexPosition = num2cell(1:nAllCount+1);
	else
		for iter = 1:nAllCount
			indexPosition{nAll(iter)+1} = iter;
			hFunction(iter, :) = hermiteFunction(nAll(iter), y);
		end	
	end
	
	a = zeros(nCount, 1);
	dHFdW = zeros(nCount, samples);
	ddHFddW = zeros(nCount, samples);
	for iter = 1:nCount
		n = nList(iter);
		hfIdx1 = [indexPosition{n+1+1}];
		hfIdx2 = [indexPosition{n+1} indexPosition{n+2+1}];
		if n>0
			hfIdx1 = [indexPosition{n-1+1} indexPosition{n+1+1}];
		end
		if n>1
			hfIdx2 = [indexPosition{n-2+1} indexPosition{n+1} indexPosition{n+2+1}];
		end
		a(iter) = mean(hFunction(indexPosition{n+1}, :));
		dHFdW(iter, :) = firstDerivativeHF(hFunction(hfIdx1, :), n);
		ddHFddW(iter, :) = secondDerivativeHF(hFunction(hfIdx2, :), n);
	end
	
	totalPower = sum(a.^2);
	pos0 = indexPosition{0+1};
		
	numerator = - (2 * a(pos0) * ddHFddW(pos0, :) * totalPower^2) ...
		- (2 * dHFdW(pos0, :).^2 * totalPower^2) ...
		+ (8 * a(pos0) * dHFdW(pos0, :) .* sum(a.*dHFdW) * totalPower) ...
		+ (2 * a(pos0)^2 * sum(a.*ddHFddW) * totalPower) ...
		+ (2 * a(pos0)^2 * sum(dHFdW.^2) * totalPower) ...
		- (8 * a(pos0)^2 * sum(a .* dHFdW).^2) ;

	denominator = totalPower^3;
	ddHFddy = numerator/denominator;
	
	clear y nList hFunction dHFdW ddHFddW
end
