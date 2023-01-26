function [out] = PRxValidation()

addpath('C:\Users\Jennifer Briggs\Documents\GitHub\UniversalCode')
w = warning('off')
x = [0:.0167:14400]; %Four hours of 60 Hz data
y1 = sin(x)+1; %O2 waves
y2 = 5*sin(6.3*x)+1; %ABP HR
y3 = sin(x/5.2)+1; %Random wave
y4 = sin(x/17)+1; %Meyers Wave
y5 = sin(x/134) + 1;
yall = y1+y2+y3+y4+y5; %ABP wave

%scale ABP wave to between 40 and 200;

yall = rescale(yall, 50, 160)+rand(size(yall));
ee = 2*pi*50/.05;
figure, subplot(2,1,1), plot(x(1:ee),yall(1:ee))
title('Full ABP waveform', 'FontSize', 20)
set(gca, 'yticklabel', [])
set(gca, 'xticklabel', [])
subplot(2,1,2), hold on 
    plot(x(1:ee),y2(1:ee)), plot(x(1:ee),y1(1:ee), 'LineWidth', 2)
    plot(x(1:ee),y3(1:ee),'LineWidth', 2),plot(x(1:ee),y4(1:ee),'LineWidth', 2),plot(x(1:ee),y5(1:ee),'LineWidth', 2)
legend( 'HR (y1)',  'O2 waves (y2) ',...
    'Random wave around 30 sec (y3) ', 'Meyers wave at 1 1/2 min (y4)', ...
'Random wave > 15 min (y5)')
set(gca, 'yticklabel', [])
title('Frequencies making up ABP','FontSize', 20)
xlabel('Time (s)','FontSize', 15)

c = linspace(3600, 12000, 10);%Correlation every 5 minutes

aves = [1:30] %averaging windows form 1 to 20 seconds
win = ['3' , '5', '10']



%% CPP opts
yall2= struct
Error = zeros(10,length(aves),10);
opt = zeros(10,length(aves),10);
CPPopt = zeros(10);
for bs = 1:2%100 %Run 10 different CPP options
disp(['Bootstrap itteration = ' num2str(bs) ' out of 1000'])

%create ICP based on CA 
yall2 = y1+.5*y2+y3+y4+y5+ 5*sin(x/600)+2; %yall2 is ICP wave. Adding extra slow wave, minimize heartrate
yall2 = rescale(yall2, 5,40);
%shift ICP over by .3 seconds
yall2 = yall2(15:end);
yall = yall(1:end-14); x = x(1:end-14); y1 = y1(1:end-14); y2 = y2(1:end-14);
y3 = y3(1:end-14); y4 = y4(1:end-14); y5 = y5(1:end-14);
negvec = [-1,1];
optval = 65+(20*rand)*negvec(randi(2)) %define an optimal ABP value

alpha = ((yall-yall2) - optval).^2/max((yall-yall2) - optval).^2; %Define alpha function that is minimized at optimal CPP
    
%Define ICP based on optimal value
ICP_opt = .5.*y2+alpha.*1.6.*y1+alpha.^1.1.*1.3.*y3+...
            1.2.*alpha.^1.3.*y4+alpha.^2.*y5+rand(size(y5));

    
if length((find(abs(yall2 - optval) < .05 & abs(optval-yall2)<.05))) > 5000
    disp('Error')
end

CPP = yall-ICP_opt; 
CPPopt(bs) = optval;


for avy = [1:length(aves)]
    tic
    
    %Take averages every 'avy' seconds
    meanwidths = [1:avy*60:length(ICP_opt)]; 
    for i = 1:length(meanwidths)-1 %loop to average the abp every 'avy' seconds
        io(i) = mean(ICP_opt(meanwidths(i):meanwidths(i+1)));
        ao(i) = mean(yall(meanwidths(i):meanwidths(i+1)));
        CPP_m(i) = mean(CPP(meanwidths(i):meanwidths(i+1)));
        t(i) = x(round(meanwidths(i)));
    end

    % look over correlation samples
    for cory = [2:65] %correlation windows (in number of samples), from 1 to 65 samples
        close all
        corwidth_j = [1:cory:length(io)];
        for j = 1:length(corwidth_j)-1
            PRx(j) = corr(ao(corwidth_j(j):corwidth_j(j+1))', io(corwidth_j(j):corwidth_j(j+1))');
            CPP2(j) = median(CPP_m(corwidth_j(j):corwidth_j(j+1)));
        end  
        
        %Bin CPP and PRx
        CPP22 = round(CPP2./5).*5; %round CPP into bins of 5 mmHg
        cppunique = unique(CPP22);
        cppunique(isnan(cppunique))=[];
        PRx2 = NaN.*ones(size(cppunique));
        %average PRx into CPP bins
        for jk = 1:length(cppunique)
            PRx2(jk) = mean(PRx(find(CPP22 == cppunique(jk))),'omitnan');
        end

        %find CPPopt
        opt(cory,avy,bs) = cppunique(find(PRx2 == min(PRx2)));
        
                
        figure, plot(cppunique, PRx2,'o')
        xline(opt(cory,avy,bs))
         
        
        Error_squared(cory,avy,bs) =((opt(cory,avy,bs).^2-CPPopt(bs).^2)).^(1/2);
        Error_abs(cory,avy,bs) =opt(cory,avy,bs)-CPPopt(bs);

        disp(['Error: ' num2str(Error_abs(cory,avy,bs)) 'For avy =' num2str(avy) ' bs = ' num2str(bs)])
        clear CPP2
        clear PRx
    end
end
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
toc
save(['Updated2022_bs' num2str(bs)], 'bs', 'CPPopt', 'ICP_opt', 'opt', 'Error_squared','aves','Error_abs')

end

save('Updated2022')
out.Errorsquared = Error_squared;
out.Errorabs = Error_abs;
out.opt = opt;
end
