function [psdx, freq] = powerspectraldensity(x, Fs, highpass, lowpass, display)
%PSD Estimates a signal's whole-epoch power spectral density using FFT.
%   Detailed explanation goes here

if ~exist('display','var')
    display=false; % defaults to not displaying plot
end
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

if exist('lowpass','var')
    psdx = psdx(freq<=lowpass);
    freq = freq(freq<=lowpass);
end

if exist('highpass','var')
    psdx = psdx(freq>=highpass);
    freq = freq(freq>=highpass);
end

if display==true
    plot(freq,10*log10(psdx))
    grid on
    title('Periodogram Using FFT')
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (dB/Hz)')
end
end