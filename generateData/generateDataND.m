%% Generating N dimensional datasets with independent distributions

function [data] = generateDataND(pdfParameters, sampleSize, seeds)
	dimCount = length(pdfParameters);
	data = zeros(dimCount, sampleSize);
	for i = 1:dimCount
		params = pdfParameters{i};
        if ~isfield(params, 'generatingFunction')
			error(cat(2, 'Define generating funtion for dimension ', num2str(i)));
        end
        if nargin==3 & ~isempty(seeds) %% seeds defined
    		data(i, :) = params.generatingFunction(params, sampleSize, seeds(i));
        else
            data(i, :) = params.generatingFunction(params, sampleSize);
        end
	end
end