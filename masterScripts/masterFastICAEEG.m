  %% Run everything on same simulated EEG dataset fed into the function as input

function masterFastICAEEG(dataFileName, saveFileName, ...
	datasetIndices, numPC, numIC, HFnSet, numRandomStarts)
    % dataFileName : full name of file containing the data
	% saveFileName : full file name to save results
    % numPC : number of principal components reduce to
    % numIC : number of independent components to extract
	% HFnSet : list of Hermite Function indices for HF based methods
	% numRandomStarts : number of random starts per independent component

	if nargin<7, numRandomStarts = 1; end
	if nargin<6, HFnSet = 0:10; end
    if nargin<5, numIC = 1; end
	
	load(dataFileName, 'data', 'dataset', 'eyeBlinkUnmixingDirection');
    
    if nargin<4, numPC = size(data, 1); end

    if nargin<3 || isempty(datasetIndices)
        datasetIndices = 1:size(data, 2);
    end
    data = data(:, datasetIndices);
	sampleSize = size(data, 2);
        
	%% Default pow4
    [pow3UnmixingMatrix, pow3Cost, pow3Time] = ...
        fasticaRun(data, numPC, numIC, ...
        'pow3', 'pow3', HFnSet, numRandomStarts);

    %% tanh
    [tanhUnmixingMatrix, tanhCost, tanhTime] = ...
        fasticaRun(data, numPC, numIC, ...
        'tanh', 'tanh', HFnSet, numRandomStarts);

    %% gaus
    [gausUnmixingMatrix, gausCost, gausTime] = ...
        fasticaRun(data, numPC, numIC, ...
        'gaus', 'gaus', HFnSet, numRandomStarts);

    %% Hermite-based method with learning rate
    [hfPowLinUnmixingMatrix, hfPowLinCost, hfPowLinTime] = ...
        fasticaRun(data, numPC, numIC, ...
        'hfpowl', 'hfpowl', HFnSet, numRandomStarts);
	
	save(saveFileName);
	
	clear data; 
	clear pow3Time tanhTime gausTime hfPowLinTime
	clear pow3UnmixingMatrix tanhUnmixingMatrix gausUnmixingMatrix 
	clear hfPowLinUnmixingMatrix
	clear pow3Cost tanhCost gausCost hfPowLinCost

end

function [unmixingMatrix, cost, runTime] = fasticaRun(...
	data, numPC, numIC, gCost, gFinetune, nList, numRandomStarts)
	
	dim = size(data, 1);
	% initialization
	unmixingMatrix = nan(numIC, dim);
	cost = nan(numIC, 4);
	
	% estimation
	tic
	[sig, ~, w] = fastica(data, 'lastEig', numPC, 'numofIC', numIC, ...
        'g', gCost, 'approach', 'defl', 'finetune', gFinetune, ...
        'nList', nList, 'verbose', 'off', ...
        'numRandomStarts', numRandomStarts);
	runTime = toc;
    
	% populating output
	if ~isempty(w) & ~isnan(w)
		sig = normalize(sig, 2);
        for wIdx = 1:size(w, 1)
    		unmixingMatrix(wIdx, :) = normalize(w(wIdx, :), 'norm');
        	cost(wIdx, :) = estimateCosts(sig(wIdx, :), nList);
        end
	end
	
	clear data sig w;
end
