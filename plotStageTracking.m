function [] = plotStageTracking(fHndl)
% Finds and plots the 'delay' as depined as the sampling time where the
% correlation between steplength and countdeviation between the 3 detectors
% is at its maximum.
% 
% INPUT:
% fHndl = The figure handle for the base figure
% 
% OUTPUT:
% 

%% Read in data

data = evalin('base', 'data');
param = evalin('base', 'param');

%% Read in filter parameters
        
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

%% Read in raw unsmoothed data for the displayed timerange

xHndl = findobj(fHndl, 'Tag', 'scannerXPlot' );
yHndl = findobj(fHndl, 'Tag', 'scannerYPlot' );
xStageHndl = findobj(fHndl, 'Tag', 'stageXPlot' );
yStageHndl = findobj(fHndl, 'Tag', 'stageYPlot' );
apdHndl = findobj(fHndl, 'Tag', 'apd1Plot' );

axHndl = findobj(fHndl, 'Tag', 'linkX_x');
limits = get(axHndl,'XLim');

origPlotData = get(xHndl, 'UserData');
xOrigPlotData = origPlotData(:, 1);
x1Ind = find(xOrigPlotData >= limits(1), 1, 'first'); x2Ind = find(xOrigPlotData <= limits(2), 1, 'last');
dataT = xOrigPlotData(x1Ind:x2Ind);
scannerX = origPlotData(x1Ind:x2Ind, 2)';

origPlotData = get(yHndl, 'UserData');
scannerY = origPlotData(x1Ind:x2Ind, 2)';

origPlotData = get(xStageHndl, 'UserData');
stageX = origPlotData(x1Ind:x2Ind, 2)';

origPlotData = get(yStageHndl, 'UserData');
stageY = origPlotData(x1Ind:x2Ind, 2)';

origPlotData = get(apdHndl, 'UserData');
apdCounts = origPlotData(x1Ind:x2Ind, 2:end);

trigger = double(data{1}.trigger)';
if isempty(find(trigger,1)) % if trigger consists only of zeros
    trigger(1:1000:end) = 1;
end
trigger = trigger(x1Ind:x2Ind);


            %% calculate histogram

            edges  = 0:param.controllerUpdateClock/1e3:1200;
            histAll   = zeros(length(edges),3);
            for i = 1:3
                histAll(:,i)   = histc(apdCounts(:,i),edges);
            end

        %% calculate error between stage and scanner-----------------------
            errorX = (scannerX-stageX);
            errorY = (scannerY-stageY);
            [scannerXLP, scannerXHP] = freqCutoffFilter(dataT/1e3, scannerX, 5, 5);
            [scannerYLP, scannerYHP] = freqCutoffFilter(dataT/1e3, scannerY, 5, 5);
            [errorXLP, errorXHP] = freqCutoffFilter(dataT/1e3, errorX, 5, 5);
            [errorYLP, errorYHP] = freqCutoffFilter(dataT/1e3, errorY, 5, 5);
            error = sqrt(errorXHP.^2+errorYHP.^2);
