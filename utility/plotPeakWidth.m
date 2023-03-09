function plotPeakWidth(data, xValues, y, colorValues)

	data = normalize(data, 2, 'range');
	m = mean(data);
    sd2 = 2*std(data);
	[~, peakIdx] = max(m);
    peakLower = m(peakIdx) - sd2(peakIdx);
    upperBoundary = m + sd2;
	
	centerX = data(peakIdx);
	indices = find((upperBoundary > peakLower) | (abs(peakLower-upperBoundary)<1e-6));
    
	errorbar(centerX, y, xValues(indices(1)), ...
		xValues(indices(end)), 'horizontal', ...
		'color', colorValues, 'LineWidth', 2);
end
