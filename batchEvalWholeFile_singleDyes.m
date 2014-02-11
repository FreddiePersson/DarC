% evaluate whole file

clc, clear

% Shortest acceptable trace in seconds
minTrace = 5; %s
% Max distance the x and y positions is allowed to vary between the chunks
maxDist = 0.100; %um

track_filename = get_cf_highlight; %get filename from Current Folder Explorer
track_filename = track_filename{1};

[data, numTraces, paramList] = track_open_all_traces(track_filename);

for ni=1:numTraces
    disp(['Processing trace ' num2str(ni) ' of ' num2str(numTraces)])

    % Variables of interest for the trace.
    coordsScn = [data{ni}.scannerX, data{ni}.scannerY];
    coordsStg = [data{ni}.stageX, data{ni}.stageY];
    timeStep = data{ni}.t(2)-data{ni}.t(1);
    
    % Parameters for chunk processing
    chunkLength = 100e-3; %[s]
    chunkSize = floor(chunkLength/timeStep);
    nChunks = ceil(length(data{ni}.scannerX)/chunkSize);
    
    % Init. of variables
    meanSL = zeros(1, nChunks);
    meanPosX = zeros(1, nChunks);
    meanPosY = zeros(1, nChunks);
    meanCounts = zeros(1, nChunks);
    meanError = zeros(1, nChunks);
    xcorr0lag = zeros(1, nChunks);
    
    % Chunk processing
    for i=1:nChunks 
        % Indexing limits for chunk
        startIndex = (i-1) * chunkSize+1;
        endIndex = min((i) * chunkSize-1, length(data{ni}.scannerX) );
        
        % Processing
        meanCounts(i) = mean(sum(data{ni}.apds(startIndex:endIndex,:),2))/timeStep*1e-3;
        
        scnX = coordsScn(startIndex:endIndex,1)-mean(coordsScn(startIndex:endIndex,1));
        stgX = coordsStg(startIndex:endIndex,1)-mean(coordsStg(startIndex:endIndex,1));
        scnY = coordsScn(startIndex:endIndex,2)-mean(coordsScn(startIndex:endIndex,2));
        stgY = coordsStg(startIndex:endIndex,2)-mean(coordsStg(startIndex:endIndex,2));
        
        coords = [scnX, scnY];
        dCoords = coords(2:1:end,1:2) - coords(1:1:end-1,1:2);
        stepLengths = sqrt(sum(dCoords.^2,2)); % sqrt(dx^2+dy^2)
        meanSL(i) = mean(stepLengths);
        meanPosX(i) = mean(coordsScn(startIndex:endIndex,1));
        meanPosY(i) = mean(coordsScn(startIndex:endIndex,2));
        
        meanError(i) = mean( (scnX-stgX).^2 + (scnY-stgY).^2);
        xcorr0lag(i) = sum(scnX.*stgX .* scnY.*stgY)/length(scnX);
        
    end
    MX{ni} = meanPosX;
    MY{ni} = meanPosY;
    MSL{ni} = meanSL;
    MC{ni} = meanCounts;
    ME{ni} = meanError;
    XC{ni} = xcorr0lag;

end

MCFull = cell2mat(MC);
MEFull = cell2mat(ME);
XCFull = cell2mat(XC);

%% Figure. Macro time
% 
% % macro time
% tMacro = chunkLength*(1:length(MCFull)) ;
% 
% figure, 
% clf
% subplot(211)
% plot(tMacro, sqrt(MEFull)*1e3,'linewidth',1),
% grid on
% ylabel 'meanError [nm]'
% xlabel 'Macro time [s]'
% ylim([0 200])
% 
% subplot(212)
% plot(tMacro, MCFull,'linewidth',1),
% grid on
% ylabel 'meanCounts [kHz]'
% xlabel 'Macro time [s]'
% 
% % hysteresisThHi = 0.10;
% % hysteresisThLo = 0.02;
% % hold all
% % plot(tMacro, (D1full)>hysteresisThHi ,'linewidth',1)
% % plot(tMacro, (D1full)<hysteresisThLo ,'linewidth',1)
% % hold off
% 
% linkaxes(findobj(gcf,'type','axes'),'x')

%% Figure. Macro time trace separation

% macro time
tMacro = chunkLength*(1:length(MCFull)) ;

% Local and global time for each trace.
for i=1:numTraces
    tChunkLocal{i} = (0:length(ME{i})-1) * chunkLength;
    if i==1
        tChunkGlobal{i} = tChunkLocal{i};
    else
        tChunkGlobal{i} = tChunkLocal{i} + tChunkGlobal{i-1}(end);
    end
end


