%% Case specific parameters

if ~exist('filePath', 'var') || ~exist('fileName', 'var')
    [fileNames, filePath] = uigetfile('*_curated.mat', ...
        'Select curated file(s) to plot', 'MultiSelect', 'on');
    if ~iscell(fileNames)
        fileNames = {fileNames};
    end
else
    fileNames = {fileName};
end

%% Case agnostic parameters

loadColors;

method = '';
alphaValue = 0.6;

colorList = {dr; dg; db; bk; lr; lg; lb; gr};

if ~exist('legendStrings', 'var') || ~exist('legendIndices', 'var')
    legendStrings = {};
    legendIndices = [];
end

warning('off', 'MATLAB:legend:IgnoringExtraEntries');

%% Plots
hold on;
for file = fileNames
    fileName = file{1};
    data = load(strcat(filePath, '/', fileName));
    disp(strcat("Selected ", filePath, '/', fileName));
    scatterFlag = true;
    if contains(fileName, 'all')
        pattern = '-';
        scatterFlag = false;
    elseif contains(fileName, 'even')
        pattern = 'x';
    else % odd
        pattern = 'o';
    end

    HFnSetX = data.HFnMaxList + 0.3*(log10(data.sampleSizeArray')-2.5);
    for sampleSizeIter = 1:data.numSampleSizes
        plotScatteredErrorBars(HFnSetX(sampleSizeIter, :), ...
            data.HFnPowerAV(:, :, sampleSizeIter), method, ...
            colorList{sampleSizeIter}, alphaValue, pattern);
        legendIndices(end+1) = length(get(gca, 'Children'));    
        legendStrings{end+1} = strcat(num2str( ...
                    data.sampleSizeArray(sampleSizeIter)), ...
                    " ", data.HFnCaseName);
    end
end

%% Axis properties
axis square;
set(gca, 'YScale', 'log');
ylabel('Circular Variance');
ylim([5e-7 5e-1]);
% yticks([1e-6 1e-5 1e-4 1e-3 1e-2]);
xlabel('Max order n of H_n');
xlim([1 50]);
xticks([1 10:10:50]);
title({'Effect of set of Hermite functions on circular variance', ''});
set(gca, 'lineWidth', 1.5);
set(gca, 'Fontsize', 16);
set(gca, 'FontWeight', 'bold');

names = get(gca, 'Children');
fpnames = flip(names);
numPlots = size(names, 1);
numSampleSize = length(data.sampleSizeArray);
lgd = legend(fpnames(legendIndices), legendStrings, ...
    'Location', 'best', 'Units', 'normalized', ...
    'numColumns', 3);

clear data;
