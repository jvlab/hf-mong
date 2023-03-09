%% Generates unimodal asymmetric data based on 
%% generalized extreme value distribution
%% with given distribution parameters

function [data] = generateDataGeneralizedExtremeValue(...
    pdfParameters, sampleSize, seed)
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
	
    if ~isfield(pdfParameters, 'kappa') || length(pdfParameters.kappa) > 1
        error('Define shape parameter of the distribution as scalar field kappa'); 
    end
    
    % Generate data
    data = random('Generalized Extreme Value', ...
		pdfParameters.kappa, pdfParameters.sigma, pdfParameters.mu, ...
		1, sampleSize);
end