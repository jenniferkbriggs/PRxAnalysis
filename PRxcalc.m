function [PRX_store, opt, optfish, time_final] = PRxcalc(icp, abp,fs,opts, t)
% options to caluclate CPPopt or plot
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



CPP = abp - icp;
aves = [1:30];
PRX_store = nan(length(aves), length([2:65]), 36000); %not sure what to make last number
time_final = nan(length(aves), length([2:65]), 36000);

for avy = [1:length(aves)]
    tic
    
    %Take averages every 'avy' seconds. Multiply by frequency
    meanwidths = [1:avy*fs:length(icp)]; 
    
    %preallocate arrays
    io = nan(length(meanwidths)-1,1);
    ao = nan(length(meanwidths)-1,1);
    to = nan(length(meanwidths)-1,1);
    
    for i = 1:length(meanwidths)-1 %loop to average the abp every 'avy' seconds
        io(i) = mean(icp(meanwidths(i):meanwidths(i+1)));
        ao(i) = mean(abp(meanwidths(i):meanwidths(i+1)));
        %CPP_m(i) = mean(CPP(meanwidths(i):meanwidths(i+1)));
        %to(i) = mean(t(meanwidths(i):meanwidths(i+1)));
        to(i) = mean(t(meanwidths(i):meanwidths(i+1)));
    end
    
    % look over correlation samples
    for cory = [2:65] %correlation windows (in number of samples), from 1 to 65 samples
        close all
        corwidth_j = [1:cory/5:length(io)]; %correlation windows overlap 4/5 of the way] 
        PRx = nan(1,length(corwidth_j)-5);
        time = nan(1,length(corwidth_j)-5);
        for j = 1:length(corwidth_j)-5
            PRx(j) = corr(ao(corwidth_j(j):corwidth_j(j+5)), io(corwidth_j(j):corwidth_j(j+5)));
            %time(j) = mean(to(corwidth_j(j):corwidth_j(j+5)));
            time(j) = mean(to(corwidth_j(j):corwidth_j(j+5)));
            % CPP2(j) = median(CPP_m(corwidth_j(j):corwidth_j(j+5)));
        end  
        %note that the eventual PRx that is given is not indexed by time,
        %but rather by 4*cory/5
        
        PRX_store(avy, cory, 1:length(PRx)) = PRx; %store PRx
        time_final(avy, cory, 1:length(time)) = time;
        
        if ~isempty(find(diff(time)<0))
            disp('Problem time is wrong')
            disp(['Cor:' num2str(cory)])
            disp(['Av:' num2str(avy)])
            %keyboard
        end
        clear time
        if opts.calccppopt == 1;
            %Fischer Transform PRx
            PRx_new = 0.5*log((1+PRx)./(1-PRx)); %Kelly et al. 
            %Bin CPP and PRx
            CPPbinned = round(CPP2./5).*5; %round CPP into bins of 5 mmHg
            cppunique = unique(CPPbinned);
            cppunique(isnan(cppunique))=[];
            PRx2_all = NaN.*ones(length(cppunique),length(PRx));
            PRx2New_all = NaN.*ones(length(cppunique),length(PRx));

            %average PRx into CPP bins
            for jk = 1:length(cppunique)
                PRxplaceholder = (PRx(find(CPPbinned == cppunique(jk))));
                PRx2_all(jk,1:length(PRxplaceholder)) = PRxplaceholder;
                PRxplaceholderNew = (PRx_new(find(CPPbinned == cppunique(jk))));
                PRx2New_all(jk,1:length(PRxplaceholderNew)) = (PRxplaceholderNew);
                %hs = scatter(jk*ones(size(PRxplaceholder)), PRxplaceholder)
            end

            %find CPPopt  %%NEED TO FIGURE OUT HOW TO FIT THE FUNCTION WITH
            %INVERTED U

            %fitting CPPopt curve using quadratic regression
            cppuniquenew = [1:length(cppunique)] %just an array to fit the curve to then we will shift it over
            A = [sum(cppunique.^4), sum(cppunique.^3), sum(cppunique.^2);
                sum(cppunique.^3), sum(cppunique.^2), sum(cppunique);
                sum(cppunique.^2), sum(cppunique.^1), length(cppunique)];
            b = [sum(cppunique.^2.*mean(PRx2_all','omitnan')); sum(cppunique.*mean(PRx2_all','omitnan')); sum(cppunique)];

            X = linsolve(A,b)
            
            
            %fisher
%             A = [sum(cppunique.^4), sum(cppunique.^3), sum(cppunique.^2);
%                 sum(cppunique.^3), sum(cppunique.^2), sum(cppunique);
%                 sum(cppunique.^2), sum(cppunique.^1), length(cppunique)];
%             b = [sum(cppunique.^2.*mean(PRx2New_all','omitnan')); sum(cppunique.*mean(PRx2New_all','omitnan')); sum(cppunique)];
            cppunique_wint = [cppunique-70];
            mPRx = mean(PRx2New_all','omitnan');
           
            A = [length(cppunique_wint), sum(cppunique_wint), sum(cppunique_wint.^2);
                sum(cppunique_wint),   sum(cppunique_wint.^2), sum(cppunique_wint.^3);
                sum(cppunique_wint.^2), sum(cppunique_wint.^3), sum(cppunique_wint.^4)];
            
            A = [length(cppunique), sum(cppunique), sum(cppunique.^2);
                sum(cppunique),   sum(cppunique.^2), sum(cppunique.^3);
                sum(cppunique.^2), sum(cppunique.^3), sum(cppunique.^4)];
            
            B = [sum(mPRx); sum(cppunique.*mPRx); sum(cppunique.*(mPRx.^2))];
            
            X = A\B;
            f = @(x, F) F(3).*x.^2 + F(2).*x + F(1);
            
            
    
    
    %         A = [sum(cppunique.^4), sum(cppunique.^3), sum(cppunique.^2);
    %             sum(cppunique.^3), sum(cppunique.^2), sum(cppunique);
    %             sum(cppunique.^2), sum(cppunique.^1), length(cppunique)];
    %         b = [sum(cppunique.^2.*mean(PRx2_all','omitnan')); sum(cppunique.*mean(PRx2_all','omitnan')); sum(cppunique)];


        %Fit CPPopt curve using fmincon (poly fit doesn't work because must be
        %constrained to a U
            f = @(x, F) F(1)*(x-F(2)).^2+F(3);
            xopt = [40:180];
            p = fmincon(@(Y) sum((f(cppunique, Y)-mean(PRx2_all','omitnan')).^2), [0.3, 60, 0],[],[],[], [],[0, 20, 0],[]); %lowest abpopt is 40 
           % [p] = polyfit(cppunique,mean(PRx2_all','omitnan'),2);
            [pfisher] = fmincon(@(Y) sum((f(cppunique, Y)-mean(PRx2New_all','omitnan')).^2), [0.3, 60, 0],[],[],[], [],[0, 20, 0]); %lowest abpopt is 40 

            if opts.figs 
           figure,nexttile, hold on, plot(f(xopt, p))%p(1)*cppunique.^2+p(2).*cppunique+p(3))
           hold on, plot(cppunique, mean(PRx2_all', 'omitnan'),'o')
           nexttile
           plot(f(xopt, pfisher)), hold on, plot(cppunique, mean(PRx2New_all', 'omitnan'), 'o')

            end
            optfish(cory,avy) = pfisher(2);
            opt(cory,avy) = p(2);
        else
            optfish = NaN;
            opt = NaN;
        end
        clear CPP2
        clear PRx PRx2 PRx2New
    end
    clear to ao io
end

end