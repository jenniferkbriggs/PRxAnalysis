% Look at PRx synthetic for different frequencies
clear all
close all
clc

cd('/data/brain/tmp_jenny/PRxError/Results/10.19.2022_syntheticdata_fasterfreq/')
%load and plot data from PRxValidation
try
    addpath('~/Git/UniversalCode/')
catch

    addpath('~/Documents/GitHub/UniversalCode/')
end
files = dir('10*.mat')

min_absent=[]
min_impaired=[]
min_intact = []
for i = 1:length(files)
    disp(i)
    load(files(i).name)
    if 0
        time_absent = time_absent_HR;
        time_impaired = time_impaired_HR;
        time_intact = time_intact_HR;
        PRx_absent = PRx_absent_HR;
        PRx_impaired = PRx_impaired_HR;
        PRx_intact = PRx_intact_HR;
    end
    time_absent(time_absent == 0) = NaN;
    PRx_absent(PRx_absent == 0) = NaN;
    
    time = time_absent;
    PRx_intact(PRx_intact == 0) = NaN;
    PRx_impaired(PRx_impaired == 0) = NaN;
    
    Q_intact = quantile(PRx_intact(:,:,:), [0.025, 0.25, 0.5, 0.075, 0.975],3);
    Q_impaired = quantile(PRx_impaired(:,:,:), [0.025, 0.25, 0.5, 0.075, 0.975],3);
    Q_absent = quantile(PRx_absent(:,:,:), [0.025, 0.25, 0.5, 0.075, 0.975],3);


    
    %calculate error
    Error_intact = (Q_intact - 0);
    Error_impaired = (Q_impaired - 0.44);
    Error_absent = (Q_absent - 0.97);
    Err_intact_all(i,:,:) = Error_intact(:,:,3);
    Err_impaired_all(i,:,:) = Error_impaired(:,:,3);
    Err_absent_all(i,:,:) = Error_absent(:,:,3);
    
    %calculate Bias for figure 5
    STD_intact(i,:,:) = std(PRx_intact, [], 3, 'omitnan');
    STD_intact(i,:,:) = std(PRx_intact, [], 3, 'omitnan');
    STD_intact(i,:,:) = std(PRx_intact, [], 3, 'omitnan');

    if 1 
        for k = 1:30
            for j = 2:64
                deviation_from_true(i*3-2,k,j) = mean(squeeze(PRx_intact(k,j,:)) - 0, 'omitnan');
                deviation_from_true(i*3-1,k,j) = mean(squeeze(PRx_impaired(k,j,:)) - .44, 'omitnan');
                deviation_from_true(i*3,k,j) = mean(squeeze(PRx_absent(k,j,:)) - 0.97, 'omitnan');
            end
        end
    end 
    total_bias = squeeze(mean(deviation_from_true(:,:,:),1,'omitnan'));
    uncertainty_mean = squeeze(std(deviation_from_true(:,:,:),[],1,'omitnan'));

    %find optimal
    optimal_uncertainty = (uncertainty_mean < 0.22);
    writematrix(optimal_uncertainty, '/data/brain/tmp_jenny/PRxError/Results/synthetic_STD_all_bin.csv')

    optimal_bias = (abs(total_bias) < 0.22);
    writematrix(optimal_bias, '/data/brain/tmp_jenny/PRxError/Results/synthetic_Mean_all_bin.csv')



    writematrix(squeeze(mean(deviation_from_true(:,:,:),1,'omitnan')),'/data/brain/tmp_jenny/PRxError/Results/synthetic_Mean_all.csv')
    writematrix(squeeze(std(deviation_from_true(:,:,:),[],1,'omitnan')),'/data/brain/tmp_jenny/PRxError/Results/synthetic_STD_all.csv')

%     % minimize error and std: 
%     costfunc_intact = (abs(Error_intact(:,:,3)).*(std(PRx_intact, [], 3, 'omitnan'))).^2;
%     costfunc_impaired = (abs(Error_impaired(:,:,3)).*(std(PRx_impaired, [], 3, 'omitnan'))).^2;
%     costfunc_absent = (abs(Error_absent(:,:,3)).*(std(PRx_absent, [], 3, 'omitnan'))).^2;
% 
%     HR_all(i) = HR;
%     
    %Cmap = jet(30*65);
    %stdev_intact = reshape(std(PRx_intact, [], 3, 'omitnan'),1,[]);
    %[~,Cmapsort] = sort(stdev_intact);
    %Colortrip= Cmap(Cmapsort,:);
%     

