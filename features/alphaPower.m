function [avgpower] = alphaPower(eeg,Fs)
%ALPHAPOWER Calculates log band power in the alpha (8-13Hz) band of an
% EEG signal.

x = eeg;
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

assert(length(psdx)==length(freq))

power8to13 = psdx((freq >= 8) & (freq <= 13));
avgpower = mean(power8to13);

end
