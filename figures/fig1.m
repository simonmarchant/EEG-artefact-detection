% calculate all the things
filePath = fileparts(matlab.desktop.editor.getActiveFilename);

temp = load('all_epochs.mat', 'balancedgrouped');
balancedepochs = temp.balancedgrouped;
num_of_raters = 7;
num_initial_cols = 8;
rater_comps = NaN(num_of_raters);
for n=1:num_of_raters
    col = n+num_initial_cols;
    for m=1:num_of_raters
        if n~=m
            rater_comps(n,m) = cohensKappa(balancedepochs{:,col},balancedepochs{:,m+num_initial_cols});
        end
    end
end
rater_comps = array2table(rater_comps,'VariableNames',balancedepochs.Properties.VariableNames(num_initial_cols+1:num_initial_cols+num_of_raters));
rater_comps.Avg = mean(rater_comps{:,:},2,'omitnan');
counts = histcounts(sum(balancedepochs{:,9:15}=='Artefact',2));
counts = [fliplr(counts(5:8));counts(1:4)];
counts = counts./[sum(counts);sum(counts)].*100;

fontsz = 8;
colours = brewermap(2,'accent');

% fig 1a
h = heatmap(rater_comps{:,1:end-1}, ...
    'ColorLimits',[0,1], ...
    'ColorMap',[1,1,1], ...
    'XDisplayLabels',{'A','B','C','D','E','F','G'}, ...
    'YDisplayLabels',{'A','B','C','D','E','F','G'});
h.Units = 'centimeters';
h.Position(3) = 4.5; %width
h.Position(4) = 5; %height
h.ColorbarVisible = 'off';
h.CellLabelFormat = '%0.2f';
h.FontSize = 8;
xlabel('Rater ID')
exportgraphics(h, sprintf('%s/fig1a.eps',filePath) )

% fig 1b
f = figure;
b = bar(counts','stacked', 'FaceColor', 'flat');
Y = counts(1,:);
xticklabels({'0','1','2','3'})
ylabel('Percentage of epochs rated','FontSize',fontsz)
ylim([0 100])
xlabel('# raters in disagreement','FontSize',fontsz)
f.Units = 'centimeters';
f.Position(3) = 4.5; %width
f.Position(4) = 5; %height
b(1).CData = colours(1,:);
b(2).CData = colours(2,:);
set(gca,'box','off')
set(gca,'Tickdir','out')
set(gca, 'fontsize', 8)
% counts+1 offsets text upwards by 1px.
text([1:length(Y)], counts(1,:)+1, num2str(Y','n=%.0f'),'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',fontsz,'Rotation',90)
exportgraphics(f, sprintf('%s/fig1b.eps',filePath) )

% fig 1c
f = figure;
groupcolumn = 'Type';
groups = cellstr(unique(balancedepochs{:,groupcolumn}));
groups = groups([2, 1, 7, 6, 5, 3, 4]); % rearrange for Caroline
accrates = table('Size',[length(groups),2], ...
    'VariableTypes',{'double','double'}, ...
    'VariableNames',{'Artefact','Clean'}, ...
    'RowNames',groups);
for n=1:length(groups)
    group = groups(n);
    subtable = balancedepochs{balancedepochs.(groupcolumn)==group,"GroupDecision"};
    accrates{group,"Artefact"} = sum(subtable=='Artefact');
    accrates{group,"Clean"} = sum(subtable=='Clean');
end
Y = accrates.Artefact;
temp1 = accrates.Artefact.*100./sum(accrates{:,:},2);
temp2 = accrates.Clean.*100./sum(accrates{:,:},2);
accrates.Artefact = temp1; accrates.Clean = temp2;
b = bar(accrates{:,:},'stacked', 'FaceColor', 'flat');
b(1).CData = colours(1,:);
b(2).CData = colours(2,:);
f.Units = 'centimeters';
f.Position(3) = 6; %width
f.Position(4) = 5; %height
set(gca,'box','off')
set(gca,'Tickdir','out')
set(gca, 'fontsize', 8)
xticklabels(groups)
ylabel('Percentage of epochs rated')
xtickangle(90)
text([1:length(Y)], accrates.Artefact+1, num2str(Y,'n=%.0f'),'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',fontsz,'Rotation',90) 
exportgraphics(f, sprintf('%s/fig1c.eps',filePath) )

% fig 1d
f = figure;
groupcolumn = 'AgeGroup';
groups = cellstr(unique(balancedepochs{:,groupcolumn}));
accrates = table('Size',[length(groups),2], ...
    'VariableTypes',{'double','double'}, ...
    'VariableNames',{'Artefact','Clean'}, ...
    'RowNames',groups);
for n=1:length(groups)
    group = groups(n);
    subtable = balancedepochs{balancedepochs.(groupcolumn)==group,"GroupDecision"};
    accrates{group,"Artefact"} = sum(subtable=='Artefact');
    accrates{group,"Clean"} = sum(subtable=='Clean');
end
Y = accrates.Artefact;
temp1 = accrates.Artefact.*100./sum(accrates{:,:},2);
temp2 = accrates.Clean.*100./sum(accrates{:,:},2);
accrates.Artefact = temp1; accrates.Clean = temp2;
b = bar(accrates{:,:},'stacked', 'FaceColor', 'flat');
b(1).CData = colours(1,:);
b(2).CData = colours(2,:);
f.Units = 'centimeters';
f.Position(3) = 3.5; %width
f.Position(4) = 5; %height
set(gca,'box','off')
set(gca,'Tickdir','out')
set(gca, 'fontsize', 8)
xticklabels(groups)
xtickangle(90)
ylabel('Percentage of epochs rated')
text([1:length(Y)], accrates.Artefact+1, num2str(Y,'n=%.0f'),'HorizontalAlignment','left','VerticalAlignment','middle','FontSize',fontsz,'Rotation',90)
exportgraphics(f, sprintf('%s/fig1d.eps',filePath) )
%clear b h col colours counts f filePath fontsz groupcolumn groups accrates n m group subtable Y temp temp1 temp2