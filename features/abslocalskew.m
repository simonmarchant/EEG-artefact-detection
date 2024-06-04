function [abslocalskew] = abslocalskew(eeg, Fs)
%ABSLOCALSKEW Calculates the local skewness of every 15ms of signal, and
%returns the mean of these.

interval = round(15 * Fs * 0.001);
localskew = [];
for i=1:interval:length(eeg)/interval-interval
    % skew in 15ms segment
    localskew = [localskew, abs(skewness(eeg(1+(i-1)*interval : 1+i*interval)))];
end
abslocalskew = mean(localskew);
end
