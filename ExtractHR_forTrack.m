mHR = []
sHR = []
for i = 1:21
load(files(i).name)
icpt = icpt(1:450000);
icp = icp(1:450000);
abpt = abp(1:450000);
abp = abp(1:450000);
[~, meanHR, stdHR] = findheartbeat(abp, icp, abp, abpt);
mHR = [mHR meanHR]
sHR = [sHR stdHR]
end