function [] = drawImageOverlay(image, beamPos, magn, coords)
% Draws tracking coordinates from a scanning beam on an image
% 
% INPUT:
% image 
% beamPos:   The 0, 0 popsition of the beam in image coordinates
% magn:   The size of a pixel on the image plane
% coords:   The coordinates from the tracking
% 
% OUTPUT:
% 

%% 
figHndl = figure;
hold all
vecX = (1:size(image, 2))*magn;
vecY = (1:size(image, 1))*magn;
imagesc(vecX,vecY,image);
colormap('gray');
beamX = beamPos(1)*magn;
beamY = beamPos(2)*magn;
plot(beamX, beamY, '*k')
plot((coords(:, 1)-coords(1, 1))./1e3+beamX, (coords(:, 2)-coords(1, 2))./1e3+beamY, '-r');
plot((coords(:, 1))./1e3+beamX, (coords(:, 2))./1e3+beamY, '-g');
title('Image of Bacteria with trace')
xlabel('um')
ylabel('um')
set(gca,'xlim',[beamPos(1)*magn-15 beamPos(1)*magn+15],'ylim',...
    [beamPos(2)*magn-15 beamPos(2)*magn+15])
daspect([1 1 1])

end
%%
% figure
% hold all
% for ni = 1:9
%     plot(dataT{23,ni},scannerX{23,ni})
%     xlabel('sec')
% end
% %% boxplot
% figure
% hold all
% % t = round(time(:,1)/60*10)/10;
% boxplot(meanCounts',time(:,1))
% xlabel('time [min]')
% ylabel('mean Counts')
% title('Boxplot of mean Counts')
% set(gca,'ylim',[0.2 0.9])
% %% linfit to mean
% figure
% hold all
% [t,ind] = sort(time(:,1));
% plot(t,mean(meanCounts(ind,:),2),'.k')
% % linear fit
% % [1 t1;1 t2 ...]*[cons ao]=mean(meanCounts,2)
% % => [cons ao]=[1 t1;1 t2 ...]\mean(meanCounts,2)
% A = [ones(length(time),1),t];
% q = A\mean(meanCounts,2);
% plot(t,A*q,'r')
% xlabel('time [min]')
% ylabel('Mean Counts')
% 
% %%
% figure
% hold all
% i = 8;
% ni = 6;
% plot(dataT{i,ni}*10^3,apds{i,ni}(:,1),'r')
% plot(dataT{i,ni}*10^3,apds{i,ni}(:,2),'g')
% plot(dataT{i,ni}*10^3,apds{i,ni}(:,3),'b')
% %% average counts
% i = 3;
% ni = 3;
% apdAll = apds{i,ni}(:,1)+apds{i,ni}(:,2)+apds{i,ni}(:,3);
% t1 = 1000;
% t2 = 3000;
% range = round(-dataT{i,ni}(1)*10^4+10*t1):round(-dataT{i,ni}(1)*10^4+10*t2);
% burstTime = range(end)-range(1);
% average = mean(apdAll(range));
% clc
% disp(['Average Counts: ',num2str(average)])
% disp(['Burst length: ',num2str(burstTime*0.1),' ms'])
% 
% 
% end