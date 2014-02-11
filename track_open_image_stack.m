% function to read the labview generated file
%
% input: the filename to be read and index of the trace
% outputs:
%  - data: a cell array with one cell for each point measured in the sample
%          each cell is a struct with the following elements
%          - t: Time axis
%          - nPoints: #points in each trace
%          - idx: #measurement point
%          - aoX: Commanded position to scanner in X
%          - aoY: Commanded position to scanner in Y
%          - scannerX: Measured position of scanner in X
%          - scannerY: Measured position of scanner in Y
%          - stageX: Stage position in X
%          - stageY: Stage position in Y
%          - trigger: Stage movement trigger
%          - feedbackEnable: feedback state
%          - apd1: APD 1 counts
%          - apd2: APD 2 counts
%          - apd3: APD 3 counts
%          - apds: Combined APD counts
%          - apds_norm: Combined APD counts
% - conditions: a single struct with the following elements
%          - adcClock
%          - controlP
%          - controllerUpdateClock

function [imageStack, beamPos] = track_open_image_stack(filename)

% clearvars -except 'filename' 'ind' 'direction' 'ni'

% Groups
PARAMETER = '/parameters';
DATA = '/data';
TRACE = '/trace';
IMAGE = '/Images';

% Elements
STACK = '/Stack';
BP = '/Beam Position';

% h5disp(filename)

try
    info = h5info(filename);
catch
    [filename, pathname] = uigetfile({'*.h5', 'HDF (*.h5)'}, 'Select tracking file (HDF format)');
     if ( filename == 0 )
        filename = 0;
        pathname = 0;
        error('No valid HDF file selected!')
        return
     else
         filename = [ pathname, filename ];
         info = h5info(filename);
     end
end

imageStack = h5read(filename, [IMAGE STACK]);
beamPos = h5read(filename, [IMAGE BP]);

end

