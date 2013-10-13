function plotMSD(finalTraj, unitTime, minTrajLength, maxTrajLength, maxSteps)


%% Does a 'global' MSD plot for many trajectories in cell array called finalTraj
color = 'b';
trajLengthWeight = 0; % NOT WORKING YET....
frameSpacing = 1;  % If you want to skip frames and only use eg every third.
if frameSpacing>1
    unitTime = unitTime*frameSpacing;
end
%%

% Make MSD plot(one for all trajectories)
msdCell = cell(3, length(finalTraj));
[max_size, max_index] = max(cellfun('size', finalTraj, 1));
sqDisplTotCell = cell(3, max_size);

% Run through the trajectories
for i = 1:length(finalTraj)
    tempTraj = finalTraj{i}(1:frameSpacing:end, :);
    i;
    if size(tempTraj, 1)>=minTrajLength & size(tempTraj, 1)<=maxTrajLength
        i;
    % Calculate all squared displacements
    for dt = 1:min(maxSteps, size(tempTraj, 1));
        
        dCoords = tempTraj(1+dt:end,1:2) - tempTraj(1:end-dt,1:2);
        sqDispl = sum(dCoords.^2,2); % dx^2+dy^2
%         if trajLengthWeight
%             sqDisplTotCell{1, dt} = [sqDisplTotCell{1, dt}; nanmean(sqDispl)];
%         else
            sqDisplTotCell{1, dt} = [sqDisplTotCell{1, dt}; sqDispl];
%         end
        
%         sqDisplX = dCoords(:, 1).^2;
%         if trajLengthWeight
%             sqDisplTotCell{2, dt} = [sqDisplTotCell{2, dt}; nanmean(sqDisplX)];
%         else
%             sqDisplTotCell{2, dt} = [sqDisplTotCell{2, dt}; sqDisplX];
%         end
        
              
    end
%     % Save the individual MSDs in a cell structure
%     msdCell{1, i} = msd;
%     msdCell{2, i} = msdX;
  
    end
end

% Make one general MSD list
msdTot = [length(sqDisplTotCell), 4];
% msdTotX = [length(sqDisplTotCell), 4];


for dt = 1:length(sqDisplTotCell)
    msdTot(dt,1) = nanmean(sqDisplTotCell{1, dt}); % average
    msdTot(dt,2) = nanstd(sqDisplTotCell{1, dt}); % std
    msdTot(dt,3) = length(sqDisplTotCell{1, dt}); % n
    
%     msdTotX(dt,1) = nanmean(sqDisplTotCell{2, dt}); % average
%     msdTotX(dt,2) = nanstd(sqDisplTotCell{2, dt}); % std
%     msdTotX(dt,3) = length(sqDisplTotCell{2, dt}); % n
end

% Calculate diffusion constant from the 2 first points

diffArr = [msdTot(1:maxSteps, 1)']./(1e6);
xArr = 1:maxSteps;
[p, S] = polyfit(xArr.*unitTime, diffArr, 1);
diffOffset = p(2);
diffCoeff = p(1)/4;

% diffArr = [msdTotX(1:maxSteps, 1)']./(1e6);
% xArr = 1:maxSteps;;
% [pX, S] = polyfit(xArr.*unitTime, diffArr, 1);
% diffOffsetX = pX(2);
% diffCoeffX = pX(1)/2;



% Plot the MSD if desired

fighand1 = figure(666);
set(fighand1, 'Name', 'MSD plot','NumberTitle','off');
hold on
xArr = find(msdTot(:, 1));
plot(xArr.*unitTime, msdTot(:, 1)./(1e6), ['-' color]);
hE = errorbar(xArr.*unitTime, msdTot(:, 1)./(1e6), msdTot(:, 2)./(1e6.*sqrt(msdTot(:, 3))-1), ['+' color]);
fplot(strcat('x*', num2str(p(1)), '+', num2str(p(2))), [0, maxSteps*unitTime], '--r');

% % Confidence bounds 95%
% [pop_fit,delta] = polyval(p, xArr.*unitTime, S);
% % Plot the data, the fit, and the confidence bounds
% plot(xArr.*unitTime, msdTot(:, 1)./(1e6),'+',...
%      xArr.*unitTime, pop_fit,'g-',...
%      xArr.*unitTime, (pop_fit+2*delta),'r:',...
%      xArr.*unitTime, (pop_fit-2*delta),'r:'); 
hold off

title('MSD XY');
xlabel('Time [s]');
ylabel('Mean square displacement [\mum^2]');
xlim([0, maxSteps*unitTime]);
text(0.1, 0.9, ['Diff. Coeff = ', num2str(diffCoeff), '\mum^2/s'], 'Units', 'normalized');
text(0.1, 0.85, ['Offset = ', num2str(diffOffset), '\mum^2'], 'Units', 'normalized');

hE_c                   = ...
    get(hE     , 'Children'    );
errorbarXData          = ...
    get(hE_c(2), 'XData'       );
errorbarXData(4:9:end) = ...
    errorbarXData(1:9:end) + 0.001;
errorbarXData(7:9:end) = ....
    errorbarXData(1:9:end) + 0.001;
errorbarXData(5:9:end) = ...
    errorbarXData(1:9:end) - 0.001;
errorbarXData(8:9:end) = ...
    errorbarXData(1:9:end) - 0.001;
set(hE_c(2), 'XData', errorbarXData);




% fighand2 = figure(667);
% set(fighand2, 'Name', 'MSD plot','NumberTitle','off');
% hold on
% xArr = find(msdTotX(:, 1));
% plot(xArr.*unitTime, msdTotX(:, 1)./(1e6), ['-' color]);
% hE = errorbar(xArr.*unitTime, msdTotX(:, 1)./(1e6), msdTotX(:, 2)./(1e6.*sqrt(msdTotX(:, 3))-1), ['+' color]);
% fplot(strcat('x*', num2str(pX(1)), '+', num2str(pX(2))), [0, maxSteps*unitTime], '--r');
% title('MSD X');
% xlabel('Time [s]');
% ylabel('Mean square displacement [\mum^2]');
% xlim([0, maxSteps*unitTime]);
% text(0.1, 0.9, ['Diff. Coeff = ', num2str(diffCoeffX), '\mum^2/s'], 'Units', 'normalized');
% text(0.1, 0.85, ['Offset = ', num2str(diffOffsetX), '\mum^2'], 'Units', 'normalized');
% hold off
% hE_c                   = ...
%     get(hE     , 'Children'    );
% errorbarXData          = ...
%     get(hE_c(2), 'XData'       );
% temp = 4:3:length(errorbarXData);
% temp(3:3:end) = [];
% % xleft and xright contain the indices of the left and right
% % endpoints of the horizontal lines
% xleft = temp; xright = temp+1;
% % Increase line length by 0.2 units
% errorbarXData(xleft) = errorbarXData(xleft) + 0.9*abs(errorbarXData(xleft(1)));
% errorbarXData(xright) = errorbarXData(xright) - 0.9*errorbarXData(xright(1));
% set(hE_c(2), 'XData', errorbarXData);


end
