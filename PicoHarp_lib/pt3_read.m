function trace = pt3_read(filename)
tic
%% Open File
% filename = ['P:\Shared\from_Martin\13.06.17 Mediciones NRB_642\STED power 88\NRB_642_88_4\NRB_642_88_4.pt3'];
fid=fopen(filename);

%% The following represents the readable ASCII file header portion 

Ident = char(fread(fid, 16, 'char'));
FormatVersion = deblank(char(fread(fid, 6, 'char')'));
CreatorName = char(fread(fid, 18, 'char'));
CreatorVersion = char(fread(fid, 12, 'char'));
FileTime = char(fread(fid, 18, 'char'));
CRLF = char(fread(fid, 2, 'char'));
CommentField = char(fread(fid, 256, 'char'));

%% The following is binary file header information

Curves = fread(fid, 1, 'int32');
BitsPerRecord = fread(fid, 1, 'int32');
RoutingChannels = fread(fid, 1, 'int32');
NumberOfBoards = fread(fid, 1, 'int32');
ActiveCurve = fread(fid, 1, 'int32');
MeasurementMode = fread(fid, 1, 'int32');
SubMode = fread(fid, 1, 'int32');
RangeNo = fread(fid, 1, 'int32');
Offset = fread(fid, 1, 'int32');
AcquisitionTime = fread(fid, 1, 'int32');
StopAt = fread(fid, 1, 'int32');
StopOnOvfl = fread(fid, 1, 'int32');
Restart = fread(fid, 1, 'int32');
DispLinLog = fread(fid, 1, 'int32');
DispTimeFrom = fread(fid, 1, 'int32');
DispTimeTo = fread(fid, 1, 'int32');
DispCountFrom = fread(fid, 1, 'int32');
DispCountTo = fread(fid, 1, 'int32');

for i = 1:8
DispCurveMapTo(i) = fread(fid, 1, 'int32');
DispCurveShow(i) = fread(fid, 1, 'int32');
end;

for i = 1:3
ParamStart(i) = fread(fid, 1, 'float');
ParamStep(i) = fread(fid, 1, 'float');
ParamEnd(i) = fread(fid, 1, 'float');
end;

RepeatMode = fread(fid, 1, 'int32');
RepeatsPerCurve = fread(fid, 1, 'int32');
RepeatTime = fread(fid, 1, 'int32');
RepeatWait = fread(fid, 1, 'int32');
ScriptName = char(fread(fid, 20, 'char'));

%% The next is a board specific header

HardwareIdent = char(fread(fid, 16, 'char'));
HardwareVersion = char(fread(fid, 8, 'char'));
HardwareSerial = fread(fid, 1, 'int32');
SyncDivider = fread(fid, 1, 'int32');
CFDZeroCross0 = fread(fid, 1, 'int32');
CFDLevel0 = fread(fid, 1, 'int32');
CFDZeroCross1 = fread(fid, 1, 'int32');
CFDLevel1 = fread(fid, 1, 'int32');
Resolution = fread(fid, 1, 'float');
RouterModelCode      = fread(fid, 1, 'int32');      % Router settings are meaningful only for an existing router: RouterModelCode>0
RouterEnabled        = fread(fid, 1, 'int32');

% Router Ch1
RtChan1_InputType    = fread(fid, 1, 'int32');
RtChan1_InputLevel   = fread(fid, 1, 'int32');
RtChan1_InputEdge    = fread(fid, 1, 'int32');
RtChan1_CFDPresent   = fread(fid, 1, 'int32');
RtChan1_CFDLevel     = fread(fid, 1, 'int32');
RtChan1_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch2
RtChan2_InputType    = fread(fid, 1, 'int32');
RtChan2_InputLevel   = fread(fid, 1, 'int32');
RtChan2_InputEdge    = fread(fid, 1, 'int32');
RtChan2_CFDPresent   = fread(fid, 1, 'int32');
RtChan2_CFDLevel     = fread(fid, 1, 'int32');
RtChan2_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch3
RtChan3_InputType    = fread(fid, 1, 'int32');
RtChan3_InputLevel   = fread(fid, 1, 'int32');
RtChan3_InputEdge    = fread(fid, 1, 'int32');
RtChan3_CFDPresent   = fread(fid, 1, 'int32');
RtChan3_CFDLevel     = fread(fid, 1, 'int32');
RtChan3_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch4
RtChan4_InputType    = fread(fid, 1, 'int32');
RtChan4_InputLevel   = fread(fid, 1, 'int32');
RtChan4_InputEdge    = fread(fid, 1, 'int32');
RtChan4_CFDPresent   = fread(fid, 1, 'int32');
RtChan4_CFDLevel     = fread(fid, 1, 'int32');
RtChan4_CFDZeroCross = fread(fid, 1, 'int32');

%% The next is a T3 mode specific header

ExtDevices = fread(fid, 1, 'int32');
Reserved1 = fread(fid, 1, 'int32');
Reserved2 = fread(fid, 1, 'int32');
CntRate0 = fread(fid, 1, 'int32');
CntRate1 = fread(fid, 1, 'int32');
StopAfter = fread(fid, 1, 'int32');
StopReason = fread(fid, 1, 'int32');
Records = fread(fid, 1, 'uint32');
ImgHdrSize = fread(fid, 1, 'int32');
ImgHdr = fread(fid, ImgHdrSize, 'int32');       %Special header for imaging 

%%  This reads the T3 mode event records

ofltime = 0;
WRAPAROUND=65536;

amount_p_ch1=0;     %Counters
amount_p_ch2=0;
amount_p_ch3=0;
amount_p_ch4=0;
amount_pc=0;
amount_lc=0;
amount_o=0;

syncperiod = 1E9/CntRate0;   % in nanoseconds

tiempo= zeros(Records,1);
tiempo_par= zeros(Records,1);
data= zeros(Records,1);
truetime = zeros(Records,1);
T3Record = zeros(Records,1);


T3Record = fread(fid, Records, 'ubit32');     % all 32 bits. Ex: A = fread(fileID, sizeA, precision)
%   +-------------------------------+  +-------------------------------+ 
%   |x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|  |x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|x|
%   +-------------------------------+  +-------------------------------+  

fclose(fid);

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

% Obtain all records 
nsync   = bitand(T3Record,65535);       
chan    = bitand(bitshift(T3Record,-28),15);   
dtime   = bitand(bitshift(T3Record,-16),4095);
markers = bitand(bitshift(T3Record,-16),15);

% Calculate real times
trace.trueSync      = nsync + cumsum(chan==15 & markers==0)* WRAPAROUND; %takes intoaccount the nsync overflow
trace.trueTime      = dtime * Resolution + trace.trueSync * syncperiod;  %trueTime includes sync time and delay time
trace.relativeTime  = dtime * Resolution;

% Individual markers
trace.ch1       = (chan==1);
trace.ch2       = (chan==2);
trace.ch3       = (chan==3);
trace.ch4       = (chan==4);
trace.marker1   = (chan==15 & markers==1);
trace.marker2   = (chan==15 & markers==2);
trace.marker3   = (chan==15 & markers==3);
trace.marker4   = (chan==15 & markers==4);

elapsedTime = toc;
disp(['Load time: ' num2str(elapsedTime) 's'])


end

