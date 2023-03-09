%% Plot mean as solid and one sem as shaded region

function [] = plotContinuousErrorBars(xValues, data, method, ...
    colorCode, alphaValue, pattern)
	
    if nargin < 3 || isempty(method)
		method = '2sem';
	end
	% Accounting for string input
	method = convertStringsToChars(method);
	if nargin < 4 || isempty(colorCode)
		colorCode = 'b';
	end
	if nargin < 5 || isempty(alphaValue)
		alphaValue = 0.3;
	end
	if nargin < 6 || isempty(pattern)
		pattern = '-';
	end
	m = mean(data);
	n = length(data);
	switch method
		case 'sem'
			bars = std(data)/sqrt(n);
		case '2sem'
			bars = 2*std(data)/sqrt(n);
		case 'std'
			bars = std(data);
		case '2std'
			bars = 2*std(data);
		otherwise
			error("Method should be sem, 2sem, std, or 2std");
	end
    hold on;
    plot(xValues, m, 'Color', colorCode, 'LineWidth', 3, 'LineStyle', pattern);
    fill([xValues flip(xValues)], [m-bars flip(m+bars)], colorCode, ...
        'LineStyle', 'none');
    alpha(alphaValue);
end
