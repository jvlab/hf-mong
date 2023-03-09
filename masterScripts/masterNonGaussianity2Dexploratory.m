%% Finding direction of maximum non-Guassianess, for 2D datasets, 
% by projection on different angles, and saving results

function masterNonGaussianity2Dexploratory(pdfParameters, projectionAngles, ...
	sampleSize, numSimulations, HFnSet, saveFileName)
	% pdfParameters : struct of parameters for pdf
	% projectionAngles : angles for direction of projection to 1D 
	% sampleSize = number of samples
	% numSimulations = number of simulations 
	% HFnSet : set of Hermite Function indices for HF based methods
	% saveFileName : full file name to save results

	thetaCount = length(projectionAngles);

	% HF based estimate
	hfPowerArray = zeros(numSimulations, thetaCount);
	
	%% Estimation
    seedOffset = 0:numSimulations:numSimulations*2;
    currentPool = gcp();
    
	for simulationIter = 1:numSimulations
		data = generateDataND(pdfParameters, sampleSize, ...
            seedOffset+simulationIter);

		parfor thetaIter = 1:thetaCount
			theta = projectionAngles(thetaIter);
			directionVector = [cosd(theta) sind(theta)];
			projectedData = normalize(directionVector*data, 'zscore', 'std');
			hfPowerArray(simulationIter, thetaIter) = ...
				estimateHFPower(projectedData, HFnSet);
		end
		clear data directionVector projectedData;
	end
	
	delete(currentPool);
	save(saveFileName);
	
	clear pdfParameters thetaValues
	clear hfPowerArray 
end