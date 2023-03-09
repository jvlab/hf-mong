%% Measuring non-Gaussianness for different measurses for 1D dataset,
% for multiple simulations of a family, and saving results

function masterNonGaussianity1D(pdfParameterValues, sampleSize, ...
	numSimulations, HFnSet, saveFileName)
	% pdfParameterValues: Array of struct of parameters for pdf
	% sampleSize: number of samples
	% numSimulation: number of simulations 
	% HFnSet: set of Hermite Function indices for HF based methods
	% saveFileName: full file name to save results

	parameterValuesCount = length(pdfParameterValues);
	
	% FastICA cost functions
	pow3Array = zeros(numSimulations, parameterValuesCount);
	tanhArray = zeros(numSimulations, parameterValuesCount);
	gausArray = zeros(numSimulations, parameterValuesCount);
	
	% Normality tests
	DAKSArray = zeros(numSimulations, parameterValuesCount);
	JBTestArray = zeros(numSimulations, parameterValuesCount);
	ADArray = zeros(numSimulations, parameterValuesCount);
	KSArray = zeros(numSimulations, parameterValuesCount);
	SWArray = zeros(numSimulations, parameterValuesCount);

	% HF based estimate
	hfPowerArray = zeros(numSimulations, parameterValuesCount);
	
	%% Estimation
    currentPool = gcp();
	parfevalOnAll(@warning,0,'off','stats:jbtest:PTooSmall');
    parfevalOnAll(@warning,0,'off','stats:jbtest:PTooBig');
    parfevalOnAll(@warning,0,'off','stats:adtest:OutOfRangePLow');
    parfevalOnAll(@warning,0,'off','stats:adtest:OutOfRangePHigh');
    
	for simulationIter = 1:numSimulations
		parfor paramIter = 1:parameterValuesCount
			
			pdfParameters = pdfParameterValues(paramIter);
			
			% Generate data and standardize it
			data = normalize( ...
				pdfParameters.generatingFunction(...
                pdfParameters, sampleSize, simulationIter), ...
				'zscore', 'std');
			
			pow3Array(simulationIter, paramIter) = ...
				fPow3(data);
			tanhArray(simulationIter, paramIter) = ...
				fTanh(data);
			gausArray(simulationIter, paramIter) = ...
				fGaus(data);
			DAKSArray(simulationIter, paramIter) = ...
				estimateDAKS(data);
			JBTestArray(simulationIter, paramIter) = ...
				estimateJBTest(data);
			ADArray(simulationIter, paramIter) = ...
				estimateAD(data);
			KSArray(simulationIter, paramIter) = ...
				estimateKS(data);
			SWArray(simulationIter, paramIter) = ...
				estimateSW(data);
			hfPowerArray(simulationIter, paramIter) = ...
				estimateHFPower(data, HFnSet);
		end
		clear data
	end
	
	delete(currentPool);
	clear pdfParameters
	save(saveFileName);
	
	clear pdfParameterValues
	clear pow4Array logCosArray gaussArray
	clear DAKSArray JBTestArray ADArray KSArray SWArray
	clear hfPowerArray
end