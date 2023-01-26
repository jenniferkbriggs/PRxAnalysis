    %% Plot time series of most common methods
function deviation_from_av = plottime(out, patnum)
addpath('home/jenniferb/Git/UniversalCode/')
%pastel colors
%     c = [64, 129, 236; 
%         28, 16, 76;
%         100, 169, 175;
%         138, 4, 88]./255

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
    
    ten_30 = squeeze(out.PRx(patdata).data(10,30,:));%
    ten_30 = ten_30(~isnan(ten_30));
    ten_30t = squeeze(out.time(patdata).data(10,30,:));
    ten_30t = ten_30t(~isnan(ten_30));
    
    ten_40 =  squeeze(out.PRx(patdata).data(10,40,:));
    ten_40 = ten_40(~isnan(ten_40));
    ten_40t =  squeeze(out.time(patdata).data(10,40,:));%
    ten_40t = ten_40t(~isnan(ten_40));
    
    fifteen_30 = squeeze(out.PRx(patdata).data(15,30,:));%
    fifteen_30 = fifteen_30(~isnan(fifteen_30));
    fifteen_30t = squeeze(out.time(patdata).data(15,30,:));
    fifteen_30t = fifteen_30t(~isnan(fifteen_30));
    
    
    five_40 = squeeze(out.PRx(patdata).data(5,40,:));%
    five_40 = five_40(~isnan(five_40));
    five_40t = squeeze(out.time(patdata).data(5,40,:));
    five_40t = five_40t(~isnan(five_40));
    
    
    six_40 = squeeze(out.PRx(patdata).data(6,40,:));%
    six_40 = six_40(~isnan(six_40));
    six_40t = squeeze(out.time(patdata).data(6,40,:));
    six_40t = six_40t(~isnan(six_40));
    
    % interpolate so all times line up. 
    five_40i = interp1(five_40t, five_40, time);
    fifteen_30i = interp1(fifteen_30t, fifteen_30, time);
    ten_40i = interp1(ten_40t, ten_40, time);
    ten_30i = interp1(ten_30t, ten_30, time);
    six_40i = interp1(six_40t, six_40, time);
    % eventually, take the average and then mind the average
    
    if 1
    time = time/60/60 % Change to hours
    nexttile,
    pl = plot(time, ten_40i,  time, ten_30i, time, five_40i, time, fifteen_30i, time, six_40i)
    for k = 1:4
        pl(k).Color = c(k,:), pl(k).LineWidth = 2
    end
    xlabel('Hours')
    ylabel('PRx')
    
    set(gca, 'Color', [0.9400 0.9400 0.9400])
    set(gca, 'Box', 'off')
    end
    
    all_av = mean([ten_40i, ten_30i, five_40i, fifteen_30i, six_40i], 2)

    % Calculate and plotaverage distance from average
    if 1
    deviation_from_av(i,:) = [mean(ten_40i - all_av, 'omitnan'), mean(ten_30i - all_av, 'omitnan'), ...
        mean(five_40i - all_av, 'omitnan'), mean(fifteen_30i - all_av, 'omitnan'), mean(six_40i - all_av, 'omitnan')]
    end
    
    if i == length(patnum)
    legend('Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp')
    end
    title(num2str(i))
    
    if 0
       %currently wrong
       %multiseedplotsave(1, deviation_from_av', '', {'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp'}, 'Average deviation from mean of all methods','', c')
    end
       
    end %finished itterating through patients
%code in Universal code path
if 1
    figure
violinplot(deviation_from_av, {'Avg: 10s, Corr: 40 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp', 'Avg 6s, Cor: 40 samp'}, 'ViolinColor',c)
set(gca, 'color','none')
set(gca, 'box', 'off')
set(gca, 'FontSize', 13)
ylabel('Emperical Estimator Bias')
end
end
