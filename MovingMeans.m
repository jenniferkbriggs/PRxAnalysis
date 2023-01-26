clear all
close all
clc
addpath('C:\Users\Jennifer Briggs\Documents\GitHub\UniversalCode_Briggs')
x = [0:.05:5000];
y1 = sin(x)+1; %O2 waves
y2 = sin(6.3*x)+1; %ABP HR
y3 = sin(x/5.2)+1; %Random wave
y4 = sin(x/17)+1; %Meyers Wave
y5 = sin(x/134) + 1;
yall = y1+y2+y3+y4+y5;
ee = 2*pi*50/.05
figure, subplot(2,1,1), plot(x(1:ee),yall(1:ee))
title('Full ABP waveform', 'FontSize', 20)
set(gca, 'yticklabel', [])
set(gca, 'xticklabel', [])
subplot(2,1,2), hold on 
    plot(x(1:ee),y2(1:ee)), plot(x(1:ee),y1(1:ee), 'LineWidth', 2)
    plot(x(1:ee),y3(1:ee),'LineWidth', 2),plot(x(1:ee),y4(1:ee),'LineWidth', 2),,plot(x(1:ee),y5(1:ee),'LineWidth', 2)
legend( 'HR (y1)',  'O2 waves (y2) ',...
    'Random wave around 30 sec (y3) ', 'Meyers wave at 1 1/2 min (y4)', ...
'Random wave > 15 min (y5)')
set(gca, 'yticklabel', [])
title('Frequencies making up ABP','FontSize', 20)
xlabel('Time (s)','FontSize', 15)
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Freq.fig')
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Frequencies.png')

x1 = movmean(yall, 2*pi/6.3/5.2/.05);
x2 = movmean(yall, 2*pi/3.7/.05);
x3 = movmean(yall, 2*pi*2.8/.05);
x4 = movmean(yall, pi*2*11/.05);
x5 = movmean(yall, pi*2*64/.05);
x6 = movmean(yall, pi*2*169/.05);


c = [3600 6000 12000]%Correlation every 5 minutes
win = ['3' , '5', '10']

if 0
figure, 
subplot(2,3,1), plot(x(1:ee),yall(1:ee), 'LineWidth',.5),hold on,  ...
    plot(x(1:ee),x1(1:ee), 'LineWidth',2), title('k << x1 (satisfies Niquist)','FontSize', 15),xlabel('Time (s)')

 subplot(2,3,2), plot(x(1:ee),yall(1:ee), 'LineWidth',.5), xlabel('Time (s)')
...
     hold on, plot(x(1:ee),x2(1:ee), 'LineWidth',2), title('x1 < k < x2','FontSize', 15)
  subplot(2,3,3),plot(x(1:ee),yall(1:ee), 'LineWidth',.5), ...
      hold on, plot(x(1:ee),x3(1:ee), 'LineWidth',2), title('x2<k<x3','FontSize', 15),xlabel('Time (s)')

   subplot(2,3,4),plot(x(1:ee),yall(1:ee), 'LineWidth',.5), hold on, ...
       plot(x(1:ee),x4(1:ee), 'LineWidth',2), title('x3<k<x4','FontSize', 15),xlabel('Time (s)')

      subplot(2,3,5),plot(x(1:ee),yall(1:ee), 'LineWidth',.5), ...
          hold on, plot(x(1:ee),x5(1:ee), 'LineWidth',2), title('x4<k<x5','FontSize', 15),xlabel('Time (s)')

      subplot(2,3,6),plot(x(1:ee),yall(1:ee), 'LineWidth',.5), ...
          hold on, plot(x(1:ee),x6(1:ee), 'LineWidth',2), title('k>x5','FontSize', 15),xlabel('Time (s)')

   suptitle('Moving means with k at various periods')
% legend('All', 'Mean at Freq 1','Mean at Freq 2','Mean at Freq 3', 'Moving mean random period')
% legend('ABP', 'Moving mean at slowest frequency', 'Moving mean longer than slowest Frequency')

for i = 1:length(yall)-15
ICP_CA(i) = y2(i+15)+rand;
end


