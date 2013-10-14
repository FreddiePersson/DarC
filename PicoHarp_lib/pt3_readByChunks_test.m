
hlFilename = get_cf_highlight;
[trace, pt3info] = pt3_readByChunks(hlFilename{1});


% figure
% plot(trace.trueSync)

% sum(trace.chan==1)
% sum(trace.chan==2)
% sum(trace.chan==3)
nMarkers = sum(trace.markers==1);

% hist(trace.relativeTime,0:0.0032:25)

%
figure
dt = 100e6; %[ns]
counts2khz = dt/1e9*1e3;
t = 0:dt:max(trace.trueSync);
c1 = histc(trace.trueSync(trace.chan==1),t)/counts2khz;
c2 = histc(trace.trueSync(trace.chan==2),t)/counts2khz;
c3 = histc(trace.trueSync(trace.chan==3),t)/counts2khz;

markerTime = trace.trueSync(trace.markers==1);

plot(t, c1, t, c2, t, c3), hold on
plot(markerTime, ones(size(markerTime))*0,...
    'sqk', 'MarkerFaceColor', 'k')
hold off
grid on

title(['Number of Markers: ' num2str(nMarkers)])