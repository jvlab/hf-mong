%% Scaling such that mean is 1 at peak performance

function [data] = normalizePeak(data)
    data = abs(data);
	if mean(data) == 0
		error('Mean of data is 0!');
    end
    data = data/max(mean(data));
end