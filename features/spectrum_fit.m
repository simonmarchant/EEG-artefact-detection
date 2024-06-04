function [lambda, fiterror, maxdeviation] = spectrum_fit(eeg, Fs, highpassfreq, lowpassfreq)
%SPECTRUM_FIT finds the fitted power and mean-squared error from fitting a
%power law (1/f) curve to the frequency spectrum of an eeg epoch.
%Adapted from Winkler 2011, doi.org/10.1186/1744-9081-7-30.
%Used as one method of detecting suspected artefact.
% INPUTS
% eeg: signal to check.
% threshold: frames per second.
% OUTPUTS
% lambda: the power, A, in the equation $y=1/f^A + B$ when y is fitted to
% the log spectrum.
% fiterror: the root-mean-square error between the fitted line and the
% provided EEG's spectrum.
% maxdeviation: the maximum error between the fitted line and the EEG
% spectrum, normalised to errors. Measure of single-frequency inclusion.

[psdx, freq] = powerspectraldensity(eeg, Fs, 0, 70);
logpowerlaw = @(x,f) x(1).*f + x(2);
highpass = find(freq>=highpassfreq, 1);
lowpass = find(freq<=lowpassfreq, 1, 'last');
freq = freq(highpass:lowpass); psdx = psdx(highpass:lowpass); % cut to size
opts = optimset('Display','off');
fittedmodel = lsqcurvefit(logpowerlaw, ...
    [-2.2,3], ... % X0 (taken from fit to mean of all our spectra)
    log10(freq), ... % Xdata (between high & low pass limits)
    log10(psdx), ... % Ydata (fits to this)
    [],[],opts); % Suppress message output display
lambda = -fittedmodel(1);

errors = logpowerlaw(fittedmodel, log10(freq)) - log10(psdx);
fiterror = norm(errors); %RMSerror
maxdeviation = max(errors)/std(errors); %maximum deviation from fit