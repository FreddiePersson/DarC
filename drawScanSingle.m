function [ax] = drawScanSingle(data, cond, filt, subSampl)


%% Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preallocate variables:
dataT = data{1}.t*1e3;

% Time selection
% t_selAll = (data{1}.t>0.0) & (data{1}.t<max(data{1}.t)); % All the trace is selected
% t_sel = (data{1}.t>0.0) & (data{1}.t<inf); % All the trace after activation

% Time range for displaying the trigger signals
timeRange = [0, max(data{1}.t)*1e3];

% The sampling step to use
% samplStep = ceil((max(dataT)-min(dataT))/subSampl);
samplStep = 1;

%% APD Counts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ax(1) = subplot(423);
% plotColor = 'rgb';
plotColor = [
    1 0 0
    0 0.5 0
    0 0 1];

apdCounts = data{1}.apds.*cond.controllerUpdateClock./1e3;
% offset = [zeros(size(apdsScaled(:,1))),...
%     repmat(max(max(apdsScaled(:,1))),size(apdsScaled(:,1))),...
%     repmat(max(max(apdsScaled(:,1)))+max(max(apdsScaled(:,2))),size(apdsScaled(:,2)))];

for i = 1:size(apdCounts,2)
    apds_Filt = filterData(apdCounts, filt);
    h = stem(dataT(1:samplStep:end), apds_Filt(1:samplStep:end, i),...
        'Color',plotColor(i,:), ...
        'Tag', ['apd' num2str(i) 'Plot'],...
        'Marker','none',...
        'LineStyle','-');
    hold all
    set(h, 'UserData', [dataT, apdCounts]);
end

% TODO: sum of counts is not calculated here, but at the end next to the
% histogram part. It should be here with the global filters.

% plot([0 max(dataT)], cond.fbThresholdValue.*[1 1]./1e3, 'c', 'LineWidth', 2); %threshold line
hold off;
grid on
title('APDs Counts');
ylabel('Counts [kHz]');
axis tight
set(gca,'Tag','linkX_apd');
% ylim('manual')
hold off


%% Scanner X %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(2) = subplot(4,2,5);

 
% scannerX_Filt = filterData(data{1}.scannerX*1e3, filt);  % Filter data (For the moment disabled)
scannerX_Filt = data{1}.scannerX*1e3;
plot(...
    dataT(1:samplStep:end), scannerX_Filt(1:samplStep:end), 'b',...
    'Tag', 'scannerXPlot',...
    'UserData', [dataT, data{1}.scannerX*1e3]);
hold all

stageX = (data{1}.stageX)*1e3;
stageX = (stageX-(median(stageX)-median(scannerX_Filt)));
plot(...
    dataT(1:samplStep:end), stageX(1:samplStep:end)', 'r',...
    'Tag', 'stageXPlot',...
    'UserData', [dataT, stageX]); 

hold off
grid on
axis tight

ylabel('Scanner Position X [nm]');

set(gca,'Tag','linkX_x')
%% Scanner Y %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ax(3) = subplot(4,2,7);


% Filter data (For the moment disabled)
% scannerY_Filt = filterData(data{1}.scannerY*1e3, filt);
scannerY_Filt = data{1}.scannerY*1e3;
plot(...
    dataT(1:samplStep:end), scannerY_Filt(1:samplStep:end), 'b',...
    'Tag', 'scannerYPlot',...
    'UserData', [dataT, data{1}.scannerY*1e3]);
hold all

stageY = (data{1}.stageY)*1e3;
stageY = (stageY-(median(stageY)-median(scannerY_Filt)));
plot(...
    dataT(1:samplStep:end), stageX(1:samplStep:end)', 'r',...
    'Tag', 'stageYPlot',...
    'UserData', [dataT, stageY]); 

hold off
grid on
axis tight

ylabel('Scanner Position Y [nm]');

set(gca,'Tag','linkX_y');
%% Digital trigger signals

% ax(4) = subplot(423);
% try
%     h = plot(...
%         dataT, 4+0.9 * data{1}.isFeedbackEnabled,...
%         dataT, 3+0.9 * data{1}.isThresholdEnabled,...
%         dataT, 2+0.9 * data{1}.activation,...
%         'lineWidth',2);
%     legend(...
%             'Feedback Enable',...
%             'Threshold Enable',...
%             'Activation Pulse');
% catch
%         h = plot(dataT,data{1}.isFeedbackEnabled);
% end
% 
% set(h, 'Tag', 'triggerPlot');
% 
% xlim(timeRange);
% grid on
% axis tight
% set(gca,'Tag','linkX_trig');
% ylim('manual')

%% Analog Output Trajectory

% subplot(222);
% plot((data{1}.aoX(t_selAll)),(data{1}.aoY(t_selAll)))
% hold on
% plot((data{1}.aoX(1)),(data{1}.aoY(1)),'ok')
% hold off
% grid on
% xlabel('X [V]')
% ylabel('Y [V]')
% grid on
% title('AO trajectory')
% % axis image
% xlim([0 8])
% ylim([0 8])
% % axis tight
% daspect([1 1 1])
% 
% % Target points grid display
% scanRngX = cond.fbOffset(1) + linspace(-cond.scanSize(1)/2,cond.scanSize(1)/2,cond.scanPixels(1));
% scanRngY = cond.fbOffset(2) + linspace(-cond.scanSize(2)/2,cond.scanSize(2)/2,cond.scanPixels(2));
% [scanRngXMesh scanRngYMesh] = meshgrid(scanRngX , scanRngY);
% hold on
% plot(scanRngXMesh,scanRngYMesh,'sqk')
% hold off


%% Scanner trajectory

% subplot(2, 2, [2 4])
subplot(2, 2, 2)

h = plot(scannerX_Filt, scannerY_Filt, 'Tag','XYtrajPlot');
set(h, 'UserData', [data{1}.scannerX*1e3, data{1}.scannerY*1e3])
hold on

h = plot(scannerX_Filt, scannerY_Filt,...
    'r',...
    'linewidth',2,...
    'Tag','XYtrajPlot_subset');

hold off

xlabel('X [nm]')
ylabel('Y [nm]')
grid on
title('Scanner trajectory')
daspect([1 1 1])
set(gca,'Tag','adjustXY')
% ylim('manual')
axis equal
linkaxes(ax,'x');
% addlistener(ax(2), 'XLim', 'PostSet', @(src, event)scaleXYCallback(src, event, ax(2), gcf));

%% Histogram of counts

filtConstant = str2num(get(findobj(gcf, 'Tag', 'main_edHist'), 'String')); % in ms
filtCoeff = filtConstant/(dataT(2)-dataT(1));
apdCountsSumFiltered = conv(sum(apdCounts,2),ones(1,filtCoeff)./sum(ones(1,filtCoeff)),'same');
% TODO: this average should not be calculated here.
hold(ax(1), 'on'); 
plot(ax(1), dataT, apdCountsSumFiltered, 'k','linewidth',2);
hold(ax(1), 'off'); 
subplot(2,2,4)
hist(apdCountsSumFiltered,100)
xlabel('Counts [kHz]')
title(['Averaged APD-counts. Averaging: ',num2str(filtConstant),' ms'])


end


