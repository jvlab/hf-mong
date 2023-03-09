%% Case specific parameters

if ~exist('filePath', 'var') || ~exist('filePath', 'var')
    [fileName, filePath] = uigetfile('*.mat');
end
disp(strcat("Selected ", filePath, fileName));

%% Case agnostic parameters

loadColors;
method = '2std';
alphaValue = 0.25;
pAlphaValue = 0.5;
linePattern = '-';

%% Estimation

if ~exist('distName', 'var')
    distName = regexprep(fileName, '2D\w*.mat', '2D');
end
dataset = load(strcat(filePath, '/', fileName));

switch distName
    case 'bimodal_symmetric_2D'
        titleString = 'Bimodal symmetric';
    case 'bimodal_asymmetric_2D'
        titleString = 'Bimodal asymmetric';
    case 'heavy_tailed_2D'
        titleString = 'Heavy-tailed';
    case 'light_tailed_2D'
        titleString = 'Light-tailed';
    case 'unimodal_asymmetric_2D'
        titleString = 'Unimodal asymmetric';
    otherwise
        error(cat(2, 'Incorrect file choice ', fileName));
end

hold on;

%% Plotting
hold on;
plotContinuousErrorBars(dataset.projectionAngles, ...
    normalizePeak(dataset.pow3Array), method, dg, alphaValue);
plotPeakWidth(normalizePeak(dataset.pow3Array), ...
    dataset.projectionAngles, 0.1, [dg pAlphaValue]);

plotContinuousErrorBars(dataset.projectionAngles, ...
    normalizePeak(dataset.tanhArray), method, dr, alphaValue);
plotPeakWidth(normalizePeak(dataset.tanhArray), ...
    dataset.projectionAngles, 0.2, [dr pAlphaValue]);

plotContinuousErrorBars(dataset.projectionAngles, ...
    normalizePeak(dataset.gausArray), method, db, alphaValue);
plotPeakWidth(normalizePeak(dataset.gausArray), ...
    dataset.projectionAngles, 0.3, [db pAlphaValue]);

plotContinuousErrorBars(dataset.projectionAngles, ...
    normalizePeak(dataset.hfPowerArray), method, bk, alphaValue);
plotPeakWidth(normalizePeak(dataset.hfPowerArray), ...
    dataset.projectionAngles, 0.4, [bk pAlphaValue]);

% Legend
names = get(gca, 'Children');
legend(flip(names(3:3:12)), 'FastICA-I', ...
    'FastICA-II', 'FastICA-III', ...
    strcat('J_{', num2str(max(dataset.HFnSet)), '}'), ...
    'Location', 'northoutside');

%% Axis properties
axis square;
set(gca, 'lineWidth', 1.5);
set(gca, 'Fontsize', 12);
set(gca, 'FontWeight', 'bold');
ylim([0 1.2]);
yticks(0:0.2:1.2);
xlabel('\theta');
xlim(dataset.projectionAngles([1 end]));
xticks(-90:45:90);
sgtitle({strcat(titleString, ", N=", num2str(dataset.sampleSize)), ""}, ...
    'FontWeight', 'Bold');

clear dataset;
