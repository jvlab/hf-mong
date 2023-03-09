%% Case specific parameters

if ~exist('filePath', 'var') || ~exist('fileName', 'var')
    [fileName, filePath] = uigetfile('*.mat', 'Select a file');
end
disp(strcat("Selected ", filePath, '/', fileName));

%% Case agnostic parameters

loadColors;
method = '2std';
alphaValue = 0.25;
linePattern = '-';

%% Estimation
if ~exist('distName', 'var')
    distName = regexprep(fileName, '1D\w*.mat', '1D');
end
dataset = load(strcat(filePath, '/', fileName));

switch distName
    case 'bimodal_1D'
        titleString = 'Bimodal';
        parameterName = 'alpha';
    case 'heavy_tailed_1D'
        titleString = 'Heavy-tailed';
        parameterName = 'beta';
    case 'light_tailed_1D'
        titleString = 'Light-tailed';
        parameterName = 'beta';
    case 'unimodal_asymmetric_1D'
        titleString = 'Asymmetric';
        parameterName = 'kappa';
    otherwise
        error(cat(2, 'Incorrect fiel choice ', fileName));
end

parameterValues = cell2mat({dataset.pdfParameterValues.(parameterName)});

%% Plottin normality tests

subplot(1, 2, 1);
hold on;

% Moment based
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.JBTestArray), ...
    method, dr, alphaValue, linePattern);
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.DAKSArray), ...
    method, lr, alphaValue, linePattern);

% Tests based on Empirical Distribution Function (EDF)
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.KSArray), ...
    method, dg, alphaValue, linePattern);
u = unique(dataset.ADArray(:));
dataset.ADArray(isinf(dataset.ADArray)) = u(end-1)*2;
clear u;
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.ADArray), ...
    method, lg, alphaValue, linePattern);

% Frequency statistics
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.SWArray), ...
    method, db, alphaValue, linePattern);

% HF based
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.hfPowerArray), ...
    method, bk, alphaValue);

% Legend

names = get(gca, 'Children');
legend(flip(names(2:2:12)), 'Jarque-Bera Test', ...
	'DAgostinos K-squared Test', 'Kolmogorov-Smirnov Test', ...
    'Anderson-Darling Test', 'Shapiro-Wilk Test', ...
    strcat('J_{', num2str(max(dataset.HFnSet)),'}'), ...
    'Location', 'northoutside', 'NumColumns', 2);

%% Plotting FastICA contrast functions

subplot(1, 2, 2);
hold on;

plotContinuousErrorBars(parameterValues, normalizePeak(dataset.pow3Array), ...
    method, dg, alphaValue);
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.tanhArray), ...
    method, dr, alphaValue);
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.gausArray), ...
    method, db, alphaValue);
plotContinuousErrorBars(parameterValues, normalizePeak(dataset.hfPowerArray), ...
    method, bk, alphaValue);

% Legend
names = get(gca, 'Children');
legend(flip(names(2:2:8)), 'FastICA-I', ...
    'FastICA-II', 'FastICA-III', ...
    strcat('J_{', num2str(max(dataset.HFnSet)), '}'), ...
    'Location', 'northoutside');

%% Axis settings

for sp = 1:2
    subplot(1, 2, sp);
    axis square;
    set(gca, 'lineWidth', 1.5);
    set(gca, 'Fontsize', 13);
    set(gca, 'FontWeight', 'bold');
    ylim([0 1.2]);
    yticks(0:0.2:1.2);
    ylabel({'Normalized', 'Non-Gaussianity'});
    xlabel(strcat('\', parameterName));
    xtickValuesGap = 0.25*(parameterValues(end)-parameterValues(1));
    xticks(parameterValues(1):xtickValuesGap:parameterValues(end));
    xlim(parameterValues([1 end]));
end

sgtitle(strcat(cat(2, titleString, ', '), ' N=', ...
    num2str(dataset.sampleSize)), 'FontWeight', 'Bold');
clear dataset;

