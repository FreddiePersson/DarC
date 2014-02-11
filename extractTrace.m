% Creates new figure with current trace

mainFigHandle = 1;
h.yscan = findobj(mainFigHandle,'tag','linkX_y');
h.xscan = findobj(mainFigHandle,'tag','linkX_x');
h.apd = findobj(mainFigHandle,'tag','linkX_apd');
h.traj = findobj(mainFigHandle,'tag','adjustXY');

figure
copyobj(h.yscan,gcf)
copyobj(h.xscan,gcf)
copyobj(h.apd,gcf)

figure
copyobj(h.traj,gcf)

clear mainFigHandle h