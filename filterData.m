function [signal_Filt] = filterData(signal, filt)
%movingAvFilter Filters a signal by a moving average of length 'window'.
% 
% [signal_Filt] = movingAvFilter(signal, window)
% 
% INPUT:
% signal = The signal to be filtered. If 'signal' is a 2D matrix it is
%          filtered along its largest dimension.
% filt = a struct containing name and parameters for the filtering
% 
% OUTPUT:
% signal_Filt = The filtered signal of the same length as 'signal'.

%% Perform filtering

signalDims = size(signal);
    

if length(signalDims)>2
    warndlg('Invalid input to function movingAvFilter.', 'Aborting');
    return;
else
    signal_Filt = zeros(size(signal));
    for ind = 1:min(signalDims)
        if signalDims(1)<signalDims(2)
            if strcmp(filt.Name, 'S-G')
                signal_Filt(ind, :) = sgolayfilt(signal(ind, :), filt.Param(2), filt.Param(1));
            elseif strcmp(filt.Name, 'moveAv')
                moveAvFilter = ones(1, filt.Param(1))./filt.Param(1);
                signal_Filt(ind, :) = conv(signal(ind, :), moveAvFilter, 'same');
            else
                signal_Filt = signal;
            end
        else
            if strcmp(filt.Name, 'S-G')
                signal_Filt(:, ind) = sgolayfilt(signal(:, ind), filt.Param(2), filt.Param(1));
            elseif strcmp(filt.Name, 'moveAv')
                moveAvFilter = ones(1, filt.Param(1))./filt.Param(1);
                signal_Filt(:, ind) = conv(signal(:, ind), moveAvFilter, 'same');
            else
                signal_Filt = signal;
            end
        end
    end
end

end


