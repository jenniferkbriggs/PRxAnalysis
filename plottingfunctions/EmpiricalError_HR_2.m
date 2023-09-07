function [empiricalerror_HR, empiricalerror_S] = EmpiricalError_HR_2(HRestimation, Standardestimation)
        

c = [173, 29, 28;
    41, 77, 70;
    160, 82, 108;
    79, 4, 39;
    30, 123, 32]./255;
    
    %Path to violin plot code
    try
        addpath('~/Git/UniversalCode/')
    catch

        addpath('~/Documents/GitHub/UniversalCode/')
    end


%interpolate for standard method
for i = 1:21

    all_av = squeeze(mean2(HRestimation.quantiles(i).data(5:20, 20:50, 3)))
    all_avS = squeeze(mean2(Standardestimation.quantiles(i).data(5:20, 20:50, 3)))
%  all_av = squeeze(mean2(HRestimation.quantiles(i).data([10,10,5,15,6], [40,30,40,30,30], 3)))
%  all_avS = squeeze(mean2(Standardestimation.quantiles(i).data([10,10,5,15,6], [40,30,40,30,30], 3)))


    empiricalerror_HR(i,:) = [(HRestimation.quantiles(i).data(10,40,3) - all_av), (HRestimation.quantiles(i).data(10,30,3) - all_av), ...
    (HRestimation.quantiles(i).data(5,40,3) - all_av), (HRestimation.quantiles(i).data(15,30,3) - all_av),(HRestimation.quantiles(i).data(6,30,3) - all_av)]
    

    empiricalerror_S(i,:) = [(Standardestimation.quantiles(i).data(10,40,3) - all_avS), (Standardestimation.quantiles(i).data(10,30,3) - all_avS), ...
    (Standardestimation.quantiles(i).data(5,40,3) - all_avS), (Standardestimation.quantiles(i).data(15,30,3) - all_avS),(Standardestimation.quantiles(i).data(6,30,3) - all_avS)]
    
end

    figure, nexttile
    violinplot(empiricalerror_S, {'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', ...
        'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp'}, 'ViolinColor',c)
    set(gca, 'color','none')
    set(gca, 'box', 'off')
    set(gca, 'FontSize', 13)
    ylabel('Empirical Error')
    title('Standard')

    nexttile
    violinplot(empiricalerror_HR, {'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', ...
        'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp'}, 'ViolinColor',c)
    set(gca, 'color','none')
    set(gca, 'box', 'off')
    set(gca, 'FontSize', 13)
    ylabel('Empirical Error')
    title('HR')

end