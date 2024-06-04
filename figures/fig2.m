fig = figure;
fig.Units = 'centimeters';
fig.Position = [0 28 22 28];
colours = brewermap(3,'accent');
featurenames = {'LogVariance', 'Skew', 'Kurtosis', 'DeltaV',...
    'LogHalfHzPwr', 'Lambda', 'Fiterror', 'DeltaLambda', 'DeltaFiterror',...
    'DeltaLogPower', 'ThetaLambda', 'ThetaFiterror', 'ThetaLogPower',...
    'AlphaLambda', 'AlphaFiterror', 'AlphaLogPower', 'BetaLambda',...
    'BetaFiterror', 'BetaLogPower', 'GammaLambda', 'GammaFiterror',...
    'GammaLogPower', 'SumDv50', 'SumDv100', 'SumDv200', 'SumDv300',...
'SumDv500', 'HiguchiFD', 'KatzFD', 'Wavelet1', 'Wavelet2', 'Wavelet6'};
featuretitles = {'Amplitude Variance', 'Skew', 'Kurtosis', 'Amplitude Change',...
    'Power <0.5Hz', 'Lambda', 'Fit Error', 'Delta Lambda', 'Delta Fit Error',...
    'Delta Power', 'Theta Lambda', 'Theta Fit Error', 'Theta Log Power',...
    'Alpha Lambda', 'Alpha Fit Error', 'Alpha Log Power', 'Beta Lambda',...
    'Beta Fit Error', 'Beta Log Power', 'Gamma Lambda', 'Gamma Fit Error',...
    'Gamma Log Power', 'Derivatives (50ms)', 'Derivatives (100ms)', 'Derivatives (200ms)', 'Derivatives (300ms)',...
'Derivatives (500ms)', 'Fractal Dimension (Higuchi)', 'Fractal Dimension (Katz)', 'Wavelet 1', 'Wavelet 2', 'Wavelet 6'};

% Sort by p-value
features = train_set{:,featurenames};
features(isinf(features)) = 100; % logHalfHzPower contains rogue Inf values
[~,~,stats] = mnrfit(features, categorical(train_set.GroupDecision)); % logit regression
pvalues = stats.p(2:end); % first value is intercept
psorted = sortrows(table(featurenames', featuretitles', pvalues, 'VariableNames', {'feature','ftitle','p'}), 3);

% Plot
for n=1:length(featurenames)
    subplot(6,6,n)
    feat = psorted.feature{n};
    boxplot(train_set.(feat), train_set.GroupDecision, ...
        'Labels', {'Clean','Artefact'}, ...
        'BoxStyle', 'filled', ...
        'Notch', 'off', ...
        'Colors', colours)
    ylabel(psorted.ftitle{n}, 'FontSize',8)
    subtitle(strcat('p: ',num2str(psorted.p(n),'%.2f')), 'FontSize', 8)
    xtickangle(45)
    ax = gca;
    set(ax,'box','off')
    set(ax,'Tickdir','out')
    set(ax, 'fontsize', 8)
    % set outlier appearance
    outliers = findobj('Tag','Outliers');
    for m=1:length(outliers)
        outliers(m).MarkerEdgeColor = '#fc8d62';
        outliers(m).Marker = '.';
        outliers(m).MarkerSize = 3;
    end
end

exportgraphics(fig, sprintf('%s/fig2.eps',filePath) )
%clear ax features feat n m stats pvalues psorted I