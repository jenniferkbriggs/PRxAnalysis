i = 1

%% 
figure, 

for i = 1:22
    nexttile
    plot(squeeze(HRestimation.time(i).data(10,30,:)), squeeze(HRestimation.PRx(i).data(10,30,:)))
hold on
plot(squeeze(Standardestimation.time(i).data(10,30,:)), squeeze(Standardestimation.PRx(i).data(10,30,:)))
legend('HR','Standard')
end