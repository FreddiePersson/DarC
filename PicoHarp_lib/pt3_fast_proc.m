
filename = get_cf_highlight;
timeTrace =pt3_read(filename{1});
imData.dtimeLow = 0;
imData.dtimeHi  = 12;
imData.frameNumber = 3;
im = pt3_imassemble(timeTrace, imData);

imagesc(im(:,:,2)), axis image