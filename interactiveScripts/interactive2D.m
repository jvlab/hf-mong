%% Case specific parameters

disp('1. Bimodal symmetric distributions');
disp('2. Bimodal asymmetric distributions');
disp('3. Heavy-tailed distributions');
disp('4. Light-tailed distributions');
disp('5. Asymmteric distributions');
distributionChoiceList = input('Enter non-Gaussian distribution (1:5) : ');
sampleSizeArray = input('Enter array of dataset sizes (eg: 1000, [1000 10000]) : ');
 
numSimulations = input('Number of simulations for every dataset size (eg: 1, 1000) : ');
HFnSet = input('Set of Hermite Functions (eg: 0:15, [0 1:2:15]) : ');

projectionAngles = input('Enter theta values to project on (press enter for default) : ');
if isempty(projectionAngles) || length(projectionAngles)<2
    projectionAngles = [-90:-11 -10:0.5:-2 -1.9:0.1:1.9 2:0.5:10 11:90];
end

savePath = uigetdir(cd, 'Select folder to save results');
disp(strcat("Selected folder ", savePath));
warning('off', 'MATLAB:MKDIR:DirectoryExists');

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
			distName = 'bimodal_symmetric';
			pdfParameters{1}.generatingFunction = @generateDataBimodal;
			pdfParameters{1}.mu  = [-2 2];
			pdfParameters{1}.sigma = [1 1];
			pdfParameters{1}.alpha = 0.5;
		case 2
			% Bimodal asymmetric
			distName = 'bimodal_asymmetric';
			pdfParameters{1}.generatingFunction = @generateDataBimodal;
			pdfParameters{1}.mu  = [-2 2];
			pdfParameters{1}.sigma = [1 0.4];
			pdfParameters{1}.alpha = 0.7;
		case 3
			% Heavy-tailed
			distName = 'heavy_tailed';
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameters{1}.beta = 1;
		case 4
			% Light-tailed
			distName = 'light_tailed';
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameters{1}.beta = 10;
		case 5
			% Unimodal asymmetric
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
