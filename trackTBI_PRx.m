function [commonPRx, PRx, commonCPP, PRx_icm, time_final,icp, abp] = trackTBI_PRx(filename, fourhrs,opts)
%input abp file name, will automatically load abp
close all
addpath('~/Git/ABP2ICP/CA_assessment/PRxdata')
cd('/data/brain/tmp_jenny/trackclean/withcbf/')
warning('off')

if ~exist('opts')
    opts = [];
end

opts.calccppopt = 0;


load(filename)
loc=strfind(filename, 'abp')
try
PRx_icm = PRx; 
clear PRx PRxt
end

    

patnum = filename(1:16)


%% Calculate PRx for different averaging windows
fs = 1/mean(diff(icpt));

if fourhrs == 1
% Find a CPPopt middle four hours (middleish because most stable data normally)
fourWidth = round(fs*4*60*60); %number of PRx/CPPopt data points in four hrs.

if length(abpt) - fourWidth > fourWidth %if there is eight hours of data
    bsmax = 1;
else
    bsmax = 1
end
end

    abpsave = abp;
    icpsave = icp;
    bs = 1;
    
    while bs <= bsmax
        %try
       
        if length(icp)~= length(abp)
            ll = length(icpt) - length(abpt);
            if ll > 0
                st = find(icpt == abpt(1));
                if st == 1
                    st = find(icpt == abpt(end));
                    icpt(st+1:end) = [];
                    icpt(st+1:end) = [];
                else
                    icpt(1:st) = [];
                    icp(1:st) = [];
                end
            else
                st = find(abpt == icpt(1));
                if st == 1
                    st = find(abpt == icpt(end));
                    abpt(st+1:end) = [];
                    abp(st+1:end) = [];
                else
                    abpt(1:st) = [];
                    abp(1:st) = [];
                end
            end
        end
        
        
%         % Sanity check
%         if (abs(abpt(1) - icpt(1)))>1 | (abs(abpt(end) - icpt(end)))>1
%             disp('Times do not match')
%             keyboard
%             disp(num2str(abpt(1)-icpt(1)))
%             commonPRx =NaN
%             PRx=NaN
%             commonCPP=NaN
%             PRx_icm = NaN
%             time_final = NaN
%             return
%         end
        
         abp = abpsave;
        if (fourWidth)>length(abp)
            disp('Width is shorter than four hours')
            fourWidth = length(abp);
        end
        try
        abp = abp(fourWidth*bs - fourWidth +1 : fourWidth*bs);
        
        icp = icpsave;
        icp = icp(fourWidth*bs - fourWidth +1 : fourWidth*bs);
        
        abpt = abpt(fourWidth*bs - fourWidth +1 :fourWidth*bs);
        icpt = icpt(fourWidth * bs - fourWidth+1:fourWidth*bs);
        catch
            disp(['Length is shorter than four hours: ' num2str(bs)])
        end
        
        %calculate CPP
        CPP = abp - icp;

         [PRX, tt] = PRxcalc_byHR(icp, abp,fs,opts, icpt); %actual function which calculates everything

        %[PRX, opt,optfish, tt] = PRxcalc(icp, abp,fs,opts, icpt); %actual function which calculates everything
        %[PRX] = randi(10,4,4,4);%PRxcalc(icp, abp,opts); %actual function which calculates everything
    
        time_final = tt;
        
        maxPRx(:,:) = max(PRX,[],3);
        minPRx(:,:) = min(PRX,[],3);
        meanPRx(:,:) = mean(PRX,3,'omitnan');
        PRx = PRX;
        
        
        if opts.calccppopt
        cppopt(:,:,bs) = opt;
        cpoptfish(:,:,bs) = optfish;
        end
        
        if opts.figs 
        figure, 
        contourf(maxPRx(:,:,bs), 'edgecolor','none')
        h= colorbar
        ylabel(h, 'Maximum PRx')
        title('Variation in max PRx value')
        xlabel('Number of samples taken for correlation')
        ylabel('Averaging Window (seconds)')
        hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
        text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
        saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'maxprx.fig'])

        figure,
        contourf(minPRx(:,:,bs), 'edgecolor','none')
        h = colorbar;
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

        if opts.calccppopt 
        figure,
        contourf(cppopt(:,:,bs), 'edgecolor','none')
        h = colorbar
        ylabel(h, 'CPPopt [mmHg]')
        title('Variation in CPPopt')
        xlabel('Number of samples taken for correlation')
        ylabel('Averaging Window (seconds)')
        hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
        text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
        saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'cppopt.fig'])


        figure,
        contourf(cppoptfish(:,:,bs), 'edgecolor','none')
        h = colorbar
        ylabel(h, 'CPPopt [mmHg]')
        title('Variation in CPPopt')
        xlabel('Number of samples taken for correlation')
        ylabel('Averaging Window (seconds)')
        hold on, scatter([60,30,40,30],[6,10,5,15],'black', 'filled')
        text(min(15),mean([6,10,5]),'Common choices for PRx calculation')
        saveas(gcf, ['/data/brain/tmp_jenny/PRxError/trackTBI/' patnum num2str(bs) 'cppoptfish.fig'])

        end
        commonCPP(1,:,bs) = [cppopt(6,60,bs) cppoptfish(6,60,bs)];
        commonCPP(2,:,bs) = [cppopt(10,30,bs) cppoptfish(10,30,bs)];
        commonCPP(3,:,bs) = [cppopt(5,40,bs) cppoptfish(5,40,bs)];
        commonCPP(4,:,bs) = [cppopt(15,30,bs), cppoptfish(15,30,bs)];
        end
        
        commonCPP = [];
        commonPRx(1,:) = [maxPRx(6,60,bs), minPRx(6,60,bs), meanPRx(6,60,bs)];
        commonPRx(2,:) = [maxPRx(10,30,bs), minPRx(10,30,bs),meanPRx(10,30,bs)];
        commonPRx(3,:) = [maxPRx(5,40,bs), minPRx(5,40,bs),meanPRx(5,40,bs)];
        commonPRx(4,:) = [maxPRx(15,30,bs), minPRx(15,30,bs), meanPRx(15,30,bs)];

        bs = bs+1
   % catch
%             disp('PRx caculation unsucessful')
%             commonPRx = NaN;
%             commonCPP =[];
%             PRx = NaN;
%             bs = bsmax + 1;
    end
end