%% Set random number generator
rng(0);

%% Case specific parameters

if exist('datasets', 'dir')
    filePath = 'datasets';
else
    filePath = uigetdir(cd, 'Select folder containing datasets');
end
disp(strcat("Selected folder ", filePath));

fileNames = dir(strcat(filePath, '/*.mat'));
fileNames = {fileNames.name};
if ~exist('numDatasets', 'var')
    numDatasets = length(fileNames);
end

if ~exist('sampleSizeArray', 'var')
    sampleSizeArray = [1502 3752 7502 15002 37502];
end

numSampleSizes = length(sampleSizeArray);
datasetIndices = cell(1, numSampleSizes);
numSignals = 2;
for sampleSizeIter = 1:numSampleSizes
    sampleSize = sampleSizeArray(sampleSizeIter);
    if sampleSize<1500
        error('Sample size muse be atleast 1500');
    elseif sampleSize<3752
        datasetIndices{sampleSizeIter} = 10000 + [1:sampleSize];
    elseif sampleSize==3752
        datasetIndices{sampleSizeIter} = 8000 + [1:sampleSize];
    else
        datasetIndices{sampleSizeIter} = 1:sampleSize;
    end
end

if ~exist('numPC', 'var')
    numPC = 50;
end
if ~exist('numIC', 'var')
    numIC = 20;
end
if ~exist('numRandomStarts', 'var')
    numRandomStarts = 25;
end

if ~exist('HFnSet' ,'var')
    HFnSet = 0:15;
end

distName = 'simulated_eeg';
warning('off', 'MATLAB:MKDIR:DirectoryExists');

selectFolder = input('Do you want to choose directory to save file? (y/N)', 's');
if strcmpi(selectFolder, 'y')
    savePath = uigetdir(cd, 'Select folder to save results');
    disp(strcat("Selected folder ", savePath));
else
    savePath = 'Results';
    mkdir('Results');
    disp('Created a folder named Results on the current path');
end

distPath = strcat(savePath, '/', distName);
mkdir(distPath);

disp("Using the following set of Hermite functions : ");
disp(HFnSet);
disp(strcat("Number of datasets : ", num2str(length(fileNames))));

%% Estimation
warning('off', 'MATLAB:MKDIR:DirectoryExists');

for file = fileNames
    dataFileName = strcat(filePath, '/', file{1});
    fileBits = split(file{1}, {'_', '.'});
    datasetID = str2double(fileBits{3});
    
    if datasetID > numDatasets
        continue;
    end

    for sampleSizeIter = 1:numSampleSizes
        
        sampleSize = sampleSizeArray(sampleSizeIter);
        disp(strcat("for dataset ", num2str(datasetID), " with ", ...
                num2str(sampleSize), " samples"));

        saveFileName = strcat(distPath, '/', distName, ...
            '_N', num2str(sampleSize), ...
            '_HF', num2str(max(HFnSet)), ...
            '_RS', num2str(numRandomStarts), ...
            '_D', num2str(datasetID), '.mat');

        % Running
        masterFastICAEEG(dataFileName, saveFileName, ...
            datasetIndices{sampleSizeIter}, numPC, numIC, ...
            HFnSet, numRandomStarts);
        
        disp(strcat("Saved ", saveFileName));
    end
end

filePath = distPath;
selectICASignals;
fileName = saveFileName; % created by selectICASignals.m
plotErrorICA;
pairedStatsICA;
