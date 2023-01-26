function out = ConvolveTBI(filename,i)
    load(filename)

    abp(find(isnan(abp))) = 0;
    icp(find(isnan(icp))) = 0;
    
    ffta = fft(abp);
    ffti = fft(icp);

    ffta = ffta(1:length(ffta)/2+1);
    ffta(1) = [];
    freq = 1./mean(diff(abpt))*(0:(length(ffta)-1))/length(ffta);

    ffti = ffti(1:length(ffti)/2+1);
    ffti(1) = [];
    freqii = 1./mean(diff(abpt))*(0:(length(ffti)-1))/length(ffti);

%     figure, t = tiledlayout(3,2), 
%     t.TileSpacing = 'compact',t.Padding = 'compact'
    nexttile
    plot(freq,abs(ffta)) 
    xlabel('f (Hz)')
    ylabel('|Amplitude Spectrum of ABP|')
    ylim([0, 3*10^6])
    hold on, 
    plot(freqii,abs(ffti)) 
    xlabel('f (Hz)')
    ylabel('|Amplitude Spectrum of ICP|')
    legend('ABP','ICP')
%     ax = gca;
    L = min(length(ffti), length(ffta));
%     nexttile, plot(freq(1:L),abs(ffti(1:L).*ffta(1:L)))
%     ylim([0, 10^13])
%     ax2 = gca;
%   
%     xlabel('f (Hz)')
%     ylabel('|F(ABP)F(ICP)|')
%     linkaxes([ax ax2], 'x')
%     xlim([0,10])
    
    %sgtitle([filename(4:7) '-' filename(15:16)])
    %keyboard
% 
%     saveas(gcf, ['./figs/' filename(4:7) filename(15:16) 'FrequencySpectrum.png'])
%     saveas(gcf, ['./figs/'  filename(4:7) filename(15:16)  'FrequencySpectrum.fig'])

    
     nexttile(3,[1,2]), plot(freq(1:L)',abs(ffti(1:L)./ffta(1:L)))
%     out =  [freq(1:L)',abs(ffti(1:L)./ffta(1:L))];
end