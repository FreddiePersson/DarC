function [trace, pt3info] = pt3_readByChunks(filename)
% tic
fid=fopen(filename);

pt3info = pt3LowLevelReadHeader(fid);

% Number of chunks to load the file.
maxRecordsPerChunk = 1e5;
chunks = ceil(pt3info.Records/maxRecordsPerChunk);

chunkSize = [maxRecordsPerChunk(ones(1,chunks-1)) pt3info.Records-(chunks-1)*maxRecordsPerChunk];

% [trace.trueSync trace.relativeTime trace.chan trace.markers] = deal(zeros(maxRecordsPerChunk,1));
% trace.endsync = 0
% traceChunks(1:chunks) = trace;

for i=1:chunks
    traceChunks(i) = pt3LowLevelChunkReader(fid,pt3info,chunkSize(i));
    recordsPerChunk(i) = length(traceChunks(i).trueSync);
end
fclose(fid);

totalRecords = sum(recordsPerChunk);

[trace.trueSync trace.relativeTime trace.chan trace.markers trace.endsync] = deal(zeros(1,totalRecords));

%%

syncOffset = [0 traceChunks(1:end-1).endSync];

for i=1:chunks
    jointIndex = (1:recordsPerChunk(i))+sum(recordsPerChunk(1:i-1));
    trace.trueSync(jointIndex)      = traceChunks(i).trueSync + sum(syncOffset(1:i));
    trace.relativeTime(jointIndex)  = traceChunks(i).relativeTime;
    trace.chan(jointIndex)          = traceChunks(i).chan;
    trace.markers(jointIndex)       = traceChunks(i).markers;
end

%  toc


%% Interpretation of Records

% NSYNC
% the lowest 16 bits: 65535==1111111111111111 Ex: C = bitand(A,B) calculates the bit-wise AND of arguments A and B.
%   +-------------------------------+  +-------------------------------+ 
%   | | | | | | | | | | | | | | | | |  |x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|
%   +-------------------------------+  +-------------------------------+  
% CHANNELS
% the upper 4 bits: Ex: Shifting 1100 (12, decimal) to the left two bits yields 110000 (48, decimal)    I move it to the right 28 positions and then multiply by 1111
%   +-------------------------------+  +-------------------------------+ 
%   |x|x|x|x| | | | | | | | | | | | |  | | | | | | | | | | | | | | | | |
%   +-------------------------------+  +-------------------------------+
% DTIME    
% if chan = 1,2,3 or 4, then these  bits contain the dtime:     4095==111111111111
%   +-------------------------------+  +-------------------------------+ 
%   | | | | |x|x|x|x|x|x|x|x|x|x|x|x|  | | | | | | | | | | | | | | | | |
%   +-------------------------------+  +-------------------------------+    
% MARKERS
% This means we have a special record (15==1111)
% where these four bits are markers:
%   +-------------------------------+  +-------------------------------+ 
%   | | | | | | | | | | | | |x|x|x|x|  | | | | | | | | | | | | | | | | |
%   +-------------------------------+  +-------------------------------+


