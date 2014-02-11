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
dt = .05e6; %[ns]
counts2khz = dt/1e9*1e3;
t = pt3limits(1):dt:pt3limits(2);%:max(pt3data.trueSync);
c1 = histc(pt3data.trueSync(windowIndex & pt3data.chan==1),t)/counts2khz;
c2 = histc(pt3data.trueSync(windowIndex & pt3data.chan==2),t)/counts2khz;
c3 = histc(pt3data.trueSync(windowIndex & pt3data.chan==3),t)/counts2khz;

subplot(311)
stem(t-t(1), c1, 'marker','none'), hold all
stem(t-t(1)+dt/3, c2, 'marker','none')
stem(t-t(1)+dt*2/3, c3, 'marker','none'), hold off
    
grid on
xlabel('[ns]')
ylabel('Counts [kHz]')
title('Original counts binned at 1ms')

% cl1=pt3data.trueSync(windowIndex & pt3data.chan==1);
% cl2=pt3data.trueSync(windowIndex & pt3data.chan==2);
% cl3=pt3data.trueSync(windowIndex & pt3data.chan==3);

% [Cl1 Cl2] = meshgrid(cl1,cl2);
% C12 = Cl1-Cl2; 
% clear Cl1 Cl2
% figure,
% hist(abs(C12(:)),logspace(2,7,50))
% set(gca,'Xscale','log')
% % set(gca,'Yscale','log')

maxlagsSecs = 100e-3; %[s] Maximum lag for correlation curve
maxlagsSamples = ceil(maxlagsSecs / dt / 1e-9); %Because dt comes in nanoseconds

[xc12, lags]= xcorr(c1-mean(c1),c2-mean(c2), maxlagsSamples, 'unbiased');
xc23 = xcorr(c2-mean(c2),c3-mean(c3), maxlagsSamples, 'unbiased');
xc13 = xcorr(c1-mean(c1),c3-mean(c3), maxlagsSamples, 'unbiased');

subplot(312)
plot(lags*dt/1e9, xc12/xc12((end-1)/2+1)), hold all
plot(lags*dt/1e9, xc23/xc23((end-1)/2+1)),
plot(lags*dt/1e9, xc13/xc13((end-1)/2+1)), hold off
grid on
xlabel('lag [s]')
ps sx gxy gm
ticklabel2eng x

% Plot lifetime of selected area
tMicro = 0:pt3info.Resolution:1/pt3info.CntRate0*1e9;

c1Micro = hist(pt3data.relativeTime(windowIndex & pt3data.chan==1) ,tMicro);
c2Micro = hist(pt3data.relativeTime(windowIndex & pt3data.chan==2) ,tMicro);
c3Micro = hist(pt3data.relativeTime(windowIndex & pt3data.chan==3) ,tMicro);


% Fitting of lifetime
tOrigin = 4; %[ns]
xFit = (tMicro(tMicro>tOrigin)-tOrigin)';
yFit1 = c1Micro(tMicro>tOrigin)';
yFit2 = c2Micro(tMicro>tOrigin)';
yFit3 = c3Micro(tMicro>tOrigin)';


warning off
fitObj1exp1 = fit(xFit ,yFit1 , 'exp1');
fitObj2exp1 = fit(xFit ,yFit2 , 'exp1');
fitObj3exp1 = fit(xFit ,yFit3 , 'exp1');
fitObj1exp2 = fit(xFit ,yFit1 , 'exp2');
fitObj2exp2 = fit(xFit ,yFit2 , 'exp2');
fitObj3exp2 = fit(xFit ,yFit3 , 'exp2');
warning on

tau1 = 1./[coeffvalues(fitObj1exp1)
coeffvalues(fitObj2exp1)
coeffvalues(fitObj3exp1)];

tau2 = 1./[coeffvalues(fitObj1exp2)
coeffvalues(fitObj2exp2)
coeffvalues(fitObj3exp2)];

subplot(337)
plot(tMicro, c1Micro,'o','linewidth',1,'markerSize',2), hold all
plot( xFit+tOrigin, feval(fitObj1exp1,xFit), ...
    xFit+tOrigin, feval(fitObj1exp2,xFit),'linewidth',2), hold off
ps gxy

legend({...
    'APD1',...
    [num2str(-tau1(1,2),'%.2f') 'ns'],...
    [num2str(-tau2(1,2),'%.2f') 'ns, ' num2str(-tau2(1,4),'%.2f') 'ns' ] })

subplot(338)
plot(tMicro, c2Micro,'o','linewidth',1,'markerSize',2), hold all
plot( xFit+tOrigin, feval(fitObj2exp1,xFit), ...
    xFit+tOrigin, feval(fitObj2exp2,xFit),'linewidth',2), hold off
ps gxy

legend({...
    'APD2',...
    [num2str(-tau1(2,2),'%.2f') 'ns'],...
    [num2str(-tau2(2,2),'%.2f') 'ns, ' num2str(-tau2(2,4),'%.2f') 'ns' ] })

subplot(339)
plot(tMicro, c3Micro,'o','linewidth',1,'markerSize',2), hold all
plot( xFit+tOrigin, feval(fitObj3exp1,xFit), ...
    xFit+tOrigin, feval(fitObj3exp2,xFit),'linewidth',2), hold off
ps gxy

legend({...
    'APD3',...
    [num2str(-tau1(3,2),'%.2f') 'ns'],...
    [num2str(-tau2(3,2),'%.2f') 'ns, ' num2str(-tau2(3,4),'%.2f') 'ns' ] })


% title(['lifetimes ' num2str(-tau(:,2)') '    [ns]'])



% title(['lifetimes ' num2str(-tau(:,2)') ...
%     '    [ns]  ' num2str(-tau(:,4)') '    [ns]'])


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