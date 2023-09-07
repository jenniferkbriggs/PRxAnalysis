   %% Plot time series of most common methods
function [total_uncertainty_time] = plottime(out, patnum)
%this function is used in figure 4e, 5e-h to compare timecourses averages
%of PRx

addpath('home/jenniferb/Git/UniversalCode/')

    c = [173, 29, 28;
        41, 77, 70;
        160, 82, 108;
        79, 4, 39;
        30, 123, 32]./255;
        
    fig = figure,
    fig.Position = [318 145 1659 1192]
    fig.Units = 'pixels'
    tiledlayout('flow', 'Padding','compact','tilespacing', 'tight')
    ct = 1
    
    %load and plot data from PRxValidation
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
    hold on
            
    % Just extracting the data and removing nans
    time = (squeeze(out.time(patdata).data(5, 40, :)));
    time = time(~isnan(time));
    cppon = 1;
    try
        CPP = (squeeze(out.CPP(patdata).data(5, 40, :)));
        cut = find(time == 0);
        time = time(1:cut(1));
    catch
        cppon = 0; %some datasets have CPP in them to plot cpp with time
    end
    if cppon 
        time = fillmissing(time, 'linear');
        CPP = CPP(1:cut(1));
        CPP = fillmissing(CPP, 'spline');
    end
    ten_30 = squeeze(out.PRx(patdata).data(10,30,:));%
    ten_30 = ten_30(~isnan(ten_30));
    ten_30t = squeeze(out.time(patdata).data(10,30,:));
    try
        ten_30t = ten_30t(~isnan(ten_30(1:length(ten_30t))));
    catch
        ten_30t = ten_30t(~isnan(ten_30));
    end
    ten_30t = ten_30t((ten_30~=0));
    ten_30 = ten_30(ten_30~=0);
    ten_30 = ten_30(~isnan(ten_30t));
    ten_30t = ten_30t(~isnan(ten_30t));

    ten_40 =  squeeze(out.PRx(patdata).data(10,40,:));
    ten_40 = ten_40(~isnan(ten_40));
    ten_40t =  squeeze(out.time(patdata).data(10,40,:));%
    try
        ten_40t = ten_40t(~isnan(ten_40(1:length(ten_40t))));
    catch
        ten_40t = ten_40t(~isnan(ten_40));
    end
    ten_40t = ten_40t((ten_40~=0));
    ten_40 = ten_40(ten_40~=0);
    ten_40 = ten_40(~isnan(ten_40t));
    ten_40t = ten_40t(~isnan(ten_40t));

    fifteen_30 = squeeze(out.PRx(patdata).data(15,30,:));%
    fifteen_30 = fifteen_30(~isnan(fifteen_30));
    fifteen_30t = squeeze(out.time(patdata).data(15,30,:));
    try
        fifteen_30t = fifteen_30t(~isnan(fifteen_30(1:length(fifteen_30t))));
    catch
        fifteen_30t = fifteen_30t(~isnan(fifteen_30));
    end
    fifteen_30t = fifteen_30t((fifteen_30~=0));
    fifteen_30 = fifteen_30(fifteen_30~=0);
    fifteen_30 = fifteen_30(~isnan(fifteen_30t));
    fifteen_30t = fifteen_30t(~isnan(fifteen_30t));

    five_40 = squeeze(out.PRx(patdata).data(5,40,:));%
    five_40 = five_40(~isnan(five_40));
    five_40t = squeeze(out.time(patdata).data(5,40,:));
    try
    five_40t = five_40t(~isnan(five_40(1:length(five_40t))));
    catch
    five_40t = five_40t(~isnan(five_40));
    end
    five_40t = five_40t((five_40(1:length(five_40t))~=0));
    five_40 = five_40(five_40~=0);
    five_40 = five_40(~isnan(five_40t));
    five_40t = five_40t(~isnan(five_40t));

    
    six_40 = squeeze(out.PRx(patdata).data(6,40,:));%
    six_40 = six_40(~isnan(six_40));
    six_40t = squeeze(out.time(patdata).data(6,40,:));
    try
    six_40t = six_40t(~isnan(six_40(1:length(six_40t))));
    catch
    six_40t = six_40t(~isnan(six_40));
    end
    six_40t = six_40t(six_40~=0);
    six_40 = six_40(six_40~=0);
    six_40 = six_40(~isnan(six_40t));
    six_40t = six_40t(~isnan(six_40t));
    
    % interpolate so all times line up. 
    five_40i = interp1(five_40t, five_40, time);
    fifteen_30i = interp1(fifteen_30t, fifteen_30, time);
    ten_40i = interp1(ten_40t, ten_40, time);
    ten_30i = interp1(ten_30t, ten_30, time);
    six_40i = interp1(six_40t, six_40, time);
    % eventually, take the average and then mind the average


    if 0 %want to plot the timecourse
    time = (time - time(1))/60/60; % Change to hours
    nexttile,
    pl = plot(time, ten_40i,  time, ten_30i, time, five_40i, time, fifteen_30i, time, six_40i)
    for k = 1:5
        pl(k).Color = c(k,:), pl(k).LineWidth = 2, pl(k).LineStyle = '-'
    end
    xlabel('Hours')
    ylabel('PRx')
    if 0 %plot bar of CPP on right axis
        cut = find(CPP == 0);
        time = time(1:cut(1));
        CPP = CPP(1:cut(1));
        ct = 1
        for i = 1:5:length(time)
        CPPmean(ct) = mean(CPP(i:i+1));
        timest(ct) = time(i);
        ct = ct+1;
        end
        CPPmean2 = interp1(timest, CPPmean, [timest(1):mean(diff(timest)):timest(end)]);
        timest2 =  [timest(1):mean(diff(timest)):timest(end)];

        yyaxis right, bar(timest2, CPPmean2)
    end
    set(gca, 'Color', [0.9400 0.9400 0.9400])
    set(gca, 'Box', 'off')
    end
    

    if i == length(patnum)
    legend('Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp')
    end
    title(num2str(i))
    
    %Calculate the empirical error over time for all hyperparameters
    %interpolate each hyperparameter pair
        time = (squeeze(out.time(patdata).data(5, 40, :)));
    time = time(~isnan(time));
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
        empiricalerror_time(patdata,1:length(time),:) = [(squeeze(PRx_all(10,40,:)) - all_av), (squeeze(PRx_all(10,30,:)) - all_av), ...
        (squeeze(PRx_all(5,40,:)) - all_av), (squeeze(PRx_all(15,30,:)) - all_av), (squeeze(PRx_all(6,40,:)) - all_av)];
    clear PRx_all
    end %finished itterating through patients

    empiricalerror_time(empiricalerror_time == 0) = NaN; %empirical error is equal to zeros if the length of the array is larger than timeseries - set to NaN
    
    %calculate uncertainty over patients
    total_uncertainty = squeeze(std(empiricalerror_time, [], 1,'omitnan'));

    %Makes figure 5 - contourplots are done in Prism
%     Uncertainty_in_common_estimators = table(squeeze(total_uncertainty(10,40,:)), ...
%         squeeze(total_uncertainty(10,30,:)), squeeze(total_uncertainty(5,40,:)), ...
%         squeeze(total_uncertainty(15,30,:)), squeeze(total_uncertainty(6,40,:)), 'VariableNames',...
%         ["Avg: 10s, Corr: 40 samp", "Avg: 10s, Corr: 30 samp", ...
%         "Avg 5s, Corr: 40 samp", "Avg 15s, Cor: 30 samp", "Avg 6s, Cor: 40 samp"])
writematrix(total_uncertainty, '/data/brain/tmp_jenny/PRxError/Results/Standard_Uncertainty_in_common_estimators.csv')
%writematrix(squeeze(mean(total_uncertainty,3,'omitnan')), '/data/brain/tmp_jenny/PRxError/Results/NewDataHR_STD_all.csv')
   % uncertainty_mean = squeeze(mean(total_uncertainty,3,'omitnan'));

%     total_bias = mean(squeeze(mean(deviation_from_av_all, 1, 'omitnan')),3, 'omitnan');
   % writematrix(total_bias, '/data/brain/tmp_jenny/PRxError/Results/HRMean_all.csv')


end
