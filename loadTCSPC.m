function loadTCSPC(fHndl)

% Get filename
highlightedFiles = get_cf_highlight;

try
    % Check existence of loaded variables in base
    baseWho = evalin('base','who');
    if ~strcmp(baseWho,'pt3data')
        
        % load file
        tcspcFilename = highlightedFiles{2};
        disp(['Loading file ' tcspcFilename])
        tic;
        [trace, pt3info] = pt3_readByChunks(tcspcFilename);
        loadTime = toc;
        disp(['Load time: ' num2str(loadTime) 's'])
        
        % Some useful data
        trace.nMarkers = sum(trace.markers==1);
        trace.markerTime = trace.trueSync(trace.markers==1);
        
        % Send to base workspace
        assignin('base', 'pt3info', pt3info);
        assignin('base', 'pt3data', trace);
        
    end
    
    % plotTCSPC(fHndl)

catch
    if length(highlightedFiles)~=2,
        error('There is no second file selected. Select a second file with the TCSPC ')
    end
end

end

