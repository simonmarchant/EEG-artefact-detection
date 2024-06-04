function [amp] = rmsamplitude(eeg)
%ALPHAPOWER Calculates log band power in the alpha (8-13Hz) band of an
% EEG signal.

eeg = sqrt(sum((eeg./mean(eeg)).^2));
amp = sum(eeg.^2);

end
