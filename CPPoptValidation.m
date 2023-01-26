function [out] = CPPoptValidation(bsnum,meanopt)


%fmincon options: 

%options = optimoptions('Display','off','iter','Algorithm','sqp');
addpath('/home/jenniferb/Git/ABP2ICP/CA_assessment/PRxdata')
w = warning('off')
x = [0:.0167:14400]; %Four hours of 60 Hz data
y1 = sin(x)+1; %O2 waves
y2 = 5*sin(6.3*x)+1; %ABP HR
y3 = sin(x/5.2)+1; %Random wave
y4 = sin(x/17)+1; %Meyers Wave
y5 = sin(x/134) + 1;

%Add another wave to ABP
y6 = 8.*1./(1+exp(-0.001*(x-5030)));%5*sin(x/590.8)+5;
yall = y1+y2+y3+y4+y5+y6;%+yd; %ABP wave

%scale ABP wave to between 50 and 160;

yall = rescale(yall, 50, 160)+rand(size(yall));
ee = 2*pi*50/.05;
% x(1:30) = [];
figure, subplot(2,1,1), plot(x(1:ee),yall(1:ee))
title('Full ABP waveform', 'FontSize', 20)
set(gca, 'yticklabel', [])
set(gca, 'xticklabel', [])
subplot(2,1,2), hold on 
    plot(x(1:ee),y2(1:ee)), plot(x(1:ee),y1(1:ee), 'LineWidth', 2)
    plot(x(1:ee),y3(1:ee),'LineWidth', 2),plot(x(1:ee),y4(1:ee),'LineWidth', 2),plot(x(1:ee),y5(1:ee),'LineWidth', 2)
legend( 'HR (x1)',  'O2 waves (x2) ',...
    'Random wave around 30 sec (x3) ', 'Meyers wave at 1 1/2 min (x4)', ...
'Random wave > 15 min (x5)')
set(gca, 'yticklabel', [])
title('Frequencies making up ABP','FontSize', 20)
xlabel('Time (s)','FontSize', 15)

c = linspace(3600, 12000, 10);%Correlation every 5 minutes

aves = [1:30] %averaging windows form 1 to 20 seconds
win = ['3' , '5', '10']


%% CPP opts
yall2= struct
Error = zeros(10,length(aves),bsnum);
opt = zeros(10,length(aves),bsnum);
CPPopt = zeros(bsnum,1);
for bs = 1:bsnum%100 %Run 10 different CPP options
    disp(['Bootstrap itteration = ' num2str(bs) ' out of ' num2str(bsnum)])

    %create ICP based on CA 
    yall2 = y1+.5*y2+y3+y4+y5; %yall2 is ICP wave. Adding extra slow wave, minimize heartrate
    yall2 = rescale(yall2, 5,30);
    %shift ICP by 6.8 seconds
    yall2 = yall2(407:end);

    yall = yall(1:end-406); x = x(1:end-406); y1 = y1(1:end-406); y2 = y2(1:end-406);
    y3 = y3(1:end-406); y4 = y4(1:end-406); y5 = y5(1:end-406);
    negvec = [-1,1];
    optval = meanopt+(30*rand)*negvec(randi(2)) %define an optimal ABP value
    %ICP = ICP+rand(size(ICP)).*negvec(randi(2,size(ICP)));

    mABP = movmean(yall,60);
    alpha = (mABP - optval).^2/max(mABP- optval).^2; %Define alpha function that is minimized at optimal CPP

    %Define ICP based on optimal value
    % ICP_opt = .5.*y2+alpha.*1.6.*y1+alpha.^1.1.*1.3.*y3+...
    %             1.2.*alpha.^1.3.*y4+alpha.^2.*y5+rand(size(y5));
    %         
    ICP_opt = .5.*y2+alpha.*1.6.*y1+alpha.^1.1.*1.3.*y3+...
                1.2.*alpha.^1.3.*y4+alpha.^2.*y5+rand(size(y5)); %When alpha is large, more


    ICP_opt = rescale(ICP_opt, 5,30);


    if length((find(abs(yall2 - optval) < .05 & abs(optval-yall2)<.05))) > 5000
        disp('Error')
    end

    CPP = yall-ICP_opt; 
    CPPopt(bs) = optval;
    opts.calccppopt = 1;
    
    [PRX, opt_temp, optfish_temp] = PRxcalc(ICP_opt, yall,opts);
    
    opt(:,:,bs) = opt_temp;
    optfish(:,:,bs) = optfish_temp;

    Error_squared(cory,avy,bs) =((opt_temp.^2-CPPopt(bs).^2)).^(1/2);
    Error_abs(cory,avy,bs) =optfish_temp-CPPopt(bs);
    Error_absfisher(cory,avy,bs) =optfish_temp-CPPopt(bs);

    %disp(['Error: ' num2str(Error_absfisher(cory,avy,bs)) 'For avy =' num2str(avy) ' bs = ' num2str(bs)])
    clear CPP2
    clear PRx PRx2 PRx2New
