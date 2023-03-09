%% Plot mean as solid and one sem as shaded region

function [] = plotScatteredErrorBars(xValues, data, method, ...
    colorCode, alphaValue, pattern)
	
	if nargin < 3
		method = '';
	else
	% Accounting for string input
    if isstring(method)
    	method = convertStringsToChars(method);
    end
	if nargin < 4 || isempty(colorCode)
		colorCode = 'b';
	end
	if nargin < 5 || isempty(alphaValue)
		alphaValue = 0.4;
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
			bars = [];
	end
    if contains(pattern, '-')
        if ~isempty(method)
            errorbar(xValues, m, bars, 'Color', colorCode, ...
            'LineWidth', 2);
        else
            plot(xValues, m, pattern, 'Color', colorCode, ...
                'LineWidth', 2);
        end
    else
        if ~isempty(method)
            errorbar(xValues, m, bars, 'Color', [colorCode 0.3], ...
            'LineWidth', 2);
        else
            plot(xValues, m, 'Color', [colorCode 0.3], ...
                'LineWidth', 2);
        end
        scatter(xValues, m, 60, pattern, ...
            'MarkerEdgeColor', colorCode, ...
            'MarkerEdgeAlpha', alphaValue, ...
            'LineWidth', 2);
    end
end
