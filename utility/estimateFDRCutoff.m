function [pIndependent, pNonparametric] = estimateFDRCutoff(pValues, fdrLevel)
    % pt = fdr(p,q) does the false discovery rate adjustment
    % pValues - vector of p-values
    % fdrLevel - False Discovery Rate level
    %
    % pIndependent - p-value threshold based on independence or positive dependence
    % pNonparam - nonparametric p-value threshold

    pValues = sort(pValues(:))';
    numSamples = length(pValues);
    k = 1:numSamples;

    cm_independent = 1;
    pIndependent = pValues(find(pValues <= ((k*fdrLevel)./(numSamples*cm_independent)), 1, 'last'));

	cm_nonparametric = sum(1./(1:numSamples));
	pNonparametric = pValues(find(pValues <= ((k*fdrLevel)./(numSamples*cm_nonparametric)), 1, 'last'));
	
	% Adjusting for empty cutoff values
	if isempty(pIndependent)
		pIndependent = -1;
	end
	if isempty(pNonparametric)
		pNonparametric = -1;
	end
end