if 0%i == 1
    figure, nexttile
    S = surfc(Error_intact(:,:,3))
    xlabel('Number of samples taken for correlation')
    ylabel('Averaging Window (seconds)')
    %hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
    %text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
    h = colorbar
    ylabel(h, 'Uncertainty in measurement')
    zlabel('Error Intact PRx')
    set(S, 'EdgeColor','none')

           
    S = surfc(Error_impaired(:,:,3))
    xlabel('Number of samples taken for correlation')
    ylabel('Averaging Window (seconds)')
    %hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
    %text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
    h = colorbar
    ylabel(h, 'Uncertainty in measurement')
    zlabel('Error Impaired PRx')
    colormap(inferno())
    set(S, 'EdgeColor','none') 
    
    
    S = surfc(Error_absent(:,:,3))
    xlabel('Number of samples taken for correlation')
    ylabel('Averaging Window (seconds)')
    %hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
    %text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
    h = colorbar
    ylabel(h, 'Uncertainty in measurement')
    zlabel('Error Absent PRx')
   colormap(inferno())
    set(S, 'EdgeColor','none')
   

end

    
    
    %%--- Optimize option 1: looking for optimal methods based on heart
    %%rate ----- 
%     
%     %find all values lower than 1% of cost function distribution
%     cutoff = quantile(costfunc_absent, 0.001, 'all');
%     [r, c] = find(costfunc_absent <= cutoff)
%     min_absent = [min_absent; ones(length(r),1).*HR, r, c];
%     
%     cutoff = quantile(costfunc_impaired, 0.001, 'all');
%     [r, c] = find(costfunc_impaired <= cutoff)
%     min_impaired = [min_impaired; ones(length(r),1).*HR, r, c];
%     
%     cutoff = quantile(costfunc_intact, 0.001, 'all');
%     [r, c] = find(costfunc_intact <= cutoff)
%     min_intact = [min_intact; ones(length(r),1).*HR, r, c];
%     
end

%% 
if 1
%%---- Optimize #2 Model averaging ---- 
Error_av_intact = mean([Err_intact_all(:,6,60), Err_intact_all(:,10,30), Err_intact_all(:,5, 40), Err_intact_all(:,15,30)],2)
Error_av_impaired = mean([Err_impaired_all(:,6,60), Err_impaired_all(:,10,30), Err_impaired_all(:,5, 40), Err_impaired_all(:,15,30)],2)
Error_av_absent = mean([Err_absent_all(:,6,60), Err_absent_all(:,10,30), Err_absent_all(:,5, 40), Err_absent_all(:,15,30)],2)

%%----Optimize #3 Is there one that consistantly underestimates?
[~, min_av_intact] = min([Err_intact_all(:,10,40),Err_intact_all(:,10,30),Err_intact_all(:,5, 40),Err_intact_all(:,15,30),Err_intact_all(:,6,40)],[],2)
[~, min_av_impaired] = min([Err_impaired_all(:,10,40),Err_impaired_all(:,10,30),Err_impaired_all(:,5, 40),Err_impaired_all(:,15,30),Err_impaired_all(:,6,40)],[],2)
[~, min_av_absent] = min([Err_absent_all(:,10,40),Err_absent_all(:,10,30),Err_absent_all(:,5, 40),Err_absent_all(:,15,30),Err_absent_all(:,6,40)],[],2)

h1 = histogram(min_av_intact);
h1 = h1.Values;
h2 = histogram(min_av_impaired);
h2 = h2.Values;
h3 = histogram(min_av_absent);
h3 = [0 0 144 0 71];
labels = ({'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp'})
figure, til = tiledlayout('flow','Padding', 'compact','TileSpacing','Compact')

nexttile, pie(h1), title('Intact CA'), set(gca, 'FontSize',12), set(gca, 'color','none')
nexttile, pie(h2), title('Impaired CA'),  set(gca, 'FontSize',12), set(gca, 'color','none')
nexttile, pie(h3), title('Absent CA'),  set(gca, 'FontSize',12), set(gca, 'color','none')
l = legend(labels)

color = [173, 29, 28;
        41, 77, 70;
        160, 82, 108;
        79, 4, 39;
        30, 123, 32;
        173, 29, 28;
        41, 77, 70;
        160, 82, 108;
        79, 4, 39;
        30, 123, 32;
        173, 29, 28;
        41, 77, 70;
        160, 82, 108;
        79, 4, 39;
        30, 123, 32]./255;




