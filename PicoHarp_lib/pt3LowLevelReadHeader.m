function header = pt3LowLevelReadHeader(fid)

%% The following represents the readable ASCII file header portion 

header.Ident = char(fread(fid, 16, 'char'));
header.FormatVersion = deblank(char(fread(fid, 6, 'char')'));
header.CreatorName = char(fread(fid, 18, 'char'));
header.CreatorVersion = char(fread(fid, 12, 'char'));
header.FileTime = char(fread(fid, 18, 'char'));
header.CRLF = char(fread(fid, 2, 'char'));
header.CommentField = char(fread(fid, 256, 'char'));

%% The following is binary file header information

header.Curves = fread(fid, 1, 'int32');
header.BitsPerRecord = fread(fid, 1, 'int32');
header.RoutingChannels = fread(fid, 1, 'int32');
header.NumberOfBoards = fread(fid, 1, 'int32');
header.ActiveCurve = fread(fid, 1, 'int32');
header.MeasurementMode = fread(fid, 1, 'int32');
header.SubMode = fread(fid, 1, 'int32');
header.RangeNo = fread(fid, 1, 'int32');
header.Offset = fread(fid, 1, 'int32');
header.AcquisitionTime = fread(fid, 1, 'int32');
header.StopAt = fread(fid, 1, 'int32');
header.StopOnOvfl = fread(fid, 1, 'int32');
header.Restart = fread(fid, 1, 'int32');
header.DispLinLog = fread(fid, 1, 'int32');
header.DispTimeFrom = fread(fid, 1, 'int32');
header.DispTimeTo = fread(fid, 1, 'int32');
header.DispCountFrom = fread(fid, 1, 'int32');
header.DispCountTo = fread(fid, 1, 'int32');

for i = 1:8
header.DispCurveMapTo(i) = fread(fid, 1, 'int32');
header.DispCurveShow(i) = fread(fid, 1, 'int32');
end;

for i = 1:3
header.ParamStart(i) = fread(fid, 1, 'float');
header.ParamStep(i) = fread(fid, 1, 'float');
header.ParamEnd(i) = fread(fid, 1, 'float');
end;

header.RepeatMode = fread(fid, 1, 'int32');
header.RepeatsPerCurve = fread(fid, 1, 'int32');
header.RepeatTime = fread(fid, 1, 'int32');
header.RepeatWait = fread(fid, 1, 'int32');
header.ScriptName = char(fread(fid, 20, 'char'));

%% The next is a board specific header

header.HardwareIdent = char(fread(fid, 16, 'char'));
header.HardwareVersion = char(fread(fid, 8, 'char'));
header.HardwareSerial = fread(fid, 1, 'int32');
header.SyncDivider = fread(fid, 1, 'int32');
header.CFDZeroCross0 = fread(fid, 1, 'int32');
header.CFDLevel0 = fread(fid, 1, 'int32');
header.CFDZeroCross1 = fread(fid, 1, 'int32');
header.CFDLevel1 = fread(fid, 1, 'int32');
header.Resolution = fread(fid, 1, 'float');
header.RouterModelCode      = fread(fid, 1, 'int32');      % Router settings are meaningful only for an existing router: RouterModelCode>0
header.RouterEnabled        = fread(fid, 1, 'int32');

% Router Ch1
header.RtChan1_InputType    = fread(fid, 1, 'int32');
header.RtChan1_InputLevel   = fread(fid, 1, 'int32');
header.RtChan1_InputEdge    = fread(fid, 1, 'int32');
header.RtChan1_CFDPresent   = fread(fid, 1, 'int32');
header.RtChan1_CFDLevel     = fread(fid, 1, 'int32');
header.RtChan1_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch2
header.RtChan2_InputType    = fread(fid, 1, 'int32');
header.RtChan2_InputLevel   = fread(fid, 1, 'int32');
header.RtChan2_InputEdge    = fread(fid, 1, 'int32');
header.RtChan2_CFDPresent   = fread(fid, 1, 'int32');
header.RtChan2_CFDLevel     = fread(fid, 1, 'int32');
header.RtChan2_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch3
header.RtChan3_InputType    = fread(fid, 1, 'int32');
header.RtChan3_InputLevel   = fread(fid, 1, 'int32');
header.RtChan3_InputEdge    = fread(fid, 1, 'int32');
header.RtChan3_CFDPresent   = fread(fid, 1, 'int32');
header.RtChan3_CFDLevel     = fread(fid, 1, 'int32');
header.RtChan3_CFDZeroCross = fread(fid, 1, 'int32');
% Router Ch4
header.RtChan4_InputType    = fread(fid, 1, 'int32');
header.RtChan4_InputLevel   = fread(fid, 1, 'int32');
header.RtChan4_InputEdge    = fread(fid, 1, 'int32');
header.RtChan4_CFDPresent   = fread(fid, 1, 'int32');
header.RtChan4_CFDLevel     = fread(fid, 1, 'int32');
header.RtChan4_CFDZeroCross = fread(fid, 1, 'int32');

%% The next is a T3 mode specific header

header.ExtDevices = fread(fid, 1, 'int32');
header.Reserved1 = fread(fid, 1, 'int32');
header.Reserved2 = fread(fid, 1, 'int32');
header.CntRate0 = fread(fid, 1, 'int32');
header.CntRate1 = fread(fid, 1, 'int32');
header.StopAfter = fread(fid, 1, 'int32');
header.StopReason = fread(fid, 1, 'int32');
header.Records = fread(fid, 1, 'uint32');
header.ImgHdrSize = fread(fid, 1, 'int32');
header.ImgHdr = fread(fid, header.ImgHdrSize, 'int32');       %Special header for imaging 

end