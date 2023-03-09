%% Finding direction of maximum non-Guassianess, for 2D datasets, 
% by projection on different angles, and saving results

function masterNonGaussianity2D(pdfParameters, projectionAngles, ...
	sampleSize, numSimulations, HFnSet, saveFileName)
	% pdfParameters : struct of parameters for pdf
	% projectionAngles : angles for direction of projection to 1D 
	% sampleSize = number of samples
	% numSimulations = number of simulations 
	% HFnSet : set of Hermite Function indices for HF based methods
	% saveFileName : full file name to save results

	numAngles = length(projectionAngles);

	% FastICA cost functions
	pow3Array = zeros(numSimulations, numAngles);
	tanhArray = zeros(numSimulations, numAngles);
	gausArray = zeros(numSimulations, numAngles);
	
	% Normality tests
	DAKSArray = zeros(numSimulations, numAngles);
	JBTestArray = zeros(numSimulations, numAngles);
	ADArray = zeros(numSimulations, numAngles);
	KSArray = zeros(numSimulations, numAngles);
	SWArray = zeros(numSimulations, numAngles);

	% HF based estimate
	hfPowerArray = zeros(numSimulations, numAngles);
	
	%% Estimation
    currentPool = gcp();
    parfevalOnAll(@warning,0,'off','stats:jbtest:PTooSmall');
    parfevalOnAll(@warning,0,'off','stats:jbtest:PTooBig');
    parfevalOnAll(@warning,0,'off','stats:adtest:OutOfRangePLow');
    parfevalOnAll(@warning,0,'off','stats:adtest:OutOfRangePHigh');

    seedOffset = 0:numSimulations:numSimulations*2;
    
	for simulationIter = 1:numSimulations
		data = generateDataND(pdfParameters, sampleSize, ...
            seedOffset+simulationIter);
		    
		parfor angleIter = 1:numAngles
			anlgeTheta = projectionAngles(angleIter);
			directionVector = [cosd(anlgeTheta) sind(anlgeTheta)];
			projectedData = normalize(directionVector*data, 'zscore', 'std');
			pow3Array(simulationIter, angleIter) = ...
				fPow3(projectedData);
			tanhArray(simulationIter, angleIter) = ...
				fTanh(projectedData);
			gausArray(simulationIter, angleIter) = ...
				fGaus(projectedData);
			DAKSArray(simulationIter, angleIter) = ...
				estimateDAKS(projectedData);
			JBTestArray(simulationIter, angleIter) = ...
				estimateJBTest(projectedData);
			ADArray(simulationIter, angleIter) = ...
				estimateAD(projectedData);
			KSArray(simulationIter, angleIter) = ...
				estimateKS(projectedData);
			SWArray(simulationIter, angleIter) = ...
				estimateSW(projectedData);
			hfPowerArray(simulationIter, angleIter) = ...
				estimateHFPower(projectedData, HFnSet);
		end
		clear data directionVector projectedData;
	end
	
	delete(currentPool);
	save(saveFileName);
	
	clear pdfParameters thetaValues
	clear pow4Array logCosArray gaussArray
	clear DAKSArray JBTestArray ADArray KSArray SWArray
	clear hfPowerArray
end