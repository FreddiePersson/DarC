function dynamicY(ax)
% Dynamically updates the y-axes of linked subplots.

hL = addlistener(ax, 'XLim', 'PostSet', @(src, event)scaleY(src, event, ax) );
   
end

function scaleY(~, ~, hndl)
        
        hline = findobj(hndl, 'type','line' );
        xlim =  get(hndl, 'XLim');
        
        for i = 1: length(hline)
            
            xData = get(hline(i),'XData');
            yData = get(hline(i),'YData');
                      
            ylimMin(i) = min(yData(xData > xlim(1) & xData < xlim(2)));
            ylimMax(i) = max(yData(xData > xlim(1) & xData < xlim(2)));
                               
        end     
        % when pushing next hline = 0. this results in error.
        % circumvent execution using try
        try 
        set(hndl,'YLim',[min(ylimMin) max(ylimMax)])
        end
    end