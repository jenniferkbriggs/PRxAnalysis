 %load and plot data from PRxValidation
clear all
close all
clc

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


%% 
for i = 1:length(out.filename)
    for q = 1:5
        [X,Y,Z] = surfnorm(out.quantiles(i).data(:,2:64,q));
        area_temp =  sqrt((X-mean2(X)).^2+(Y-mean2(Y)).^2+(Z-mean2(Z)).^2)./Z;
        area(i,q) = trapz(trapz(area_temp))
        ran(i,q) = max(max(out.quantiles(i).data(:,2:64,q))) - min(min(out.quantiles(i).data(:,2:64,q)));
        %ran_common(i,q) = range([out.quantiles(i).data(5,40,q), out.quantiles(i).data(15,30,q), out.quantiles(i).data(6,60,q), out.quantiles(i).data(10,30,q)])
        ran_common(i,q) = range([out.quantiles(i).data(15,4,q),out.quantiles(i).data(10,30,q), ...
            out.quantiles(i).data(10,40,q), out.quantiles(i).data(4,40,q),...
            out.quantiles(i).data(6,40,q)'])
       ran_common_all(i,:,q) = ([out.quantiles(i).data(15,4,q),out.quantiles(i).data(10,30,q), ...
            out.quantiles(i).data(10,40,q), out.quantiles(i).data(4,40,q),...
            out.quantiles(i).data(6,40,q)]')
    end
end

%% 
for i = 1:length(out.filename)
    for q = 1:5
        %interpolate over surface. 
        [xq, yq] = meshgrid([1:1:65],[1:1:30]);
        [vq] = griddata([1:65],[1:30],squeeze(out.quantiles(i).data(:,:,q)),xq, yq);
        
        %Approximate derivatives. We can do this because we interpolated.
        fx = diff(vq,1,1);
        fy = diff(vq,1,2);
        
        fxx = diff(fx, 1, 1);
        fyy = diff(fy, 1, 2);
        fxy = diff(fx, 1, 2);
        
        %approximate different sizes by dropping first and last values:
        fx = fx(1:end-1, 2:end-1);
        fy = fy(2:end-1, 1:end-1);
        fxx = fxx(:, 2:end-1);
        fyy = fyy(2:end-1, :);
        fxy = fxy(1:end-1, 1:end-1);
        
        %loop over every point in the grid:
        for k = 1:size(fxx,1)
            for j = 1:size(fxx,2)
                hess = [fxx(k,j), fxy(k,j); fxy(k,j), fyy(k,j)]; 
                dethess(k,j) = det(hess);
                normcurv(k,j) = (1+fx(k,j)^2+fy(k,j)^2);
                jac(k,j) = norm([fx(k,j), fy(k,j)]);
                perc_change(k,j) = norm([100*abs(vq(k+1,j)-vq(k,j))/2, 100*abs(vq(k,j+1)-vq(k,j))/2]);
            end
        end
        
        curv_first(i,q) = mean(mean(abs(jac),'omitnan'), 'omitnan');
        curvature(i,q) =  mean(mean(abs(dethess./normcurv),'omitnan'),'omitnan');
        perc_change_all(i,q) = mean(mean(perc_change, 'omitnan'), 'omitnan');
        common_method(i,q) = perc_change(10, 30);
        
    end
end

[ranked_curv, curvature_sort] = sort(curvature(:,3));
[ranked_curv_first, curv_sort_first] = sort(curv_first(:,3));
[ranked_perc, curv_sort_perc] = sort(perc_change_all(:,3));

%normalize curvature between -1:1:
curvature_norm = (curvature(:,3)-min(curvature(:,3)))/(range(curvature(:,3)))

close all


%% find max and min of each quantile
% onenew = [-1, 1]
% twonew = [-1, 1]
% threenew = [-1, 1]
% fournew = [-1, 1]
% fivenew = [-1, 1]
% 
% for i = 1:length(out.commonPRx)
%     one = [max(nonzeros(out.quantiles(i).data(:,:,1))), min(nonzeros(out.quantiles(i).data(:,:,1)))]
%     two = [max(nonzeros(out.quantiles(i).data(:,:,2))), min(nonzeros(out.quantiles(i).data(:,:,2)))]
%     three = [max(nonzeros(out.quantiles(i).data(:,:,3))), min(nonzeros(out.quantiles(i).data(:,:,3)))]
%     four = [max(nonzeros(out.quantiles(i).data(:,:,4))), min(nonzeros(out.quantiles(i).data(:,:,4)))]
%     five = [max(nonzeros(out.quantiles(i).data(:,:,5))), min(nonzeros(out.quantiles(i).data(:,:,5)))]
% 
% 
%     onenew = [max(onenew(1), one(1)), min(onenew(2), one(2))]
%     twonew = [max(twonew(1), two(1)), min(twonew(2), two(2))]
%     threenew = [max(threenew(1), three(1)), min(threenew(2), three(2))]
%     fournew = [max(fournew(1), four(1)), min(fournew(2), four(2))]
%     fivenew = [max(fivenew(1), five(1)), min(fivenew(2), five(2))]
% end
% 
% allnew = [onenew; twonew; threenew; fournew; fivenew]
% 
%  plotcontinuous(out, patnum)
%  
%  %% Plot time series
% % ICM+ is 10 sec av, 30 cor
% function maxcor = ploticm(out)
%     av = 10
%     cor = 30
% 
%     for i = 1:length(out.filename)
%         if ~isempty(out.PRx_icmpplus_time(i).data)
%         % find where times align:
%         time_est = nonzeros(squeeze(out.time(i).data(av, cor, :)));
%         PRx_est = nonzeros(squeeze(out.PRx(i).data(av, cor, :)));
% 
%         tend_est = max(time_est(find(~isnan(PRx_est))));
%         tend_icm = max(out.PRx_icmpplus_time(i).data);
% 
%         all_est = find(time_est<tend_icm); %any data less than max icmplus
%         all_icm = find(out.PRx_icmpplus_time(i).data<tend_est);
% 
%         time_est = time_est(all_est);
%         PRx_est = PRx_est(all_est);
% 
%         figure, nexttile,
%         plot(time_est,PRx_est)
%         hold on, plot(out.PRx_icmpplus_time(i).data(all_icm), out.PRx_icmpplus(i).data(all_icm))
%         legend('Calculated','ICM+')
%         title('Raw Data')
% 
%         % Find the xcor for the max best lag.
%         % 1. interpolate so they have the same time series. 
%         icm = interp1(out.PRx_icmpplus_time(i).data(all_icm), out.PRx_icmpplus(i).data(all_icm), time_est(all_est));
% 
%         nexttile, plot(time_est, PRx_est, time_est, icm), title('Interpolated')
% 
%         % Remove locations of nan - NOTE: this is not responsible for real time
%         % series analysis but since we are just doing this to compare and we will
%         % remove the same data points for both sections, we are okay.
%         icm(isnan(PRx_est(all_est))) = [];
%         time_est(isnan(PRx_est(all_est))) = [];
%         PRx_est(isnan(PRx_est(all_est))) = [];
% 
%         time_est(isnan(icm)) = [];
%         PRx_est(isnan(icm)) = [];
%         icm(isnan(icm)) = [];
% 
%         nexttile, plot(time_est, PRx_est, time_est, icm), title('Remove NaN')
% 
%         % 2. calculate the xcor and find max
%         [r, lags] = xcorr(PRx_est, icm, 'coeff');
%         [maxcor(i), mlag] = max(r)
%         maxlag(i) = lags(mlag)
%         clear mlag
% 
%         % 3. shift by max lag
%         t_diff = mean(diff(time_est))
%         nexttile, plot(time_est, PRx_est, time_est+t_diff.*maxlag(i), icm)
%         title('Lagged')
% 
%         % Calculate correlation by matching rather than inter
%         end
%     end
% end
%     %% Plot time series of most common methods
% function f = plottime(out)
%     av = 10
%     cor = 30
%     figure, plot(squeeze(out.time(i).data(av, cor, :)), squeeze(out.PRx(i).data(av,cor,:)))
% 
%     hold on, 
%     av = 6, cor = 60
%     plot(squeeze(out.time(i).data(6, 60, :)), squeeze(out.PRx(i).data(6,60,:)))
%     av = 15, cor = 30
%     plot(squeeze(out.time(i).data(15, 30, :)), squeeze(out.PRx(i).data(15,30,:)))
%     av = 5, cor = 40
%     plot(squeeze(out.time(i).data(5, 40, :)), squeeze(out.PRx(i).data(5,40,:)))
%     legend('Avg: 60s, Corr: 6 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp')
% end
% 
% 
% %calculate how often each is positive or negative
% 
% % Quantify sensativity to each metric
% 
% function fig = discrete(out, patnum)
% %% Plot quantiles using discrete colors for PRx values and continuous shade.
% 
% % Discretize PRx into 5 bins: (https://mdigi.tools/color-shades/#461010)
% % [-1.00   -0.60   -0.20    0.20    0.60    1.00]
% %
% % 1: -1.0 -> -0.6: Green
% % 2: -0.6 -> -0.2: Light Blue
% % 2: -0.2 ->  0.2: Blue
% % 3:  0.2 ->  0.6: Purple
% % 4:  0.6 ->  1.0: Red
% 
% 
% % ADD ANOTHER COLOR!!
% 
% % need to add rest of color arrays:
% 
% Red = [251, 238, 238; 243, 203, 203; 235, 168, 168; 227, 134, 134; ...
%     219, 99, 99; 212, 65, 65; 190, 43, 43; 156, 36, 36; 121, 28, 28; ...
%     86, 20, 20]./255; %matlab's rgb is divided by 255
% 
% Blue = [234, 237, 250; 193, 200, 241; 151, 164, 232; 109, 128, 222; ...
%     68, 91, 213; 42, 66, 187; 33, 51, 146; 23, 37, 104; ...
%     14, 22, 62; 5, 7, 21]./255;
% 
% Purple = [250, 234, 247; 241, 193, 232; 232, 151, 217; 222, 109, 202; ...
%     213, 68, 186; 187, 42, 161; 146, 33, 125; 104, 23, 89; ...
%     62, 14, 54; 21, 5, 18]./255;
% 
% LightBlue = [234, 249, 250; 193, 237, 241; 151, 226, 232; 109, 214, 222;...
%     68, 202, 213; 42, 177, 187; 33, 137, 146; 23, 98, 104; ...
%     14, 59, 62; 5, 20, 21]./255; 
% 
% Green = [234, 250, 234; 193, 241, 193; 151, 232, 152; 109, 222, 111;...
%     68, 213, 70; 42, 187, 45; 33, 146, 35; 23, 104, 25; ...
%     14, 62, 15; 5, 21, 5]./255;
% 
% Cmap = [Red; Purple; Blue; LightBlue; Green];
% 
% 
% 
% %% Plot quantiles surf
% 
% if ~exist('patnum')
%     patnum = [1:length(out.commonPRx)]
% end
% 
%     for quant = 1:5
%         fig = figure,
%         fig.Position = [318 145 1659 1192]
%         fig.Units = 'pixels'
%         tiledlayout('flow', 'Padding','compact','tilespacing', 'tight')
% 
%             for i = patnum %1:length(out.commonPRx)
%                 nexttile(i+1)
%                 hold on
% 
%                 surf(out.quantiles(i).data(:,2:64,quant))
%                 caxis manual
%                 caxis([-1,1])
%                 colormap(Cmap)
% 
%                 zlim([-1, 1])
%                 title(num2str(i))
% 
%                 xlabel('Av. Sec')
%                 ylabel('Corr. Samples')
%                 zlabel('PRx')
% 
%                 set(gca, 'Color', [0.9400 0.9400 0.9400])
% 
%                 %rotate axis labels
%         %         set(gca,'dataaspectratio',[1 1 0.5],'projection','perspective','box','on')
%         %         h = rotate3d;
%         %         set(h,'ActionPreCallback',...
%         %             'set(gcf,''windowbuttonmotionfcn'',@align_axislabel)')
%         %         set(h,'ActionPostCallback',...
%         %             'set(gcf,''windowbuttonmotionfcn'','''')')
% 
%                 set(gca, 'View',[153.8611   27.3678])
% 
%                 %normal calcs
% 
%                 normal = [squeeze(out.quantiles(i).data(6,60,quant))';
%                     squeeze(out.quantiles(i).data(10,30,quant))';
%                     squeeze(out.quantiles(i).data(5,40,quant))';
%                     squeeze(out.quantiles(i).data(15,30,quant))'];
% 
%                 ax2 = gca;
%                 jump = range(ax2.ZLim)/50;
% 
%                hold on, scatter3(60, 6, normal(1)+jump,40, 'MarkerEdgeColor','w',...
%                         'MarkerFaceColor','k')
%                hold on, scatter3(30, 10, normal(2)+jump,40,'MarkerEdgeColor','w',...
%                         'MarkerFaceColor','k')
%                hold on, scatter3(40, 5, normal(3)+jump,40, 'MarkerEdgeColor','w',...
%                         'MarkerFaceColor','k')
%                if i == 1 %for legend
%                     hold on, t = scatter3(30, 15, normal(4)+jump,40, 'MarkerEdgeColor','w',...
%                         'MarkerFaceColor','k')
%                     ax_old = gca;
%                     ax = gca
%                else
%                     hold on, scatter3(30, 15, normal(4)+jump,30, 'MarkerEdgeColor','w',...
%                         'MarkerFaceColor','k')
%                     ax_old = ax;
%                     ax = gca;
%                     linkaxes([ax, ax_old],'xy')
%                end
% 
% 
%             end
% 
%         nexttile(24,[1,3])
%         set(gca, 'Visible','off')
%         l = legend(t, 'Standard Calculation','fontsize',20, 'Position', [0.4389 0.1764 0.1097 0.0185], 'Units', 'normalized')
%         l.EdgeColor = 'none'
%         h = colorbar
%         h.FontSize = 12
%         h.Position = [0.4489 0.0570 0.5001 0.11]
%         h.TickLabels = {'-1.0 -> -0.6', '-0.6 -> -0.2', '-0.2 ->  0.2', '0.2 ->  0.6', '0.6 ->  1.0'}
%         ylabel(h, 'PRx Value', 'FontSize',15)
%         set(h, 'YAxisLocation','left')
%         tit = ['Quantile' num2str(quant) 'ZaxisHold']%'AllQuantDiffColor'
%         sgtitle([tit])
%         saveas(gcf, [filename tit '.fig'])
% 
%     %     saveas(gcf, ['~/OneDrive - The University of Colorado Denver/Anschutz/Albers/PRx/' tit '.fig'])
%     % 
%     %     saveas(gcf, ['~/OneDrive - The University of Colorado Denver/Anschutz/Albers/PRx/' tit '.png'])
% 
%     end
% end
% % %% Plot quantiles surf
% % for quant = 1:5
% % 
% % fig = figure,
% % fig.Position = [155 380 1906 957]
% % fig.Units = 'pixels'
% % tiledlayout('flow', 'Padding','compact','tilespacing', 'compact')
% 
% %%
% function fig = plotcontinuous(out, patnum) %patnum is optional
%     
%     if ~exist('patnum')
%         patnum = [1:length(out.commonPRx)]
%     end
% 
%     for quant = 1:5
%     fig = figure,
%     fig.Position = [318 145 1659 1192]
%     fig.Units ='pixels'
%     tiledlayout('flow', 'Padding','compact','tilespacing', 'tight')
% 
%         for i = patnum %1:length(out.commonPRx)
%             nexttile(i+1)
%             hold on
% 
%             surf(out.quantiles(i).data(:,2:64,quant))
%             caxis manual, caxis([-1,1]), colormap(inferno())
%             
%             zlim([-1, 1])
%             title(num2str(i))
% 
%             xlabel('Av. Sec'), ylabel('Corr. Samples'), zlabel('PRx')
% 
%             set(gca, 'Color', [0.9400 0.9400 0.9400])
% 
%             %rotate axis labels
%     %         set(gca,'dataaspectratio',[1 1 0.5],'projection','perspective','box','on')
%     %         h = rotate3d;
%     %         set(h,'ActionPreCallback',...
%     %             'set(gcf,''windowbuttonmotionfcn'',@align_axislabel)')
%     %         set(h,'ActionPostCallback',...
%     %             'set(gcf,''windowbuttonmotionfcn'','''')')
% 
%             set(gca, 'View',[153.8611   27.3678])
% 
%             %normal calcs
% 
%             normal = [squeeze(out.quantiles(i).data(6,60,quant))';
%                 squeeze(out.quantiles(i).data(10,30,quant))';
%                 squeeze(out.quantiles(i).data(5,40,quant))';
%                 squeeze(out.quantiles(i).data(15,30,quant))'];
% 
%             ax2 = gca;
%             jump = range(ax2.ZLim)/50;
% 
%            hold on, scatter3(60, 6, normal(1)+jump,40, 'MarkerEdgeColor','w',...
%                     'MarkerFaceColor','k')
%            hold on, scatter3(30, 10, normal(2)+jump,40,'MarkerEdgeColor','w',...
%                     'MarkerFaceColor','k')
%            hold on, scatter3(40, 5, normal(3)+jump,40, 'MarkerEdgeColor','w',...
%                     'MarkerFaceColor','k')
%            if i == 1 %for legend
%                 hold on, t = scatter3(30, 15, normal(4)+jump,40, 'MarkerEdgeColor','w',...
%                     'MarkerFaceColor','k')
%                 ax_old = gca;
%                 ax = gca
%            else
%                 hold on, scatter3(30, 15, normal(4)+jump,30, 'MarkerEdgeColor','w',...
%                     'MarkerFaceColor','k')
%                 ax_old = ax;
%                 ax = gca;
%                 linkaxes([ax, ax_old],'xy')
%            end
% 
% 
%         end
% 
%     nexttile(24,[1,3])
%     set(gca, 'Visible','off')
%     l = legend(t, 'Standard Calculation','fontsize',20, 'Position', [0.4389 0.1764 0.1097 0.0185], 'Units', 'normalized')
%     l.EdgeColor = 'none'
%     h = colorbar
%     h.FontSize = 12
%     h.Position = [0.4489 0.0570 0.5001 0.11]
%     h.TickLabels = {'-1.0 -> -0.6', '-0.6 -> -0.2', '-0.2 ->  0.2', '0.2 ->  0.6', '0.6 ->  1.0'}
%     ylabel(h, 'PRx Value', 'FontSize',15)
%     set(h, 'YAxisLocation','left')
%     tit = ['Quantile' num2str(quant) 'ContinuousColor']%'AllQuantDiffColor'
%     sgtitle([tit])
%     saveas(gcf, [filename tit '.fig'])
%     end
% end
% 
% %% Plot quantiles contour
% function fig = twoD(out, patnum)
%   if ~exist('patnum')
%         patnum = [1:length(out.commonPRx)]
%     end
% 
% for quant = 1:5
% 
% fig = figure,
% fig.Position = [155 380 1906 957]
% fig.Units = 'pixels'
% tiledlayout('flow', 'Padding','compact','tilespacing', 'compact')
% 
%     for i = patnum
%         nexttile(i)
%         hold on
%         contourf(out.quantiles(i).data(:,2:64,quant),'LineWidth',0.05)
%         caxis manual
%         colormap(inferno())
%         caxis([allnew(quant,2), allnew(quant,1)])
% 
%         title(num2str(i))
%         xlabel('Av. Window (s)')
%         ylabel('Corr. Samples (samp)')
% 
%         %normal calcs
% 
%         normal = [squeeze(out.quantiles(i).data(6,60,quant))';
%             squeeze(out.quantiles(i).data(10,30,quant))';
%             squeeze(out.quantiles(i).data(5,40,quant))';
%             squeeze(out.quantiles(i).data(15,30,quant))'];
% 
%        hold on, scatter(60, 6,30, 'k','filled')
%        hold on, scatter(30, 10,30,'k', ...
%           'filled')
%        hold on, scatter(40, 5,30, 'k','filled')
%        if i == 1 %for legend
%             hold on, t = scatter(30, 15,30, 'k','filled')
%        else
%             hold on, scatter(30, 15,30, 'k','filled')
%        end
% 
% 
%     end
% legend(t, 'Standard Calculation', 'location','north', 'fontsize',15)
% h = colorbar
% ylabel(h, 'PRx')
% tit = ['ContourQuantile' num2str(quant) 'ColorHold']%'AllQuantDiffColor'
% sgtitle([tit])
% saveas(gcf, [filename tit])
% 
% end
% end
% 
% 
% %% just plot with most common PRx values:
% 
% function fig = commonprx(out, patnum)
%     figure
%     for i = patnum
%         nexttile
%         PRxdata = [squeeze(out.PRx(i).data(6,60,:))';
%                     squeeze(out.PRx(i).data(10,30,:))';
%                     squeeze(out.PRx(i).data(5,40,:))';
%                     squeeze(out.PRx(i).data(15,30,:))']; %note for patient 5, 2 follows 4 exactly
%         PRxdata = PRxdata';
% 
%         maxtime = max(find(~isnan(PRxdata(:,3))));
%         for k = 1:4
%             final = max(find(~isnan(PRxdata(:,k))));
%             T_esthold = linspace(1, maxtime, final);
%             T_esthold(length(PRxdata(:,k)+1):36000) = NaN;
% 
%             T_est(:,k) = T_esthold;
%         end
% 
%         if i > 1
%             axold = ax;
%         else
%             legend('Avg: 60s, Corr: 6 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp')
%         end
%         plot(T_est,PRxdata)
%         ax = gca;
%         axc = ax.Children
%         %axc(1).Color = 'k'
%         %axc(1).LineStyle = '--'
%         axc(3).LineWidth = 2
%         title(num2str(i))
% 
%         xlabel('time')
%         ylabel('PRx')
% 
%         if i >1
%         linkaxes([axold, ax], 'x')
%         end
% 
%         clear T_est
%         end
%     sgtitle('Time Series: Four Most Common Windowing Choices')
%     saveas(gcf, 'Alltimeseries.fig')
% 
% 
%     %%
%     ylabel(h, 'Maximum PRx')
%     title('Variation in max PRx value')
%     xlabel('Number of samples taken for correlation')
%     ylabel('Averaging Window (seconds)')
%     hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
%     text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
%     saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'maxprx.fig'])
% 
%     figure,
%     contourf(minPRx(:,:,bs), 'edgecolor','none')
%     h = colorbar
%     ylabel(h,'minimum PRx')
%     title('Variation in min PRx value')
%     xlabel('Number of samples taken for correlation')
%     ylabel('Averaging Window (seconds)')
%     hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
%     text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
% 
%     saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'minprx.fig'])
% 
%     figure,
%     contourf(meanPRx(:,:,bs), 'edgecolor','none')
%     h = colorbar
%     ylabel(h, 'PRx')
%     title('Average in PRx')
%     xlabel('Number of samples taken for correlation')
%     ylabel('Averaging Window (seconds)')
%     hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
%     text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
% 
%     saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'meanprx.fig'])
%     end