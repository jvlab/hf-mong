%% Whiten data to have 0 mean, identity covariance matrix

function [whitenedData, V] = whitenData(data)
 	centeredData = normalize(data, 2, 'zscore', 'std');
	Cx = cov(centeredData');
    [E, D] = eig(Cx);
    V = E*sqrt(inv(D))*E';
    whitenedData = V*centeredData;
end