%% Second derivative of sum of non-zero coefficients measure

function ddHFddy = secondDerivativeHFSum(y, nList)
	
	samples = length(y);
	continuousFlag = false;
	
	if (length(unique(diff(nList))) == 1) && (min(nList) == 0)
		continuousFlag = true;
	end
	nCount = length(nList);
	nAll = unique([(nList-2) (nList-1) nList (nList+1) (nList+2)]);
	nAll = nAll(nAll>=0);
	nAllCount = length(nAll);
	nAllMax = max(nAll);

	indexPosition = cell(nAllMax+1, 1);
	hFunction = zeros(nAllCount, samples);

	if continuousFlag
		hFunction = hermiteFunctionsUptoN(nAllMax, y);
		indexPosition = num2cell(1:nAllCount+1);
	else
		for iter = 1:nAllCount
			indexPosition{nAll(iter)+1} = iter;
			hFunction(iter, :) = hermiteFunction(nAll(iter), y);
		end	
	end
	
	ddHFddy = 0;
	for iter = 1:nCount
		n = nList(iter);
		if n == 0
			continue;
		end
		hfIdx = [indexPosition{n+1} indexPosition{n+2+1}];
		if n>1
			hfIdx = [indexPosition{n-2+1} hfIdx];
		end
		ddHFddy = ddHFddy + secondDerivativeHF(hFunction(hfIdx, :), n);
	end	
	clear y nList function
end