% 
%     for avy = [1:length(aves)]
%         tic
% 
%         %Take averages every 'avy' seconds
%         meanwidths = [1:avy*60:length(ICP_opt)]; 
%         for i = 1:length(meanwidths)-1 %loop to average the abp every 'avy' seconds
%             io(i) = mean(ICP_opt(meanwidths(i):meanwidths(i+1)));
%             ao(i) = mean(yall(meanwidths(i):meanwidths(i+1)));
%             CPP_m(i) = mean(CPP(meanwidths(i):meanwidths(i+1)));
%             t(i) = x(round(meanwidths(i)));
%         end
% 
%         % look over correlation samples
%         for cory = [2:65] %correlation windows (in number of samples), from 1 to 65 samples
%             close all
%             corwidth_j = [1:cory/5:length(io)]; %correlation windows overlap 4/5 of the way]
%             for j = 1:length(corwidth_j)-5
%                 PRx(j) = corr(ao(corwidth_j(j):corwidth_j(j+5))', io(corwidth_j(j):corwidth_j(j+5))');
%                 CPP2(j) = median(CPP_m(corwidth_j(j):corwidth_j(j+5)));
%             end  
% 
% 
%             %Fischer Transform PRx
%             PRx_new = 0.5*log((1+PRx)./(1-PRx));
%             %Bin CPP and PRx
%             CPPbinned = round(CPP2./5).*5; %round CPP into bins of 5 mmHg
%             cppunique = unique(CPPbinned);
%             cppunique(isnan(cppunique))=[];
%             PRx2_all = NaN.*ones(length(cppunique),length(PRx));
%             PRx2New_all = NaN.*ones(length(cppunique),length(PRx));
% 
%             %average PRx into CPP bins
%             for jk = 1:length(cppunique)
%                 PRxplaceholder = (PRx(find(CPPbinned == cppunique(jk))));
%                 PRx2_all(jk,1:length(PRxplaceholder)) = PRxplaceholder;
%                 PRxplaceholderNew = (PRx_new(find(CPPbinned == cppunique(jk))));
%                 PRx2New_all(jk,1:length(PRxplaceholderNew)) = (PRxplaceholderNew);
%                 %hs = scatter(jk*ones(size(PRxplaceholder)), PRxplaceholder)
%             end

            %find CPPopt  %%NEED TO FIGURE OUT HOW TO FIT THE FUNCTION WITH
            %INVERTED U
    %         cppuniquenew = [1:length(cppunique)] %just an array to fit the curve to then we will shift it over
    %         A = [sum(cppuniquenew.^4), sum(cppuniquenew.^3), sum(cppuniquenew.^2);
    %             sum(cppuniquenew.^3), sum(cppuniquenew.^2), sum(cppuniquenew);
    %             sum(cppuniquenew.^2), sum(cppuniquenew.^1), length(cppuniquenew)];
    %         b = [sum(cppuniquenew.^2.*mean(PRx2_all','omitnan')); sum(cppuniquenew.*mean(PRx2_all','omitnan')); sum(cppunique)];

    %         X = linsolve(A,b)
    %         
    %         A = [sum(cppunique.^4), sum(cppunique.^3), sum(cppunique.^2);
    %             sum(cppunique.^3), sum(cppunique.^2), sum(cppunique);
    %             sum(cppunique.^2), sum(cppunique.^1), length(cppunique)];
    %         b = [sum(cppunique.^2.*mean(PRx2_all','omitnan')); sum(cppunique.*mean(PRx2_all','omitnan')); sum(cppunique)];

