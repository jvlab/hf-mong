%% Selecting files
numFiles = input('Number of distributions (eg: 1, 5) : ');
for fileIter = 1:numFiles
    [fileName, filePath] = uigetfile('*.mat');
    fullFileName{fileIter} = strcat(filePath, fileName);
    disp(strcat("Selected ", filePath, fileName));
end

%% Parameters for distribution

contrastFunctions = {'FastICA-I'; 'FastICA-II'; 'FastICA-III'; 'J_{15}'};
numContrastFn = length(contrastFunctions);

%% Run agnostic parameters
naValues = [];
groupDist = [];
groupSize = [];
groupContrast = [];
groupDatasetID =[];

for distributionChoice = 1:numFiles
    dataset = load(fullFileName{distributionChoice});
    for datasetID = 1:dataset.numDatasets
        for dpIter = 1:dataset.numSampleSizes
        	sampleSize = dataset.sampleSizeArray(dpIter);
            for costIter = 1:numContrastFn
				y = dataset.negAccuracyComplex(:, costIter, dpIter, datasetID);
				naValues = cat(1, naValues, y);
                sizeY = length(y);
                groupDist = cat(1, groupDist, ...
                    repmat(distributionChoice, sizeY, 1));
                groupSize = cat(1, groupSize, ...
                    repmat(sampleSize, sizeY, 1));
                groupContrast = cat(1, groupContrast, ...
                    repmat(string(contrastFunctions{costIter}), sizeY, 1));
                groupDatasetID = cat(1, groupDatasetID, ...
                    repmat(datasetID, sizeY, 1));
            end
        end
    end
end

naValues = log(naValues);
if numFiles == 1
    [p,t,stats,terms]=anovan(naValues, {groupSize, groupContrast, groupDatasetID}, ...
        'varnames', {'Sample size', 'Contrast function', 'Dataset ID'}, ...
        'model', 'full');
else
    [p,t,stats,terms]=anovan(naValues, {groupDist, groupSize, groupContrast, groupDatasetID}, ...
        'varnames', {'Distribution', 'Sample size', 'Contrast function', 'Dataset ID'}, ...
        'model', 'full');
end