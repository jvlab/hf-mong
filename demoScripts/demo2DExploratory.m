%% Set random number generator
rng(0);

%% Case specific parameters

if ~exist('distributionChoiceList', 'var')
    distributionChoiceList = 1:5;
end

if ~exist('sampleSizeArray', 'var')
    sampleSizeArray = [100 1000 10000 100000];
end

if ~exist('numSimulations', 'var')
    numSimulations = 1000;
end

if ~exist('HFnCaseList', 'var')
    HFnCaseList = 1:3;
end
if ~exist('HFnMaxListSet', 'var')
    HFnMaxListSet = {1:50; 2:2:50; 1:2:49};
end

if ~exist('projectionAngles', 'var')
    projectionAngles = [-10:0.5:-2 -1.9:0.1:1.9 2:0.5:10];
end

if ~exist('numBootStraps', 'var')
    numBootStraps = 1000;
end

if ~exist('bootStrapSize', 'var')
    bootStrapSize = 1000;
end

selectFolder = input('Do you want to choose directory to save file? (y/n)', 's');
if strcmpi(selectFolder, 'n')
    savePath = uigetdir(cd, 'Select folder to save results');
    disp(strcat("Selected folder ", savePath));
else
    savePath = 'Results';
    mkdir('Results');
    disp('Created a folder named Results on the current path');
end

disp('Running extensive non-Gassianity assessments for 2D datasets with');

%% Case agnostic parameters

pdfParameters = {struct, struct};

% Defining Gaussian signal parameters
pdfParameters{2}.generatingFunction = @generateDataGaussian;
pdfParameters{2}.mu = 0;
pdfParameters{2}.sigma = 1;

%% Estimation
warning('off', 'MATLAB:MKDIR:DirectoryExists');
subplotIndices = [1 2 4 5 6];
figure('Units', 'normalized', 'Position', [0 0 1 1]);
for distributionChoice = distributionChoiceList
	switch distributionChoice
		case 1
			% Bimodal symmetric
            disp('1. Bimodal symmetric distributions');
            titleString = 'Bimodal symmetric';
			distName = 'bimodal_symmetric';
			pdfParameters{1}.generatingFunction = @generateDataBimodal;
			pdfParameters{1}.mu  = [-2 2];
			pdfParameters{1}.sigma = [1 1];
			pdfParameters{1}.alpha = 0.5;
		case 2
			% Bimodal asymmetric
            disp('2. Bimodal asymmetric distributions');
            titleString = 'Bimodal asymmetric';
			distName = 'bimodal_asymmetric';
			pdfParameters{1}.generatingFunction = @generateDataBimodal;
			pdfParameters{1}.mu  = [-2 2];
			pdfParameters{1}.sigma = [1 0.4];
			pdfParameters{1}.alpha = 0.7;
		case 3
			% Heavy-tailed
            disp('3. Heavy-tailed distributions');
            titleString = 'Heavy-tailed';
			distName = 'heavy_tailed';
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameters{1}.beta = 1;
		case 4
			% Light-tailed
			distName = 'light_tailed';
            titleString = 'Light-tailed';
            disp('4. Light-tailed distributions');
			pdfParameters{1}.generatingFunction = @generateDataGeneralizedNormal;
			pdfParameters{1}.beta = 10;
		case 5
			% Unimodal asymmetric
			distName = 'unimodal_asymmetric';
            titleString = 'Unimodal asymmetric';
            disp('5. Asymmetric distributions');
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
    
    for HFnCase = HFnCaseList
        HFnMaxList = HFnMaxListSet{HFnCase};
        for HFn = HFnMaxList
            switch HFnCase
                case 1
                    disp('a. All orders');
                    HFnCaseName = 'all';
                    HFnSet = 0:HFn;
                case 2
                    disp('b. Even orders');
                    HFnCaseName = 'even';
                    HFnSet = 0:2:HFn;
                case 3
                    disp('c. Odd orders');
                    HFnCaseName = 'odd';
                    HFnSet = [0 1:2:HFn];
            end
            disp("Using the following set of Hermite functions : ");
            disp(HFnSet);
            for sampleSize = sampleSizeArray
                disp(strcat("for ", num2str(sampleSize), " samples"));
                
                saveFileName = strcat(distPath, '/', ...
                    distName, '_S', num2str(numSimulations), '_N', ...
                    num2str(sampleSize), '_HF', num2str(HFn), ...
                    '_', HFnCaseName, '.mat');

                % Running
                masterNonGaussianity2Dexploratory(pdfParameters, projectionAngles, ...
                    sampleSize, numSimulations, HFnSet, saveFileName);

                disp(strcat("Saved ", saveFileName));
            end
        end
        filePath = distPath;
        curate2DExploratory;
        fileName = saveFileName;
        plot2DExploratory;
    end
	pdfParameters{1} = struct;
    title(titleString);
    pause(1);
end

for distributionChoice = distributionChoiceList
    subplot(2, 3, subplotIndices(distributionChoice));
    legend off;
end

sgtitle({'Effect of set of Hermite functions on circular variance', ''}, ...
    'FontWeight', 'Bold', 'FontSize', 16);
lgd = legend(flip(names([1:2:(numPlots-numSampleSizes) ...
    (numPlots-numSampleSizes+1):numPlots])), legendStrings, ...
    'Location', 'eastoutside', 'Units', 'normalized', ...
    'numColumns', 3);
lgd.Position = lgd.Position + [0 0.5 0 0];

