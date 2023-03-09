%% Case specific parameters

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

if ~exist('distributionChoiceList', 'var')
    distributionChoiceList = 1:5;
end

if ~exist('sampleSizeArray', 'var')
    sampleSizeArray = [1000 10000 100000];
end

if ~exist('numSimulations', 'var')
    numSimulations = 1000;
end

if ~exist('HFnSet', 'var')
    HFnSet = 0:15;
end

if ~exist('projectionAngles', 'var')
    projectionAngles = [-90:-11 -10:0.5:-2 -1.9:0.1:1.9 2:0.5:10 11:90];
end

disp("Using the following set of Hermite functions : ");
disp(HFnSet);
disp(strcat("Number of simulations for each dataset : ", num2str(numSimulations)));

disp('Running non-Gassianity assessments for 2D datasets with');

%% Case agnostic parameters

pdfParameters = {struct, struct};

% Defining Gaussian signal parameters
pdfParameters{2}.generatingFunction = @generateDataGaussian;
pdfParameters{2}.mu = 0;
pdfParameters{2}.sigma = 1;

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
			distName = 'light_tailed';
            disp('4. Light-tailed distribution');
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
	
    distName = strcat(distName, '_2D');
    distPath = strcat(savePath, '/', distName);
	mkdir(distPath);
	
	for sampleSize = sampleSizeArray
        disp(strcat("for ", num2str(sampleSize), " samples"));
        
        saveFileName = strcat(distPath, '/', distName, '_S', ...
            num2str(numSimulations), '_N', num2str(sampleSize), ...
            '_HF', num2str(max(HFnSet)),'.mat');

        % Running
        masterNonGaussianity2D(pdfParameters, projectionAngles, ...
            sampleSize, numSimulations, HFnSet, saveFileName);
        
        disp(strcat("Saved ", saveFileName));
        
        [filePath, fileName] = fileparts(saveFileName);
        figure('Units', 'normalized', 'Position', [0 0 1 1]);
        plot2D;
	end
	pdfParameters{1} = struct;
	clear folder;
end
