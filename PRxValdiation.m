function [out] = PRxValidation(bsnum, savename, part)
addpath('~/Git/UniversalCode')
addpath('~/Git/ABP2ICP/CA_assessment/PRxdata')

%load ICP and ABP distributions from TrackTBI
icpdata = load('/data/brain/tmp_jenny/ICPdist.mat')

ICPpat = icpdata.patfit;

clear icpdata icp_gamma


abpdata = load('/data/brain/tmp_jenny/ABPdist.mat')

ABPpat = abpdata.patfit;
clear abpdata

HR_freq = [40:140];   %bpm
HR_freq = HR_freq/60; %bps

for bs = 1:bsnum%100 %Run 10 different CPP options

HR_opt = mod(bs,length(HR_freq));
HR = HR_freq(HR_opt+1);
% Make ABP
w = warning('off')
x = [0:.0167:14400]; %Four hours of 60 Hz data
y1 = 2*sin(x*(2*pi/6))+1; %O2 waves
y2 = sin(x*(2*pi/HR))+3; %ABP HR
y3 = 2*sin(x*(2*pi/34))+1; %Random wave
y4 = sin(x*(2*pi/(1.5*60)))+1; %Meyers Wave -- put this in ICP only!
%y5 = 3*sin(x*(2*pi/(17*60))) + 1;
y5 = 3*sin(x*(2*pi/(5.52*60))) + 1; %Random wave at 0.003 [minimum frequency acorrding to Fraser 2013]


%%If you want to view 
% ABP = rescale(ABP, minABP, maxABP)+rand(size(ABP));
% ee = 2*pi*50/.05;
% % x(1:30) = [];
% figure, subplot(2,1,1), plot(x(1:ee),ABP(1:ee))
% title('Full ABP waveform', 'FontSize', 20)
% set(gca, 'yticklabel', [])
% set(gca, 'xticklabel', [])
% subplot(2,1,2), hold on 
%     plot(x(1:ee),y2(1:ee)), plot(x(1:ee),y1(1:ee), 'LineWidth', 2)
%     plot(x(1:ee),y3(1:ee),'LineWidth', 2),plot(x(1:ee),y4(1:ee),'LineWidth', 2),plot(x(1:ee),y5(1:ee),'LineWidth', 2)
% legend( 'HR (x1)',  'O2 waves (x2) ',...
%     'Random wave around 30 sec (x3) ', 'Meyers wave at 1 1/2 min (x4)', ...
% 'Random wave > 15 min (x5)')
% set(gca, 'yticklabel', [])
% xlabel('Time (s)','FontSize', 15)
% 
% c = linspace(3600, 12000, 10);%Correlation every 5 minutes
%

aves = [1:30];

%% CPP opts
opts.calccppopt = 0;

%predefining variables
ICP= struct
Error = zeros(60,length(aves),bsnum);
opt = zeros(60,length(aves),bsnum);
CPPopt = zeros(bsnum,1);

disp(['Bootstrap itteration = ' num2str(bs) ' out of 1000'])

%--------------Create synthetic data---------------

%pick scaling based on patient data
    rng(bs+part*bsnum) % set random seed generator based on input
    rndpat = randi(length(ICPpat))
    
    
%Rescale HR!!
abp_gamma = gamrnd(ABPpat(rndpat,1),ABPpat(rndpat,2), 100,1);
minABP = quantile(abp_gamma, 0.1);
maxABP = quantile(abp_gamma, 0.9);
y2 = rescale(y2, minABP, maxABP)+rand(size(y2));

ABP = y1+y2+y3+y5; %ABP is sum of five frequencies


    %Rescale ICP to distribution according to patient data
    icp_gamma = gamrnd(ICPpat(rndpat,1),ICPpat(rndpat,2), 100,1);
    icpmin = quantile(icp_gamma, 0.1)
    maxICP = quantile(icp_gamma,0.9);

    %sanity check
    if maxICP > 60 
        disp('maxICP is too high')
        keyboard
    end


