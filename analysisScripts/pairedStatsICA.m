%% Selecting file

fileNames = dir(strcat(filePath, '/*_performance.mat'));
if ~iscell(fileNames), fileNames = {fileNames};
else, fileNames = {fileNames.name}; end

%% Parameters for distribution

contrastMarkers = {'o'; '^'; 's'; 'v'};
loadColors;
contrastColors = {dg; dr; db; bk};
markerFaceOpacity = 0.8;

compList = {'FastICA-I'; 'FastICA-II'; 'FastICA-III'; 'Best of FastICA'};
numContrastFn = 4;

%% Run agnostic parameters

resultArray = cell(numSampleSizes, 7, numContrastFn);
effectsArray = zeros(numSampleSizes, numContrastFn);
ratioArray = zeros(numSampleSizes, numContrastFn);

negAccuraySelected = nan(numSignals, numContrastFn+1, ...
    numSampleSizes, numDatasets);

for sampleSizeIter = 1:numSampleSizes
    sampleSize = sampleSizeArray(sampleSizeIter);
    for datasetID = 1:numDatasets
        fileName = strcat(distPath, '/', distName, ...
            '_N', num2str(sampleSize), ...
            '_HF', num2str(max(HFnSet)), ...
            '_RS', num2str(numRandomStarts), ...
            '_D', num2str(datasetID), '_performance.mat');
        load(fileName, 'negAccuracyComplex');
        negAccuraySelected(:, 1:(numContrastFn-1), sampleSizeIter, ...
            datasetID) = negAccuracyComplex(:, 1:(numContrastFn-1));
        negAccuraySelected(:, numContrastFn, sampleSizeIter, datasetID) = ...
            min(negAccuracyComplex(:, 1:(numContrastFn-1)), [], 2);
        negAccuraySelected(:, numContrastFn+1, sampleSizeIter, ...
            datasetID) = negAccuracyComplex(:, numContrastFn);
    end
    clear negAccuracyComplex
end
for sampleSizeIter = 1:numSampleSizes
    cf2 = log10(negAccuraySelected(:, numContrastFn+1, sampleSizeIter, :));
    for cfIter = 1:numContrastFn
        cf1 = log10(negAccuraySelected(:, cfIter, sampleSizeIter, :));
        [~, p, ~, stats] = ttest(cf1(:), cf2(:));
        resultArray{sampleSizeIter, 1, cfIter} = sampleSize;
        resultArray{sampleSizeIter, 2, cfIter} = stats.df;
        resultArray{sampleSizeIter, 3, cfIter} = stats.sd;
        resultArray{sampleSizeIter, 4, cfIter} = mean(cf1(:)) - mean(cf2(:));
        resultArray{sampleSizeIter, 5, cfIter} = stats.tstat;
        resultArray{sampleSizeIter, 6, cfIter} = p;
        effectsArray(sampleSizeIter, cfIter) = mean(cf1(:)) - mean(cf2(:));
        ratioArray(sampleSizeIter, cfIter) = mean(cf2(:))/mean(cf1(:));
    end
end

%% Plotting
figure('units','normalized','outerposition',[0 0 1 1]);

plot(sampleSizeArray, ones(1, numSampleSizes), ...
    'Color', gr*1.5, 'LineWidth', 1);
hold on;
for cfIter = 1:numContrastFn
    plot(sampleSizeArray, ratioArray(:, cfIter), ...
        'Color', contrastColors{cfIter}, ...
        'LineWidth', 2);
    scatter(sampleSizeArray, ...
        ratioArray(:, cfIter), ...
        125, 'Marker', contrastMarkers{cfIter}, ...
        'MarkerEdgeColor', contrastColors{cfIter}, ...
        'MarkerFaceColor', contrastColors{cfIter}, ...
        'MarkerEdgeAlpha', markerFaceOpacity, ...
        'MarkerFaceAlpha', markerFaceOpacity);
end
set(gca, 'XScale', 'log');
set(gca, 'YScale', 'log');
xlim([min(1000, min(sampleSizeArray)), ...
    max(100000, max(sampleSizeArray))]);
xticks(sampleSizeArray);
ylim([0.5 5]);
yticks(0.5:0.5:5);
yticklabels({'0.5', '1', '', '2', '', '3', '', '4', '', '5'});
axis square;
set(gca, 'FontSize', 16);
set(gca, 'FontWeight', 'bold');
set(gca, 'LineWidth', 2);
set(gca, 'TickLength', 0.03*[1 1]);
xlabel('Sample Size');
ylabel({'Error ratio'}, 'FontSize', 16);
set(gca, 'XMinorTick', 'off');
set(gca, 'YMinorTick', 'on');
ax = gca;
ax.YAxis.MinorTickValues = 0.5:0.1:5;
