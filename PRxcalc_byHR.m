function [PRX_store, time_final, CPP_final] = PRxcalc_byHR(icp, abp,fs,opts, t)
%%% -----------------------------------------------------------------------------
% This is the main function used for calculating PRx by heartbeat!!
% Inputs: 
% -- icp: Intracranial Pressure
% -- abp: Arterial blood pressure
% -- fs: Frequency of data collection
% -- t: Time (s)
% -- opts: options structure for PRx calculation
% ------- opts.figs if you want to automatically plot PRx output and contour plots
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------
try
    opts.calccppopt;
catch
    opts.calccppopt = 1;
end

try 
    opts.figs ;
catch
    opts.figs = 0;
end

%(1) Itterate over all averaging width - now aves is the number of heartbeats to average over
CPP = abp - icp;
aves = [1:30];
PRX_store = nan(length(aves), 65, 4000); %not sure what to make last number
time_final = nan(length(aves), 65, 4000);
peaks = findheartbeat(abp, icp, CPP, t); %calls findheartbeat function which returns all heartbeats for the patient
for avy = [1:length(aves)] 
    meanwidths = [1:avy:length(peaks)];
    meanwidths = peaks(meanwidths); %Gives the location to pull peaks from
    for i = 1:length(meanwidths)-1 %loop to average the abp every 'avy' seconds
        io(i) = mean(icp(meanwidths(i):meanwidths(i+1)));
        ao(i) = mean(abp(meanwidths(i):meanwidths(i+1)));
        to(i) = mean(t(meanwidths(i):meanwidths(i+1)));
        CPP_m(i) = mean(CPP(meanwidths(i):meanwidths(i+1)));
    end
    
    % (2) Correlation over correlation samples
    for cory = 1:65 %correlation windows (in number of samples), from 1 to 65 samples
        close all
        corwidth_j = [1:cory/5:length(io)]; %correlation windows overlap 4/5 of the way] 
        PRx = nan(1,length(corwidth_j)-5);
        time = nan(1,length(corwidth_j)-5);
        for j = 1:length(corwidth_j)-5
            PRx(j) = corr(ao(corwidth_j(j):corwidth_j(j+5))', io(corwidth_j(j):corwidth_j(j+5))');
            %time(j) = mean(to(corwidth_j(j):corwidth_j(j+5)));
            time(j) = mean(to(corwidth_j(j):corwidth_j(j+5)));
            CPP2(j) = median(CPP_m(corwidth_j(j):corwidth_j(j+5)));
        end  
        %note that the eventual PRx that is given is not indexed by time,
        %but rather by 4*cory/5
        
        PRX_store(avy, cory, 1:length(PRx)) = PRx; %store PRx
        time_final(avy, cory, 1:length(time)) = time;
        CPP_final(avy, cory, 1:length(CPP2)) = CPP2;

        if length(find(~isnan(PRx))) < 3
            keyboard
        end
        if ~isempty(find(diff(time)<0))
            disp('Problem time is wrong')
            disp(['Cor:' num2str(cory)])
            disp(['Av:' num2str(avy)])
            %keyboard
        end
        clear time
        clear PRx PRx2 PRx2New
    end
    clear to ao io
end

end