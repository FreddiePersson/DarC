function evalTrackSingle

%% Set parameters
% 'triggering' for the kicking 'modulation' is in offsetX and offsetX in data.
%  Convert from triangular mod to triggersignal by:
% plot(sqrt(diff(osX).^2+diff(osY).^2))

%%

figHandle = 1;
if ishandle(figHandle)
    close(figHandle)
end

%% Open file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
track_filename = get_cf_highlight; %get filename from Current Folder Explorer
track_filename = track_filename{1};
disp(['Loading ''' track_filename '''...'])
[data, param, imageStack, ni, numTraces] = track_open_single_hdf5(track_filename, 1, 1);
assignin('base', 'data', data);
assignin('base', 'param', param);
assignin('base', 'ni', ni);
assignin('base', 'imageStack', imageStack);
disp('Done!')

% ni is the trace nr in data structure

%% Create UI controls %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(figHandle)

% Adapt figure to screensize
set(figHandle,'Toolbar','figure') % Show figure toolbar
screen = get(0,'ScreenSize');
screen(2) = screen(4)*0.05;
screen(4) = screen(4)*0.95;
set(figHandle,'OuterPosition',screen) 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% FIX positions etc.... 
% UI Controls position constants
xSize = [0.2 0.3 0.05 0.05 0.05 0.04 0.07 0.04 0.08];
xStep = 0.01 * ones(size(xSize));
xPos = cumsum(xStep) + [0 cumsum(xSize(1:end-1))];
 
ySize = 0.035;
yPos = 0.01;

ctrlPos.lbComment = [xPos(3)-0.2 yPos xSize(3)*2 ySize];
ctrlPos.edComment = [xPos(1) yPos xSize(2) ySize];
ctrlPos.exportTrace = [xPos(6) yPos xSize(6) ySize];
ctrlPos.lbTime = [xPos(7) yPos xSize(7) ySize];
ctrlPos.adjustTime = [xPos(8) yPos xSize(8) ySize];
ctrlPos.analyseSelection = [xPos(9) yPos xSize(9) ySize];
ctrlPos.analysisMeth = [xPos(9), yPos+0.03, xSize(9), ySize];
ctrlPos.sliderTrace = [0.5, 0.5, xSize(5), ySize];
ctrlPos.lbSlider = [xPos(3)-0.09 yPos xSize(3)*3 ySize];
ctrlPos.lbLine = [xPos(4) yPos xSize(5) ySize];
ctrlPos.puFilter = [xPos(1) 0.91 xSize(5)*2.5 ySize];
ctrlPos.edFilt1 = [xPos(1)+0.13 0.91 xSize(5) ySize];
ctrlPos.edFilt2 = [xPos(1)+0.18 0.91 xSize(5) ySize];
ctrlPos.lbFilter = [xPos(1) 0.95 xSize(5)*2.5 ySize-0.005];
ctrlPos.lbFilt1 = [xPos(1)+0.13 0.95 xSize(5) ySize-0.005];
ctrlPos.lbFilt2 = [xPos(1)+0.18 0.95 xSize(5) ySize-0.005];
ctrlPos.lbSubSampling = [xPos(1) 0.845 xSize(5)*2.5 ySize];
ctrlPos.adjustSubSampling = [xPos(1)+0.13 0.85 xSize(5) ySize];

set(gcf, 'UserData', [pwd filesep track_filename]);

lbFilename = uicontrol(...
    'Style','Text',...
    'Tag', 'main_lbFilename',...
    'String',['Filename: ' track_filename],...
    'Units','Normalized',...
    'Position', [0.25, 0.96, 0.6, 0.03],...
    'BackgroundColor',0.8*[1 1 1]...
    );

%% Laser powers

lbBeamPower = uicontrol(...
    'Style','Text',...
    'String',['Beam powers [uW]'],...
    'Units','Normalized',...
    'Position', [0.3, 0.73, 0.1, 0.03],...
    'BackgroundColor',0.8*[1 1 1]...
    );
if isfield(param, 'beamPower')
    powers = param.beamPower.Power;
    wavelength = param.beamPower.Wavelength;
    % cellstr(num2str(powers))';
    
    lbWavelength = uicontrol(...
        'Style','Text',...
        'String',cellstr(num2str(wavelength))',...
        'Units','Normalized',...
        'Position', [0.4, 0.73, 0.03, 0.05],...
        'BackgroundColor',0.8*[1 1 1]...
        );
    lbPowers = uicontrol(...
        'Style','Text',...
        'String',cellstr(num2str(powers))',...
        'Units','Normalized',...
        'Position', [0.43, 0.73, 0.03, 0.05],...
        'BackgroundColor',0.8*[1 1 1]...
        );
    
end

%% MSD analysis
pmCalcMSD = uicontrol(...
    'Style','PushButton',...
    'String','MSD',...
    'Units','Normalized',...
    'Position',[0.3, 0.94, 0.1 0.035],...
    'Enable', 'on',...
    'Callback',{@MSDCallback, gcf}...
    );
edMSDSampling = uicontrol(...
    'Tag', 'main_edMSDSampling',...
    'Style','Edit',...
    'String','5',...
    'Units','Normalized',...
    'Position',[0.4, 0.94, 0.035 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbMSDSampling = uicontrol(...
    'Style','Text',...
    'String',['[ms]'],...
    'Units','Normalized',...
    'Position',[0.435, 0.93, 0.02 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
edMSDSteps = uicontrol(...
    'Tag', 'main_edMSDSteps',...
    'Style','Edit',...
    'String','20',...
    'Units','Normalized',...
    'Position',[0.46, 0.94, 0.035 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbMSDSteps = uicontrol(...
    'Style','Text',...
    'String',['steps'],...
    'Units','Normalized',...
    'Position',[0.495, 0.93, 0.02 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );

%% CDF analysis
pmCalcCDF = uicontrol(...
    'Style','PushButton',...
    'String','CDF',...
    'Units','Normalized',...
    'Position',[0.3, 0.9, 0.1 0.035],...
    'Enable', 'on',...
    'Callback',{@CDFCallback, gcf}...
    );
edCDFSampling = uicontrol(...
    'Tag', 'main_edCDFSampling',...
    'Style','Edit',...
    'String','5',...
    'Units','Normalized',...
    'Position',[0.4, 0.9, 0.035 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbCDFSampling = uicontrol(...
    'Style','Text',...
    'String',['[ms]'],...
    'Units','Normalized',...
    'Position',[0.435, 0.89, 0.02 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );

%% Stage modulation analysis
pmStageAnalysis = uicontrol(...
    'Style','PushButton',...
    'String','Stage',...
    'Units','Normalized',...
    'Position',[0.3, 0.86, 0.1 0.035],...
    'Enable', 'on',...
    'Callback',{@stageCallback, gcf}...
    );

%% Find the tracking delay
pmDelayAnalysis = uicontrol(...
    'Style','PushButton',...
    'String','Delay',...
    'Units','Normalized',...
    'Position',[0.3, 0.82, 0.1 0.035],...
    'Enable', 'on',...
    'Callback',{@delayCallback, gcf}...
    );

%% Perform TCSPC analysis
pmTcspcAnalysis = uicontrol(...
    'Style','PushButton',...
    'String','TCSPC',...
    'Units','Normalized',...
    'Position',[0.3, 0.78, 0.1 0.035],...
    'Enable', 'on',...
    'Callback',{@tcspcAnalysisCallback, gcf}...
    );

%% FOr testing new things. The callback to put the code is located last in this m file
pmTesting = uicontrol(...
    'Style','PushButton',...
    'String','FOR TESTING',...
    'Units','Normalized',...
    'Position',[0.01, 0.25, 0.07 0.1],...
    'Enable', 'on',...
    'Callback',{@testingCallback, gcf}...
    );

%% Displaying image overlays
pmDisplayOverlay = uicontrol(...
    'Style','PushButton',...
    'String','Overlay',...
    'Units','Normalized',...
    'Position',[0.01, 0.75, 0.1 0.035],...
    'Enable', 'on',...
    'Callback',{@overlayCallback, gcf}...
    );
lbFrame = uicontrol(...
    'Style','Text',...
    'String',['Frame nr'],...
    'Units','Normalized',...
    'Position',[xPos(1)+0.13, 0.77, 0.05 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
edFrame = uicontrol(...
    'Tag', 'main_edFrame',...
    'Style','Edit',...
    'String','1',...
    'Units','Normalized',...
    'Position',[xPos(1)+0.13, 0.75, 0.05 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbMagn = uicontrol(...
    'Style','Text',...
    'String',['PixelSize'],...
    'Units','Normalized',...
    'Position',[xPos(1)+0.18, 0.77, 0.05 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );
edMagn = uicontrol(...
    'Tag', 'main_edMagn',...
    'Style','Edit',...
    'String','0.102',...
    'Units','Normalized',...
    'Position',[xPos(1)+0.18, 0.75, 0.05 0.035],...
    'BackgroundColor',0.8*[1 1 1]...
    );

%% subsampling
lbSubSampling = uicontrol(...
    'Style','Text',...
    'String',['Number of points shown:'],...
    'Units','Normalized',...
    'Position',ctrlPos.lbSubSampling,...
    'BackgroundColor',0.8*[1 1 1]...
    );
edSubSampling = uicontrol(...
    'Tag', 'main_edSubSampling',...
    'Style','Edit',...
    'String','10000',...
    'Units','Normalized',...
    'Position',ctrlPos.adjustSubSampling,...
    'Callback',{@scaleXYCallback, gcf},... 
    'BackgroundColor',0.8*[1 1 1]...
    );

%% display triggering for kicks
cbKicking = uicontrol(...
    'Style','Checkbox',...
    'Tag','main_cbKicks',...
    'String',['Show kick trigger'],...
    'Value', 0,...
    'Units','Normalized',...
    'Position',[0.01, 0.5, 0.1, 0.02],...
    'BackgroundColor',0.8*[1 1 1],...
    'Callback',{@scaleXYCallback, gcf}...
    );

%% Adding comment to txt file
lbComment = uicontrol(...
    'Style','Text',...
    'String',['Add Comment for trace (<RET> to save)'],...
    'Units','Normalized',...
    'Position',ctrlPos.lbComment,...
    'BackgroundColor',0.8*[1 1 1]...
    );
edComment = uicontrol(...
    'Tag', 'main_edComment',...
    'Style','Edit',...
    'String','',...
    'Units','Normalized',...
    'Position',ctrlPos.edComment,...
    'Callback',@commentCallback,... 
    'BackgroundColor',0.8*[1 1 1]...
    );

%% Set time interval to observe
lbTime = uicontrol(...
    'Style','Text',...
    'String',['Time adjutment [sec](<RET>)'],...
    'Units','Normalized',...
    'Position',ctrlPos.lbTime,...
    'BackgroundColor',0.8*[1 1 1]...
    );
edTime = uicontrol(...
    'Tag', 'main_edTime',...
    'Style','Edit',...
    'String','',...
    'Units','Normalized',...
    'Position',ctrlPos.adjustTime,...
    'Callback',{@timeCallback, gcf},...
    'BackgroundColor',0.8*[1 1 1]...
    );

%% Handle trace number and slider
lbTrace  = uicontrol(...
    'Tag', 'main_lbTrace',...
    'Style','Text',...
    'String','Trace: 1',...
    'Units','Normalized',...
    'Position',ctrlPos.lbLine,...
    'BackgroundColor',0.8*[1 1 1]...
    );
slTraceNum = uicontrol(...
    'Tag', 'main_slTraceNum',...
    'Style','slider',...
    'Min',1,'Max',numTraces,'Value',1,...
    'Units','Normalized',...
    'Position',ctrlPos.lbSlider,...
    'Callback',{@traceNumCallback, gcf}...
    );
% Only allow integer steps
set(slTraceNum, 'SliderStep', [1, 1]/(numTraces - 1));
set(slTraceNum, 'Value', 1);
% Listen to it dynamically
hL1 = handle.listener(slTraceNum, 'ActionEvent',...
    @(src, event)dynSliderCallback(src, event, gcf));

%% Filtering of displayed data
puFilter  = uicontrol(...
    'Style','Popup',...
    'Tag', 'main_puFilter',...
    'String','SavitskyGolay|MovingAverage|None',...
    'Value', 1,...
    'Units','Normalized',...
    'Position',ctrlPos.puFilter,...
    'Callback',{@filterCallback, gcf},...
    'BackgroundColor',0.8*[1 1 1]...
    );
edFilt1 = uicontrol(...
    'Tag', 'main_edFilt1',...
    'Style','Edit',...
    'String',num2str(11),...
    'Units','Normalized',...
    'Position',ctrlPos.edFilt1,...
    'Callback',{@filterCallback, gcf},...
    'BackgroundColor',0.8*[1 1 1]...
    );
edFilt2 = uicontrol(...
    'Tag', 'main_edFilt2',...
    'Style','Edit',...
    'String',num2str(2),...
    'Units','Normalized',...
    'Position',ctrlPos.edFilt2,...
    'Callback',{@filterCallback, gcf},...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbFilter = uicontrol(...
    'Style','Text',...
    'String',['Filter'],...
    'Units','Normalized',...
    'Position',ctrlPos.lbFilter,...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbFilt1 = uicontrol(...
    'Style','Text',...
    'String',['Window'],...
    'Units','Normalized',...
    'Position',ctrlPos.lbFilt1,...
    'BackgroundColor',0.8*[1 1 1]...
    );
lbFilt2 = uicontrol(...
    'Style','Text',...
    'String',['Order'],...
    'Units','Normalized',...
    'Position',ctrlPos.lbFilt2,...
    'BackgroundColor',0.8*[1 1 1]...
    );


%% Draw everything once and link plot axes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
val = str2double(get(puFilter, 'Value'));
if val == 1
    filt.Name = 'S-G';
elseif val == 2
    filt.Name = 'moveAv';
else
    filt.Name = 'none';
end
filt.Param = [str2double(get(edFilt1, 'String')),...
    str2double(get(edFilt2, 'String'))];
ax = drawScanSingle(data, param, filt,...
     str2double(get(edSubSampling, 'String')));
set(lbTrace, 'String', sprintf('Trace: %d', ni));

hAx = handle(ax(1));
hProp = findprop(hAx, 'XLim');
hL2 = handle.listener(hAx, hProp, 'PropertyPostSet',...
    @(src, event)scaleXYCallback(src, event, gcf));
setappdata(gcf, 'myListeners', {hL1 hL2});  

zoom on


end







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Callback functions                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Choose what trace/trajectory that should be studied
function traceNumCallback(hndl, ~, fHndl)
ni = round(get(hndl, 'Value'));
track_filename = get(fHndl, 'UserData');
[data, param, imageStack, ni, ~] = track_open_single_hdf5(track_filename, ni, 1);
assignin('base', 'data', data);
assignin('base', 'param', param);
assignin('base', 'ni', ni);
assignin('base', 'imageStack', imageStack);
set(hndl, 'Value', ni);
val = get(findobj(fHndl, 'Tag', 'main_puFilter'), 'Value');
if val == 1
    filt.Name = 'S-G';
elseif val == 2
    filt.Name = 'moveAv';
else
    filt.Name = 'none';
end
filt.Param = [str2double(get(findobj(fHndl, 'Tag', 'main_edFilt1'), 'String')),...
    str2double(get(findobj(fHndl, 'Tag', 'main_edFilt2'), 'String'))];
arrayfun(@(x) cla(x, 'reset'), findall(fHndl,'type','axes'));
drawScanSingle(data, param, filt,...
    str2double(get(findobj(fHndl, 'Tag', 'main_edSubSampling'), 'String')));
set(findobj(fHndl, 'Tag', 'main_lbTrace'), 'String', sprintf('Trace: %d', ni));
end


%% Dynamically listens to the trace slider and updates its value

function dynSliderCallback(~, ~, fHndl)
val = round(get(findobj(fHndl, 'Tag', 'main_slTraceNum'), 'Value'));
set(findobj(fHndl, 'Tag', 'main_lbTrace'), 'String', sprintf('Trace: %d', val));
end


%% Sets the length of the moving average filter used for scanners & APDs

function filterCallback(~, ~, fHndl)
filt.Param = [str2double(get(findobj(fHndl, 'Tag', 'main_edFilt1'), 'String')),...
    str2double(get(findobj(fHndl, 'Tag', 'main_edFilt2'), 'String'))];

val = get(findobj(fHndl, 'Tag', 'main_puFilter'), 'Value');
if val == 1
    filt.Name = 'S-G';
    if mod(filt.Param(1), 2) == 0
        filt.Param(1) = filt.Param(1)+1;
        set(findobj(fHndl, 'Tag', 'main_edFilt1'), 'String', num2str(filt.Param(1)));
    elseif filt.Param(1) == 1
        set(findobj(fHndl, 'Tag', 'main_puFilter'), 'Value', 3);
        filt.Name = 'none';
    end      
elseif val == 2
    filt.Name = 'moveAv';
else
    filt.Name = 'none';
end
filt.Param = [str2double(get(findobj(fHndl, 'Tag', 'main_edFilt1'), 'String')),...
    str2double(get(findobj(fHndl, 'Tag', 'main_edFilt2'), 'String'))];

data = evalin('base', 'data');
param = evalin('base', 'param');
arrayfun(@cla,findall(fHndl,'type','axes'));
drawScanSingle(data, param, filt,...
    str2double(get(findobj(fHndl, 'Tag', 'main_edSubSampling'), 'String')));
end


%% Sets the length of the moving average filter used for scanners & APDs

function overlayCallback(~, ~, fHndl)
%% read in things
param = evalin('base', 'param');
imageStack = evalin('base', 'imageStack');

%% sort out the important things
beamPos = param.beamPos;
ind = str2double(get(findobj(fHndl, 'Tag', 'main_edFrame'), 'String'));
try
    if ind<=size(imageStack, 3)
        image = imageStack(:, :, ind);
    else
        image = imageStack(:, :, 1);
    end
    magn = str2double(get(findobj(fHndl, 'Tag', 'main_edMagn'), 'String'));
    
    % Also the displayed scanner coordinates
    % Be avare that with the moving average filter you change the position of
    % the overlay. Here raw data is used
    coords = get(findobj(fHndl, 'Tag', 'XYtrajPlot'), 'UserData');
    
    drawImageOverlay(image, beamPos, magn, coords);
catch
    disp('Seems like there are no images present')
end
end


%% Puts a row in the comment.txt file

function commentCallback(hndl, ~, varargin)
fid = fopen('comment.txt', 'a+');
fprintf(fid,'%s (Trace %d): %s \n', track_filename, ni, get(edComment,'String'));
fclose(fid);
set(hndl, 'String', '');
end


%%  Sets a defined timespan to be displayed on the time plots

function timeCallback(hndl, ~, fHndl)
newTime = str2double(get(hndl, 'String'))*1e3;
ax = findobj(fHndl, 'Tag', 'linkX_x');
xlim =  get(ax, 'XLim');
set(ax, 'XLim', [xlim(1) xlim(1)+newTime])
end

%% Callback for calculating and displaying MSD analysis results

function MSDCallback(~, ~, fHndl)
disp('MSD callback enabled')
xHndl = findobj(fHndl, 'Tag', 'scannerXPlot' );
yHndl = findobj(fHndl, 'Tag', 'scannerYPlot' );
axHndl = findobj(fHndl, 'Tag', 'linkX_x');
limits = get(axHndl,'XLim');
origPlotData = get(xHndl, 'UserData');
xOrigPlotData = origPlotData(:, 1);
x1Ind = find(xOrigPlotData >= limits(1), 1, 'first'); x2Ind = find(xOrigPlotData <= limits(2), 1, 'last');
xC = origPlotData(x1Ind:x2Ind, 2);
origPlotData = get(yHndl, 'UserData');
yC = origPlotData(x1Ind:x2Ind, 2);
coords = [xC, yC];

data = evalin('base', 'data');
timeStep = data{1}.t(2)-data{1}.t(1);
samplingPeriod = str2double(get(findobj(fHndl, 'Tag', 'main_edMSDSampling'), 'String'))/1e3;
maxSteps = str2double(get(findobj(fHndl, 'Tag', 'main_edMSDSteps'), 'String'));
coords = coords(1:samplingPeriod/timeStep:end, :);

plotMSD({coords}, samplingPeriod, 1, max(size(coords)), maxSteps);
end

%% Callback for calculating and displaying CDF analysis results

function CDFCallback(~, ~, fHndl)
disp('CDF callback enabled')
xHndl = findobj(fHndl, 'Tag', 'scannerXPlot' );
yHndl = findobj(fHndl, 'Tag', 'scannerYPlot' );
axHndl = findobj(fHndl, 'Tag', 'linkX_x');
limits = get(axHndl,'XLim');
origPlotData = get(xHndl, 'UserData');
xOrigPlotData = origPlotData(:, 1);
x1Ind = find(xOrigPlotData >= limits(1), 1, 'first'); x2Ind = find(xOrigPlotData <= limits(2), 1, 'last');
xC = origPlotData(x1Ind:x2Ind, 2);
origPlotData = get(yHndl, 'UserData');
yC = origPlotData(x1Ind:x2Ind, 2);
coords = [xC, yC];

data = evalin('base', 'data');
timeStep = data{1}.t(2)-data{1}.t(1);

samplingPeriod = str2double(get(findobj(fHndl, 'Tag', 'main_edCDFSampling'), 'String'))/1e3;

[param_1state, param_2state] = plotCDF(coords, timeStep, samplingPeriod);
end

%% Callback for calculating and displaying tracking stage movement results

function stageCallback(~, ~, fHndl)
disp('Stage callback enabled')
plotStageTracking(fHndl)

end

%% Callback for calculating and displaying tracking stage movement results

function delayCallback(~, ~, fHndl)
disp('Delay callback enabled')

xHndl = findobj(fHndl, 'Tag', 'scannerXPlot' );
yHndl = findobj(fHndl, 'Tag', 'scannerYPlot' );
apdHndl = findobj(fHndl, 'Tag', 'apd1Plot' );

axHndl = findobj(fHndl, 'Tag', 'linkX_x');
limits = get(axHndl,'XLim');
origPlotData = get(xHndl, 'UserData');
xOrigPlotData = origPlotData(:, 1);
x1Ind = find(xOrigPlotData >= limits(1), 1, 'first'); x2Ind = find(xOrigPlotData <= limits(2), 1, 'last');
xC = origPlotData(x1Ind:x2Ind, 2);
origPlotData = get(yHndl, 'UserData');
yC = origPlotData(x1Ind:x2Ind, 2);
coords = [xC, yC];

origPlotData = get(apdHndl, 'UserData');
apdCounts = origPlotData(x1Ind:x2Ind, 2:end);


data = evalin('base', 'data');
timeStep = data{1}.t(2)-data{1}.t(1);

[delay] = plotDelay(coords, apdCounts, timeStep.*1e3)
end


%% TCSPC analysis callback

function tcspcAnalysisCallback(~, ~, fHndl)
disp('TCSPC Analysis callback enabled')
loadTCSPC(fHndl)
plotTCSPC(fHndl)

end


%% Corrects scales etc when zooming in plots etc

function scaleXYCallback(~, ~, fHndl)
warning off;
% Get the sub sampling from the GUI (Max nr of points in the time plots)
subSampl = str2double(get(findobj(fHndl, 'Tag', 'main_edSubSampling'), 'String'));

val = get(findobj(fHndl, 'Tag', 'main_puFilter'), 'Value');
if val == 1
    filt.Name = 'S-G';
elseif val == 2
    filt.Name = 'moveAv';
else
    filt.Name = 'none';
end
filt.Param = [str2double(get(findobj(fHndl, 'Tag', 'main_edFilt1'), 'String')),...
    str2double(get(findobj(fHndl, 'Tag', 'main_edFilt2'), 'String'))];

%% Get the handles if they are all created
try
    % Get all relevant handles
    plotHandls = zeros(1, 7);
    % scanner and stage
    plotHndls(1) = findobj(fHndl, 'Tag', 'scannerXPlot' );
    plotHndls(2) = findobj(fHndl, 'Tag', 'scannerYPlot' );
    plotHndls(3) = findobj(fHndl, 'Tag', 'stageXPlot' );
    plotHndls(4) = findobj(fHndl, 'Tag', 'stageYPlot' );
    % apds
    plotHndls(5) = findobj(fHndl, 'Tag', 'apd1Plot' );
    plotHndls(6) = findobj(fHndl, 'Tag', 'apd2Plot' );
    plotHndls(7) = findobj(fHndl, 'Tag', 'apd3Plot' );
    
    % dynamic 2D tracing plot
    axScanner = findobj(fHndl, 'Tag', 'adjustXY');
    traceHndl = findobj(fHndl, 'Tag', 'XYtrajPlot');
    traceSubHndl = findobj(fHndl, 'Tag', 'XYtrajPlot_subset');
    if isempty(get(traceHndl, 'UserData'));
        return
    end
    % wether to show kicks or not
    viewKicks = get(findobj(fHndl, 'Tag', 'main_cbKicks'), 'Value');
catch
    return
end

if viewKicks
    % Make triangular offset modulation into single trigger events
    data = evalin('base', 'data');
    if isfield(data{1}, 'offsetX')
        osX = data{1}.offsetX; osY = data{1}.offsetY;
        trigKick = sqrt(diff(osX).^2+diff(osY).^2);
        % remove 2 first trigger events (due to setting offset for the scanning area)
        trigKick(find(trigKick, 2, 'first')) = 0;
        % set all triggers to same height
        trigKick(find(trigKick)) = 1;
        trigKick(end+1) = 0;
    else
        viewKicks = 0;
    end
end

try
    
    % Take the limits from a APD axis. Important since APDs are what the
    % listener listens too..
    limits =  get(get(plotHndls(6), 'Parent'),'XLim');
    
    % Load the UserData (ie the saved entire data range in for the plot)
    origPlotData = get(plotHndls(1), 'UserData');
    xOrigPlotData = origPlotData(:, 1);
    
    % Find the indexes for the current zoom
    x1Ind = find(xOrigPlotData >= limits(1), 1, 'first'); x2Ind = find(xOrigPlotData <= limits(2), 1, 'last');
    % Calculate the number of steps between displayed datapoints to be used
    samplStep = ceil((x2Ind-x1Ind)/subSampl);
    
    % Initiate variables used in the loop
    scXmed = 0;
    scYmed = 0;
    apdMax = 1;
    
    % Fix all the axis and smaller XY data on the temporal plots
    apdInd = 1;
    for ind = 1:length(plotHndls)
        origPlotData = get(plotHndls(ind), 'UserData');
        xOrigPlotData = origPlotData(:, 1);
        yOrigPlotData = origPlotData(:, 2:end);
        
        
        if strcmp(get(plotHndls(ind), 'Tag'), 'scannerXPlot')
            temp = filterData(yOrigPlotData, filt);
            set(plotHndls(ind), 'XData', xOrigPlotData(x1Ind:samplStep:x2Ind),...
                'YData', temp(x1Ind:samplStep:x2Ind));
            scXmed = median(yOrigPlotData(x1Ind:samplStep:x2Ind));
            %         set(get(plotHndls(ind), 'Parent'), 'YLim',...
            %             [min(yOrigPlotData(x1Ind:samplStep:x2Ind)), max(yOrigPlotData(x1Ind:samplStep:x2Ind))],...
            %             'XLim', limits);
            set(axScanner, 'XLim', [min(yOrigPlotData(x1Ind:x2Ind)), max(yOrigPlotData(x1Ind:x2Ind))]);
        elseif strcmp(get(plotHndls(ind), 'Tag'), 'scannerYPlot')
            temp = filterData(yOrigPlotData, filt);
            set(plotHndls(ind), 'XData', xOrigPlotData(x1Ind:samplStep:x2Ind),...
                'YData', temp(x1Ind:samplStep:x2Ind));
            scYmed = median(yOrigPlotData(x1Ind:samplStep:x2Ind));
            %         set(get(plotHndls(ind), 'Parent'), 'YLim',...
            %             [min(yOrigPlotData(x1Ind:samplStep:x2Ind)), max(yOrigPlotData(x1Ind:samplStep:x2Ind))],...
            %             'XLim', limits);
            set(axScanner,'YLim', [min(yOrigPlotData(x1Ind:x2Ind)), max(yOrigPlotData(x1Ind:x2Ind))]);
        elseif strcmp(get(plotHndls(ind), 'Tag'), 'stageXPlot')
            med = median(yOrigPlotData(x1Ind:samplStep:x2Ind)) - scXmed;
            set(plotHndls(ind), 'XData', xOrigPlotData(x1Ind:samplStep:x2Ind),...
                'YData', yOrigPlotData(x1Ind:samplStep:x2Ind)-med);
        elseif strcmp(get(plotHndls(ind), 'Tag'), 'stageYPlot')
            med = median(yOrigPlotData(x1Ind:samplStep:x2Ind)) - scYmed;
            set(plotHndls(ind), 'XData', xOrigPlotData(x1Ind:samplStep:x2Ind),...
                'YData', yOrigPlotData(x1Ind:samplStep:x2Ind)-med);
        elseif ~isempty(regexp(get(plotHndls(ind), 'Tag'), 'apd'))
            temp = filterData(yOrigPlotData(:, apdInd), filt);
            apdMax = max(apdMax, max(yOrigPlotData(x1Ind:samplStep:x2Ind)));
            set(plotHndls(ind), 'XData', xOrigPlotData(x1Ind:samplStep:x2Ind),...
                'YData', temp(x1Ind:samplStep:x2Ind));
            apdInd = apdInd+1;
            %         set(get(plotHndls(ind), 'Parent'), 'YLim',...
            %             [0, apdMax], 'XLim', limits);
        end
    end
    
    
    
    %% Add the kicking trigger to the plots
    
    if viewKicks
        for ind = [1 2 6]
            yLimits = get(get(plotHndls(ind), 'Parent'), 'YLim');
            tempTrig = trigKick*(yLimits(2)-yLimits(1))+yLimits(1);
            axes(get(plotHndls(ind), 'Parent'));
            hold all
            plot(xOrigPlotData(x1Ind:x2Ind),...
                tempTrig(x1Ind:x2Ind), 'Color', [0.5, 0.5, 0.5], 'Tag',...
                ['trigXPlot', num2str(ind)]);
            hold off
        end
    else
        for ind = [1 2 6]
            delete(findobj(fHndl, 'Tag', ['trigXPlot', num2str(ind)]));
        end
    end
    
    set(cell2mat(get(plotHndls, 'Parent')), 'YLimMode', 'auto', 'XLim', limits);
    
    %% Fix the dynamic 2D tracing plot
    % Get whole data range
    xyTrajOrigPlotData = get(traceHndl,'UserData');
    xyTrajDataX = xyTrajOrigPlotData(:, 1);
    xyTrajDataY = xyTrajOrigPlotData(:, 2);
    
    % Set the red thick plot to a subset
    tempX = filterData(xyTrajDataX, filt);
    tempY = filterData(xyTrajDataY, filt);
    
    set(traceHndl,...
        'XData', tempX(1:samplStep:end), ...
        'YData', tempY(1:samplStep:end)...
        );
    set(traceSubHndl,...
        'XData', tempX(x1Ind:samplStep:x2Ind), ...
        'YData', tempY(x1Ind:samplStep:x2Ind)...
        );
    % set(hxyTrajSub,...
    %     'XData', xyTrajDataX(xOrigPlotData > limits(1) & xOrigPlotData < limits(2)), ...
    %     'YData', xyTrajDataY(xOrigPlotData > limits(1) & xOrigPlotData < limits(2)) ...
    %     );
    
catch
    disp('Something went wrong in the scaleXYCallback function')
end
warning on;
end

%% For testing different things

function testingCallback(~, ~, fHndl)
disp('Testing callback enabled')
data = evalin('base', 'data');
param = evalin('base', 'param');

% Write whatever code you want to try out....



end