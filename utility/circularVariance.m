%% Estimate circular variance with input angles in degrees

function circVar = circularVariance(angles, estimates, symmetryFolds)
    da = 0.5*(angles(1:(end-1)) + angles(2:end));
    dlim = [angles(1)+da(1) da angles(end)+da(end)];
    frequency = histcounts(estimates, dlim);
    count = sum(frequency);
    r2 = sum(frequency.*sind(symmetryFolds*angles))^2 + sum(frequency.*cosd(symmetryFolds*angles))^2;
    circVar = 1 - sqrt(r2)/count;
end