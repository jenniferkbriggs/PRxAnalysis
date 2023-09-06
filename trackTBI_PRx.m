function [commonPRx, PRx, commonCPP, PRx_icm, time_final,icp, abp,CPP_final] = trackTBI_PRx(filename, fourhrs,opts)
%% -----------------------------------------------------------------------------
% This function first preprocesses ICP and ABP from patient data, then calls PRxcalc.m to calculate PRx
% Inputs: 
% -- filename: location of the patient data file
% ----> Assumed datasets in name:
% ---->>>> icpt: Intracranial pressure time
% ---->>>> icp: Intracranial pressure 
% ---->>>> abpt: Arterial blood pressure time
% ---->>>> abp: Arterial blood pressure
% -- fourhrs: A binary string (1) if you want to calculate only 4 hours (0) if you want to calculate PRx over the entire dataset
% -- opts: options structure for PRx calculation
% ------- opts.figs if you want to automatically plot PRx output and contour plots
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------

close all
addpath('~/Git/ABP2ICP/CA_assessment/PRxdata')

%Chane the directory to the location of the patient files. 
%cd('/data/brain/tmp_jenny/trackclean/withcbf/')
warning('off') %Warnings are turned off because the indicies for PRx time points are not always integers - we just let matlab round.

if ~exist('opts')
    opts = [];
end

%% Load data from filename
load(filename)
try
    PRx_icm = PRx; %If PRx is calculated in the clinical data set, we store it here for later.
    clear PRx PRxt
catch 
    PRx_icm = [];
end

patnum = filename; %save the patient number - this is formatted specifically for my dataset


%% Calculate PRx for different averaging windows
fs = 1/mean(diff(icpt));

if fourhrs == 1
% Find four hours (middleish because most stable data normally)
fourWidth = round(fs*6*60*60); %number of PRx/CPPopt data points in four hrs.

%Cut the data into four hours - if there is more than eight hours, the data will be cut in two
if length(abpt) - fourWidth > fourWidth %if there is eight hours of data
    bsmax = 2;
else
    bsmax = 1
end
end

    abpsave = abp;
    icpsave = icp;
    bs = 1;
    
    while bs <= bsmax
        %Making sure that icp and abp are time synchronized
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
        [u, indx] = unique(abpt);
        if length(abp) ~= length(icp)
            abp = interp1(abpt(indx), abp(indx), icpt);
            abpt = icpt;
        end

        if size(abp,1)~=size(icp,1)
            abp = abp';
        end

        CPP = abp - icp;

        %% Finally we actually calculate PRx! %% 
     
     [PRX, opt,optfish, tt,CPP_final] = PRxcalc(icp, abp,fs,opts, icpt); %actual function which calculates everything
     [PRX, time_final, CPP_final] = PRxcalc_byHR(icp, abp,fs,opts, icpt);
     try   
        time_final = tt;
     end
        
        maxPRx(:,:) = max(PRX,[],3);
        minPRx(:,:) = min(PRX,[],3);
        meanPRx(:,:) = mean(PRX,3,'omitnan');
        PRx = PRX;
        
        
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
        end
        
        commonPRx = [];
        commonPRx(1,:) = [maxPRx(6,60,bs), minPRx(6,60,bs), meanPRx(6,60,bs)];
        commonPRx(2,:) = [maxPRx(10,30,bs), minPRx(10,30,bs),meanPRx(10,30,bs)];
        commonPRx(3,:) = [maxPRx(5,40,bs), minPRx(5,40,bs),meanPRx(5,40,bs)];
        commonPRx(4,:) = [maxPRx(15,30,bs), minPRx(15,30,bs), meanPRx(15,30,bs)];

        bs = bs+1

    end
    commonCPP = [];
end