figure
violinplot([Err_intact_all(:,10,40),Err_intact_all(:,10,30),Err_intact_all(:,5, 40),Err_intact_all(:,15,30),Err_intact_all(:,6,40),...
   Err_impaired_all(:,10,40),Err_impaired_all(:,10,30),Err_impaired_all(:,5, 40),Err_impaired_all(:,15,30),Err_impaired_all(:,6,40),...
   Err_absent_all(:,10,40),Err_absent_all(:,10,30),Err_absent_all(:,5, 40),Err_absent_all(:,15,30),Err_absent_all(:,6,40)],...
    ["","Intact","","","", "Impaired","","","","Absent","",""], 'ViolinColor',color)
ax = gca;
axc = ax.Children;
ax.XTick = [2,7,12]
ax.XTickLabel =["Intact","Impaired","Absent"]
[l, icons] = legend([axc(end), axc(end-length(axc)/15), axc(end-2*length(axc)/15), axc(end-3*length(axc)/15), axc(end-4*length(axc)/15)], 'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp')

set(gca, 'color','none')
set(gca, 'box', 'off')
set(gca, 'FontSize', 15)
ylabel('Estimator Bias: Synthetic Data')
yline(0, '--')
saveas(gcf, '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/PlottingResults/SyntheticCommonMethods.fig')
saveas(gcf, '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/PlottingResults/SyntheticCommonMethods.png')


%% Error dependence on HR
Error_intact_all = squeeze(mean(mean(Err_intact_all, 2, 'omitnan'),3, 'omitnan'));
Error_impaired_all = squeeze(mean(mean(Err_impaired_all, 2, 'omitnan'),3, 'omitnan'));
Error_absent_all = squeeze(mean(mean(Err_absent_all, 2, 'omitnan'),3, 'omitnan'));

figure, plot(HR_all*60, Error_intact_all,'o'), hold on, ...
   plot(HR_all*60, Error_impaired_all,'o'), plot(HR_all*60, Error_absent_all,'o')
    ylabel('Error or Median PRx') ,   [l, icons] = legend('Inact','Impaired','Absent', 'FontSize', 15), icons = findobj(icons, 'Type','line'),
    icons = findobj(icons, 'Marker','none','-xor');
    set(icons, 'MarkerSize',12)
    xlabel('HR (bpm)')
    set(gca, 'box','off')
    set(gca, 'color','none')
    set(gca, 'FontSize',12)

 figure, plot(HR_all, Error_intact_all(:,5),'o'), hold on, ...
   plot(HR_all, Error_absent_all(:,5),'o'), plot(HR_all, Error_impaired_all(:,5),'o')
    xlabel('HR')
    ylabel('Error of Max PRx')  ,    legend('Inact','Absent', 'Impaired')

    
figure, plot(HR_all, Error_intact_all(:,1),'o'), hold on, ...
   plot(HR_all, Error_absent_all(:,1),'o'), plot(HR_all, Error_impaired_all(:,1),'o')
    xlabel('HR')
    ylabel('Error of Min PRx')
    legend('Inact','Absent', 'Impaired')
    
   
%% Plot optimal methodology
min_all = [min_intact; min_impaired; min_absent]

figure, 
plot(min_all(:,1).*60, min_all(:,2), 'o'), 
ylabel('Averaging Window'), 
xlabel('HR (bpm)')
set(gca, 'box','off')
set(gca, 'color','none')
set(gca, 'FontSize',12)

figure, 
plot(min_impaired(:,1), min_impaired(:,2), 'o'), ylabel('Averaging'), 
yyaxis right, plot(min_impaired(:,1), min_impaired(:,3), 'o'), ylabel('Correlation')
title('Optimal method for impaired PRx')


figure, 
plot(min_absent(:,1), min_absent(:,2), 'o'), ylabel('Averaging'), 
yyaxis right, plot(min_absent(:,1), min_absent(:,3), 'o'), ylabel('Correlation')
title('Optimal method for absent PRx')


else %options for PRx_*_HR where we analyzed heart rate. 

%%----Optimize #3 Is there one that consistantly underestimates?
color = [135, 49, 194;
        66, 134, 33;
        63, 12, 81;
        49, 124, 178;
        6, 18, 31;
        135, 49, 194;
        66, 134, 33;
        63, 12, 81;
        49, 124, 178;
        6, 18, 31;
        135, 49, 194;
        66, 134, 33;
        63, 12, 81;
        49, 124, 178;
        6, 18, 31]./255;


