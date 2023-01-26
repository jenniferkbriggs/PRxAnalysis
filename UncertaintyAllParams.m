close all

if ~exist('out') %load data if not already loaded
    if 1
        filename = '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/'
        savename = '9.26.2022_Patient.mat'
        addpath('~/Git/UniversalCode/')
    else
        filename = '/Volumes/Briggs_2TB/Albers/PRxError/'
        savename='9.01.Patient.mat'
        addpath('~/Documents/GitHub/UniversalCode/')
    end
    load([filename savename])
end

AllPRx = [];
for i = 1:length(out.PRx)
    AllPRx(i,:,:) = out.quantiles(i).data(:,:,3);
end
    
Labels = {}
for i = 1:length(hhav)
Labels{i} = (sprintf('Avg: %d s, Corr: %d samp', hhav(i), hhcor(i)));
Labels_av{i} = (sprintf('Avg: % d s', hhav(i)));
end
for i = 1:65
    labels_av{i} = sprintf('%d', i)
end

AllPRxt = array2table(AllPRx', 'VariableNames',Labels);
writetable(AllPRxt, '/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/AllPRxT.csv')

meanPRx = squeeze(mean(squeeze(mean(AllPRx,2,'omitnan')),2,'omitnan'));

for i = 1:21
Bias(i,:,:) = AllPRx(i,:,:) - meanPRx(i);
end


STD_all = squeeze((std(Bias, [], 1, 'omitnan')));

Legend_av = Labels_av(1:30:end)
figure, hold on
for i = 1:30
plot(STD_all(:,i), 'color',c(i,:), 'linewidth',2)
end
legend(Legend_av)

Labels = categorical(Labels)
figure
violinplot(AllPRx(40,:),Labels(40))
set(gca, 'color','none')
set(gca, 'box', 'off')
set(gca, 'FontSize', 13)
ylabel('Emperical Estimator Bias')
