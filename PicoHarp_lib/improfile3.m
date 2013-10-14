function improfile3(im)

him = findobj(gca,'type','image');

if ishandle(him)
    set(him,'tag','imageForProfile')

    [x y]=ginput(1);
    hline = imline(gca,[x x ], [y y]);
    api = iptgetapi(hline);
    id = api.addNewPositionCallback(@profileWindow);
else
    disp('No image found.')
end



    function profileWindow(pos)

        hfig = findobj('tag','profileWindow');

        if isempty(hfig)
            hfig=figure;
            set(gcf,...
                'tag','profileWindow',...
                'DeleteFcn', @(h,e) delete(hline) )
            
            subplot(221)
            hplot = plot(zeros(length(im)),zeros(length(im)),'tag','profilePlot');
            grid on
            
            subplot(222)
            hplotNorm = plot(zeros(length(im)),zeros(length(im)),'tag','profilePlotNorm');
            grid on
            
            subplot(223)
            himpr = imagesc([1],'tag','profileImage');
            grid on
%             axis image
            set(gca,'YlimMode','auto','XlimMode','auto')
            
            subplot(224)
            himprNorm = imagesc([1],'tag','profileImageNorm');
            grid on
%             axis image
            set(gca,'YlimMode','auto','XlimMode','auto')
        end

        him = findobj('tag','imageForProfile');
        hplot = findobj('tag','profilePlot');
        himpr = findobj('tag','profileImage');
        
        hplotNorm = findobj('tag','profilePlotNorm');
        himprNorm = findobj('tag','profileImageNorm');

        for i=1:length(im)
        [cx,cy,c{i}] = improfile(...
            get(him,'XData'),get(him,'YData'),im{i},...
            pos(:,1),pos(:,2),...
            'nearest');%'bilinear');
        end

       for i=1:length(im)
        set(hplot(i),...
            'XData',sqrt((cx-cx(1)).^2+(cy-cy(1)).^2),...
            'YData',c{i})
       end

       for i=1:length(im)
        set(hplotNorm(i),...
            'XData',sqrt((cx-cx(1)).^2+(cy-cy(1)).^2),...
            'YData',c{i}./max(c{i}))
       end
       
       
       profileim = cell2mat(c)';
%        set(himcr,...
%             'XData',[pos(1) pos(1)+pos(3)],...
%             'YData',[pos(2) pos(2)+pos(4)],...
%             'CData',cell2mat(c))
        set(himpr,...
        'CData',profileim)
    
        set(himprNorm,...
        'CData',profileim./(max(profileim,[],2)*ones(1,size(profileim,2))))
    end

end