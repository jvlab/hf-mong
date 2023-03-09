%% Set random number generator
rng(0);

%% Case specific parameters

disp('1. Bimodal symmetric distributions');
disp('2. Bimodal asymmetric distributions');
disp('3. Heavy-tailed distributions');
disp('4. Light-tailed distributions');
disp('5. Asymmteric distributions');
distributionChoiceList = input('Enter non-Gaussian distribution choices (eg: 1, 1:5) : ');

dim = input('Number of dimensions (eg: 5) : ');
numIC = input('Number of independent components (eg: 5) : ');
numRandomStarts = input('Number of random starts per component (eg: 25) : ');
numDatasets = input('Number of datasets : ');

sampleSizeArray = input('Enter array of dataset sizes (eg: 1000, [1000 10000]) : ');
HFnSet = input('Set of Hermite Functions (eg: 0:15, [0 1:2:15]) : ');
seedFlag = input('Do you want to define seeds for data generator? (y/n) : ', 's');

savePath = uigetdir(cd, 'Select folder to save results');
disp(strcat("Selected folder ", savePath));

%% Case agnostic parameters

pdfParameters = cell(1, dim);
pdfParameters{1} = struct;

for iter = 2:dim
    % Defining Gaussian signal parameters
    pdfParameters{iter}.generatingFunction = @generateDataGaussian;
    pdfParameters{iter}.mu = 0;
    pdfParameters{iter}.sigma = 1;
end

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
        if strcmpi(seedFlag, 'y')
            seeds = input('Input seeds : ');
        end
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
    figure('units', 'normalized', 'outerposition', [0 0 1 1]);
    pairedStatsICA;
    pause(1);
end

