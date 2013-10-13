function [paramAll1, paramAll] = plotCDF(coords, timeStep, samplingPeriod)
% 
% INPUT:
% coords = A coordinate matrix with 2 columns (x, y) in nanometers.
% samplingPeriod = The time between points to use in ms.
% 
% OUTPUT:
% paramAll1 = The fitting parameters for the 1 state model
% paramAll = The fitting parameters for the 2 state model


        % Plotting CDF --------------------------------------------------

        
        % Calculate other varables
%         timeStep = data{1}.t(2)-data{1}.t(1);
        dataPeriod = round((samplingPeriod)/timeStep);
%         temp = [data{1}.scannerX', data{1}scannerY']*1e3; % Relative coordinates in [nm]
        dCoords = coords(1+dataPeriod:dataPeriod:end,1:2) - coords(1:dataPeriod:end-dataPeriod,1:2);
        % Calculate steplengths
        stepLengths = sqrt(sum(dCoords.^2,2)); % sqrt(dx^2+dy^2)
        figH = figure;
        hold on
        try
            [xAll, fAll, paramAll1, paramAll] = fitCDF(stepLengths, samplingPeriod, 0);
            % Plot the CDF
            [f, x] = hist(stepLengths, 50);
            bar(x, f/max(f), 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'w');
            plot(xAll, fAll, 'Linewidth', 1.5);
            title('CDF XY');
            xlabel('Step length [nm]');
            ylabel('Cumulative probability');
            
            % Plot the 1 state fitted function --------------------------------
            % Plot all the fitted functions
            fplot(@(x) 1-exp(-x.^2./(4*paramAll1(2)*samplingPeriod)), [0 max(stepLengths)], '--k')
            set(findobj(gca, 'Type', 'Line', 'Color', 'k'), 'LineWidth', 1.5);
            % Write data in the plot
            text(0.35, 0.55, strcat('1 state model fit:'), 'Units', 'normalized', 'FontWeight', 'demi')
            text(0.35, 0.5, strcat('D = ', num2str(paramAll1(2)/1e6, 3), ' \mum^2/s'), 'Units', 'normalized')
            
            % Plot the 2 states fitted function -------------------------------
            % Plot all the fitted functions
            fplot(@(x) 1-paramAll(1)*exp(-x.^2./(4*paramAll(2)*samplingPeriod))-(1-paramAll(1))*exp(-x.^2./(4*paramAll(3)*samplingPeriod)), [0 max(stepLengths)], '.r')
            set(findobj(gca, 'Type', 'Line', 'Color', 'r'), 'LineWidth', 1.5);
            % Write data in the plot
            text(0.35, 0.40, strcat('2 state model fit:'), 'Units', 'normalized', 'FontWeight', 'demi')
            text(0.35, 0.35, strcat('D1* = ', num2str(paramAll(2)/1e6, 3), ' \mum^2/s'), 'Units', 'normalized')
            text(0.35, 0.3, strcat('D2* = ', num2str(paramAll(3)/1e6, 3), ' \mum^2/s'), 'Units', 'normalized')
            if paramAll(2)>paramAll(3)
                text(0.35, 0.25, strcat('Fractions all data (slow/fast) = ', num2str(1-paramAll(1), 3), '/', num2str(paramAll(1), 3)), 'Units', 'normalized')
            else
                text(0.35, 0.25, strcat('Fractions all data (slow/fast) = ', num2str(paramAll(1), 3), '/', num2str(1-paramAll(1), 3)), 'Units', 'normalized')
            end
            
            text(0.65, 0.15, strcat('Total steps used: ', num2str(length(stepLengths))), 'Units', 'normalized');
            text(0.65, 0.10, strcat('Sampling time: ', num2str(samplingPeriod*1000), ' ms'), 'Units', 'normalized');
            legend('SL histogram', 'CDF All','Fit 1 state', 'Fit 2 states','Location','NE');
            
            hold off
        catch
            disp('CDF analysis crashed due to bad data')
            text(0.1, 0.50, strcat('CDF analysis crashed due to bad input. Please choose another interval.'))
        end
        clear coords timeStep dataPeriod samplingPeriod dCoords
        
end