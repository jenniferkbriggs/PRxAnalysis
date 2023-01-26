
function fig = plotcontinuous(out, q, patnum) %patnum is optional 

%load and plot data from PRxValidation
try
    addpath('~/Git/UniversalCode/')
catch

    addpath('~/Documents/GitHub/UniversalCode/')
end
    
    if ~exist('patnum')
        patnum = [1:length(out.commonPRx)]
    end

    for quant = q
    fig = figure,
    fig.Position = [318 145 1659 1192]
    fig.Units = 'pixels'
    tiledlayout('flow', 'Padding','compact','tilespacing', 'tight')
    ct = 1
        for i = 1:length(patnum)
            nexttile(i)
            patdata = patnum(i)
            hold on

            S = surf(out.quantiles(patdata).data(:,2:64,quant))
            caxis manual, caxis([-.75,1]), colormap(viridis())
            set(S, 'EdgeColor','none')
            
            zlim([-1, 1])
            title(num2str(patdata))

            xlabel('Av. Sec'), ylabel('Corr. Samples'), zlabel('PRx')

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
            q = quant;
            normal = [squeeze([out.quantiles(i).data(15,30,q),out.quantiles(i).data(10,30,q), ...
            out.quantiles(i).data(10,40,q), out.quantiles(i).data(4,40,q),...
            out.quantiles(i).data(6,40,q)'])];

            ax2 = gca;
            jump = range(ax2.ZLim)/50;

           hold on, scatter3(30, 15, normal(1)+jump,60, 'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
           hold on, scatter3(30, 10, normal(2)+jump,60,'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
          hold on, scatter3(40, 10, normal(3)+jump,60,'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
           hold on, scatter3(40, 5, normal(4)+jump,60, 'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')
           hold on, scatter3(40, 6, normal(5)+jump,60, 'MarkerEdgeColor','w',...
                    'MarkerFaceColor','k')

        
        ct = ct+1;
        end
        
        %totsufarea:
       % [X,Y.Z] = surfnorm(

%     nexttile(ct,[1,3])
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
    %sgtitle([tit])
    %saveas(gcf, [filename tit '.fig'])
    end
end