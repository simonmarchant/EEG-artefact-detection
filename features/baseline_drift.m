function [drift] = baseline_drift(eeg, Fs, baseline_length)
%BASELINE_DRIFT Summary of this function goes here
%   Detailed explanation goes here

baseline = eeg(1:baseline_length*Fs);
[p, f] = powerspectraldensity(baseline, Fs);
drift = mean(p(f<0.5));

end