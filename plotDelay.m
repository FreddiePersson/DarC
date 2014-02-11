function [delay] = plotDelay(coords, apdCounts, samplTime)
% Finds and plots the 'delay' as defined as the sampling time where the
% correlation between steplength and countdeviation between the 3 detectors
% is at its maximum.
% 
% INPUT:
% coords = A coordinate matrix with 2 columns (x, y) in nanometers.
% apdCounts = The counts in the three different APDs
% samplTime = The natural timestep in the data, ie the time between 2
%            adjacent datapoints
% 
% OUTPUT:
% delay = The 'delay' in ms

%% Plotting Corr betw steplength and std(APD) vs sampling time -----

% Set variable
timeSteps = 0.2:0.2:30;%0.2:0.4:20; % [ms] Should be even numbers, possibly /10

% Loop over different sampling times
corr = zeros(1, length(timeSteps));
xcorrMax = zeros(2, length(timeSteps));
stdAPD = std(apdCounts, 1, 2);
ind=1;
for timeStep = timeSteps
    
    unitStep = round(timeStep/samplTime);
    
    % Moving average of length unitStep, removing the ends
    stdAPDmean = filter(ones(1, unitStep)/unitStep, 1, stdAPD);
    stdAPDmean = stdAPDmean(unitStep/2+1:end-unitStep/2);
    
    % Read out XY-coordinates
%     coords = [scannerX', scannerY'];%*1000; % Relative coordinates in [nm]
    dCoords = coords(1+unitStep:1:end,1:2) - coords(1:1:end-unitStep,1:2);
    
    % Calculate steplengths
    stepLengths = sqrt(sum(dCoords.^2,2)); % sqrt(dx^2+dy^2)
    SL_meanSub = stepLengths-mean(stepLengths);
    STD_meanSub = stdAPDmean-mean(stdAPDmean);
    
    XC = xcorr(SL_meanSub, STD_meanSub)/sqrt(var(STD_meanSub)*var(SL_meanSub));
    maxInd = find(XC==max(XC));
    xcorrMax(1, ind) = maxInd-length(stepLengths); % perhaps +1
    xcorrMax(2, ind) = XC(maxInd);
    
    corr(ind) = XC(length(stepLengths));
    
    ind = ind+1;
end

% Things to fix ugly looking plots
% xcorrMax(1, find(xcorrMax(1, :)<0)) = 0;
% xcorrMax(1, find(xcorrMax(1, :)>timeSteps(end))) = timeSteps(end);

% Plot the correlations ---------------------------------------------------
figH = figure;
hold on
% Evaluated at 0 shift
plot(timeSteps, corr, '-k'); 
% Evaluated with shifting
plot(timeSteps, xcorrMax(2, :), '--b'); 
% Like previous, but with added shifts
plot(timeSteps+xcorrMax(1, :)*samplTime, xcorrMax(2, :), '-b');
set(gca, 'xlim', [0 timeSteps(end)]);
title('Correlation steplength VS std(apdCounts))');
xlabel('Sampling time [ms]');
ylabel('Correlation');
hold off
legend('maxCorr 0 shift', 'maxXcorr', 'maxXcorr shifted');

delay = 0;

% 
% H = hist3([stdAPDmean, stepLengths],[30 30]);
% figure;
% imagesc(H)

end

