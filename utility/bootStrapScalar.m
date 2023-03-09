%% Bootstrap f(x) --> 1 functions, where x is multidimenstional
%% last dimension of input "data" is the number of sample data points 

function bootStat = bootStrapScalar(numBootStraps, sampleSize, bootfun, data)
	dimCount = ndims(data);
	dataCount = size(data, dimCount);
	bootStat = zeros(1, numBootStraps);
	for bsIter = 1:numBootStraps
		selectionIndices = randi(dataCount, 1, sampleSize);
		S.subs = repmat({':'}, 1, dimCount);
		S.type = '()';
		S.subs{dimCount} = sort(selectionIndices);
		bootStat(bsIter) = bootfun(subsref(data, S));
	end
end