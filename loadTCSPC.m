function loadTCSPC(fHndl)

% Get filename
highlightedFiles = get_cf_highlight;

% Check existence of loaded variables in base
baseWho = evalin('base','who');
if ~strcmp(baseWho,'pt3data')
    % load file
    try
        tcspcFilename = highlightedFiles{2};
        disp(['Loading file ' tcspcFilename])
        tic;
        [trace, pt3info] = pt3_readByChunks(tcspcFilename);
    catch
        [filename, pathname] = uigetfile({'*.pt3', 'TCSPC (*.pt3)'}, 'Select TCSPC file');
        if ( filename == 0 )
            filename = 0;
            pathname = 0;
            error('No valid TCSPC file selected!')
            return
        else
            tcspcFilename = [ pathname, filename ];
            disp(['Loading file ' tcspcFilename])
            tic;
            [trace, pt3info] = pt3_readByChunks(tcspcFilename);
        end  
        
    end
    
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



end

