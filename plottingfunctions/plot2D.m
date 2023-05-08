%% Plot quantiles contour
function fig = plot2D(out, q,patnum)
%%% -----------------------------------------------------------------------------
% This function is used for plotting the contour plots of median PRx for multiple patients
%Input: 
% -- out: strcture containing output from trackTBI_PRx.m
% -- q: Quantile to plot (3 is median)
% -- patnum: array of patient numbers to plot
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------
try
    addpath('~/Git/UniversalCode/')
catch

    addpath('~/Documents/GitHub/UniversalCode/')
end
    

  if ~exist('patnum')
        patnum = [1:length(out.commonPRx)]
    end

for quant =  q

fig = figure,
fig.Position = [155 380 1906 957]
fig.Units = 'pixels'
%tl = tiledlayout(2,5, 'Padding','compact','tilespacing', 'compact')
tl = tiledlayout('flow', 'Padding','compact','tilespacing', 'compact')

ct = 0
    for i = patnum
        ct = ct+1
        nexttile(ct)
        hold on
        contourf(out.quantiles(i).data(:,2:64,quant),'LineColor','none')
        caxis manual
        colormap(viridis())
        caxis([-0.75,1])

        title(num2str(i))
        
        if i == patnum(1)
        ylabel('Corr. Samples (samp)')
        end
        
        xlabel('Av. Window (s)')

        
        set(gca,'FontSize',15)
        %normal calcs

       q = quant;
            normal = [squeeze([out.quantiles(i).data(15,30,q),out.quantiles(i).data(10,30,q), ...
            out.quantiles(i).data(10,40,q), out.quantiles(i).data(5,40,q),...
            out.quantiles(i).data(6,40,q)'])];

            ax2 = gca;

           hold on, scatter(30, 15, 30, 'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
           hold on, scatter(30, 10, 50,'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
          hold on, scatter(40, 10, 30,'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
           hold on, scatter(40, 5, 30, 'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')%
           hold on, scatter(40, 6,30, 'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')


       if i == patnum(end)
        h = colorbar
        title(h, 'PRx')
        ylim(h, [-1,1])
       end
    end
%legend(t, 'Standard Calculation', 'location','north', 'fontsize',15)

tit = ['ContourQuantile' num2str(quant) 'ColorHold']%'AllQuantDiffColor'
sgtitle([tit])
%saveas(gcf, [filename tit])

end
end


%% just plot with most common PRx values:

function fig = commonprx(out, patnum)
    figure
    for i = patnum
        nexttile
        PRxdata = [squeeze(out.PRx(i).data(6,60,:))';
                    squeeze(out.PRx(i).data(10,30,:))';
                    squeeze(out.PRx(i).data(5,40,:))';
                    squeeze(out.PRx(i).data(15,30,:))']; %note for patient 5, 2 follows 4 exactly
        PRxdata = PRxdata';

        maxtime = max(find(~isnan(PRxdata(:,3))));
        for k = 1:4
            final = max(find(~isnan(PRxdata(:,k))));
            T_esthold = linspace(1, maxtime, final);
            T_esthold(length(PRxdata(:,k)+1):36000) = NaN;

            T_est(:,k) = T_esthold;
        end

        if i > 1
            axold = ax;
        else
            legend('Avg: 60s, Corr: 6 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp')
        end
        plot(T_est,PRxdata)
        ax = gca;
        axc = ax.Children
        %axc(1).Color = 'k'
        %axc(1).LineStyle = '--'
        axc(3).LineWidth = 2
        title(num2str(i))

        xlabel('time')
        ylabel('PRx')

        if i >1
        linkaxes([axold, ax], 'x')
        end

        clear T_est
        end
    sgtitle('Time Series: Four Most Common Windowing Choices')
    saveas(gcf, 'Alltimeseries.fig')


    %%
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
    end