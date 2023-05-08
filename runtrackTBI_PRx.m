%%% -----------------------------------------------------------------------------
% Run file for calculating PRx from all files
% Jennifer Briggs 2022
%% -----------------------------------------------------------------------------
addpath('/home/jenniferb/Git/ABP2ICP/CA_assessment/PRxdata/')
cd datadir %navigate to data files: 
savename = '' %Put directory you'd like to save to


files = dir('*.mat')
opts.calccppopt = 0;
opts.figs = 0;
for i = 1:length(files)
    load(files(i).name)
    out.PRx_icmpplus(i).data = PRx;
    out.PRx_icmpplus_time(i).data = PRxt;
    
    [commonPRx, PRx_sam, ~, PRx_icm, time_final, icp, abp, CPP_final] = trackTBI_PRx(files(i).name, 1,opts);
    
    out.commonPRx(i).data = commonPRx;

    PRx_sam_nz = PRx_sam; 
    PRx_sam_nz(PRx_sam == 0) = NaN;

    Q = quantile(PRx_sam_nz, [0.025, 0.25, 0.5, 0.75, 0.975],3);

    
    out.quantiles(i).data(:,:,:) = Q;
    out.PRx(i).data = PRx_sam;
    out.time(i).data = time_final;
    out.abp(i).data = abp;
    out.icp(i).data = icp;
    
    
    out.PRx_icmplus(i).data = quantile(PRx_icm, [0.025, 0.25, 0.5, 0.75, 0.975])
   
    out.filename(i).data = files(i).name;

    out.CPP(i).data =CPP_final; 
    
    save(savename, 'out', '-v7.3')
end
    
