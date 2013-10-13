function track_im(cond, im, ni)
traces = 1:size(im,2);
t = (1:size(im,1))/cond.controllerUpdateClock*1e3;
switch length(size(im))
    case 2
        imagesc(t, traces, im');
    case 3
%         imagesc(t, traces, permute(im/max(max(max(im))),[2 1 3]))
        satVal = 10;
        imagesc(t, traces, permute(im/satVal.*(im<=satVal)+1*(im>satVal),[2 1 3]))
end
line([1 size(im,1)], [ni ni]);

xlabel('Time [ms]')
ylabel('Trace')
