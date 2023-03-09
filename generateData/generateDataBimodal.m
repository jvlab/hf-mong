%% Generate bimodal distribution by adding to Gaussian

function [data] = generateDataBimodal(pdfParameters, sampleSize, seed)
    % Check if values are assigned 
	if ~isfield(pdfParameters, 'mu') || length(pdfParameters.mu) ~= 2
        error('Define centers of both Gaussian defined as 2D vector field mu'); 
	end
	
	if ~isfield(pdfParameters, 'sigma') || length(pdfParameters.sigma) ~= 2
        error('Define std of both Gaussian defined as 2D vector field sigma');
	end
	
	if ~isfield(pdfParameters, 'alpha') || (pdfParameters.alpha < 0 || pdfParameters.alpha > 1)
        error('Define mixing fraction alpha for first Gaussian as scalar field alpha (0<alpha<1)'); 
	end
	
    % Define probability distribution function 
    f = @(x) pdfParameters.alpha*normpdf(x, pdfParameters.mu(1), pdfParameters.sigma(1)) + ...
        (1-pdfParameters.alpha)*normpdf(x, pdfParameters.mu(2), pdfParameters.sigma(2));
    
    % Seed for reproducibility
    if nargin==3 & ~isempty(seed)
        rng(seed);
    end
	% Generate data
    data = slicesample(1, sampleSize, 'pdf', f);
	data = data';
end