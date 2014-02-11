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

function [data, ind, numTraces] = track_open_only_trace_hdf5(filename, ind, direction)

clearvars -except 'filename' 'ind' 'direction' 'ni'

PARAMETER = '/parameters';
DATA = '/data';
TRACE = '/trace';
STACK = '/Stack';
IMAGE = '/Images';
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


% First guesses
ImInd = 1;
dataInd = 2;
paramInd = 3;
imageStack = zeros(10, 10);

% Find out the truth
for i =1: length(info.Groups)
    switch info.Groups(i).Name
        case '/Images'
            ImInd = i;
        case '/data'
            dataInd = i;
        case '/parameters'
            paramInd = i;
    end
end 

%% Check if requested track is available
numTraces = length(info.Groups(dataInd).Datasets);
if ind > numTraces
h = warndlg(['Track number ' num2str(ind-1) ' is the last track.'], 'End of file');
uiwait(h);
ind = ind-1;
end

% %% Read in the parameters
% numParams = length( info.Groups(paramInd).Datasets); 
% for i = 1:numParams
%     name = info.Groups(paramInd).Datasets(i).Name;
%     if ~strcmpi(info.Groups(paramInd).Datasets(i).Datatype.Class, 'H5T_ENUM')
%         conditions.(name) = h5read(filename, [PARAMETER '/' name]);
%     else
%            % Ignore boolean parameters
%     end;
% end;


%% read in the trace data etc
data = cell(1, 1);

trace_name = sprintf([DATA TRACE '%d'], ind-1);
tic
traj = h5read(filename,  trace_name);
toc 
% [traj,~] = h5readc(filename,trace_name,[],[],[]);

traj.aoX = traj.aoX;
traj.aoY = traj.aoY;
traj.idx = ind;


while isempty(traj.aoX)
    h = warndlg(['Trace ' num2str(ind) ' is empty.'],'Empty datastructure');
    uiwait(h);    
    if direction == 1
        ind = ind+1;
    elseif direction == 0
        ind = ind-1;
    end
    trace_name = sprintf([DATA TRACE '%d'], ind-1);
    traj = h5read(filename,  trace_name);
    traj.aoX = traj.aoX;
    traj.aoY = traj.aoY;
    traj.idx = ind;

end

conditions = evalin('base','param');

traj.nPoints = length(traj.scannerX);
traj.t = (0:traj.nPoints-1)'/conditions.controllerUpdateClock;  % Time axis
traj.apds = [traj.apd1 traj.apd2 traj.apd3];
traj.apdsNorm = traj.apds / max(traj.apds(:));
data{1} = traj;


end