%             f = @(x, F) F(1)*(x-F(2)).^2+F(3);
% 
%             p = fmincon(@(Y) sum((f(cppunique, Y)-mean(PRx2_all','omitnan')).^2), [0.3, 60, 0],[],[],[], [],[0, 20, 0],[]); %lowest abpopt is 40 
%            % [p] = polyfit(cppunique,mean(PRx2_all','omitnan'),2);
%             [pfisher] = fmincon(@(Y) sum((f(cppunique, Y)-mean(PRx2New_all','omitnan')).^2), [0.3, 60, 0],[],[],[], [],[0, 20, 0]); %lowest abpopt is 40 
% 
%     %        figure,hold on, plot(f(xopt, p))%p(1)*cppunique.^2+p(2).*cppunique+p(3))
%     %        hold on, plot(cppunique, mean(PRx2_all', 'omitnan'),'o')
%     %         
%     %         yfish = pfisher(1)*xopt.^2+pfisher(2)*xopt+pfisher(3);
%     %         y = p(1)*xopt.^2+p(2)*xopt+p(3);
%             optfish(cory,avy,bs) = pfisher(2);
%             opt(cory,avy,bs) = p(2);
% 
%     %         
%     %         opt(cory,avy,bs) = cppunique(find(PRx2 == min(PRx2)));
%     %         opt_fisher(cory,avy,bs) = cppunique(find(PRx2New == min(PRx2New)));
%     % 
%     %          x = [10:0.01:200];
%     % 
%     %         figure, plot(cppunique, PRx2,'o'),hold on, plot(x, polyval(p,x))
%     % 
%     %         figure, plot(cppunique, PRx2New, 'o'), hold on,       
%     %         plot(x,polyval(pfisher,x))
%     % %         yyaxis left, xline(opt(cory,avy,bs))
%     %         yyaxis right, xline(opt_fisher(cory,avy,bs))
% 
%             Error_squared(cory,avy,bs) =((opt(cory,avy,bs).^2-CPPopt(bs).^2)).^(1/2);
%             Error_abs(cory,avy,bs) =opt(cory,avy,bs)-CPPopt(bs);
%             Error_absfisher(cory,avy,bs) =optfish(cory,avy,bs)-CPPopt(bs);
% 
%             %disp(['Error: ' num2str(Error_absfisher(cory,avy,bs)) 'For avy =' num2str(avy) ' bs = ' num2str(bs)])
%             clear CPP2
%             clear PRx PRx2 PRx2New
        end
   % end
    % try
    % save('Workspace_morewindowst_600to900_CPP2onCPP','aves', 'CPP','bs','CPPopt','ICP_opt', 'opt', 'Error', 'kkk', '-append')
    % catch
    % save('Workspace_morewindowst_600to900_CPP2onCPP','aves', 'CPP','bs','CPPopt','ICP_opt', 'opt', 'Error', 'kkk')
    % end
    % disp('')
    % toc
    % if mod(avy, 100) == 0
    %     save(['Workspace_morewindowst_600to900_CPP2onCPP' num2str(bs) 'aves_' num2str(avy)], 'bs','CPPopt','ICP_opt', 'opt', 'Error', 'kkk','aves')
    % end
    % end
    %toc
    %save(['Updated2022_bs' num2str(bs) 'meanoptval' num2str(meanopt)], 'bs', 'CPPopt', 'ICP_opt', 'opt', 'Error_squared','aves','Error_abs')

%end

save(['Updated2022' 'meanoptval' num2str(meanopt) '.mat'])
out.Errorsquared = Error_squared;
out.Errorabs = Error_abs;
out.opt = opt;
out.ErrorFisher = Error_absfisher;
out.CPPopt = CPPopt;
end
