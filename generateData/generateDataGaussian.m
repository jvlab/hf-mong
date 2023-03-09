 %% Generate Gaussian data with given distribution parameters

function [data] = generateDataGaussian(pdfParameters, sampleSize, seed)
	% pdfParameters has mu and sigma fields for mean and std respectively
    
    % Seed for reproducibility
    if nargin==3 & ~isempty(seed)
        rng(seed);
    end
    
    % Check if values are assigned 
	if ~isfield(pdfParameters, 'mu') || length(pdfParameters.mu) > 1
        error('Define mean of distribution as scalar field mu'); 
	end
	
	if ~isfield(pdfParameters, 'sigma') || length(pdfParameters.sigma) > 1
        error('Define std of distribution as scalar field sigma');
	end
    
    % Generate data
	data = random('Normal', pdfParameters.mu, pdfParameters.sigma, 1, sampleSize);
end