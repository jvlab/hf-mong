%% Set random number generator
rng(0);

%% Case specific parameters
if ~exist('distributionChoiceList', 'var')
    distributionChoiceList = 1:5;
end

if ~exist('sampleSizeArray', 'var')
    sampleSizeArray = [1000 10000 100000];
end

if ~exist('numDatasets', 'var')
    numDatasets = 10;
end

if ~exist('dim', 'var')
    dim = 5;
end
if ~exist('numIC', 'var')
    numIC = dim;
end
if ~exist('numRandomStarts', 'var')
    numRandomStarts = 25;
end

if ~exist('HFnSet', 'var')
    HFnSet = 0:15;
end

warning('off', 'MATLAB:MKDIR:DirectoryExists');

selectFolder = input('Do you want to choose directory to save file? (y/n)', 's');
if strcmpi(selectFolder, 'n')
    savePath = uigetdir(cd, 'Select folder to save results');
    disp(strcat("Selected folder ", savePath));
else
    savePath = 'Results';
    mkdir('Results');
    disp('Created a folder named Results on the current path');
end

disp("Using the following set of Hermite functions : ");
disp(HFnSet);
disp(strcat("Number of datasets : ", num2str(numDatasets)));

disp('Running FastICA for 5D dataets with');

%% Case agnostic parameters

pdfParameters = cell(1, dim);
pdfParameters{1} = struct;

for iter = 2:dim
    % Defining Gaussian signal parameters
    pdfParameters{iter}.generatingFunction = @generateDataGaussian;
    pdfParameters{iter}.mu = 0;
    pdfParameters{iter}.sigma = 1;
end

numSignals = 1;
subplotIndices = [1 2 4 5 6];

%% Estimation

for distributionChoice = distributionChoiceList
	switch distributionChoice
		case 1
			% Bimodal symmetric
            disp('1. Bimodal symmetric distribution');
			distName = 'bimodal_symmetric';
			pdfParameters{1}.generatingFunction = @generateDataBimodal;
			pdfParameters{1}.mu  = [-2 2];
			pdfParameters{1}.sigma = [1 1];
			pdfParameters{1}.alpha = 0.5;
		case 2
			% Bimodal asymmetric
            disp('2. Bimodal asymmetric distribution');
			distName = 'bimodal_asymmetric';
			pdfParameters{1}.generatingFunction = @generateDataBimodal;
			pdfParameters{1}.mu  = [-2 2];
			pdfParameters{1}.sigma = [1 0.4];
			pdfParameters{1}.alpha = 0.7;
		case 3
			% Heavy-tailed
            disp('3. Heavy-tailed distribution');
			distName = 'heavy_tailed';
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameters{1}.beta = 1;
		case 4
			% Light-tailed
            disp('4. Light-tailed distribution');
			distName = 'light_tailed';
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameters{1}.beta = 10;
		case 5
			% Unimodal asymmetric
            disp('5. Asymmetric distribution');
			distName = 'unimodal_asymmetric';
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedExtremeValue;
			pdfParameters{1}.mu  = 0;
			pdfParameters{1}.sigma = 1;
			pdfParameters{1}.kappa = 0;
		otherwise
			error(cat(2, 'Incorrect distribution choice ', num2str(distributionChoice)));
	end
	
	distName = strcat(distName, '_', num2str(dim), 'D');
    distPath = strcat(savePath, '/', distName);
	mkdir(distPath);
	
	for datasetID = 1:numDatasets
        seeds =[];
		for sampleSize = sampleSizeArray
            disp(strcat("Running for dataset ", num2str(datasetID), " with ", ...
                num2str(sampleSize), " samples"));
            
            data = generateDataND(pdfParameters, sampleSize, seeds);
			
			saveFileName = strcat(distPath, '/', distName, ...
				'_N', num2str(sampleSize), ...
				'_HF', num2str(max(HFnSet)), ...
                '_RS', num2str(numRandomStarts), ...
				'_D', num2str(datasetID), '.mat');

			% Running
			masterFastICAND(data, saveFileName, numIC, HFnSet, ...
                numRandomStarts);
            
            disp(strcat("Saved ", saveFileName));
		end
	end
	pdfParameters{1} = struct;
    
    filePath = distPath;
    selectICASignals;
    fileName = saveFileName; % created by selectICASignals.m
    plotErrorICA;
    pairedStatsICA;
    pause(1);
end
