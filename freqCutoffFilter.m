function [signalLP,signalHP] = freqCutoffFilter(xData,signal,cutoffLP,cutoffHP)
%freqCutoffFilter Filters a signal through a high and lowpass filter. The
% cutoff off the respective filters is defined by the cutoff frequency.
%   Nomenclature:
% 
% [signalLP,signalHP] = freqCutoffFilter(xData,signal,cutoffLP,cutoffHP)
% 
% xData  = x data in seconds.
% signal = signal to be filtered
% cutoffHP = cutoff frequency for highpass filter in Hz.
% cutoffLP = cutoff frequency for lowpass filter in Hz.


% define frequency axis
fs = 1/(xData(2)-xData(1)); %[Hz] 
NFFT = length(xData);
df = fs/NFFT;
fAxis = ifftshift((0:df:(fs-df)) - (fs-mod(NFFT,2)*df)/2);

% filter signal
signalHP = ifft( fft(signal) .* (abs(fAxis)>cutoffHP));
signalLP = ifft( fft(signal) .* (abs(fAxis)<=cutoffLP));

end

