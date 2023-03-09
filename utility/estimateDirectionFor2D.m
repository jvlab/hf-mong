%% Estimate direction for 2D analysis

function estimatedDirections = estimateDirectionFor2D(projectionAngles, estimateValues)
	[~, ngIter] = max(abs(estimateValues), [], 2);
	estimatedTheta = projectionAngles(ngIter);
	estimatedDirections = [cosd(estimatedTheta); sind(estimatedTheta)];
end