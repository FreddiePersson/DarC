function plot_normalize_all

h = get(gca,'children');
for i=1:length(h)
    y1 = get(h(i),'YData');
    set(h(i),'Ydata',y1/max(y1))
end
