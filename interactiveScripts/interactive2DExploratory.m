%% Case specific parameters

disp('1. Bimodal symmetric distributions');
disp('2. Bimodal asymmetric distributions');
disp('3. Heavy-tailed distributions');
disp('4. Light-tailed distributions');
disp('5. Asymmteric distributions');
distributionChoiceList = input('Enter non-Gaussian distribution (1:5) : ');
sampleSizeArray = input('Enter array of dataset sizes (eg: 1000, [1000 10000]) : ');
 
numSimulations = input('Number of simulations for every dataset size (eg: 1, 1000) : ');

disp('1. All orders');
disp('2. Even orders');
disp('3. Odd orders');
HFnCaseList = input('Select set of Hermite functions to use (only one) : ');
HFnMaxList = input('List of highest order of Hermite functions (eg: 15, [1:50]) : ');

projectionAngles = input('Enter theta values to project on (press enter for default) : ');
if isempty(projectionAngles) || length(projectionAngles)<2
    projectionAngles = [-10:0.5:-2 -1.9:0.1:1.9 2:0.5:10];
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
	distName = cat(2, distName, '_2D_exploratory');
	distPath = strcat(savePath, '/', distName);
	mkdir(distPath);
    
    subplot(2, 3, subplotIndices(distributionChoice));
    hold on;
    legendStrings = {};
    legendIndices = [];
	
	for HFn = HFnMaxList
        switch HFnCaseList
            case 1
                HFnSet = 0:HFn;
                HFnCaseName = 'all';
            case 2
                HFnSet = 0:2:HFn;
                HFnCaseName = 'even';
            case 3
                HFnSet = [0 1:2:HFn];
                HFnCaseName = 'odd';
            otherwise
                disp('Choice not found. Using all orders');
                HFnSet = 0:HFn;
        end
        disp("Using the following set of Hermite functions : ");
        disp(HFnSet);
		for dataPointCount = sampleSizeArray
			disp(strcat("for ", num2str(sampleSize), " samples"));
                
            saveFileName = strcat(distPath, '/', ...
                distName, '_S', num2str(numSimulations), '_N', ...
                num2str(dataPointCount), '_HF', num2str(HFn), ...
                '_', HFnCaseName, '.mat');

			% Running
			masterNonGaussianity2Dexploratory(pdfParameters, projectionAngles, ...
				dataPointCount, numSimulations, HFnSet, saveFileName);
            
            disp(strcat("Saved ", saveFileName));
			
			clear saveFileName
        end
    end
    filePath = distPath;
    curate2DExploratory;
    fileName = saveFileName;
    plot2DExploratory;
	pdfParameters{1} = struct;
	clear folder;
end
