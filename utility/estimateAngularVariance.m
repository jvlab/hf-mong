%% Estimate angular variance for the estimated directions

function av = estimateAngularVariance(actualDirections, estimatedDirections)
	directionSigns = sign(estimateDirectionalAccuracy(actualDirections, estimatedDirections));
	directionSigns(directionSigns == 0) = 1;
	estimatedDirections = estimatedDirections./vecnorm(estimatedDirections);
	squaresOfSum = mean(directionSigns .* estimatedDirections, 2, 'omitnan').^2;
	av = 1 - sqrt(sum(squaresOfSum));
end