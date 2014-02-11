% evaluate whole file

clc
clear
track_filename = get_cf_highlight; %get filename from Current Folder Explorer
track_filename = track_filename{1};

% getr only number of traces
% [data, param, imageStack, ni, numTraces] = track_open_single_hdf5(track_filename, 1, 1);

[data, numTraces] = track_open_all_traces(track_filename);

% for ni=1:numTraces
for ni=1:numTraces
    
%     [data, param, imageStack, ni, ~] = track_open_single_hdf5(track_filename, ni, 1);
%     ni
    disp(['Processing trace ' num2str(ni) ' of ' num2str(numTraces)])
       
    coordsScn = [data{ni}.scannerX, data{ni}.scannerY];
    coordsStg = [data{ni}.stageX, data{ni}.stageY];
    timeStep = data{ni}.t(2)-data{ni}.t(1);
%     samplingPeriod = str2double(get(findobj(fHndl, 'Tag', 'main_edCDFSampling'), 'String'))/1e3;
%     samplingPeriod = 5e-3; %[s]
%     dataPeriod = round((samplingPeriod)/timeStep);
%     sPMult = [1];
    
    chunkLength = 100e-3; %[s]
    chunkSize = floor(chunkLength/timeStep);
    nChunks = ceil(length(data{ni}.scannerX)/chunkSize);
%     d1 = zeros(nChunks , length(sPMult));
    meanCounts = zeros(1, nChunks);
    meanError = zeros(1, nChunks);
    
    for i=1:nChunks 
        
        % Index for chunks
        startIndex = (i-1) * chunkSize+1;
        endIndex = min((i) * chunkSize-1, length(data{ni}.scannerX) );
        
%         for j=1:length(sPMult)
%             
%             % Step length calculations
%             dCoords =...
%                 coords(startIndex + (dataPeriod*sPMult(j)):(dataPeriod*sPMult(j)): endIndex,1:2) -...
%                 coords(startIndex                         : dataPeriod*sPMult(j) :(endIndex-dataPeriod*sPMult(j)),1:2);
%             stepLengths = sqrt(sum(dCoords.^2,2))*1e3;
%             
%             % fitting CDF for obtaining the diffusivity
%             warning off
%             d1(i,j) = fitCDFsimple(stepLengths, samplingPeriod*sPMult(j));
%             warning on
%         end
        
        % save mean counts
        meanCounts(i) = mean(sum(data{ni}.apds(startIndex:endIndex,:),2))/timeStep*1e-3;
        meanError(i) = mean(...
            (coordsScn(startIndex:endIndex,1)-coordsStg(startIndex:endIndex,1)-mean(coordsScn(startIndex:endIndex,1))+mean(coordsStg(startIndex:endIndex,1))  ).^2+...
            (coordsScn(startIndex:endIndex,2)-coordsStg(startIndex:endIndex,2)-mean(coordsScn(startIndex:endIndex,2))+mean(coordsStg(startIndex:endIndex,2))  ).^2 );
        
        
    end
    
%     D1{ni} = d1;
    MC{ni} = meanCounts;
    ME{ni} = meanError;
    
end
% Calculate steplengths


% figure
% plot(coordsScn(startIndex:endIndex,1)-coordsStg(startIndex:endIndex,1)-mean(coordsScn(startIndex:endIndex,1))-mean(coordsStg(startIndex:endIndex,1)))


% D1full = abs(cell2mat(D1'));
MCFull = cell2mat(MC);
MEFull = cell2mat(ME);

%%
% figure

tMacro = chunkLength*(1:length(MCFull)) ;
figure
clf
% subplot(211)
% plot(tMacro, (D1full),'linewidth',1)
% grid on
% ylabel 'Diffusivity [um2/s]'
% xlabel 'Macro time [s]'
% ylim([0 1])
% 
% hysteresisThHi = 0.10;
% hysteresisThLo = 0.02;
% hold all
% plot(tMacro, (D1full)>hysteresisThHi ,'linewidth',1)
% plot(tMacro, (D1full)<hysteresisThLo ,'linewidth',1)
% hold off

subplot(211)
plot(tMacro, sqrt(MEFull)*1e3,'linewidth',1),
grid on
ylabel 'meanError [nm]'
xlabel 'Macro time [s]'
ylim([0 200])


subplot(212)
plot(tMacro, MCFull,'linewidth',1),
grid on
ylabel 'meanCounts [kHz]'
xlabel 'Macro time [s]'

linkaxes(findobj(gcf,'type','axes'),'x')


% countsTh = 10;
% dCluster = abs(D1full(:,1));
% cCluster = MCFull;
% dCluster(MCFull<countsTh) = nan;
% cCluster(MCFull<countsTh) = nan;
% 
% subplot(222)
% scatter(dCluster,cCluster,2,chunkLength*(1:length(MCFull)))
% grid on
% ylabel 'meanCounts [kHz]'
% xlabel 'Diffusivity [um2/s]'
% 
% subplot(224)
% plot3(chunkLength*(1:length(MCFull)), dCluster, cCluster)
% grid on

%%

countsTh = 10;
cCluster = MCFull;
eCluster = sqrt(MEFull)*1e3;
eCluster(MCFull<countsTh) = nan;
cCluster(MCFull<countsTh) = nan;

figure
% subplot(222)
scatter(cCluster,eCluster,2,chunkLength*(1:length(MCFull)))
% plot(MCFull,sqrt(MEFull)*1e3,'.' )
grid on
ylim([0 100])
xlim([0 100])
xlabel 'meanCounts [kHz]'
ylabel 'mean error [nm]'
