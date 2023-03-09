%% Case specific parameters

if ~exist('filePath', 'var')
    filePath = uigetdir(cd, 'Select folder containing results');
    disp(strcat("Selected ", filePath));
end
fileNames = dir(strcat(filePath, '/*.mat'));

if ~exist('numSignals', 'var')
    numSignals = input('Number of signals to select (1 or 2) : ');
end

autoFlag = true;
redoFlag = false;
         
if numSignals>1
    manualFlagInput = input( ...
        'Do you want to manually select components? (y/N) : ', 's');
    if strcmpi(manualFlagInput, 'y')
        fileSelection = input('Do you wish to select files? (y/N) : ', 's');
        if strcmp(fileSelection, 'y')
            fileNames = uigetfile(strcat(filePath, '/*.mat*'), 'Select files to process', ...
                'MultiSelect', 'on');
        end
        autoFlag = false;
        redoFlagInput = input( ...
            'Do you want to reselect components for processed files? (y/N) : ', 's');
        if strcmpi(redoFlagInput, 'y'), redoFlag = true; end
    end
end

if isstring(fileNames)
    fileNames = {fileNames};
else
    fileNames(contains({fileNames.name},{'_performance.mat'})) = [];
    fileNames = {fileNames.name};
end

%% Estimation
numContrastFn = 4;
figure('Units', 'normalized', 'OuterPosition', [0 0 1 1]);

for fileIter = 1:numel(fileNames)

    [~, fileName] = fileparts(fileNames{fileIter});
    fullFileName = strcat(filePath, '/', fileName);
    saveFileName = strcat(fullFileName, '_performance.mat');
    if exist(saveFileName, 'file')
        if ~redoFlag, continue; end
    end
    
    dataset = load(fullFileName);
    disp(strcat("Working on ", filePath, '/', fileName));
    sampleSize = size(dataset.data, 2);
    
    fileBits = split(fileName, {'_', '.'});
    datasetBit = fileBits{end-1};
    datasetID = str2double(datasetBit(2:end));

    if isfield(dataset, 'eyeBlinkUnmixingDirection')
        actualDirections = dataset.eyeBlinkUnmixingDirection;
    else
        actualDirections = zeros(1, size(dataset.pow3UnmixingMatrix, 2));
        actualDirections(1) = 1;
    end

    bestCostSimple = nan(numSignals, numContrastFn, numContrastFn, numContrastFn);
    negAccuracySimple = nan(numSignals, numContrastFn, numContrastFn);
    componentIndices = nan(max(1, numSignals), numContrastFn, numContrastFn);
    
    %% Accuracy
    [bestCostSimple(:, :, :, 1), negAccuracySimple(:, :, 1), ...
        componentIndices(:, :, 1)] = ...
        selectComp(dataset.pow3Cost(:, 1:numContrastFn), ...
        dataset.pow3UnmixingMatrix, actualDirections, ...
        dataset.data, 1, autoFlag);

    [bestCostSimple(:, :, :, 2), negAccuracySimple(:, :, 2), ...
        componentIndices(:, :, 2)] = ...
        selectComp(dataset.tanhCost(:, 1:numContrastFn), ...
        dataset.tanhUnmixingMatrix, actualDirections, ...
        dataset.data, 2, autoFlag);

    [bestCostSimple(:, :, :, 3), negAccuracySimple(:, :, 3), ...
        componentIndices(:, :, 3)] = ...
        selectComp(dataset.gausCost(:, 1:numContrastFn), ...
        dataset.gausUnmixingMatrix, actualDirections, ...
        dataset.data, 3, autoFlag);

    [bestCostSimple(:, :, :, 4), negAccuracySimple(:, :, 4), ...
        componentIndices(:, :, 4)] = ...
        selectComp(dataset.hfPowLinCost(:, 1:numContrastFn), ...
        dataset.hfPowLinUnmixingMatrix, actualDirections, ...
        dataset.data, 4, autoFlag);
    
    negAccuracyComplex = nan(numSignals, numContrastFn);
    bestCostAcrossCF = nan(numSignals, numContrastFn, numContrastFn);
    bestCostComplex = nan(numSignals, numContrastFn, numContrastFn);
    optimumIdx = nan(numContrastFn);
    
    for costIter = 1:numContrastFn
        [~, optimumIdx(costIter)] = max( ...
            mean(bestCostSimple(:, costIter, costIter, :), 1));
        bestCostAcrossCF(:, :, costIter) = ...
            bestCostSimple(:, :, costIter, ...
            optimumIdx(costIter));
        negAccuracyComplex(:, costIter) = ...
            negAccuracySimple(:, costIter, optimumIdx(costIter));
    end
    for sigIter = 1:numSignals
        for costIter = 1:numContrastFn
            bestCostComplex(sigIter, costIter, :) = ...
                bestCostAcrossCF(sigIter, costIter, 1:numContrastFn)/ ...
                bestCostAcrossCF(sigIter, costIter, costIter);
        end
    end
    
    save(saveFileName, 'sampleSize', 'datasetID', ...
        'bestCostSimple', 'negAccuracySimple', ...
        'componentIndices', 'optimumIdx', 'bestCostAcrossCF', ...
        'bestCostComplex', 'negAccuracyComplex');
    disp(strcat("Saved results to ", saveFileName));
    
    clear dataset bestCostSimple negAccuracySimple;
    clear componentIndices optimumIdx bestCostAcrossCF;
    clear bestCostComplex negAccuracyComplex
