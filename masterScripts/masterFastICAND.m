%% Run everything on same dataset fed into the function as input

function masterFastICAND(data, saveFileName, ...
	numIC, HFnSet, numRandomStarts)
    % data : dim x sampleSize array
	% saveFileName : full file name to save results
    % numIC : number of independent components to extract
	% HFnSet : list of Hermite Function indices for HF based methods
	% numRandomStarts : number of random starts per independent component

	if nargin<5, numRandomStarts = 1; end
	if nargin<4, HFnSet = 0:10; end
    if nargin<3, numIC = 1; end
	
    sampleSize = size(data, 2);
	preprocessedData = whitenData(data);
    
    %% Default pow4
    [pow3UnmixingMatrix, pow3Cost, pow3Time] = ...
        fasticaRun(preprocessedData, numIC, 'pow3', 'pow3', ...
        HFnSet, numRandomStarts);

    %% tanh
    [tanhUnmixingMatrix, tanhCost, tanhTime] = ...
        fasticaRun(preprocessedData, numIC, 'tanh', 'tanh', ...
        HFnSet, numRandomStarts);

    %% gaus
    [gausUnmixingMatrix, gausCost, gausTime] = ...
        fasticaRun(preprocessedData, numIC, 'gaus', 'gaus', ...
        HFnSet, numRandomStarts);

    %% Hermite-based method with learning rate
    [hfPowLinUnmixingMatrix, hfPowLinCost, hfPowLinTime] = ...
        fasticaRun(preprocessedData, numIC, 'hfpowl', 'hfpowl', ...
        HFnSet, numRandomStarts);

    save(saveFileName);
	
	clear data preprocessedData; 
	clear pow3Time tanhTime gausTime hfPowLinTime
	clear pow3UnmixingMatrix tanhUnmixingMatrix gausUnmixingMatrix 
	clear hfPowLinUnmixingMatrix
	clear pow3Cost tanhCost gausCost hfPowLinCost
end

function [unmixingMatrix, cost, runTime] = fasticaRun(...
	data, numIC, gCost, gFinetune, nList, numRandomStarts)
	
	dim = size(data, 1);
	% initialization
	unmixingMatrix = nan(numIC, dim);
	cost = nan(numIC, 4);
	
	% estimation
    ticktock = tic();
	[sig, ~, w] = fastica(data, 'numofIC', numIC, 'g', gCost, ...
		'approach', 'defl', 'finetune', gFinetune, 'nList', nList, ...
		'verbose', 'off', 'numRandomStarts', numRandomStarts);
	runTime = toc(ticktock);
	% populating output
	
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
