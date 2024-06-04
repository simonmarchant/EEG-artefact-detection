function [balancedAccuracy] = balacc(y,ypred)
%BALACC Summary of this function goes here
%   Detailed explanation goes here
    cm = confusionchart(y, ypred);
    TP = cm.NormalizedValues(2,2); TN = cm.NormalizedValues(1,1); 
    FP = cm.NormalizedValues(1,2); FN = cm.NormalizedValues(2,1); 
    sensitivity = TP/(TP+FN); specificity = TN/(TN+FP);
    balancedAccuracy = (sensitivity + specificity) / 2;
end

