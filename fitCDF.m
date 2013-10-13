function [xAll, fAll, paramAll1, paramAll] = fitCDF(stepLengths, timeStep, makePlot)
%% fitCDF: Function to calculate and plot the CDFs from a list of steplengths and samplingtime 
% Inputs:
% stepLengths:      A nx1 array of steplengths in nm. A cell array of
%                  trajectories can also be used if the 1st and 2nd columns in each
%                  trajectory are X and Y respectively.
% 
% timeStep:         The sampling timestep in seconds.
%
% makePlot:         Boolean stating if graphics output should be given.


%% Settings

% CDF parameters
resolution = 1    %nm


% Fitting parameters:
alpha = 0.1 % weight for the states
Diff1 = 30000 % Diffusion coeff for the first state (fast)
Diff2 = 5000 % Diffusion coeff for the second state (slow)


%% Fix if cell array of trajectories is given instead of steplengths

if iscell(stepLengths)
    temp = stepLengths;
    stepLengths = [];
    for i=1:length(temp)
       dCoords = temp{i}(2:end,1:2) - temp{i}(1:end-1,1:2);
       stepLengths = [stepLengths; sqrt(sum(dCoords.^2,2))]; % dr = sqrt(dx^2+dy^2)
    end
    
end


%% Making the Cumulative Distribution

maxVal = max(stepLengths);    % nm

% Get the CDF 
fitparamAll = [alpha, Diff1, Diff2];
edges = 0:resolution:maxVal;
xAll = resolution:resolution:maxVal;
nElements = histc(stepLengths, edges);
nElements(end) = [];
fAll = cumsum(nElements);

ind = find(xAll>maxVal);
xAll(ind) = [];
fAll(ind) = [];

% Norm
fAll = fAll./max(fAll);


%% Fit CDF for 1 state

    % Fit all data to get diff. coeff.
    [paramAll1, r] = nlinfit(xAll, fAll, @CDFfitAll_1state, fitparamAll);
    
    
%% Fit CDF for 2 states

% Fit all the data to get diff. coeff.
    [paramAll, r] = nlinfit(xAll, fAll, @CDFfitAll_2states, fitparamAll);
    
    
%% Plot the things
if makePlot
figure;
hold on
[f, x]=hist(stepLengths, 50);
bar(x, f/max(f), 'FaceColor', [0.8 0.8 0.8], 'EdgeColor', 'w');
plot(xAll, fAll, 'Linewidth', 1.5);
title('CDF XY');
xlabel('Step length [nm]');
ylabel('Cumulative probability');

%% Plot the 1 state fitted function
% Plot all the fitted functions
fplot(@(x) 1-exp(-x.^2./(4*paramAll1(2)*timeStep)), [0 max(stepLengths)], '--k')
set(findobj(gca, 'Type', 'Line', 'Color', 'k'), 'LineWidth', 1.5);
% Write data in the plot
text(0.35, 0.55, strcat('1 state model fit:'), 'Units', 'normalized', 'FontWeight', 'demi')
text(0.35, 0.5, strcat('D = ', num2str(paramAll1(2)/1e6, 3), ' \mum^2/s'), 'Units', 'normalized')
1 - sum(r.^2)/sum((fAll-mean(fAll)).^2)

%% Plot the 2 states fitted function
% Plot all the fitted functions
fplot(@(x) 1-paramAll(1)*exp(-x.^2./(4*paramAll(2)*timeStep))-(1-paramAll(1))*exp(-x.^2./(4*paramAll(3)*timeStep)), [0 max(stepLengths)], '.r')
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
text(0.65, 0.10, strcat('Sampling time: ', num2str(timeStep*1000), ' ms'), 'Units', 'normalized');
legend('SL histogram', 'CDF All','Fit 1 state', 'Fit 2 states','Location','NE');

1 - sum(r.^2)/sum((fAll-mean(fAll)).^2)  
 
     
hold off
end

%% Fitting functions


function y = CDFfitAll_1state(param, x)
% Only one state
y = 1-exp(-x.^2./(4*param(2)*timeStep));
y=y';
end

function y = CDFfitAll_2states(param, x)
% Two states
y = 1-param(1)*exp(-x.^2./(4*param(2)*timeStep))-(1-param(1))*exp(-x.^2./(4*param(3)*timeStep));
y=y';
end

end
