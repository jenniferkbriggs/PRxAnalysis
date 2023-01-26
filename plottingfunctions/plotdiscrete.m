
function fig = plotdiscrete(out, patnum)
%% Plot quantiles using discrete colors for PRx values and continuous shade.

% Discretize PRx into 5 bins: (https://mdigi.tools/color-shades/#461010)
% [-1.00   -0.60   -0.20    0.20    0.60    1.00]
%
% 1: -1.0 -> -0.6: Green
% 2: -0.6 -> -0.2: Light Blue
% 2: -0.2 ->  0.2: Blue
% 3:  0.2 ->  0.6: Purple
% 4:  0.6 ->  1.0: Red


% ADD ANOTHER COLOR!!

% need to add rest of color arrays:

Red = [251, 238, 238; 243, 203, 203; 235, 168, 168; 227, 134, 134; ...
    219, 99, 99; 212, 65, 65; 190, 43, 43; 156, 36, 36; 121, 28, 28; ...
    86, 20, 20]./255; %matlab's rgb is divided by 255

Blue = [234, 237, 250; 193, 200, 241; 151, 164, 232; 109, 128, 222; ...
    68, 91, 213; 42, 66, 187; 33, 51, 146; 23, 37, 104; ...
    14, 22, 62; 5, 7, 21]./255;

Purple = [250, 234, 247; 241, 193, 232; 232, 151, 217; 222, 109, 202; ...
    213, 68, 186; 187, 42, 161; 146, 33, 125; 104, 23, 89; ...
    62, 14, 54; 21, 5, 18]./255;

LightBlue = [234, 249, 250; 193, 237, 241; 151, 226, 232; 109, 214, 222;...
    68, 202, 213; 42, 177, 187; 33, 137, 146; 23, 98, 104; ...
    14, 59, 62; 5, 20, 21]./255; 

Green = [234, 250, 234; 193, 241, 193; 151, 232, 152; 109, 222, 111;...
    68, 213, 70; 42, 187, 45; 33, 146, 35; 23, 104, 25; ...
    14, 62, 15; 5, 21, 5]./255;

Cmap = [Red; Purple; Blue; LightBlue; Green];



%% Plot quantiles surf

if ~exist('patnum')
    patnum = [1:length(out.commonPRx)]
end

    for quant = 1:5
        fig = figure,
        fig.Position = [318 145 1659 1192]
        fig.Units = 'pixels'
        tiledlayout('flow', 'Padding','compact','tilespacing', 'tight')

            for i = patnum %1:length(out.commonPRx)
                nexttile(i+1)
                hold on

                surf(out.quantiles(i).data(:,2:64,quant))
                caxis manual
                caxis([-1,1])
                colormap(Cmap)

                zlim([-1, 1])
                title(num2str(i))

                xlabel('Av. Sec')
                ylabel('Corr. Samples')
                zlabel('PRx')

                set(gca, 'Color', [0.9400 0.9400 0.9400])

                %rotate axis labels
        %         set(gca,'dataaspectratio',[1 1 0.5],'projection','perspective','box','on')
        %         h = rotate3d;
        %         set(h,'ActionPreCallback',...
        %             'set(gcf,''windowbuttonmotionfcn'',@align_axislabel)')
        %         set(h,'ActionPostCallback',...
        %             'set(gcf,''windowbuttonmotionfcn'','''')')

                set(gca, 'View',[153.8611   27.3678])

                %normal calcs

                normal = [squeeze(out.quantiles(i).data(6,60,quant))';
                    squeeze(out.quantiles(i).data(10,30,quant))';
                    squeeze(out.quantiles(i).data(5,40,quant))';
                    squeeze(out.quantiles(i).data(15,30,quant))'];

                ax2 = gca;
                jump = range(ax2.ZLim)/50;

               hold on, scatter3(60, 6, normal(1)+jump,40, 'MarkerEdgeColor','w',...
                        'MarkerFaceColor','k')
               hold on, scatter3(30, 10, normal(2)+jump,40,'MarkerEdgeColor','w',...
                        'MarkerFaceColor','k')
               hold on, scatter3(40, 5, normal(3)+jump,40, 'MarkerEdgeColor','w',...
                        'MarkerFaceColor','k')
               if i == 1 %for legend
                    hold on, t = scatter3(30, 15, normal(4)+jump,40, 'MarkerEdgeColor','w',...
                        'MarkerFaceColor','k')
                    ax_old = gca;
                    ax = gca
               else
                    hold on, scatter3(30, 15, normal(4)+jump,30, 'MarkerEdgeColor','w',...
                        'MarkerFaceColor','k')
                    ax_old = ax;
                    ax = gca;
                    linkaxes([ax, ax_old],'xy')
               end


            end

        nexttile(24,[1,3])
        set(gca, 'Visible','off')
        l = legend(t, 'Standard Calculation','fontsize',20, 'Position', [0.4389 0.1764 0.1097 0.0185], 'Units', 'normalized')
        l.EdgeColor = 'none'
        h = colorbar
        h.FontSize = 12
        h.Position = [0.4489 0.0570 0.5001 0.11]
        h.TickLabels = {'-1.0 -> -0.6', '-0.6 -> -0.2', '-0.2 ->  0.2', '0.2 ->  0.6', '0.6 ->  1.0'}
        ylabel(h, 'PRx Value', 'FontSize',15)
        set(h, 'YAxisLocation','left')
        tit = ['Quantile' num2str(quant) 'ZaxisHold']%'AllQuantDiffColor'
        sgtitle([tit])
        saveas(gcf, [filename tit '.fig'])

    %     saveas(gcf, ['~/OneDrive - The University of Colorado Denver/Anschutz/Albers/PRx/' tit '.fig'])
    % 
    %     saveas(gcf, ['~/OneDrive - The University of Colorado Denver/Anschutz/Albers/PRx/' tit '.png'])

    end
end