function plot_ws_highlight

vars = get_ws_highlight;

% axes(gca);
for i=1:length(vars)
    x = evalin('base',vars{i});
    h = plot(x(:,1),x(:,2));
    set(h,'Displayname',vars{i})
    hold all
end
legend show
hold off
grid on

h_legend = findobj(gcf,'tag','legend');
set(h_legend,'interpreter','none')



