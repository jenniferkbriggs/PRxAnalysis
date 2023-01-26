%load and plot data from PRxValidation

% savename = '06.02.2022.mat'
% load(savename)


time_absent(time_absent == 0) = NaN;
PRx_absent(PRx_absent == 0) = NaN;
Q_intact = quantile(PRx_intact(:,:,:), [0.025, 0.25, 0.5, 0.075, 0.975],3);
Q_impaired = quantile(PRx_impaired(:,:,:), [0.025, 0.25, 0.5, 0.075, 0.975],3);
Q_absent = quantile(PRx_absent(:,:,:), [0.025, 0.25, 0.5, 0.075, 0.975],3);

Error_intact = Q_intact - 0;
Error_impaired = Q_impaired - 0.44;
Error_absent = Q_absent - 1;

%save('06.02.2022_analysis.mat', 'Q_intact','Q_impaired', 'Q_absent')


%% Visualize Error: 
figure, 
contourf(Q_absent(:,:,2), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Q1 PRx'];['PRx_{est}-PRx_{real}']})
title(['Error for Q1 PRx value in impaired CA: HR  ' num2str(heartrateperiod(bs))])
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/07.19.2022_syntheticdata/Q0.5Errorimpaired_' heartrateperiod(bs) '.fig'])

%% 
%intact
figure, 
contourf(mean(Error_intact(:,:,3,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Median PRx'];['PRx_{est}-PRx_{real}']})
title('Error for median PRx value in intact CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.5Errorintact.fig'])

%% 
figure, 
contourf(mean(Error_intact(:,:,2,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Q1 PRx'];['PRx_{est}-PRx_{real}']})
title('Error for Q1 PRx value in intact CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.25Errorintact.fig'])

figure, 
contourf(mean(Error_intact(:,:,4,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Q3 PRx'];['PRx_{est}-PRx_{real}']})
title('Error for Q3 PRx value in intact CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.75Errorintact.fig'])



%impaired
figure, 
contourf(mean(Error_impaired(:,:,3,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Median PRx'];['PRx_{est}-PRx_{real}']})
title('Error for median PRx value in impaired CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.5Errorimpaired.fig'])


figure, 
contourf(mean(Error_impaired(:,:,4,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Q3 PRx'];['PRx_{est}-PRx_{real}']})
title('Error for Q3 PRx value in impaired CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.75Errorimpaired.fig'])

%absent
figure, 
contourf(mean(Error_absent(:,:,3,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Median PRx'];['PRx_{est}-PRx_{real}']})
title('Error for median PRx value in absent CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/07.12.2022_ICPbasedontrack/Q0.5Errorabsent_' heartrateperiod(bs) '.fig'])

figure, 
contourf(mean(Error_absent(:,:,2,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Q1 PRx'];['PRx_{est}-PRx_{real}']})
title('Error for Q1 PRx value in absent CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.25Errorabsent.fig'])

figure, 
contourf(mean(Error_absent(:,:,4,:),4), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error Q3 PRx'];['PRx_{est}-PRx_{real}']})
title('Error for Q3 PRx value in absent CA')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/5.23.2022_ICPbasedontrack/Q0.75Errorabsent.fig'])



%% Visualize Error based on ICP range
[icprange,icprangesort] = sort(out.Range(1:100));

c = jet(length(icprangesort)/5);

figure
colororder(c)
plot(squeeze(out.PRx_absent(6,60,:,icprangesort(1:5:end))))
legend(sprintfc('%d', icprange(1:5:end)))
colorbar

figure, 
contourf(A, 'edgecolor','none')
h= colorbar
ylabel(h, 'Maximum PRx')
title('Variation in max PRx value')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'maxprx.fig'])

figure,
contourf(minPRx(:,:,bs), 'edgecolor','none')
h = colorbar
ylabel(h,'minimum PRx')
title('Variation in min PRx value')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')

saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'minprx.fig'])

figure,
contourf(meanPRx(:,:,bs), 'edgecolor','none')
h = colorbar
ylabel(h, 'PRx')
title('Average in PRx')
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')

saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'meanprx.fig'])