%% Scan through and find traces that stays within minDist for at least minTrace time
numPoints = minTrace/chunkLength;
noTraj = 1;
traceSelection =[];
figure(666); hold on
for i=1:numTraces
    ind=1;
    xPos = MX{i}-mean(MX{i});
    yPos = MY{i}-mean(MY{i});
    while ind <=length(tChunkGlobal{i})-numPoints

        if ~all(find(or(abs(xPos(ind:ind+numPoints)-xPos(ind))>maxDist,...
                abs(yPos(ind:ind+numPoints)-yPos(ind))>maxDist))==0)
            noTraj = 1;  
            ind =ind+1;
        else
            noTraj=0;
            traceInd = i;
            startInd = ind;
            endInd = startInd;
            while noTraj==0 && ind<length(tChunkGlobal{i})
                ind = ind+1;
                if or(abs(xPos(ind)-xPos(startInd))>maxDist,...
                        abs(yPos(ind)-yPos(startInd))>maxDist)
                noTraj=1;
                else
                    endInd = ind;
                end
            end
            traceSelection = [traceSelection; traceInd, startInd, endInd];
            area([tChunkGlobal{i}(startInd) tChunkGlobal{i}(endInd)], [2 2], -2);
        end
    end
end
for i=1:numTraces
    plot(tChunkGlobal{i},MX{i}-mean(MX{i}),'-r','linewidth',1),
    plot(tChunkGlobal{i},MY{i}-mean(MY{i}),'-r','linewidth',1),
end
hold off
grid on
ylabel 'meanPos'
xlabel 'Macro time [s]'

figure; 
for i=1:numTraces
    startStop = traceSelection(find(traceSelection(:, 1)==i), 2:3);
    err = [];
    count =[];
    for ind=1:size(startStop, 1)
        err=[err, mean(ME{i}(startStop(ind, 1):startStop(ind, 2)))];
        count=[count, mean(MC{i}(startStop(ind, 1):startStop(ind, 2)))];
    end
    subplot(311)
    hold on
    plot(count,sqrt(err)*1e3,'*r')
    subplot(312)
    hold on
    plot(count', (startStop(:, 2)-startStop(:, 1))*chunkLength, '*b')
    subplot(313)
    hold on
    plot((startStop(:, 2)-startStop(:, 1))*chunkLength,sqrt(err)'*1e3, '*r')
    
end

subplot(311)
grid on
hold off
ylabel 'meanError [nm]'
xlabel 'meanCounts'
ylim([0 100])
subplot(312)
grid on
hold off
ylabel 'lifetime [s]'
xlabel 'meanCounts'
ylim([0 200])
subplot(313)
grid on
hold off
xlabel 'lifetime [s]'
ylabel 'meanError [nm]'
ylim([0 100])


%% Plots

figure(10)
clf
subplot(411), hold all
for i=1:numTraces
    plot(tChunkGlobal{i},sqrt(ME{i})*1e3,'linewidth',1), 
end
hold off
grid on
ylabel 'meanError [nm]'
xlabel 'Macro time [s]'
ylim([0 200])

subplot(412), hold all
for i=1:numTraces
    plot(tChunkGlobal{i},XC{i},'linewidth',1), 
end
hold off
grid on
ylabel 'xCorr@zero lag'
xlabel 'Macro time [s]'
% ylim([0 200])

subplot(413),hold all
for i=1:numTraces
    plot(tChunkGlobal{i},(MC{i}),...
        'linewidth',1,...
        'tag',num2str(i),...
        'ButtonDownFcn', @(h,ev) disp(get(h,'Tag'))), 
end
hold off
grid on
ylabel 'meanCounts [kHz]'
xlabel 'Macro time [s]'
ylim([0 50])

subplot(414), hold all
for i=1:numTraces
    plot(tChunkGlobal{i},MX{i}-mean(MX{i}),'linewidth',1),
    plot(tChunkGlobal{i},MY{i}-mean(MY{i}),'linewidth',1),
end
hold off
grid on
ylabel 'meanPos'
xlabel 'Macro time [s]'

% hysteresisThHi = 0.10;
% hysteresisThLo = 0.02;
% hold all
% plot(tMacro, (D1full)>hysteresisThHi ,'linewidth',1)
% plot(tMacro, (D1full)<hysteresisThLo ,'linewidth',1)
% hold off

linkaxes(findobj(gcf,'type','axes'),'x')




%%

countsTh = 10;
cCluster = MCFull;
eCluster = sqrt(MEFull)*1e3;
eCluster(MCFull<countsTh) = nan;
cCluster(MCFull<countsTh) = nan;

figure(11)
% subplot(222)
scatter(cCluster,eCluster,5,chunkLength*(1:length(MCFull)),...
    'linewidth',2,...
    'marker','square')
% plot(MCFull,sqrt(MEFull)*1e3,'.' )
grid on
ylim([0 100])
xlim([0 100])
xlabel 'meanCounts [kHz]'
ylabel 'mean error [nm]'
