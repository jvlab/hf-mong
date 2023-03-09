%% Set random number generator
rng(0);

%% Case specific parameters

[fileNames, filePath] = uigetfile('*.mat', "Select datasets", 'MultiSelect', 'on');
numPC = input('Number of principal components (eg: 50) : ');
numIC = input('Number of independent components (eg: 5) : ');
numRandomStarts = input('Number of random starts per component (eg: 25) : ');

sampleSizeArray = input('Enter array of dataset sizes (eg: 1502, 75002) : ');

numSampleSizes = length(sampleSizeArray);
datasetIndices = cell(1, numSampleSizes);
disp('Indices of timepoints (eg: 10001:11502, default takes first n samples)');
for dIter = 1:numSampleSizes
    datasetIndices{dIter} = input(strcat("For ", ...
        num2str(sampleSizeArray(dIter)), " samples : "));
end
    
% indices with at least one artifact in all 10 datasets
% 1502  : [10001:11502]
% 3752  : [8001:11752]
% 7502  : [1:7502]
% 15002 : [1:15002]
% 37502 : [1:3752]
% 75002 : [1:75002]

HFnSet = input('Set of Hermite Functions (eg: 0:15, [0 1:2:15]) : ');

savePath = uigetdir(cd, 'Select folder to save results');
disp(strcat("Selected folder ", savePath));
distName = 'simulated_eeg';
distPath = strcat(savePath, '/', distName);
mkdir(distPath);

%% Estimation

for file = fileNames
    dataFileName = strcat(filePath, '/', file{1});
    fileBits = split(file{1}, {'_', '.'});
    datasetID = fileBits{3};

    for sampleSizeIter = 1:numSampleSizes
        dataPointCount = sampleSizeArray(sampleSizeIter);

        saveFileName = strcat(savePath, '/', distName, ...
            '_N', num2str(dataPointCount), ...
            '_HF', num2str(max(HFnSet)), ...
            '_RS', num2str(numRandomStarts), ...
            '_D', datasetID, '.mat');

        % Running
        masterFastICAEEG(dataFileName, saveFileName, ...
            datasetIndices{sampleSizeIter}, numPC, numIC, ...
            HFnSet, numRandomStarts);
    end
end