function [PRX_store, opt, optfish, time_final, CPP_final] = PRxcalc(icp, abp,fs,opts, t)
%%% -----------------------------------------------------------------------------
% This is the main function used for calculating PRx!
% Inputs: 
% -- icp: Intracranial Pressure
% -- abp: Arterial blood pressure
% -- fs: Frequency of data collection
% -- t: Time (s)
% -- opts: options structure for PRx calculation
% ------- opts.figs if you want to automatically plot PRx output and contour plots
% Outputs:
% -- PRX_store: 3D matrix with PRx over time for every hyperparameter pair
% -- opt: unimportant. (these were used when calculating CPPopt as well, not useful for this paper)
% -- optfish: unimportant. 
% -- time_final: 3D matrix corresponding to timepoint for each PRx calculation
% -- CPP_final: 3D matrix corresponding to median CPP during PRx calculation
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------
try 
    opts.figs ;
catch
    opts.figs = 0;
end



CPP = abp - icp;
aves = [1:30]; %Averaging windows (seconds) to calculate over.

%Make blank structures to store data 
PRX_store = nan(length([1:30]), 65, 36000); %not sure what to make last number
time_final = nan(length([1:30]), 65, 36000);

%(1) First we itterate over all of the averaging windows
for avy = [1:length(aves)]
    tic
    
    %Averaging is not on a sliding window so take averages every 'avy' seconds. Multiply by frequency to index into data.
    meanwidths = [1:avy*fs:length(icp)]; 
    
    %preallocate arrays
    io = nan(length(meanwidths)-1,1);
    ao = nan(length(meanwidths)-1,1);
    to = nan(length(meanwidths)-1,1);

    for i = 1:length(meanwidths)-1 %loop to average the abp every 'avy' seconds
        io(i) = mean(icp(meanwidths(i):meanwidths(i+1)));
        ao(i) = mean(abp(meanwidths(i):meanwidths(i+1)));
        CPP_m(i) = mean(CPP(meanwidths(i):meanwidths(i+1)));
        to(i) = mean(t(meanwidths(i):meanwidths(i+1)));
    end
    
    %(2) Then correlate over all sames
    for cory = [2:65] %correlation windows (in number of samples), from 2 to 65 samples
        close all
        corwidth_j = [1:cory/5:length(io)]; %correlation windows overlap 4/5 of the way
        PRx = nan(1,length(corwidth_j)-5);
        time = nan(1,length(corwidth_j)-5);
        CPP2 = nan(1,length(corwidth_j)-5);
        for j = 1:length(corwidth_j)-5
            PRx(j) = corr(ao(corwidth_j(j):corwidth_j(j+5)), io(corwidth_j(j):corwidth_j(j+5)));
            time(j) = mean(to(corwidth_j(j):corwidth_j(j+5)));
            CPP2(j) = median(ao(corwidth_j(j):corwidth_j(j+5))-io(corwidth_j(j):corwidth_j(j+5)));
        end  
        %note that the eventual PRx that is given is not indexed by time,
        %but rather by 4*cory/5
        
        PRX_store(avy, cory, 1:length(PRx)) = PRx; %store PRx
        time_final(avy, cory, 1:length(time)) = time;
        CPP_final(avy,cory, 1:length(time)) = CPP2;
        if ~isempty(find(diff(time)<0))
            disp('Problem time is wrong')
            disp(['Cor:' num2str(cory)])
            disp(['Av:' num2str(avy)])
            %keyboard
        end
        clear time
        
        %old variables that would take too long to delete everywhere

        optfish = NaN;
        opt = NaN;
        clear CPP2
        clear PRx PRx2 PRx2New
    end
    clear to ao io
end
end
