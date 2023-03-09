%% Generate generalized normal data with given power beta

function [data] = generateDataGeneralizedNormal(pdfParameters, sampleSize, seed)
	if ~isfield(pdfParameters, 'beta')
		error('Define shape parameter of the distribution as scalar field beta');
	end
	
	% Define constants
    c1 = pdfParameters.beta/(2^(1+1/pdfParameters.beta)*gamma(1/pdfParameters.beta));
    c2 = 0.5;
    
	% Define probability distribution function
    f = @(x) c1*exp(-c2*abs(x.^pdfParameters.beta));
	
	% Generate data, implemented so since slicesample is prone to crashes
    % The do-while loop like implementation tries till it has generated dataset
    % Rarely needs more than 2 attempts. If program gets stuck here, it means
    % param values provided are incompatible with the distribution function.
    
    % Seed for reproducibility
    if nargin==3 & ~isempty(seed)
        rng(seed);
    end

    % Generate data
    dataFlag = false;
	while ~dataFlag
		try
            data = slicesample(0, sampleSize, 'pdf', f);
            dataFlag = true;
        catch
            disp('Failed to generate data.');
		end
	end
	data = data';
end
