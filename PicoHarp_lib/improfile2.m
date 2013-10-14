function improfile2

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

            hplot = plot([1],[1],'tag','profilePlot');
            grid on
        end

        him = findobj('tag','imageForProfile');
        hplot = findobj('tag','profilePlot');

        [cx,cy,c] = improfile(...
            get(him,'XData'),get(him,'YData'),get(him,'CData'),...
            pos(:,1),pos(:,2),...
            'nearest');%'bilinear');

        set(hplot,...
            'XData',sqrt((cx-cx(1)).^2+(cy-cy(1)).^2),...
            'YData',c)

    end

end