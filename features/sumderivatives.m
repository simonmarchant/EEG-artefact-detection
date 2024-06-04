function [maxdV] = sumderivatives(eeg, framesinwindow)
% SUMDERIVATIVES calculates the derivative of the signal at each point, and
% then uses a moving window filter to sum derivatives in a given window
% width. The maximum sum of derivatives in a window is normalised to the
% signal variance. Related: https://doi.org/10.1016/j.cmpb.2015.10.011
% INPUTS
% eeg: signal to check.
% framesinwindow: size (in frames) of window to sum derivatives over.
% OUTPUTS
% maxdV: maximum sum of derivatives in window found in signal.
% This is normalised to the signal variance over the whole epoch.
dVdt = diff(eeg);
maxdV = 0;
for n=1:length(dVdt)-framesinwindow
    window = dVdt(n:n+framesinwindow);
    sumdVdt = sum(window);
    if abs(sumdVdt) > abs(maxdV)
        maxdV = sumdVdt;
    end
end
%maxdV = maxdV/var(eeg);