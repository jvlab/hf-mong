%% Case specific parameters

if ~exist('savePath', 'var')
    filePath = uigetdir(cd, ...
        strcat("Select folder for exploration in 2D ", ...
        distString, " distributions"));
    disp(strcat("Selected folder ", filePath));
    if strcmp(filePath(end), '/') || strcmp(filePath(end), '\')    
        [~, distName] = fileparts(fileName);
    else
        [~, distName] = fileparts(fileName(1:end-1));
    end
else
    filePath = strcat(savePath, '/', distName);
end

if ~exist('sampleSizeArray', 'var')
    sampleSizeArray = input( ...
        'Enter array of dataset sizes (eg: 1000, [1000 10000]) : ');
end

if ~exist('numSimulations', 'var')
    numSimulations = input( ...
        'Number of simulations for every dataset size (eg: 1000) : ');
end

if ~exist('HFnCaseName', 'var')
    HFnCaseName = input('Select a case (all, even, or odd) : ', s);
end

if ~exist('HFnMaxList', 'var')
        HFnMaxList = input( ...
            strcat("List of order of Hermite functions to curate ", ...
            "(eg: 1:10, [1 5 10]) : "));
end

if ~exist('numBootStraps', 'var')
    numBootStraps = input('Number of bootstraps : ');
end
if ~exist('bootStrapSize', 'var')
    bootStrapSize = input('Size of bootstraps : ');
end

%% Estimation

numHFn = length(HFnMaxList);
numSampleSizes = length(sampleSizeArray);
HFnPowerAV = inf(numBootStraps, numHFn, numSampleSizes);
HFnPowerMean = inf(numBootStraps, numHFn, numSampleSizes);
actualDirection = [1; 0];
for sampleSizeIter = 1:numSampleSizes	
    for HFnIter = 1:numHFn
        HFn = HFnMaxList(HFnIter);
        sampleSize = sampleSizeArray(sampleSizeIter);
        dataFileName = strcat(filePath, '/', distName, '_S', ...
            num2str(numSimulations), '_N', num2str(sampleSize), ...
            '_HF', num2str(HFn), '_', HFnCaseName, '.mat');
        data = load(dataFileName);
        disp(strcat("Working on ", dataFileName));
        for bootIter = 1:numBootStraps
            rng(bootIter);
            randIndices = randi(data.numSimulations, 1, ...
                bootStrapSize);
            HFnPowerSubset = data.hfPowerArray(randIndices, :);
            [~, maxIndices] = max(HFnPowerSubset, [], 2);
            maxAngle = data.projectionAngles(maxIndices);
            estimatedDirections = [cosd(maxAngle); sind(maxAngle)];
            HFnPowerAV(bootIter, HFnIter, sampleSizeIter) = ...
                estimateAngularVariance( ...
                actualDirection, estimatedDirections);
            HFnPowerMean(bootIter, HFnIter, sampleSizeIter) = ...
                mean(actualDirection'*estimatedDirections);
        end
        thetaValues = data.projectionAngles;
        clear data;
    end
end
saveFileName = strcat(distName, '_', HFnCaseName, '_curated.mat');
save(strcat(filePath, '/', saveFileName));
disp(strcat("Saved ", filePath, '/', saveFileName));
