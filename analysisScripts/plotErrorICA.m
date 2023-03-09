%% Parameters for distribution

if ~exist('filePath', 'var')
    filePath = uigetdir(cd, 'Select folder containing results');
    disp(strcat("Selected ", filePath));
end

fileNames = dir(strcat(filePath, '/*_performance.mat'));
if ~iscell(fileNames), fileNames = {fileNames};
else, fileNames = {fileNames.name}; end

contrastFunctions = {'FastICA-I'; 'FastICA-II'; 'FastICA-III'; 'J_{15}'};
numContrastFn = length(contrastFunctions);
contrastMarkers = {'o'; '^'; 's'; 'd'};

loadColors;
contrastColors = {dg; dr; db; bk};
markerSize = 125;
markerFaceOpacity = 0.6;

%% Run agnostic parameters
figF = figure('units','normalized','outerposition',[0 0 1 1]);
sgtitle(strcat("Results for ", strrep(distName, "_", " ")), ...
    'FontSize', 20, 'FontWeight', 'bold');

numSampleSizes = length(sampleSizeArray);
sq = sqrt(numSampleSizes);
if floor(sq) == sq
    numRows = sq;
    numColumns = sq;
else
    numRows = floor(sq);
    numColumns = ceil(sq);
end

for sampleSizeIter = 1:numSampleSizes
    sampleSize = sampleSizeArray(sampleSizeIter);
    subplot(numRows, numColumns, sampleSizeIter);
    title(strcat('N=', num2str(sampleSize)));
    hold on;
    for datasetID = 1:numDatasets
        fileName = strcat(distPath, '/', distName, ...
            '_N', num2str(sampleSize), ...
            '_HF', num2str(max(HFnSet)), ...
            '_RS', num2str(numRandomStarts), ...
            '_D', num2str(datasetID), '_performance.mat');
        disp(fileName);
        load(fileName, 'negAccuracyComplex');
        negAccuracyComplex = mean(negAccuracyComplex, 1);
        % abcissa
        xValues = [1:numContrastFn] + 0.02*(datasetID-0.5*numDatasets-1);
        for costIter = 1:numContrastFn
            %% Error in accuracy plot
            scatter(xValues(costIter), negAccuracyComplex(costIter), ...
                markerSize, contrastColors{costIter}, ...
                'filled', contrastMarkers{costIter}, ...
                'MarkerFaceAlpha', markerFaceOpacity);
            set(gca, 'YScale', 'log');
            ylabel('Error');
            set(gca, 'YMinorTick', 'on');
            set(gca, 'TickLength', 0.03*[1 1]);
            xlabel('Contrast Function maximized');
            xticks(1:numContrastFn);
            xlim([0.4 numContrastFn+0.6]);
            xticklabels(contrastFunctions);
            xtickangle(45);
            set(gca, 'lineWidth', 2);
            set(gca, 'FontSize', 16);
            set(gca, 'FontWeight', 'bold');
            axis square;
        end

        plot(xValues, negAccuracyComplex, ...
            'color', contrastColors{costIter});
        legend(contrastFunctions, 'Location', 'northoutside');
    end
    clear negAccuracyComplex
end