%             
%             % shift stage vs scanner and calculate error   
%             shift=20; % in ms (multiple of 500us)
%             shiftVec = 0.5:0.5:shift;
%             errorXshift = zeros(length(shiftVec), 1);
%             errorYshift = zeros(length(shiftVec), 1);
%             for i = 1:length(shiftVec)
%                 shiftedErrorX = scannerXHP-circshift(stageX-mean(stageX),[0 shiftVec(i)*10]);
%                 errorXshift(i) = mean(abs(shiftedErrorX));
%                 shiftedErrorY = scannerYHP-circshift(stageY-mean(stageY),[0 shiftVec(i)*10]);
%                 errorYshift(i) = mean(abs(shiftedErrorY));
%             end
%             % time shift for minimum error
%             delayX = shiftVec(errorXshift==min(errorXshift));
%             delayY = shiftVec(errorYshift==min(errorYshift));
%             delay = mean([delayX, delayY]);
%             % errorX,Y for shift: delay
%             shiftedErrorX = scannerX-circshift(stageX,[0 round(delay*10)]);
%             [~, shiftedErrorX] = freqCutoffFilter(dataT/1e3, shiftedErrorX, 5, 5);
%             shiftedErrorY = scannerY-circshift(stageY, [0 round(delay*10)]);
%             [~, shiftedErrorY] = freqCutoffFilter(dataT/1e3, shiftedErrorY, 5, 5);
%             shiftedError = sqrt(shiftedErrorX.^2+shiftedErrorY.^2);     
            
        %% calculate velocity ----------------------------------------------
            scannerVx = gradient(conv(scannerX, ones(1,100), 'same'));
            scannerVy = gradient(conv(scannerY, ones(1,100), 'same'));
            scannerV = sqrt(scannerVx.^2 + scannerVy.^2);
            
        %% get triggerEdges for reshaping
            triggerGradient = gradient(trigger);
            triggerRisingEdges = triggerGradient>0;
            triggerEdges = find(triggerRisingEdges == 1);
            triggerEdges = [1 triggerEdges];
            
        %% reshape in periods of the stage movement
            columns = (length(triggerEdges)-1)/2;
            rows = triggerEdges(2)-triggerEdges(1)+1;
            scannerX1P = reshape(scannerX(1:columns*rows)',rows,columns);
            scannerY1P = reshape(scannerY(1:columns*rows)',rows,columns);
            
            scannerXHP1P = reshape(scannerXHP(1:columns*rows)',rows,columns);
            scannerYHP1P = reshape(scannerYHP(1:columns*rows)',rows,columns);
                        
            stageX1P   = reshape(stageX(1:columns*rows)',rows,columns);
            stageY1P   = reshape(stageY(1:columns*rows)',rows,columns);
            dataT1P    = reshape(dataT(1:columns*rows)',rows,columns);
            apdCounts1P = reshape(apdCounts(1:columns*rows,:),[rows,columns,3]);
            scannerVx1P = reshape(scannerVx(1:columns*rows)',rows,columns);
            scannerVy1P = reshape(scannerVy(1:columns*rows)',rows,columns);
            scannerV1P  = reshape(scannerV(1:columns*rows)',rows,columns);
            % mean apds1P
            meanApdCounts1P = squeeze(mean(apdCounts1P,2));
            
        %% calculate covariance matrix.
%             errorXX = mean((stageX1P-mean(mean(stageX1P))-scannerXHP1P).^2,2)';
%             errorYY = mean((stageY1P-mean(mean(stageY1P))-scannerYHP1P).^2,2)';
%             errorXY = mean((stageX1P-mean(mean(stageX1P))-scannerXHP1P).*...
%                 (stageY1P-mean(mean(stageY1P))-scannerYHP1P),2)';
%             errorMax = zeros(length(errorXX),1);
%             angle = zeros(length(errorXX),1);
%             for i = 1:length(errorXX)
%                 covMatrix = [errorXX(i),errorXY(i);errorXY(i),errorYY(i)];
%                 [V,D] = eig(covMatrix);
%                 [varMax,indMax] = max(max(D));
%                 errorMax(i) = sqrt(varMax);
%                V = V(:,indMax);
%                angle(i)=atan2(V(2),V(1))*180/pi;
%             end
            
        %% calculate count intensity
%             compX = apds(:,1).*cosd(param.fbAngles(1)+param.fbAdditiveAngle) + ...
%             apds(:,2).*cosd(param.fbAngles(2)+param.fbAdditiveAngle) + ...
%             apds(:,3).*cosd(param.fbAngles(3)+param.fbAdditiveAngle);
%             compY = apds(:,1).*sind(param.fbAngles(1)+param.fbAdditiveAngle) + ...
%             apds(:,2).*sind(param.fbAngles(2)+param.fbAdditiveAngle) + ...
%             apds(:,3).*sind(param.fbAngles(3)+param.fbAdditiveAngle);
%             comp = sqrt(compX.^2+compY.^2);
              
            
            
        %% correlation between counts. 
            apdCountMeanCorr =  apdCounts-repmat(mean(apdCounts),length(apdCounts),1);
            % correlation @ 0 lag of possible combinations of two count traces 
            cc12 = corr0Lag(apdCountMeanCorr(:,1),apdCountMeanCorr(:,2));
            cc13 = corr0Lag(apdCountMeanCorr(:,1),apdCountMeanCorr(:,3));
            cc23 = corr0Lag(apdCountMeanCorr(:,2),apdCountMeanCorr(:,3));
            % multiplying double correlatios
            cc123 = cc12.*cc13.*cc23;
            % correlation @ 0 lag of 3 count-traces simultaneously
            cc123 = corr0Lag(apdCountMeanCorr(:,1),apdCountMeanCorr(:,2).*apdCountMeanCorr(:,3));
            % std of counts
            apdCountStd = std(apdCounts,1,2);
            
            
            
%%      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % draw figure and display data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figHndl = figure;
        
        figure(figHndl)
        screen = get(0,'ScreenSize');
        screen(2) = screen(4)*0.05;
        screen(4) = screen(4)*0.95;
        screen(1) = screen(3)*0.05;
        screen(3) = screen(3)*0.95;
        set(figHndl,'OuterPosition',screen)
        
        
        %% plot apd counts
        height = 0.16; % height of figure
        height1 = 0.166;% height of placement of figure
        width = 0.55;
        ax(1) = subplot('Position',[0 height1*5 0.55 height]);
        plotColor = 'rgb';
        hold all
        for i=1:3
            plot(dataT, filterData(apdCounts(:,i), filt), plotColor(i))
        end
        title(['Total Counts APD 1,2,3: ',num2str(round(sum(apdCounts))),...
            '. Mean: ', num2str(round(mean(apdCounts))), ' Counts @ ',...
            num2str(round(1/(dataT(2)-dataT(1)))), ' kHz'])  
        grid on
        hold off
        ylabel('Counts')
        xlabel('time [ms]')
        axis tight
        set(gca,'OuterPosition', [0 height1*5 0.55 height])
        set(gca, 'LooseInset', get(gca,'TightInset'))
        
        % sum of counts
            apdCountSum = sum(apdCounts,2);
            ax(2) = subplot('Position', [0 height1*4 0.55 height]);
            plot(dataT, filterData(apdCountSum, filt), 'k')
%             hold on
%             plot(dataT, ones(size(dataT))*3, 'm')
%             hold off
            grid on
            title(['Total Counts: ',...
                num2str(round(sum(apdCountSum))), '. Mean: ',...
                num2str(round(mean(apdCountSum))), ' Counts @ ',...
            num2str(round(1/(dataT(2)-dataT(1)))), ' kHz'])
            ylabel('Counts')
            xlabel('time [ms]')
            axis tight
            set(gca,'OuterPosition', [0 height1*4 0.55 height])
            set(gca, 'LooseInset', get(gca,'TightInset'))
            
        % correlation
            ax(3) = subplot('Position', [0 height1*3 0.55 height]);
            plot(dataT, filterData(cc123, filt), 'b')
            grid on
            title('Correlation @ 0 lag')
            ylabel('Correlation')
            xlabel('time [ms]')
            axis tight
            set(gca,'OuterPosition', [0 0.166*3 0.55 height])
            set(gca, 'LooseInset', get(gca,'TightInset'))
        
         % std of counts
            ax(4) = subplot('Position', [0 height1*2 0.55 height]);
            plot(dataT, filterData(apdCountStd, filt) , 'b')
            grid on
            title('Std of counts')
            ylabel('Std')
            xlabel('time [ms]')
            axis tight
            set(gca,'OuterPosition', [0 height1*2 0.55 height])
            set(gca, 'LooseInset', get(gca, 'TightInset'))
        
        %% plot scanner and stage positions
            ax(5) = subplot('Position',[0 height1*1 0.55 height]);
            plot(dataT, filterData(stageX-mean(stageX)+scannerXLP-mean(scannerXLP), filt), 'r')
            hold on
            plotBlueX = plot(dataT, filterData(scannerX-mean(scannerX), filt), 'b');
            plot(dataT, filterData(scannerXLP-mean(scannerXLP), filt), 'k')
            hold off
            grid on
            title('Scanner X')
            ylabel('Position X [nm]')
            xlabel('time [ms]')
            axis tight
            set(gca,'OuterPosition',[0 height1*1 0.55 height])
            set(gca, 'LooseInset', get(gca,'TightInset'))

            ax(6) = subplot('Position',[0 0 0.55 height]);
            plot(dataT, filterData(stageY-mean(stageY)+scannerYLP-mean(scannerYLP), filt), 'r')
            hold on
            plotBlueY = plot(dataT, filterData(scannerY-mean(scannerY), filt), 'b');
            plot(dataT, filterData(scannerYLP-mean(scannerYLP), filt), 'k')
            hold off
            grid on
            title('Scanner Y')
            ylabel('Position Y [nm]')
            xlabel('time [ms]')
            axis tight
            set(gca,'OuterPosition',[0 0 0.55 height])
            set(gca, 'LooseInset', get(gca,'TightInset'))
            
            % link axes
            linkaxes(ax,'x')
%             % add listener
%             dynamicY(ax(1));
%             dynamicY(ax(2));
%             dynamicY(ax(3));
%             dynamicY(ax(4));
%             dynamicY(ax(5));
%             dynamicY(ax(6));
%             else
            % link axes
%             linkaxes(ax,'x')
%             % add listener
%             dynamicY(ax(1));
%             dynamicY(ax(2));
%             dynamicY(ax(3));
%             dynamicY(ax(4));
%             end


        %% plot histogram 
        subplot('Position',[0.575 0.551 0.44 0.44])
        [Nhist, Chist] = hist3([filterData(scannerX-mean(scannerX)-errorXLP, filt)' filterData(scannerY-mean(scannerY)-errorYLP, filt)']...
            ,[1 1]*120 );
                imagesc(Chist{2}, Chist{1}, Nhist) 
        title(['Corrected scanner trajectory. Tracked: ',...
            num2str(round((limits(2)-limits(1))/1e3)) ,' sec.']);
%      figure;
%             [Nhist, Chist] = hist3([(scannerX-mean(scannerX))' (scannerY-mean(scannerY))']...
%             ,[1 1]*120 );
%                 imagesc(Chist{2}, Chist{1},Nhist) 
%         title(['Scanner trajectory. Tracked: ',...
%             num2str(round((limits(2)-limits(1))/10^2)/10),' sec.']);

        daspect([1 1 1]) 
        xlabel('X [nm]')
        ylabel('Y [nm]')
        colorbar
        set(gca,'OuterPosition',[0.575 0.55 0.4 0.4])
        set(gca, 'LooseInset', get(gca,'TightInset'))
                
        % draw trajectory -------------------------------------------------
        subplot('Position',[0.575 0.05 0.4 0.4])
        hold all
        plotRed0 = plot(filterData(scannerX, filt), filterData(scannerY, filt), 'b');
        plotRed  = plot(filterData(scannerX, filt), filterData(scannerY, filt), 'r', 'linewidth', 2);
        hold off
        xlabel('position x [nm]')
        ylabel('position y [nm]')
        title('Scanner Trajectory')
        daspect([1 1 1])
        set(gca,'OuterPosition',[0.575 0.05 0.4 0.4])
        set(gca, 'LooseInset', get(gca,'TightInset'))
       
        % change axes on Scanner trajectory
        addlistener(ax(1), 'XLim', 'PostSet', @scaleXY1 );
        function scaleXY1(varargin)          
            % dynamic subset of trace in red
            try              
                xTrajData = get(plotBlueX,'YData');
                yTrajData = get(plotBlueY,'YData');
                xTrajLim = get(ax(5),'xlim');
                xDataRng = dataT > xTrajLim(1) & dataT < xTrajLim(2);
                set(plotRed,...
                    'XData', xTrajData(xDataRng), ...
                    'YData', yTrajData(xDataRng))
                set(plotRed0,...
                    'XData', xTrajData, ...
                    'YData', yTrajData)
            end
        end
           
    
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % create new figure -----------------------------------------------
        figHndl2 = figure;
        figure(figHndl2)
        screen = get(0, 'ScreenSize');
        screen(2) = screen(4)*0.05;
        screen(4) = screen(4)*0.95;
        screen(1) = screen(3)*0.05;
        screen(3) = screen(3)*0.5;
        set(figHndl2, 'OuterPosition', screen)
        
        % plot error ------------------------------------------------------
        dataT_corrected = triggerEdges(1):1:triggerEdges(2);
        subplot('Position',[0 0.2*4 0.9 0.15])
        plot(dataT_corrected, mean(scannerXHP1P,2)*10^3 ,'r','LineWidth', 2); hold all
        plot(dataT_corrected, (mean(scannerXHP1P,2) + std(scannerXHP1P, [], 2))*10^3, 'r')
        plot(dataT_corrected, (mean(scannerXHP1P,2) - std(scannerXHP1P, [], 2))*10^3, 'r')
        plot(dataT_corrected, (mean(stageX1P,2)-mean(mean(stageX1P)))*10^3, 'k', 'LineWidth', 2),
        title('Mean scannerX position [um]')
        xlabel('time [ms]')
        ylabel('nm')
        hold off
        grid on
        axis tight
        set(gca,'OuterPosition', [0 0.2*4 0.9 0.2])
        set(gca, 'LooseInset', get(gca, 'TightInset'))
        
        subplot('Position',[0 0.2*3 0.9 0.15])
        plot(dataT_corrected, mean(scannerYHP1P,2)*10^3,'b','LineWidth', 2); hold all
        plot(dataT_corrected, (mean(scannerYHP1P,2) + std(scannerYHP1P, [], 2))*10^3, 'b')
        plot(dataT_corrected, (mean(scannerYHP1P,2) - std(scannerYHP1P, [], 2))*10^3, 'b')
        plot(dataT_corrected, (mean(stageY1P,2)-mean(mean(stageY1P)))*10^3, 'k', 'LineWidth', 2),
        title('Mean scannerY position [um]')
        xlabel('time [ms]')
        ylabel('nm')
        hold off
        grid on
        axis tight
        set(gca,'OuterPosition', [0 0.2*3 0.9 0.2])
        set(gca, 'LooseInset', get(gca, 'TightInset'))
        
        subplot('Position',[0 0.2*0 0.9 0.15])
        plot(dataT_corrected, meanApdCounts1P)
        title('Mean Counts.')
        xlabel('time [ms]')
        ylabel('counts')
        hold off
        grid on
        axis tight
        set(gca,'OuterPosition', [0 0.2*0 0.9 0.2])
        set(gca, 'LooseInset', get(gca,'TightInset'))

        subplot('Position', [0 0.2*2 0.9 0.15])
        plot(dataT_corrected, std(scannerXHP1P, [], 2)*10^3, 'r'), hold all
        plot(dataT_corrected, std(scannerYHP1P, [], 2)*10^3, 'b')
        title('Precision of scanner movement.')
        xlabel('time [ms]')
        ylabel('precision [nm]')
        hold off
        grid on
        axis tight
        set(gca,'OuterPosition', [0 0.2*2 0.9 0.2])
        set(gca, 'LooseInset', get(gca,'TightInset'))
        
        %%
%         subplot('Position',[0 0.2*1 0.4 0.15])
%         plot(dataT_corrected,errorMax)
%         title('Accuracy of trace.')
%         xlabel('time [ms]')
%         ylabel('accuracy [nm]')
%         hold off
%         grid on
%         axis tight
%         set(gca,'OuterPosition',[0 0.2*1 0.4 0.2])
%         set(gca, 'LooseInset', get(gca,'TightInset'))
        
        %%
%         columns = 4;
%         rows = round(length(meanApdCounts1P(:,i))/columns);
%         slope = zeros(rows*columns,1);
%         countCicleApd = zeros(3,columns);
%         for i = 1:3
%             meanApdCountsQP = reshape(meanApdCounts1P(:,i),rows,columns);
%             slopeQP = repmat(mean(meanApdCountsQP(round(end-0.2*rows):end,:)),rows,1);
%             dataTQP = repmat(dataT_corrected(1:rows)',1,columns);
%             meanApdCOuntsQP = reshape(meanApdCounts1P(:,i),rows,columns);
%             cumMeanApdCountsQP = cumsum(meanApdCOuntsQP)-dataTQP.*slopeQP;
%             countCicleApd(i,:) = round(cumMeanApdCountsQP(end,:));
%             slope(:,i) = reshape(slopeQP,rows*columns,1);
%         end
         
        %%
%         subplot('Position',[0.5 0 0.5 0.5])
%         plot(dataT_corrected,cumsum(meanApdCounts1P)-...
%             dataT_corrected'*[1 1 1].*slope), hold all
%         totalCountsJumping = sum(cumsum(meanApdCounts1P)-dataT_corrected'*[1 1 1].*slope,2);%-dataT_corrected'.*sum(slope,2);
%         plot(dataT_corrected,totalCountsJumping), hold off
%         title('Counts per jump.')
%         %         legend({['Apd1: ',num2str(countCicleApd(1,:))],...
%         %             ['Apd2: ',num2str(countCicleApd(2,:))],...
%         %             ['Apd3: ',num2str(countCicleApd(3,:))]},'Location','NorthWest')
%         legend({'Apd1','Apd2','Apd3',['Sum: ',num2str(sum(countCicleApd))]},'Location','NorthWest')
%         xlabel('time [ms]')
%         ylabel('counts')
%         hold off
%         grid on
%         axis tight
%         set(gca,'ylim',[0 max(totalCountsJumping)*1.1])
%         set(gca,'OuterPosition',[0.45 0 0.5 0.5])
%         set(gca, 'LooseInset', get(gca,'TightInset'))
        
        
        %% plot shifted error ----------------------------------------------
%         subplot('Position',[0.5 0.5 0.5 0.5])
%         plot([0,shiftVec],[mean(abs(errorXHP)),errorXshift']*10^3,'r','LineWidth',1)
%         hold on
%         plot([0,shiftVec],[mean(abs(errorYHP)),errorYshift']*10^3,'b','LineWidth',1)
%         plot(delayX,min(errorXshift)*10^3,'.r')
%         plot(delayY,min(errorYshift)*10^3,'.g')
%         hold off
%         grid on
%         legend({['Min errorX: ',num2str(round(min(errorXshift)*10^3)),' nm, @ ',num2str(delayX),' ms.'],...
%             ['Min errorY: ',num2str(round(min(errorXshift)*10^3)),' nm, @ ',num2str(delayY),' ms.']},'Location','NorthEast')
%         title(['Error using a time shift. Mean delay: ',...
%             num2str(delay),' ms.'])
%         xlabel('shift [ms]')
%         ylabel('mean of the error [nm]')
%         set(gca,'ylim',[0 max([errorXshift;errorYshift])*1.1*10^3])
%         set(gca,'OuterPosition',[0.45 0.5 0.5 0.5])
%         set(gca, 'LooseInset', get(gca,'TightInset'))
        
        %% plot velocity - error histogram
%         subplot('Position',[0.605 0.33 0.33 0.33])
%         hist([errorXHP',scannerVx']*1/sqrt(2)*[-1;1],linspace(-.1,.1,100))
%         xlabel('PC1')
%         ylabel('Events')
%         set(gca,'xlim',[-0.099 0.099])
%         set(gca,'OuterPosition',[0.605 0.33 0.33 0.33])
%         set(gca, 'LooseInset', get(gca,'TightInset'))
%                 subplot('Position',[0.605 0 0.33 0.33])
%                 hist([error',scannerV']*1/sqrt(2)*[1;1],linspace(0,.1,100))
%                 xlabel('PC1')
%                 ylabel('Events')
%                 set(gca,'xlim',[0 0.099])
%                 set(gca,'OuterPosition',[0.605 0 0.33 0.33])
%                 set(gca, 'LooseInset', get(gca,'TightInset'))

%    close(figHndl)     
end