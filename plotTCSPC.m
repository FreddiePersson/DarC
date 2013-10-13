function plotTCSPC(fHndl)

% Get loaded data
pt3info = evalin('base', 'pt3info');
pt3data = evalin('base', 'pt3data');
data = evalin('base', 'data');
ni = evalin('base', 'ni');

% Get time limits
axHndl = findobj(fHndl, 'Tag', 'linkX_x');
limits = get(axHndl,'XLim')*1e6; %from [ms] to [ns]

% Find picoHarp trigger on FPGA data
picoHarpTriggerIndex = find(diff(double(data{1}.picoHarpTrigger))>0);
picoHarpTriggerTime = data{1}.t(picoHarpTriggerIndex)*1e9; %From [s] to [ns]

% Calculate timelimits in the pt3 file.
pt3limits = limits - picoHarpTriggerTime + pt3data.markerTime(ni);

% Determination of the window in units of the picoHarp trace
windowIndex = (pt3data.trueSync>pt3limits(1) & pt3data.trueSync<pt3limits(2));

% Plots
figure(2)

% Plot counts again, to check they are right
dt = .1e6; %[ns]
counts2khz = dt/1e9*1e3;
t = pt3limits(1):dt:pt3limits(2);%:max(pt3data.trueSync);
c1 = histc(pt3data.trueSync(windowIndex & pt3data.chan==1),t)/counts2khz;
c2 = histc(pt3data.trueSync(windowIndex & pt3data.chan==2),t)/counts2khz;
c3 = histc(pt3data.trueSync(windowIndex & pt3data.chan==3),t)/counts2khz;

subplot(311)
plot(t-t(1), c1,...
    t-t(1), c2,...
    t-t(1), c3)
grid on
xlabel('[ns]')
ylabel('Counts [kHz]')
title('Original counts binned at 1ms')

cl1=pt3data.trueSync(windowIndex & pt3data.chan==1);
cl2=pt3data.trueSync(windowIndex & pt3data.chan==2);
cl3=pt3data.trueSync(windowIndex & pt3data.chan==3);

% [Cl1 Cl2] = meshgrid(cl1,cl2);
% C12 = Cl1-Cl2; 
% clear Cl1 Cl2
% figure,
% hist(abs(C12(:)),logspace(2,7,50))
% set(gca,'Xscale','log')
% set(gca,'Yscale','log')

subplot(312)
plot(xcorr(c1,c2,'biased')), hold all
plot(xcorr(c2,c3,'biased')),
plot(xcorr(c1,c3,'biased')), hold off
grid on
xlabel('[ns]')


% Plot lifetime of selected area
tMicro = 0:pt3info.Resolution:1/pt3info.CntRate0*1e9;

c1Micro = hist(pt3data.relativeTime(windowIndex & pt3data.chan==1) ,tMicro);
c2Micro = hist(pt3data.relativeTime(windowIndex & pt3data.chan==2) ,tMicro);
c3Micro = hist(pt3data.relativeTime(windowIndex & pt3data.chan==3) ,tMicro);

subplot(313)
plot(tMicro, c1Micro,...
    tMicro, c2Micro,...
    tMicro, c3Micro)
grid on
xlabel('[ns]')



% hold on
% plot(pt3data.markerTime, ones(size(pt3data.markerTime))*0,...
%     'sqk', 'MarkerFaceColor', 'k')
% hold off
% grid on
%
% title(['Number of Markers: ' num2str(nMarkers)])


% figure(3)
% dt = 10e6; %[ns]
% counts2khz = dt/1e9*1e3;
% t = 0:dt:max(pt3data.trueSync);
% c1 = histc(pt3data.trueSync(pt3data.chan==1),t)/counts2khz;
% c2 = histc(pt3data.trueSync(pt3data.chan==2),t)/counts2khz;
% c3 = histc(pt3data.trueSync(pt3data.chan==3),t)/counts2khz;
%
% plot(t, c1, t, c2, t, c3), hold on
% plot(pt3data.markerTime, ones(size(pt3data.markerTime))*0,...
%     'sqk', 'MarkerFaceColor', 'k')
% hold off
% grid on
%
% title(['Number of Markers: ' num2str(pt3data.nMarkers)])
% 1;

end