%determine how lagged ICP is from ABP between 3 and 9.99 seconds[Steinmeir 1996]
    shift = 3+rand(1)+randi([0,6]);
    shift = 6; %for now let's not randomize.

    shift_scaled = round(shift/0.0167);
    ABP_new = ABP(1:end-shift_scaled+1); x2 = x(1:end-shift_scaled+1); %in order to match times
    
    x = x(1:end-shift_scaled+1);
%create ICP based on CA 
negvec = [-1,1];

ABP_new = ABP_new+rand(size(ABP_new)).*negvec(randi(2,size(ABP_new)));

%% CA good always
ICP = 0.5*y2 + y4; %yall2 is ICP wave. Adding extra slow wave, minimize heartrate
ming(bs) = icpmin;
maxg(bs) = maxICP;
ICP = rescale(ICP, ming(bs), maxg(bs));
%shift ICP over by 6.8 \pm 3 seconds [Steinmeier 1996 Stroke]
ICP = ICP(shift_scaled:end);
ICP = ICP+rand(size(ICP)).*negvec(randi(2,size(ICP)));
fs = 1/0.0167
%[PRx_intact(:,:,:), ~, ~, time_intact] = PRxcalc(ICP,ABP_new,fs,opts, x);%aves,x);
[PRx_intact_HR(:,:,:),time_intact_HR] = PRxcalc_byHR(ICP,ABP_new,fs,opts, x);%aves,x);

%% CA always impaired
ICP = 0.5*y2 + 0.001*y3 + 0.001*y5 + y1 + y4 ; %yall2 is ICP wave. Adding extra slow wave, minimize heartrate

ICP = rescale(ICP, ming(bs), maxg(bs));
%shift ICP over by 6.8 \pm 3 seconds [Steinmeier 1996 Stroke]
ICP = ICP(shift_scaled:end);
ICP = ICP+rand(size(ICP)).*negvec(randi(2,size(ICP)));
%[PRx_impaired(:,:,:), time_impaired] = PRxcalc(ICP,ABP_new,fs,opts, x);%,aves,x);
[PRx_impaired_HR(:,:,:),time_impaired_HR] = PRxcalc_byHR(ICP,ABP_new,fs,opts, x);%aves,x);


%% CA always bad
ICP = 0.5*y2 + y1 + y3 + y4 + y5; %yall2 is ICP wave. Adding extra slow wave, minimize heartrate

ICP = rescale(ICP, ming(bs), maxg(bs));
%shift ICP over by 6.8 seconds [Steinmeier 1996 Stroke]
ICP = ICP(shift_scaled:end);
ICP = ICP+rand(size(ICP)).*negvec(randi(2,size(ICP)));
%[PRx_absent(:,:,:), ~, ~, time_absent] = PRxcalc(ICP,ABP_new,fs,opts, x);%aves,x);
[PRx_absent_HR(:,:,:),time_absent_HR] = PRxcalc_byHR(ICP,ABP_new,fs,opts, x);%aves,x);

ICPRange = [ming(bs); maxg(bs)];
ABPRange = [minABP; maxABP];
Shift = shift;

disp(['Saving' num2str(bs)])

heartrateperiod = HR_freq;
%save([savename 'bs' num2str(bs+part*bsnum) '.mat'],'PRx_impaired', 'PRx_absent','PRx_intact','ICPRange', 'Shift', 'ICP', 'ABP', 'HR', 'time_intact','time_impaired','time_absent', 'bs')
save([savename 'bs' num2str(bs+part*bsnum) 'HR.mat'],'PRx_impaired_HR', 'PRx_absent_HR','PRx_intact_HR','ICPRange', 'Shift', 'ICP', 'ABP', 'HR', 'time_intact_HR','time_impaired_HR','time_absent_HR', 'bs')

clearvars -except savename bsnum bs ABPpat ICPpat part HR_freq HR_opt
end


