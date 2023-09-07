%Make Table for comparison
load('/data/brain/tmp_jenny/PRxError/Results/HRvsStandard_Patient.mat')

%compare 10 and 40 std:
for i = 1:21
    tenforty(i,:) = [std(nonzeros(squeeze(Standardestimation.PRx(i).data(10, 30, :))), 'omitnan'), ...
    std(nonzeros(squeeze(HRestimation.PRx(i).data(10, 30, :))), 'omitnan')];
end
%average percent change
for k = 1:length(Standardestimation.filename)
    q = 3
    PRx = Standardestimation.quantiles(k).data(:,2:64,q);
    percchange = []
    for i = 1:30*63
       try %super inefficient but gets percent change from +/- averaging or correlation window
       percchange = [percchange (PRx(i-1)-PRx(i))/PRx(i)];
       end
       try
       percchange = [percchange (PRx(i+1)-PRx(i))/PRx(i)];
       end
       try
       percchange = [percchange (PRx(i+30)-PRx(i))/PRx(i)];
       end
       try
       percchange = [percchange (PRx(i-30)-PRx(i))/PRx(i)];
       end
    end
    percchange_all_s(k) = mean(abs(percchange));
end

for k = 1:length(HRestimation.filename)
    q = 3
    PRx = HRestimation.quantiles(k).data(:,2:64,q);
    percchange = []
    for i = 1:30*63
       try %super inefficient but gets percent change from +/- averaging or correlation window
       percchange = [percchange (PRx(i-1)-PRx(i))/PRx(i)];
       end
       try
       percchange = [percchange (PRx(i+1)-PRx(i))/PRx(i)];
       end
       try
       percchange = [percchange (PRx(i+30)-PRx(i))/PRx(i)];
       end
       try
       percchange = [percchange (PRx(i-30)-PRx(i))/PRx(i)];
       end
    end
    percchange_all_hr(k) = mean(abs(percchange));
end

