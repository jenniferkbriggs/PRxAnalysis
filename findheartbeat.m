function [Heartbeats, meanHR, stdHR] = findheartbeat(abp, icp, CPP, Time)
    %make sure abp is a row vector...
    if size(abp, 1) < size(abp,2)
        abp = abp';
    end
    %try a sliding window:
    ap = [];
    window = [1:125*60:length(abp)]; %one minute at a time
    for i = 1:length(window)-1
        XX = (find(isnan(CPP(window(i)+200:window(i+1)+200))));
        Switch = 1;
        maxap = quantile(abp(window(i):window(i+1)+200), 0.90);
        minap = quantile(abp(window(i):window(i+1)+200), 0.1);
        if (length(XX)+50)>(125*60)%the entire window is nan, give peaks from previous 2 windows
            avHR = round(mean(diff(ap(end-100:end))));
            lastpeak = ap(end);
            lastrecording = window(i+1)+200; 
            ap1 = [lastpeak: avHR: lastrecording];
            ap1 = ap1';
            Switch = 0;
        elseif length(XX) > 0 & Switch == 1 & XX(1) == 1 %means that nan is in the beginning
            avHR = round(mean(diff(ap(end-100:end))));
            lastpeak = ap(end);
            lastrecording = XX(end)+200+window(i)-1; 
            ap3 = [lastpeak: avHR: lastrecording];
            Switch = 0;
            [~,ap1] = findpeaks(-abp(window(i):window(i+1)+200), 'MinPeakProminence', (maxap-minap)./2);
            ap1 = ap1+window(i)-1;
            ap1 = unique([ap1; ap3']);

        else
        [~,ap1] = findpeaks(-abp(window(i):window(i+1)+200), 'MinPeakProminence', (maxap-minap)./2);
        ap1 = ap1+window(i)-1;
%         plot([window(i):window(i+1)+200], abp(window(i):window(i+1)+200))
%         xline(ap1), keyboard, close all
        end
       ap2 = setdiff(ap1, ap);
       XM = ap2(2:end)-ap2(1:end-1);
       double = find(XM < 35);
       ap2(double+1) = [];
       XT = find(diff(ap2)>300);
       if length(XT)>1
           %keyboard
           disp('Err')
       end

        if length(XX) > 5 & Switch == 1 %nan is at the end
            %if is nan, take average HR over past time frame. 
            if length(XT)>0
                avHR = mean(diff(ap1(ap1~=ap1(XT(1))))); %units s/frequency
            else
                avHR = mean(diff(ap1));
            end
            if length(XT)>0 %nan is in middle
                after = ap(XT(1)+1)+window(i)-1;
                %after = ap2(after + 2)
                %ap2first = ap2(ap2<XT(1)+window(i)-1);
                lastpeak = ap2(XT(1));
                lastrecording = ap2(XT(1)+1);
                ap3 = [lastpeak: avHR: floor(lastrecording/avHR)*avHR-avHR];
                ap3 = setdiff(ap3, ap2);
                if ~isempty(ap3)
                    ap2 = [ap2; ap3'];
                end
                ap2 = sort(ap2);
            else %nan is at the end
                lastpeak = ap2(end);
                lastrecording = XX(end)+window(i)-1; %last value in window
                ap3 = [lastpeak: avHR: lastrecording];
                ap3 = setdiff(ap3, ap2);
                ap2 = [ap2; ap3'];
            end
        end
        ap = [ap; ap2];
    end
    
    figure, plot(diff(ap))
    %[~,ap2] = findpeaks(abp, 'MinPeakDistance', 125/3);
%     [~,ip1] = findpeaks(-icp, 'MinPeakProminence',5);
%     [~,ip2] = findpeaks(icp, 'MinPeakDistance', 125/3);
%     
% %    ap = intersect(ap1,ap2);
%    ip = intersect(ip1,ip2);
%     if (length(ap1)-length(ap2))> 5000
%         keyboard
%     end
    Heartbeats = ap;
    HB = diff(ap)/125;
    HB = rmoutliers(HB);
    meanHR = mean(HB);
    stdHR = std(HB);
end

