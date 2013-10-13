function [z] = corr0Lag(signal1, signal2)
%  Calculates the correlation at 0 lag.
% 
% Input:
% signal1
% signal2


signal1 = signal1(:);
signal2 = signal2(:);

% multiply

z = signal1.*signal2;

end

