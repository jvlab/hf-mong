%% Case specific parameters

disp('1. Bimodal distributions');
disp('2. Heavy-tailed distributions');
disp('3. Light-tailed distributions');
disp('4. Asymmteric distributions');
distributionChoiceList = input('Enter distribution (1:4) : ');
sampleSizeArray = input('Enter array of dataset sizes (eg: 1000, [1000 10000]) : ');
 
numSimulations = input('Number of simulations for every dataset size (eg: 1, 1000) : ');
HFnSet = input('Set of Hermite Functions (eg: 0:15, [0 1:2:15]) : ');

savePath = uigetdir(cd, 'Select folder to save results');
disp(strcat("Selected folder ", savePath));
warning('off', 'MATLAB:MKDIR:DirectoryExists');

%% Estimation

for distributionChoice = distributionChoiceList
	switch distributionChoice
		case 1
            % Bimodal
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
    distPath = strcat(savePath, '/', distName);
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
