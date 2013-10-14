function interp_ws_highlight

vars = get_ws_highlight;

% axes(gca);
for i=1:length(vars)
    x{i} = evalin('base',vars{i});
    h{i} = plot(x{i}(:,1),x{i}(:,2));
    set(h{i},'Displayname',vars{i})
    hold all
    
    min_x{i} = min(x{i}(:,1));
    max_x{i} = max(x{i}(:,1));
end


lower_lim = max([min_x{:}]);
higher_lim = min([max_x{:}]);

xi = linspace(lower_lim,higher_lim,1000);

y_prod = ones(size(xi));
for i=1:length(vars)
    yi{i} = interp1(x{i}(:,1),x{i}(:,2),xi);
    y_prod = y_prod.*yi{i};
end
h_prod = plot(xi,y_prod);
set(h_prod,'Displayname','Product')
hold off
grid on


legend show
h_legend = findobj(gcf,'tag','legend');
set(h_legend,'interpreter','none')