i1 = movmean(ICP_CA, 2*pi/6.3/5.2/.05);
i2 = movmean(ICP_CA, 2*pi/3.7/.05);
i3 = movmean(ICP_CA, 2*pi*2.8/.05);
i4 = movmean(ICP_CA, pi*2*11/.05);
i5 = movmean(ICP_CA, pi*2*64/.05);
i6 = movmean(ICP_CA, pi*2*169/.05);

for kkk = 1:3
    corwidth = c(kkk) %Correlation every 5 minutes

for j = (corwidth/2+1):length(ICP_CA) - corwidth/2
    PRx1(j) = corr(x1(j-corwidth/2:j+corwidth/2)', i1(j-corwidth/2:j+corwidth/2)');
    PRx2(j) = corr(x2(j-corwidth/2:j+corwidth/2)', i2(j-corwidth/2:j+corwidth/2)');
    PRx3(j) = corr(x3(j-corwidth/2:j+corwidth/2)', i3(j-corwidth/2:j+corwidth/2)');
    PRx4(j) = corr(x4(j-corwidth/2:j+corwidth/2)', i4(j-corwidth/2:j+corwidth/2)');
    PRx5(j) = corr(x5(j-corwidth/2:j+corwidth/2)', i5(j-corwidth/2:j+corwidth/2)');
    PRx6(j) = corr(x6(j-corwidth/2:j+corwidth/2)', i6(j-corwidth/2:j+corwidth/2)');

end
    MEAN(kkk,1) = mean(PRx1);
    MEAN(kkk,2) = mean(PRx2);
    MEAN(kkk,3) = mean(PRx3);
    MEAN(kkk,4) = mean(PRx4);
    MEAN(kkk,5) = mean(PRx5);
    MEAN(kkk,6) = mean(PRx6);

    clear PRx1 PRx2 PRx3 PRx4 PRx5
figure,plot(x(1:ee),ICP_CA(1:ee)), hold on, plot(x(1:ee), yall(1:ee))
title('ICP with intact CA','FontSize', 20)
xlabel('Time (s)','FontSize', 20)
set(gca, 'yticklabel', [])
legend('ICP', 'ABP', 'FontSize', 15)
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\IntactCAwaveform.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\IntactCAwaveform.png')


