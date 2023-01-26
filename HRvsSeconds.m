%compare HR and Second methods
%load and plot data from PRxValidation
addpath('~/Git/UniversalCode/')

%patient data
patSec = load('/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/9.26.2022_Patient.mat')
patHR = load('/data/brain/tmp_jenny/PRxError/Results/6.06.222_patientresults/12.17.2022_HRPatient.mat')

[seccurv_first, seccommon_method, secpercchange] = calculat_curvs(patSec.out);
[HRcurv_first, HRcommon_method, HRpercchange] = calculat_curvs(patHR.out);
HRcommon_method(22,:) = [];

for i = 1:21
    stdHR(i) = std(squeeze(patHR.out.PRx(i).data(10,30,:)), 'omitnan')
    stdpat(i) = std(squeeze(patSec.out.PRx(i).data(10,30,:)), 'omitnan')
    
    difference(i) = mean(nonzeros(patHR.out.PRx(i).data(10,30,:)),'omitnan') - mean(nonzeros(patSec.out.PRx(i).data(10,30,:)), 'omitnan')
    hr(i) =  mean(nonzeros(patHR.out.PRx(i).data(10,30,:)), 'omitnan')
    sec(i) = mean(nonzeros(patSec.out.PRx(i).data(10,30,:)), 'omitnan')
end

prxdiff = [hr' sec'];

c = [53 101 162;
    98 57 159]./255;
    mm = min(nonzeros(squeeze(patHR.out.time(18).data(10,30,:))))
figure, plot(squeeze(patHR.out.time(18).data(10,30,:))-mm, squeeze(patHR.out.PRx(18).data(10,30,:)), 'linewidth', 3, 'color',c(1,:))
hold on,
plot(squeeze(patSec.out.time(18).data(10,30,:))-mm, squeeze(patSec.out.PRx(18).data(10,30,:)),'--', 'linewidth',2.5,'color',c(2,:))
ylabel([{'PRx estimation'};{'Avg: 10 sec/hearbeats, Corr: 30 Samp'}])
xlabel('Time (seconds)')
l = legend('Heartbeat','Seconds')
title(l, 'Averaging Method')
set(gca, 'FontSize',15)
set(gca, 'Box','off')
set(gca, 'color','none')



lab = {'Avg: 10s, Corr: 40 samp','', 'Avg: 10s, Corr: 30 samp','', 'Avg 5s, Corr: 40 samp','', 'Avg 15s, Cor: 30 samp', '','Avg 6s, Cor: 40 samp',''}
c = [173, 29, 28;
    173, 29, 28;
    41, 77, 70;
    41, 77, 70;
    160, 82, 108;
    160, 82, 108;
    79, 4, 39;
    79, 4, 39;
    30, 123, 32
    30, 123, 32]./255;

c(1:2:end,:) = c(1:2:end,:)./2

figure
violinplot([HRcommon_method(:,1), seccommon_method(:,1),...
    HRcommon_method(:,2), seccommon_method(:,2),...
    HRcommon_method(:,3), seccommon_method(:,3),...
    HRcommon_method(:,4), seccommon_method(:,4),...
    HRcommon_method(:,5), seccommon_method(:,5)],...
lab, 'ViolinColor',c)


figure
violinplot([HRcurv_first(1:21)', seccurv_first'],...
["HR","Sec"])%, 'ViolinColor',color)

figure
violinplot([HRpercchange(1:21)', secpercchange'],...
["HR","Sec"])%, 'ViolinColor',color)




plot2D(out, 3, [1,4])
plot2D(patHR, 3, [1,4])







load('/data/brain/tmp_jenny/PRxError/Results/1.01.2023_HR/HRvsSeconds.mat')

%%----Optimize #3 Is there one that consistantly underestimates?
c = [53 101 162;
    98 57 159;
    53 101 162;
    98 57 159;
    53 101 162;
    98 57 159]./255;

figure
violinplot([HR_intact(:,10,30),Sec_intact(1:118,10,30),...
HR_impaired(:,10,30),Sec_impaired(1:118,10,30),...
HR_absent(:,10,30),Sec_absent(1:118,10,30)],...
["","Intact","", "Impaired","","Absent"], 'ViolinColor',c)
ax = gca;
axc = ax.Children;
 ax.XTick = [1.5, 3.5, 5.5]
 ax.XTickLabel =["Intact","Impaired","Absent"]
yline(0, '--')
l = legend([axc(end), axc(end-8)], 'Heartbeat','Seconds')
title(l, 'Averaging Method')
set(gca, 'FontSize',15)
set(gca, 'Box','off')
set(gca, 'color','none')


%%