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
    distributionChoiceList = 1:4;
end

if ~exist('sampleSizeArray', 'var')
    sampleSizeArray = [1000 10000 100000];
end

if ~exist('numSimulations', 'var')
    numSimulations = 1000;
end
disp(strcat("Number of simulations for each dataset : ", num2str(numSimulations)));

if ~exist('HFnSet', 'var')
    HFnSet = 0:15;
end
disp("Using the following set of Hermite functions : ");
disp(HFnSet);

disp('Running non-Gaussianity assessments for 1D datasets with');

%% Estimation

for distributionChoice = distributionChoiceList
	switch distributionChoice
		case 1
            % Bimodal
            disp('1. Bimodal distributions');
			distName = strcat('bimodal');
			alphaValues = 0:0.05:1;
			temp.alpha = 0;
			temp.mu = [-2 2];
			temp.sigma = [1 1];
			temp.generatingFunction = @generateDataBimodal;
			pdfParameterValues = repmat(temp, 1, length(alphaValues));
			for i = 1:length(alphaValues)
				pdfParameterValues(i).alpha = alphaValues(i);
			end
			clear alphaValues
		case 2
            % Heavy-tailed
			disp('2. Heavy-tailed distributions');
            distName = 'heavy_tailed';
			betaValues = [0.5:0.05:1 1.1:0.1:2];
			temp = struct;
			temp.beta = 2;
			temp.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameterValues = repmat(temp, 1, length(betaValues));
			for i = 1:length(betaValues)
				pdfParameterValues(i).beta = betaValues(i);
			end
			clear betaValues temp
		case 3
            % Light-tailed
            disp('3. Light-tailed distributions');
			distName = 'light_tailed';
			betaValues = [2:0.1:4 4.5:0.5:6 7:10];
			temp = struct;
			temp.beta = 2;
			temp.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameterValues = repmat(temp, 1, length(betaValues));
			for i = 1:length(betaValues)
				pdfParameterValues(i).beta = betaValues(i);
			end
			clear betaValues temp
		case 4
            % Asymmetric
            disp('4. Asymmetric distributions');
			distName = 'unimodal_asymmetric';
			kappaValues = -1:0.05:1;
			temp = struct;
			temp.kappa = 2;
			temp.mu = 0;
			temp.sigma = 1;
			temp.generatingFunction = @generateDataGeneralizedExtremeValue;
			pdfParameterValues = repmat(temp, 1, length(kappaValues));
			for i = 1:length(kappaValues)
				pdfParameterValues(i).kappa = kappaValues(i);
			end
			clear kValues temp
		otherwise
			error(cat(2, 'Incorrect distribution choice ', num2str(distributionChoice)));
	end
    
    distName = strcat(distName, '_1D');
    distPath =strcat(savePath, '/', distName);
	mkdir(distPath);
	
    for sampleSize = sampleSizeArray
        disp(strcat("for ", num2str(sampleSize), " samples"));
        
        saveFileName = strcat(distPath, '/', distName, ...
            '_S', num2str(numSimulations), '_N', num2str(sampleSize), ...
            '_HF', num2str(max(HFnSet)),'.mat');

        % Runing
        masterNonGaussianity1D(pdfParameterValues, sampleSize, ...
            numSimulations, HFnSet, saveFileName);
        
        disp(strcat("Saved ", saveFileName));
        
        [filePath, fileName] = fileparts(saveFileName);
        figure('Units', 'normalized', 'Position', [0 0 1 1]);
        plot1D;
    end
    
	clear saveFileName pdfParameterValues;
end