figure, 
subplot(3,2,1)
plot(i1,x1(1:length(ICP_CA)),'o')
ll = corr(i1',x1(1:length(ICP_CA))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEAN(1))])
title('PRx k << x1 (satisfies Niquist Frequency)')
subplot(3,2,2)
plot(i2,x2(1:length(ICP_CA)),'o')
ll = corr(i2',x2(1:length(ICP_CA))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEAN(2))])
title('PRx x1<k<x2')
subplot(3,2,3)
plot(i3,x3(1:length(ICP_CA)),'o')
ll = corr(i3',x3(1:length(ICP_CA))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEAN(3))])
title('PRx x2<k<x3')
subplot(3,2,4)
plot(i4,x4(1:length(ICP_CA)),'o')
ll = corr(i4',x4(1:length(ICP_CA))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEAN(4))])
title('PRx moving mean x3<k<x4 ')
subplot(3,2,5)
plot(i5,x4(1:length(ICP_CA)),'o')
ll = corr(i5',x5(1:length(ICP_CA))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEAN(5))])
title('PRx moving mean x4<k<x5 ')
subplot(3,2,6)
plot(i6,x4(1:length(ICP_CA)),'o')
ll = corr(i6',x6(1:length(ICP_CA))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEAN(6))])
title('PRx moving mean k>>x5 ')
suptitle('PRx perfect CA (PRx should be 0): corr window = 3min')



%%

for i = 1:length(yall)-15
ICP_half(i) = .8*y1(i+15)+y2(i+15)+.5*y3(i+15)+.2*y4(i+15)+rand;
end


figure,plot(x(1:ee),ICP_half(1:ee)), hold on, plot(x(1:ee), yall(1:ee))
title('ICP with impaired CA','FontSize', 20)
xlabel('Time (s)','FontSize', 20)
set(gca, 'yticklabel', [])
legend('ICP', 'ABP', 'FontSize', 15)
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\ImpairedCAwaveform.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\ImpairedCAwaveform.png')

ih1 = movmean(ICP_half, 2*pi/6.3/5.2/.05);
ih2 = movmean(ICP_half, 2*pi/3.7/.05);
ih3 = movmean(ICP_half, 2*pi*2.8/.05);
ih4 = movmean(ICP_half, pi*2*11/.05);
ih5 = movmean(ICP_half, pi*2*64/.05);
ih6 = movmean(ICP_half, pi*2*169/.05);


for j = (corwidth/2+1):length(ICP_half) - corwidth/2
    PRxnh1(j) = corr(x1(j-corwidth/2:j+corwidth/2)', ih1(j-corwidth/2:j+corwidth/2)');
    PRxnh2(j) = corr(x2(j-corwidth/2:j+corwidth/2)', ih2(j-corwidth/2:j+corwidth/2)');
    PRxnh3(j) = corr(x3(j-corwidth/2:j+corwidth/2)', ih3(j-corwidth/2:j+corwidth/2)');
    PRxnh4(j) = corr(x4(j-corwidth/2:j+corwidth/2)', ih4(j-corwidth/2:j+corwidth/2)');
    PRxnh5(j) = corr(x5(j-corwidth/2:j+corwidth/2)', ih5(j-corwidth/2:j+corwidth/2)');
    PRxnh6(j) = corr(x6(j-corwidth/2:j+corwidth/2)', ih6(j-corwidth/2:j+corwidth/2)');

end
    MEANhn(kkk,1) = mean(PRxnh1);
    MEANhn(kkk,2) = mean(PRxnh2);
    MEANhn(kkk,3) = mean(PRxnh3);
    MEANhn(kkk,4) = mean(PRxnh4);
    MEANhn(kkk,5) = mean(PRxnh5);
    MEANhn(kkk,6) = mean(PRxnh6);

    clear PRx1 PRx2 PRx3 PRx4 PRx5

figure, 
subplot(3,2,1)
plot(ih1,x1(1:length(ICP_half)),'o')
ll = corr(ih1',x1(1:length(ICP_half))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANhn(kkk,1))])
title('PRx k << x1 (satisfies Niquist Frequency)')
subplot(3,2,2)
plot(ih2,x2(1:length(ICP_half)),'o')
ll = corr(ih2',x2(1:length(ICP_half))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANhn(kkk,2))])
title('PRx x1<k<x2')
subplot(3,2,3)
plot(ih3,x3(1:length(ICP_half)),'o')
ll = corr(ih3',x3(1:length(ICP_half))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANhn(kkk,3))])
title('PRx x2<k<x3')
subplot(3,2,4)
plot(ih4,x4(1:length(ICP_half)),'o')
ll = corr(ih4',x4(1:length(ICP_half))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANhn(kkk,4))])
title('PRx moving mean x3<k<x4 ')
subplot(3,2,5)
plot(ih5,x5(1:length(ICP_half)),'o')
ll = corr(ih5',x5(1:length(ICP_half))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANhn(kkk,5))])
title('PRx moving mean x4<k<x5 ')
subplot(3,2,6)
plot(ih6,x6(1:length(ICP_half)),'o')
ll = corr(ih6',x6(1:length(ICP_half))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANhn(kkk,6))])
title('PRx moving mean k>>x5 ')
suptitle(['PRx from slightly functional CA: corr window = 10 min'])
end


%%
for kkk = 1:3
        corwidth = c(kkk) %Correlation every 5 minutes

for i = 1:length(yall)-15
ICP_no(i) = yall(i+15)+rand;
end
% figure,plot(x(1:ee),ICP_no(1:ee)), hold on, plot(x(1:ee), yall(1:ee))
% title('ICP with absent CA','FontSize', 20)
% xlabel('Time (s)','FontSize', 20)
% set(gca, 'yticklabel', [])
% legend('ICP', 'ABP', 'FontSize', 15)
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\NOCAwaveform.fig')
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\NOCAwaveform.png')

in1 = movmean(ICP_no, 2*pi/6.3/5.2/.05);
in2 = movmean(ICP_no, 2*pi/3.7/.05);
in3 = movmean(ICP_no, 2*pi*2.8/.05);
in4 = movmean(ICP_no, pi*2*11/.05);
in5 = movmean(ICP_no, pi*2*64/.05);
in6 = movmean(ICP_no, pi*2*169/.05);


for j = (corwidth/2+1):length(ICP_no) - corwidth/2
    PRxn1(j) = corr(x1(j-corwidth/2:j+corwidth/2)', in1(j-corwidth/2:j+corwidth/2)');
    PRxn2(j) = corr(x2(j-corwidth/2:j+corwidth/2)', in2(j-corwidth/2:j+corwidth/2)');
    PRxn3(j) = corr(x3(j-corwidth/2:j+corwidth/2)', in3(j-corwidth/2:j+corwidth/2)');
    PRxn4(j) = corr(x4(j-corwidth/2:j+corwidth/2)', in4(j-corwidth/2:j+corwidth/2)');
    PRxn5(j) = corr(x5(j-corwidth/2:j+corwidth/2)', in5(j-corwidth/2:j+corwidth/2)');
    PRxn6(j) = corr(x6(j-corwidth/2:j+corwidth/2)', in6(j-corwidth/2:j+corwidth/2)');
end
    MEANn(kkk, 1,bs) = mean(PRxn1);
    MEANn(kkk, 2, bs) = mean(PRxn2);
    MEANn(kkk,3, bs) = mean(PRxn3);
    MEANn(kkk,4, bs) = mean(PRxn4);
    MEANn(kkk,5, bs) = mean(PRxn5);
    MEANn(kkk,6, bs) = mean(PRxn6);
    
    clear PRx1 PRx2 PRx3 PRx4 PRx5 PRx6 icpno
end


% figure, 
subplot(3,2,1)
plot(in1,x1(1:length(ICP_no)),'o')
ll = corr(in1',x1(1:length(ICP_no))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANn(1))])
title('PRx k << x1 (satisfies Niquist Frequency)')
subplot(3,2,2)
plot(in2,x2(1:length(ICP_no)),'o')
ll = corr(in2',x2(1:length(ICP_no))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANn(2))])
title('PRx x1<k<x2')
subplot(3,2,3)
plot(in3,x3(1:length(ICP_no)),'o')
ll = corr(in3',x3(1:length(ICP_no))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANn(3))])
title('PRx x2<k<x3')
subplot(3,2,4)
plot(in4,x4(1:length(ICP_no)),'o')
ll = corr(in4',x4(1:length(ICP_no))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANn(4))])
title('PRx moving mean x3<k<x4 ')
subplot(3,2,5)
plot(in5,x5(1:length(ICP_no)),'o')
ll = corr(in5',x5(1:length(ICP_no))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANn(5))])
title('PRx moving mean x4<k<x5 ')
subplot(3,2,6)
plot(in6,x6(1:length(ICP_no)),'o')
ll = corr(in6',x6(1:length(ICP_no))');
xlabel('ICP'), ylabel('ABP'), legend(['r=' num2str(MEANn(6))])
title('PRx moving mean k>>x5 ')
suptitle('PRx from impaired CA: corr window = 10min')

figure
bar3(MEANn)
set(gca, 'yticklabels', {'3 min', '6 min', '10 min'})
xlabel('Correlation Windows')
set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
ylabel('Averaging Windows')
zlabel('PRx')
title('Absent CA')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\NoCA.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\NoCA.png')


figure
bar3(MEAN)
set(gca, 'yticklabels', {'3 min', '6 min', '10 min'})
xlabel('Correlation Windows')
set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
ylabel('Averaging Windows')
zlabel('PRx')
title('Intact CA')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\FullCA.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\FullCA.png')

figure
bar3(MEANhn)
set(gca, 'yticklabels', {'3 min', '5 min', '10 min'})
ylabel('Correlation Windows')
set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
xlabel('Averaging Windows')
zlabel('PRx')
title('Impaired CA')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\ImpairedCA.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\ImpairedCA.png')


truecor = polyfit(ICP_CA',yall(1:end-15)',1)
truecorhn = polyfit(ICP_half',yall(1:end-15)',1)
truecorn = polyfit(ICP_no',yall(1:end-15)',1)

for i = 1:3
    for j = 1:6
        RSS1(i,j) = (MEAN(i,j) - truecor(1))^2;
        RSS1hn(i,j) = (MEANhn(i,j) - truecorhn(1))^2;
        RSS1n(i,j) = (MEANn(i,j) - truecorn(1))^2;
    end
end

MSE = sqrt(sum(sum(RSS1)))
MSEhn = sqrt(sum(sum(RSS1hn)))
MSEn = sqrt(sum(sum(RSS1n)))
    
figure, 
subplot(3,1,1)
plot(sqrt(RSS1)', 'o-')
ylabel('|Error|', 'FontSize', 15)
ylim([0, 0.6])
set(gca, 'xticklabels', {'k1', [], 'k2' ,[]', 'k3', [], 'k4', [], 'k5', [], 'k6'})

legend('3 min Correlation Window', '5 min Correlation Window', ...
    '10 min Correlation Window', 'Location', 'NW', 'FontSize', 12)
title('Intact CA', 'FontSize', 15)
subplot(3,1,2)
plot(sqrt(RSS1hn)', 'o-')
ylim([0, 0.6])

ylabel('|Error|', 'FontSize', 15)
title('Impaired CA', 'FontSize', 15)
set(gca, 'xticklabels', {'k1', [], 'k2' ,[]', 'k3', [], 'k4', [], 'k5', [], 'k6'})
subplot(3,1,3)
plot(sqrt(RSS1n)', 'o-')
ylim([0, 0.6])
set(gca, 'xticklabels', {'k1', [], 'k2' ,[]', 'k3', [], 'k4', [], 'k5', [], 'k6'})

ylabel('|Error|', 'FontSize', 15)
 xlabel('Averaging Windows', 'FontSize', 15)
 title('Absent CA', 'FontSize', 15)
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Error.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Error.png')


figure
bar3(sqrt(RSS1))
set(gca, 'yticklabels', {'3 min', '5 min', '10 min'})
ylabel('Correlation Windows')
set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
xlabel('Averaging Windows')
zlabel('|Error|')
title('Intact CA')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Error.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Error.png')

figure
bar3(sqrt(RSS1hn))
set(gca, 'yticklabels', {'3 min', '5 min', '10 min'})
ylabel('Correlation Windows')
set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
xlabel('Averaging Windows')
zlabel('|Error|')
title('Impaired CA')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\simpairedCAError.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\simpairedCAError.png')

figure
bar3(sqrt(RSS1n))
set(gca, 'yticklabels', {'3 min', '5 min', '10 min'})
ylabel('Correlation Windows')
set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
xlabel('Averaging Windows')
zlabel('|Error|')
title('Absenct CA')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\impairedCAError.fig')
saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\impairedCAError.png')
end

%% CPP opts
if 1
    Cory = {'3 min', '6 min', '10 min'}
for bs = 1:1000
    tic
    disp(['Bootstrap itteration = ' num2str(bs) ' out of 1000'])
yall2 = yall + 5*sin(x/678)+2;
% optval(bs) = randi([2 8],1,1)+rand
optval(bs) = 5+rand
alpha = (yall2 - optval(bs)).^2/max(yall2 - optval(bs)).^2;
for i = 1:length(yall)-15
ICP_opt(i) = .5*y2(i+15)+alpha(i)*1.6*y1(i+15)+alpha(i).^1.1*1.3*y3(i+15)+...
    1.2*alpha(i).^1.3*y4(i+15)+alpha(i).^2*y5(i+15)+rand;
end
CPP = yall2(1:end-15)-ICP_opt;
if length((find(abs(yall2 - optval(bs)) < .05 & abs(optval(bs)-yall2)<.05))) > 5000
    disp('Error')
end
CPPopt(bs) = mean(CPP(find(abs(yall2(1:length(CPP)) - optval(bs)) < .05 & abs(optval(bs)-yall2(1:length(CPP))<.05))))
% 
% figure, subplot(2,1,1), plot(x(1:end-15),yall2(1:end-15)), 
% subplot(2,1,1), title('ABP vs ICP with CA funcionality optimized at ABP = 5','FontSize', 20)
% ylabel('ABP', 'FontSize', 20)
% subplot(2,1,1), yyaxis right, plot(x(1:end-15), alpha(1:end-15))
% ylabel('\alpha', 'FontSize', 20)
% legend('ABP', '\alpha', 'FontSize', 15)
% subplot(2,1,2), plot(x(1:end-15), ICP_opt)
% ylabel('ICP', 'FontSize', 20)
% 
% yyaxis right, plot(x(1:end-15), CPP)
% ylabel('CPP', 'FontSize', 20)
% yline(3, 'Label', 'CPP_{opt}', 'FontSize', 15)
% xlabel('Time (s)','FontSize', 20)
% legend('ICP', 'CPP', 'FontSize', 15)

% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Icpopt.fig')
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Icpopt.png')

io1 = movmean(ICP_opt, 2*pi/6.3/5.2/.05);
io2 = movmean(ICP_opt, 2*pi/3.7/.05);
io3 = movmean(ICP_opt, 2*pi*2.8/.05);
io4 = movmean(ICP_opt, pi*2*11/.05);
io5 = movmean(ICP_opt, pi*2*64/.05);
io6 = movmean(ICP_opt, pi*2*169/.05);

xo1 = movmean(yall2, 2*pi/6.3/5.2/.05);
xo2 = movmean(yall2, 2*pi/3.7/.05);
xo3 = movmean(yall2, 2*pi*2.8/.05);
xo4 = movmean(yall2, pi*2*11/.05);
xo5 = movmean(yall2, pi*2*64/.05);
xo6 = movmean(yall2, pi*2*169/.05);
%% 
for kkk = 1:3
    corwidth = c(kkk) %Correlation every 5 minutes
for j = (corwidth/2+1):length(ICP_opt) - corwidth/2
    Cor(kkk).PRxo1(j) = corr(xo1(j-corwidth/2:j+corwidth/2)', io1(j-corwidth/2:j+corwidth/2)');
    Cor(kkk).PRxo2(j) = corr(xo2(j-corwidth/2:j+corwidth/2)', io2(j-corwidth/2:j+corwidth/2)');
    Cor(kkk).PRxo3(j) = corr(xo3(j-corwidth/2:j+corwidth/2)', io3(j-corwidth/2:j+corwidth/2)');
    Cor(kkk).PRxo4(j) = corr(xo4(j-corwidth/2:j+corwidth/2)', io4(j-corwidth/2:j+corwidth/2)');
    Cor(kkk).PRxo5(j) = corr(xo5(j-corwidth/2:j+corwidth/2)', io5(j-corwidth/2:j+corwidth/2)');
    Cor(kkk).PRxo6(j) = corr(xo6(j-corwidth/2:j+corwidth/2)', io6(j-corwidth/2:j+corwidth/2)');
    
    Cor(kkk).CPP(j) = CPP(j);
    Cor(kkk).CPP1(j) = xo1(j);
    Cor(kkk).CPP2(j) = xo2(j);
    Cor(kkk).CPP3(j) = xo3(j);
    Cor(kkk).CPP4(j) = xo4(j);
    Cor(kkk).CPP5(j) = xo5(j);
    Cor(kkk).CPP6(j) = xo6(j);
end  
d = find(Cor(kkk).CPP ~= 0);


CPP2 = Cor(kkk).CPP(d);
% figure, subplot(2,3,1)
% plot(CPP2,Cor(kkk).PRxo1(d),'o')
% ylabel('PRx', 'FontSize', 13)
[~, indx] = min(Cor(kkk).PRxo1(d));
% xline(CPP2(indx))
opt(kkk,1,bs) = CPP2(indx);
if length(indx) <1;
    disp('Error')
end
% title(['k1:' 'Est Cpp_{opt} = ' num2str(CPP2(indx))])
% subplot(2,3,2)
% plot(CPP2,Cor(kkk).PRxo2(d), 'o')
[~, indx] = min(Cor(kkk).PRxo2(d));
if length(indx) <1;
    disp('Error')
end
% xline(CPP2(indx))
% title(['k2:' 'Est Cpp_{opt} = ' num2str(CPP2(indx))])
opt(kkk,2,bs) = CPP2(indx);
if length(indx) <1;
    disp('Error')
end
% 
% subplot(2,3,3)
% plot(CPP2,Cor(kkk).PRxo3(d), 'o')
[~, indx] = min(Cor(kkk).PRxo3(d));
if length(indx) <1;
    disp('Error')
end
% xline(CPP2(indx))
% title(['k3:' 'Est Cpp_{opt} = ' num2str(CPP2(indx))])
opt(kkk,3,bs) = CPP2(indx);
if length(indx) <1;
    disp('Error')
end
% subplot(2,3,4)
% plot(CPP2,Cor(kkk).PRxo4(d), 'o')
[~, indx] = min(Cor(kkk).PRxo4(d));
% xline(CPP2(indx))
% title(['k4: Est Cpp_{opt} = ' num2str(CPP2(indx))])
if length(indx) <1;
    disp('Error')
end
opt(kkk,4,bs) = CPP2(indx);
% ylabel('PRx', 'FontSize', 13)
% xlabel('CPP', 'FontSize', 13)

% subplot(2,3,5)
% plot(CPP2,Cor(kkk).PRxo5(d), 'o')
[~, indx] = min(Cor(kkk).PRxo5(d));
if length(indx) <1;
    disp('Error')
end
% xline(CPP2(indx))
% title(['k5:' 'Est Cpp_{opt} = ' num2str(CPP2(indx))])
% xlabel('CPP', 'FontSize', 13)

opt(kkk,5,bs) = CPP2(indx);


% subplot(2,3,6)
 plot(CPP2,Cor(kkk).PRxo6(d), 'o')
[~, indx] = min(Cor(kkk).PRxo3(d));
if length(indx) <1;
    disp('Error')
end
xline(CPP2(indx))
title(['k6: Est Cpp_{opt} = ' num2str(CPP2(indx))])
xlabel('CPP', 'FontSize', 13)
opt(kkk,6,bs) = CPP2(indx);
% 
% A = ['Correlation Window: ', char(Cory(kkk))];
% suptitle( {A ' Real CPP_{opt} = 3'})
end
opt(2,:,bs) - CPPopt(bs)
clear CPP2 Cor
toc
end
% 
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Opt5.fig')
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Opt5.png')
% 
% figure
% bar3(abs(opt-3)/(max(CPP)-min(CPP)))
% set(gca, 'yticklabels', {'3 min', '6 min', '10 min'})
% xlabel('Correlation Windows')
% set(gca, 'xticklabels', {'k<<x1', 'x1<k<x2', 'x2<k<x3', 'x3<k<x4', 'x5<k<x6', 'k>x6'})
% ylabel('Averaging Windows')
% zlabel('Percent Error is CPP_{opt} Estimation')
% 
% 
% figure, 
% plot((abs(opt-3)/(max(CPP)-min(CPP)))', 'o-', 'LineWidth', 3)
% ylabel('Percentage error', 'FontSize', 15)
% xlabel('Averaging Windows', 'FontSize', 15)
% set(gca, 'xticklabels', {'k1', [], 'k2' ,[]', 'k3', [], 'k4', [], 'k5', [], 'k6'})
% title('Possible Percentage Error in CPP_{opt}', 'FontSize', 20)
% legend('3 min Correlation Window', '5 min Correlation Window', ...
%     '10 min Correlation Window', 'Location', 'SW', 'FontSize', 15)
% 
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\errorCPP.fig')
% saveas(gcf, 'C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\errorCPP.png')
%%

end

% try
% save('C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\PRxError\Workspace')
% catch
save('Workspace_novarianceinCPPopt')
% end
%saveAllFigsToPPT('C:\Users\Jennifer Briggs\Dropbox\ICP_jennifer\CApositions_draft\CAtimescales\PRxcalculations_10mincor')