end
close();

function [bestContrast, negAccuracy, compIdx] = selectComp(contrast, ...
    unmixingMatrix, actualDirections, data, contrastID, autoFlag)
    
    [~, numContrastFn, numSims] = size(contrast);
    numSignals = size(actualDirections, 1);
    bestContrast = nan(numSignals, numContrastFn, numContrastFn);
    negAccuracy = nan(numSignals, numContrastFn);
    compIdx = nan(numSignals, numContrastFn);
    contrast = abs(contrast);
    [numIC, ~, ~] = size(unmixingMatrix);
    topContrast = nan(numSignals, numContrastFn, numSims);
    simCompIdx = nan(numSignals, numContrastFn, numSims); 
    
    % Automatically select signal maximizing
    % measure of non-Gaussianity
    for contrastIter = 1:numContrastFn
        for simIter = 1:numSims
            [~, simCompIdx(:, contrastIter, simIter)] = ...
                maxk(contrast(:, contrastIter, simIter), numSignals);
            topContrast(:, :, simIter) = ...
                contrast(simCompIdx(:, contrastIter, simIter), :, simIter);
        end
        sumContrast = sum(topContrast, 1);
        [~, simIdx] = max(sumContrast(1, contrastIter, :));
        compIdx(:,  contrastIter) = simCompIdx(:, contrastIter, simIdx);
        bestContrast(:, :, contrastIter) = ...
            contrast(compIdx(:, contrastIter), :, simIdx);
        negAccuracy(:, contrastIter) = 1 - ...
            diag(abs(unmixingMatrix(compIdx(:, contrastIter), :, simIdx) * ...
            actualDirections'));
    end
    if ~autoFlag
        % Manually enter indices to the best signals from the dataset
        for simIter = 1:numSims
            simCIdx = simCompIdx(:, contrastID, simIter);
            numSamples = size(data, 2);
            plotSamples = min(5000, numSamples);
            components = normalize(unmixingMatrix(:, :, simIter)*data, 2);
            yMax = max(abs(components(:)));
            for compIter = 1:numIC
                if numIC>10
                    subplot(10, ceil(numIC/10), compIter);
                else
                    subplot(numIC, 1, compIter);
                end
                title(compIter);
                plot(1:plotSamples, components(compIter, 1:plotSamples));
                ylim(yMax*[-1 1]);
                title(strcat("component ", num2str(compIter)));
            end
            changeSelection = 'y';
            while ~strcmpi(changeSelection, 'n')
                for sigIter = 1:numSignals
                    if numIC>10
                        subplot(10, ceil(numIC/10), simCIdx(sigIter));
                    else
                        subplot(numIC, 1, simCIdx(sigIter));
                    end
                    hold on;
                    ax = gca;
                    box on;
                    ax.XColor = 'r';
                    ax.YColor = 'r';
                    ax.LineWidth = 2;
                end
                disp('Selected components are highlighted with red axes');
                changeSelection = input("Change selection (y/N) : ", 's');
                if ~strcmpi(changeSelection, 'y')
                    changeSelection = 'n';
                else
                    for sigIter = 1:numSignals
                        if numIC>10
                            subplot(10, ceil(numIC/10), simCIdx(sigIter));
                        else
                            subplot(numIC, 1, simCIdx(sigIter));
                        end
                        hold on;
                        ax = gca;
                        ax.XColor = 'k';
                        ax.YColor = 'k';
                        ax.LineWidth = 1;
                    end
                    simCIdx = reshape(input(strcat("Enter indices of ",  ...
                        num2str(numSignals), " components (eg: [2 4]) : ")), ...
                        numSignals, 1);
                end
            end
            negAcc = 1 - diag(abs(unmixingMatrix(simCIdx, :, simIter) * ...
                actualDirections'));
            topContrast(:, :, simIter) = repmat(negAcc, 1, numContrastFn);
            simCompIdx(:, :, simIter) = ...
                repmat(simCIdx, 1, numContrastFn);   
        end
        clf();
    end

    if numSignals > 1
        for contrastIter = 1:numContrastFn
            sumContrast = sum(topContrast, 1);
            [~, simIdx] = max(sumContrast(1, contrastIter, :));
            compIdx(:,  contrastIter) = simCompIdx(:, contrastIter, simIdx);
            sigNegAccuracy = 1 - ...
                abs(unmixingMatrix(compIdx(:, contrastIter), :, simIdx) ...
                * actualDirections');
            if trace(sigNegAccuracy) < (sigNegAccuracy(1, 2) + sigNegAccuracy(2, 1))
                bestContrast(:, :, contrastIter) = ...
                    contrast(compIdx(:, contrastIter), :, simIdx);
                negAccuracy(:, contrastIter) = diag(sigNegAccuracy);
            else
                bestContrast(:, :, contrastIter) = ...
                    contrast(compIdx([2 1], contrastIter), :, simIdx);
                negAccuracy(:, contrastIter) = sigNegAccuracy([2 3]);
                compIdx(:, contrastIter) = compIdx([2 1], contrastIter);
            end
        end
    end
    clear cost unmixingMatrix actualDirections
end
