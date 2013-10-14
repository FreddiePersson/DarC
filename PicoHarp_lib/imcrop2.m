function imcrop2

him = findobj(gca,'type','image');

if ishandle(him)
    set(him,'tag','imageForProfile')

    [x y]=ginput(1);
    hline = imrect(gca,[x y 1 1]);
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

            himcr = imagesc([1]);
            set(himcr,'tag','profilePlot')
            grid on
            axis image
            set(gca,'YlimMode','auto','XlimMode','auto')
            
        end

        him = findobj('tag','imageForProfile');
        himcr = findobj('tag','profilePlot');

        [X,Y,I,rect] = imcrop(...
            get(him,'XData'),get(him,'YData'),get(him,'CData'),...
            pos(:));

        set(himcr,...
            'XData',[pos(1) pos(1)+pos(3)],...
            'YData',[pos(2) pos(2)+pos(4)],...
            'CData',I)
        

    end

end