percchangecomparison = mean([percchange_all_hr(1:21); percchange_all_s]')

%calculate empirical estimator bias: 
[empiricalerror_HR, empiricalerror_S] = EmpiricalError_HR(HRestimation, Standardestimation)

%Standard 30
[~,indx] = max(abs(empiricalerror_S(:,2)))
empiricalerror_S(indx,2)
std(empiricalerror_S(:,2))
mean(empiricalerror_S(:,2))

%Standard 40
[~,indx] = max(abs(empiricalerror_S(:,1)))
empiricalerror_S(indx,1)
std(empiricalerror_S(:,1))
mean(empiricalerror_S(:,1))

%HR 30
[~,indx] = max(abs(empiricalerror_HR(:,2)))
empiricalerror_HR(indx,2)
std(empiricalerror_HR(:,2))
mean(empiricalerror_HR(:,2))

%HR 40 samp
[~,indx] = max(abs(empiricalerror_HR(:,1)))
empiricalerror_HR(indx,1)
std(empiricalerror_HR(:,1))
mean(empiricalerror_HR(:,1))


%ST of PRx over time: 
for i = 1:21
    PRx = HRestimation.PRx(i).data(10,30,:);
    PRx(PRx == 0) = NaN;
    ST_HR(i) = std(PRx,[],'omitnan')

    PRx = Standardestimation.PRx(i).data(10,30,:);
    PRx(PRx == 0) = NaN;
    ST_s(i) = std(PRx,[],'omitnan')

    Range_common_HR(i) = range([(HRestimation.quantiles(i).data(10,40,3)), (HRestimation.quantiles(i).data(10,30,3)), ...
    (HRestimation.quantiles(i).data(5,40,3)), (HRestimation.quantiles(i).data(15,30,3)),(HRestimation.quantiles(i).data(6,30,3))])
    
    Range_common_S(i) = range([(Standardestimation.quantiles(i).data(10,40,3)), (Standardestimation.quantiles(i).data(10,30,3)), ...
    (Standardestimation.quantiles(i).data(5,40,3)), (Standardestimation.quantiles(i).data(15,30,3)),(Standardestimation.quantiles(i).data(6,30,3))])
    
end

%% Synthetic Data:
HR_synthetic = [mean([std(HR_intact(:,10,40)); std(HR_impaired(:,10,40)); std(HR_absent(:,10,40))])
mean([std(HR_intact(:,10,30)); std(HR_impaired(:,10,30)); std(HR_absent(:,10,30))])
mean([std(HR_intact(:,5,40)); std(HR_impaired(:,5,40)); std(HR_absent(:,5,40))])
mean([std(HR_intact(:,15,30)); std(HR_impaired(:,15,30)); std(HR_absent(:,15,30))])
mean([std(HR_intact(:,6,40)); std(HR_impaired(:,6,40)); std(HR_absent(:,6,40))])]

Sec_synthetic = [mean([std(Sec_intact(:,10,40)); std(Sec_impaired(:,10,40)); std(Sec_absent(:,10,40))])
mean([std(Sec_intact(:,10,30)); std(Sec_impaired(:,10,30)); std(Sec_absent(:,10,30))])
mean([std(Sec_intact(:,5,40)); std(Sec_impaired(:,5,40)); std(Sec_absent(:,5,40))])
mean([std(Sec_intact(:,15,30)); std(Sec_impaired(:,15,30)); std(Sec_absent(:,15,30))])
mean([std(Sec_intact(:,6,40)); std(Sec_impaired(:,6,40)); std(Sec_absent(:,6,40))])]

%
HR_synthetic = [([std(HR_intact(:,10,40)); std(HR_impaired(:,10,40)); std(HR_absent(:,10,40))])
([std(HR_intact(:,10,30)); std(HR_impaired(:,10,30)); std(HR_absent(:,10,30))])
([std(HR_intact(:,5,40)); std(HR_impaired(:,5,40)); std(HR_absent(:,5,40))])
([std(HR_intact(:,15,30)); std(HR_impaired(:,15,30)); std(HR_absent(:,15,30))])
([std(HR_intact(:,6,40)); std(HR_impaired(:,6,40)); std(HR_absent(:,6,40))])]

Sec_synthetic = [([std(Sec_intact(:,10,40)); std(Sec_impaired(:,10,40)); std(Sec_absent(:,10,40))])
([std(Sec_intact(:,10,30)); std(Sec_impaired(:,10,30)); std(Sec_absent(:,10,30))])
([std(Sec_intact(:,5,40)); std(Sec_impaired(:,5,40)); std(Sec_absent(:,5,40))])
([std(Sec_intact(:,15,30)); std(Sec_impaired(:,15,30)); std(Sec_absent(:,15,30))])
([std(Sec_intact(:,6,40)); std(Sec_impaired(:,6,40)); std(Sec_absent(:,6,40))])]



HR_syntheticmean = [mean([mean(HR_intact(:,10,40)); mean(HR_impaired(:,10,40)); mean(HR_absent(:,10,40))])
mean([mean(HR_intact(:,10,30)); mean(HR_impaired(:,10,30)); mean(HR_absent(:,10,30))])
mean([mean(HR_intact(:,5,40)); mean(HR_impaired(:,5,40)); mean(HR_absent(:,5,40))])
mean([mean(HR_intact(:,15,30)); mean(HR_impaired(:,15,30)); mean(HR_absent(:,15,30))])
mean([mean(HR_intact(:,6,40)); mean(HR_impaired(:,6,40)); mean(HR_absent(:,6,40))])]

Sec_syntheticmean = [mean([mean(Sec_intact(:,10,40)); mean(Sec_impaired(:,10,40)); mean(Sec_absent(:,10,40))])
mean([mean(Sec_intact(:,10,30)); mean(Sec_impaired(:,10,30)); mean(Sec_absent(:,10,30))])
mean([mean(Sec_intact(:,5,40)); mean(Sec_impaired(:,5,40)); mean(Sec_absent(:,5,40))])
mean([mean(Sec_intact(:,15,30)); mean(Sec_impaired(:,15,30)); mean(Sec_absent(:,15,30))])
mean([mean(Sec_intact(:,6,40)); mean(Sec_impaired(:,6,40)); mean(Sec_absent(:,6,40))])]


