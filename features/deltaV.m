function [isartifact, maxdelta] = deltaV(eeg,threshold,framesinwindow)
%DELTAV Takes a signal and tells you whether there are any amplitude
%changes greater than the selected maxdelta, within a given time range.
%Used as one method of detecting suspected artefact.
% INPUTS
% eeg: signal to check.
% threshold: maximum permissable amplitude change; larger deltas return as
% artefact.
% framesinwindow: range of frames within which an amplitude must change in
% order to trigger.
% OUTPUTS
% isartifact: 1 if the amplitude change within the set window is greater
% than max delta (at any point); else 0.
% maxdelta: maximum dV found in signal.
isartifact = 0;
maxdelta = 0;
for n=1:length(eeg)-framesinwindow
    window = eeg(n:n+framesinwindow);
    delta = max(window) - min(window);
    if delta > maxdelta
        maxdelta = delta;
    end
    if delta > threshold
        isartifact = 1;
    end
end
