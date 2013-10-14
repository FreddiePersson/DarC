function im = pt3_imassemble(timeTrace, imData)
tic

% imData.dtimeLow
% imData.dtimeHi

% Indexes where theres line markers.
lineIdx = find(timeTrace.marker2);
lineIdx = [lineIdx; length(timeTrace.marker2)]; %Patch for the last line, all the rest of the trace is analyzed.

% Cumulative sum of line markers. This indicates the line number
lineCumsum = cumsum(timeTrace.marker2);

% Amount of pixels in a line is the sum of marker1 in a given line.
pixelInLine = sum(timeTrace.marker1(lineIdx(1):lineIdx(2)));

% Initialize image matrix
im=zeros(length(lineIdx)-1,pixelInLine);


for i=1:length(lineIdx)-1
    % generate index range to work with smaller arrays
    currentLineIndexRange = lineIdx(i):lineIdx(i+1);
    
    % For the line i, get the pixel markers and accumulate.
    pixelx = 1 + cumsum(...
        timeTrace.marker1(currentLineIndexRange) &...
        lineCumsum(currentLineIndexRange)==i);
    
    % Count the right records for each pixel on the line. 
    [pixelNumber pixelCount] = unique2(pixelx(...
        lineCumsum(currentLineIndexRange)==i &...                    % Records on current line
        timeTrace.ch1(currentLineIndexRange) &...                  z       % Records on channel 1
        timeTrace.relativeTime(currentLineIndexRange)>imData.dtimeLow &...% Records with relative time greater that dtimLow
        timeTrace.relativeTime(currentLineIndexRange)<imData.dtimeHi...   % Records with relative time smaller that dtimeHi        )');
        )');

    %Remove extra pixel clocks that may be wrong.
    pixelNumber = pixelNumber(pixelNumber<=pixelInLine);
    pixelCount  = pixelCount(pixelNumber<=pixelInLine);
    
    % Add at current line i the amount of records for each pixel.
    im(i,pixelNumber) = pixelCount;
end
%         imagesc(im), axis image

% Separate frames
im = permute( reshape(im',[pixelInLine i/imData.frameNumber  imData.frameNumber ]),[2 1 3] );
 
% clc
% m = [ones(2,2);ones(2,2)*2;ones(2,2)*3]
% m1 = reshape(m',[2 2 3])


elapsedTime = toc;
disp(['Assemble time: ' num2str(elapsedTime) 's'])
end