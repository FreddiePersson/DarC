function trace = pt3LowLevelChunkReader(fid,pt3info,chunkSize)

% Constants.
ofltime = 0;
WRAPAROUND=65536;
syncperiod = 1E9/pt3info.CntRate0; 

% Initialization
T3Record = zeros(chunkSize,1);
T3Record = fread(fid, chunkSize, 'ubit32');     % all 32 bits. Ex: A = fread(fileID, sizeA, precision)

% Obtain all records 
nsync   = bitand(T3Record,65535);       
chan    = bitand(bitshift(T3Record,-28),15);   
dtime   = bitand(bitshift(T3Record,-16),4095);
markers = bitand(bitshift(T3Record,-16),15);

% Calculate real times
trueSync      = nsync + cumsum(chan==15 & markers==0)* WRAPAROUND; %takes intoaccount the nsync overflow
% trueTime      = dtime * pt3info.Resolution + trueSync * syncperiod;  %trueTime includes sync time and delay time
relativeTime  = dtime * pt3info.Resolution;

% Indexing rule excluding OVERFLOW markers.
outputIndex = ~(chan==15 & markers==0); 

% Output records.
trace.trueSync      = trueSync(outputIndex)*syncperiod;
% trace.trueTime      = trueTime(outputIndex);
trace.relativeTime  = relativeTime(outputIndex);
trace.chan          = chan(outputIndex);
trace.markers       = (chan(outputIndex)==15).* markers(outputIndex);
trace.endSync = trueSync(end)*syncperiod; % Output last syncperiod to add to the next chunk.

% trace.chan = [1 2 3 4] means the channels. 
% trace.chan = [10 20 30 40] means the markers.
