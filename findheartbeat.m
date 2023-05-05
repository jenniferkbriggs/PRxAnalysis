function [Heartbeats, meanHR, stdHR] = findheartbeat(abp, icp, CPP, Time)
%%% -----------------------------------------------------------------------------
% This function is used for extracting heart beat from abp and icp
%Input: 
% -- icp: Intracranial Pressure
% -- abp: Arterial blood pressure
% -- CPP: Cerebral Perfusion Pressure
% -- Time: Time (s)
% Output:
% - Heartbeats: Vector with index of beginning of systole
% - meanHR: single number giving average heart rate
% - stdHR: standard deviation of the heart rates
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------
    if size(abp, 1) < size(abp,2) %Make sure that the array size is correct
        abp = abp';
    end

    %We extract heart heat over a sliding window of one minute
    ap = [];
    window = [1:125*60:length(abp)]; %one minute at a time - assuming frequency is 125 Hz
    for i = 1:length(window)-1

        %Checking for nan - if there are too many then the heart rates are just the average frequency from the previous window
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
        else %This is the case for most windows. 
        [~,ap1] = findpeaks(-abp(window(i):window(i+1)+200), 'MinPeakProminence', (maxap-minap)./2); %find heartbeats!
        ap1 = ap1+window(i)-1;
        end
       ap2 = setdiff(ap1, ap); %Since we use a sliding window, remove any heart beats that occur twice 
       %Another sanity check - make sure that the average distance between heartbeats aren't too close together, if they are, remove eraneous 'heartbeat'
       XM = ap2(2:end)-ap2(1:end-1); 
       double = find(XM < 35);
       ap2(double+1) = [];
       XT = find(diff(ap2)>300); %similar idea
       if length(XT)>1
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
    Heartbeats = ap;
    HB = diff(ap)/125;
    HB = rmoutliers(HB);
    meanHR = mean(HB);
    stdHR = std(HB);
end

