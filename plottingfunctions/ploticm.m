%%% -----------------------------------------------------------------------------
% This function is used to compare clinical data set with PRx output
%Input: 
% -- out: strcture containing output from trackTBI_PRx.m
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------
% ICM+ is 10 sec av, 30 cor
function [maxcor, maxlag] = ploticm(out)
    av = 10
    cor = 30
    figure
    for i = 1:length(out.filename)
        if ~isempty(out.PRx_icmpplus_time(i).data)
        % find where times align:
        time_est = nonzeros(squeeze(out.time(i).data(av, cor, :)));
        PRx_est = nonzeros(squeeze(out.PRx(i).data(av, cor, :)));

        tend_est = max(time_est(find(~isnan(PRx_est))));
        tend_icm = max(out.PRx_icmpplus_time(i).data);

        all_est = find(time_est<tend_icm); %any data less than max icmplus
        all_icm = find(out.PRx_icmpplus_time(i).data<tend_est);

        time_est = time_est(all_est);
        PRx_est = PRx_est(all_est);
% 
%         figure, nexttile,
%         plot(time_est,PRx_est)
%         hold on, plot(out.PRx_icmpplus_time(i).data(all_icm), out.PRx_icmpplus(i).data(all_icm))
%         legend('Calculated','ICM+')
%         title('Raw Data')

        % Find the xcor for the max best lag.
        % 1. interpolate so they have the same time series. 
        icm = interp1(out.PRx_icmpplus_time(i).data(all_icm), out.PRx_icmpplus(i).data(all_icm), time_est(all_est));

%         nexttile, plot(time_est, PRx_est, time_est, icm), title('Interpolated')

        % Remove locations of nan - NOTE: this is not responsible for real time
        % series analysis but since we are just doing this to compare and we will
        % remove the same data points for both sections, we are okay.
        icm(isnan(PRx_est(all_est))) = [];
        time_est(isnan(PRx_est(all_est))) = [];
        PRx_est(isnan(PRx_est(all_est))) = [];

        time_est(isnan(icm)) = [];
        PRx_est(isnan(icm)) = [];
        icm(isnan(icm)) = [];

        %nexttile, plot(time_est, PRx_est, time_est, icm), title('Remove NaN')

        % 2. calculate the xcor and find max
        [r, lags] = xcorr(PRx_est, icm, 'coeff');
        [maxcor(i), mlag] = max(r)
        maxlag(i) = lags(mlag)
        clear mlag

        % 3. shift by max lag
        t_diff = mean(diff(time_est))
        nexttile, plot(time_est, PRx_est, 'linewidth',1), hold on, plot(time_est+t_diff.*maxlag(i), icm, '--')
        title(num2str(i))
        xlabel('Time (s)')
        ylabel('PRx')
        % Calculate correlation by matching rather than inter
        end
    end
end

%calculate how often each is positive or negative

% Quantify sensativity to each metric

% %% Plot quantiles surf
% for quant = 1:5
% 
% fig = figure,
% fig.Position = [155 380 1906 957]
% fig.Units = 'pixels'
% tiledlayout('flow', 'Padding','compact','tilespacing', 'compact')

%%