figure
violinplot([Err_intact_all(:,5,1),Err_intact_all(:,10,1),Err_intact_all(:,15, 1),Err_intact_all(:,20,1),Err_intact_all(:,30,1),...
   Err_impaired_all(:,5, 1),Err_impaired_all(:,10,1),Err_impaired_all(:,15, 1),Err_impaired_all(:,20,1),Err_impaired_all(:,30,1),...
   Err_absent_all(:,5,1),Err_absent_all(:,10,1),Err_absent_all(:,15, 1),Err_absent_all(:,20,1),Err_absent_all(:,30,1)],...
    ["","Intact","","","", "Impaired","","","","Absent","",""], 'ViolinColor',color)
ax = gca;
axc = ax.Children;
ax.XTick = [2,7,12]
ax.XTickLabel =["Intact","Impaired","Absent"]
yline(0, '--')

l = legend([axc(end), axc(end-length(axc)/15), axc(end-2*length(axc)/15), axc(end-3*length(axc)/15), axc(end-4*length(axc)/15)], '5 Heart Beats','10 Heart Beats', '15 Heart Beats','20 Heart Beats', '25 Heart Beats')
title(l, 'Correlation over 30 samples')

set(gca, 'color','none')
set(gca, 'box', 'off')
set(gca, 'FontSize', 15)
ylabel('Estimator Bias: Synthetic Data')
saveas(gcf, '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/PlottingResults/SyntheticAveragebyHR.fig')
saveas(gcf, '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/PlottingResults/SyntheticAveragebyHR.png')



%% Error dependence on HR
Error_intact_all = squeeze((mean(Err_intact_all(:,:,1), 3, 'omitnan')));
Error_impaired_all = squeeze((mean(Err_impaired_all(:,:,1), 3, 'omitnan')));
Error_absent_all = squeeze((mean(Err_absent_all(:,:,1), 3, 'omitnan')));

figure, plot(HR_all, Error_intact_all,'o'), hold on, ...
   plot(HR_all, Error_impaired_all,'o'), plot(HR_all, Error_absent_all(:,3),'o')
    xlabel('HR')
    ylabel('Error or Median PRx') ,   legend('Inact','Impaired', 'Absent')

    
 figure, plot(HR_all, Error_intact_all(:,5),'o'), hold on, ...
   plot(HR_all, Error_absent_all(:,5),'o'), plot(HR_all, Error_impaired_all(:,5),'o')
    xlabel('HR')
    ylabel('Error of Max PRx')  ,    legend('Inact','Absent', 'Impaired')

    
figure, plot(HR_all, Error_intact_all(:,1),'o'), hold on, ...
   plot(HR_all, Error_absent_all(:,1),'o'), plot(HR_all, Error_impaired_all(:,1),'o')
    xlabel('HR')
    ylabel('Error of Min PRx')
    legend('Inact','Absent', 'Impaired')
    
   
%% Plot optimal methodology
min_all = [min_intact; min_impaired; min_absent]

figure, 
plot(min_all(:,1).*60, min_all(:,2), 'o'), 
ylabel('Averaging Window'), 
xlabel('HR (bpm)')
set(gca, 'box','off')
set(gca, 'color','none')
set(gca, 'FontSize',12)

figure, 
plot(min_impaired(:,1), min_impaired(:,2), 'o'), ylabel('Averaging'), 
yyaxis right, plot(min_impaired(:,1), min_impaired(:,3), 'o'), ylabel('Correlation')
title('Optimal method for impaired PRx')

figure, 
plot(min_intact(:,1), min_intact(:,2), 'o'), ylabel('Averaging'), 
title('Optimal method for functional PRx')

figure, 
plot(min_absent(:,1), min_absent(:,2), 'o'), ylabel('Averaging'), 
yyaxis right, plot(min_absent(:,1), min_absent(:,3), 'o'), ylabel('Correlation')
title('Optimal method for absent PRx')

end
%% 
figure, 
nexttile
contourf(std(PRx_intact, [], 3, 'omitnan'), 'edgecolor','none')
h= colorbar
ylabel(h, {'Uncertainty'})
title(['Uncertainty in PRx value in inact CA: HR  ' num2str(HR)])
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
nexttile
contourf(Error_intact(:,:,3), 'edgecolor','none')
h= colorbar
ylabel(h, {['Error  PRx'];['(PRx_{est}-PRx_{real})^2']})
title(['Error for Median PRx value in intact CA: HR  ' num2str(HR)])
xlabel('Number of samples taken for correlation')
ylabel('Averaging Window (seconds)')
hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
text(min(15),mean([6,10,5]),'Common choices for PRx calculation')




%saveas(gcf, ['/data/brain/tmp_jenny/PRxError/Results/07.19.2022_syntheticdata/Q0.5Errorimpaired_' heartrateperiod(bs) '.fig'])
