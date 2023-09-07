function [empiricalerror] = EmpiricalError(out, patnum)
% Calculate Empirical Error - figures 3a,b, 4g,h, 5 a,b,c,d

addpath('home/jenniferb/Git/UniversalCode/')

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

if ~exist('patnum')
    patnum = [1:length(out.commonPRx)]
end



for i = 1:length(patnum)
    patdata = patnum(i)

    %set reference time to hyperparameters 5 second averaging, 40 samples
    time = (squeeze(out.time(patdata).data(5, 40, :)));
    time = time(~isnan(time));

    %interpolate each hyperparameter pair
    for ik = 1:30
        for j = 2:65
            time_hyper = squeeze(out.time(patdata).data(ik,j,:));
            prx_hyper = squeeze(out.PRx(patdata).data(ik,j,:));
            prx_hyper = prx_hyper(~isnan(time_hyper));
            time_hyper = time_hyper(~isnan(prx_hyper));
            prx_hyper = prx_hyper(~isnan(prx_hyper));
            %to interpolate, we can only interpolate times between min and
            %max reference time: 
            interp_indx = find(time_hyper > min(time) & time_hyper<max(time));
            %and they have to be unique...
            time_hyper = time_hyper(interp_indx);
            prx_hyper = prx_hyper(interp_indx);

            [time_hyper_unique, unique_indx] = unique(time_hyper);
            PRx_all(ik,j,:) = interp1(time_hyper_unique, prx_hyper(unique_indx), time);
        end
    end


    all_av = squeeze(mean(mean([PRx_all(5:20, 20:50, :)], 1),2)); %average over a small range of feasible hyperparameters

    % Calculate empirical estimator bias
    empiricalerror(patdata,:) = [mean(squeeze(PRx_all(10,40,:)) - all_av, 'omitnan'), mean(squeeze(PRx_all(10,30,:)) - all_av, 'omitnan'), ...
    mean(squeeze(PRx_all(5,40,:)) - all_av, 'omitnan'), mean(squeeze(PRx_all(15,30,:)) - all_av, 'omitnan'), mean(squeeze(PRx_all(6,40,:)) - all_av, 'omitnan')]
    clear PRx_all
end
    figure
    violinplot(empiricalerror, {'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', ...
        'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp'}, 'ViolinColor',c)
    set(gca, 'color','none')
    set(gca, 'box', 'off')
    set(gca, 'FontSize', 13)
    ylabel('Empirical Error')
end