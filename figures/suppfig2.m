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

terms = double(train_set.GAbirth >= 34)*2;
terms(train_set.GAbirth < 34 & train_set.GAtest >= train_set.GAbirth+2) = 1;

for n=1:length(featurenames)
    subplot(7,5,n)
    feat = featurenames{n};
    boxplot(train_set.(feat), terms, ...
        'Labels', {'Premature 1','Premature 2','Term'}, ...
        'Colors', colours, ...
        'BoxStyle', 'filled', ...
        'Notch', 'off')
    ylabel(featuretitles{n},'FontSize',8)
    %[~,~,stats] = mnrfit(train_set.(feat), terms, 'Model','nominal'); %anovan(train_set.(feat), terms, 'display', 'off');
    %subtitle({'tstat: ',num2str(stats.p,'%.2f')},'FontSize',8)
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

exportgraphics(fig, sprintf('%s/suppfig2.eps',filePath) )