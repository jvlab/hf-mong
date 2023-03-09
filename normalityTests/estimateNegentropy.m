%% Estimation of negentropy using binning

function [negEntropy] = estimateNegentropy(data, binEdges)
	% Negentopy estimated by proving standardized data,
	% with uniform or non-uniform binning (adaptive), with bin edges
	
    t = 0.5*(1+log(2*pi));
    p = histcounts(data, binEdges, 'Normalization', 'probability');
	dx = diff(binEdges);
	if length(dx) > 1
		dx = dx(p>0);
	end
    p = p(p>0);
    y = p.*log(p);
    negEntropy = t + sum(y.*dx);
    if abs(negEntropy) < 1e-12
        negEntropy = 0;
    end
end
