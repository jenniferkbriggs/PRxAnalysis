cd /data/brain/tmp_jenny/trackclean/
addpath('~/Git/ABP2ICP/CA_assessment/PRxdata')

filename = dir('*.mat')
opts.calccppopt = 0;
for i = 1:length(filename)
[PRx(i).common, PRx(i).data] = trackTBI_PRx(filename(i).name, 1, opts);
PRx(i).filename = filename(i).name
save('/data/brain/tmp_jenny/PRxError/Results/12.17.2022.mat', 'PRx')
end
