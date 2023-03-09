%% Estimate directional accuracy given actual and estimated directions

function accuracy = estimateDirectionalAccuracy(actualDirections, estimatedDirections)
	actualDirections = actualDirections./vecnorm(actualDirections);
	estimatedDirections = estimatedDirections./vecnorm(estimatedDirections);
	if size(actualDirections, 2) == 1
		accuracy = actualDirections' * estimatedDirections;
	else
		accuracy = sum(actualDirections .* estimatedDirections);
	end
end