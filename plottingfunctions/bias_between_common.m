% Just extracting the data and removing nans
function deviation_from_av = bias_between_common(out)

%interpolate between common times
time = (squeeze(out.time(i).data(5, 40, :)));
time = time(~isnan(time));
ten_30i = squeeze(out.PRx(i).data(10,30,:));
ten_30i = ten_30(~isnan(ten_30));
ten_30t = squeeze(out.time(i).data(10,30,:));
ten_30t = ten_30t(~isnan(ten_30));
six_60 =  squeeze(out.PRx(i).data(6,60,:));
six_60 = six_60(~isnan(six_60));
six_60t =  squeeze(out.time(i).data(6,60,:));
six_60t = six_60t(~isnan(six_60));
fifteen_30 = squeeze(out.PRx(i).data(15,30,:));
fifteen_30 = fifteen_30(~isnan(fifteen_30));
fifteen_30t = squeeze(out.time(i).data(15,30,:));
fifteen_30t = fifteen_30t(~isnan(fifteen_30));
five_40 = squeeze(out.PRx(i).data(5,40,:));
five_40 = five_40(~isnan(five_40));
five_40t = squeeze(out.time(i).data(5,40,:));
five_40t = five_40t(~isnan(five_40));
% 
% % interpolate so all times line up.
% five_40i = interp1(five_40t, five_40, time);
% fifteen_30i = interp1(fifteen_30t, fifteen_30, time);
% six_60i = interp1(six_60t, six_60, time);
% ten_30i = interp1(ten_30t, ten_30, time);
% 
% % interpolate so all times line up.
% five_40i = interp1(five_40t, five_40, time, 'cubic');
% fifteen_30i = interp1(fifteen_30t, fifteen_30, time, 'cubic');
% six_60i = interp1(six_60t, six_60, time, 'cubic');
% ten_30i = interp1(ten_30t, ten_30, time, 'cubic');
% figure, plot(time, six_60i,time, fifteen_30i), ylim([-1.5, 1.5])
% five_40i = interp1(time, five_40, five_40t, 'cubic');

% 
% % % interpolate so all times line up.
% five_40i = spline(five_40t, five_40, time);
% fifteen_30i = spline(fifteen_30t, fifteen_30, time);
% five_40i = spline(five_40t, five_40, time);
% fifteen_30i = spline(fifteen_30t, fifteen_30, time);
% six_60i = spline(six_60t, six_60, time);
% figure, plot(time, five_40i, time, fifteen_30i)
% ylim([-1.5,1.5])
% figure, plot(five_40t, five_40, fifteen_30t, fifteen_30)
% figure, plot(six_60t, six_60, fifteen_30t, fifteen_30)
% close all
% figure, nexttile, plot(six_60t, six_60, fifteen_30t, fifteen_30), nexttile, plot(time, six_60i, time, fifteen_30i)

five_40i = interp1(five_40t, five_40, time);
fifteen_30i = interp1(fifteen_30t, fifteen_30, time);
six_60i = interp1(six_60t, six_60, time);
ten_30i = interp1(ten_30t, ten_30, time);
figure, nexttile, plot(six_60t, six_60, fifteen_30t, fifteen_30), nexttile, plot(time, six_60i, time, fifteen_30i)
nexttile(1)
ax = gca
nexttile(2)
ax2 = gca
linkaxes([ax ax2], 'xy')
figure
plot(time, six_60i, time, ten_30i, time, five_40i, time, fifteen_30i)
legend('Avg: 60s, Corr: 6 samp', 'Avg: 10s, Corr: 30 samp', 'Avg 5s, Corr: 40 samp', 'Avg 15s, Cor: 30 samp')
[six_60i, ten_30i]
all_av = mean([six_60i, ten_30i, five_40i, fifteen_30i], 'omitnan')
all_av = mean([six_60i, ten_30i, five_40i, fifteen_30i], 'omitnan',2)
all_av = mean([six_60i, ten_30i, five_40i, fifteen_30i], 2,'omitnan')
hold on, plot(time, all_av, 'linewidth', 3)
hold on, plot(time, all_av, 'linewidth', 3)
six_60i - all_av
mean(six_60i - all_av)
mean(six_60i - all_av, 'omitnan')
deviation_from_av(i,:) = [mean(six_60i - all_av, 'omitnan'), mean(ten_30i - all_av, 'omitnan'), ...
mean(five_40i - all_av, 'omitnan'), mean(fifteen_30i - all_av, 'omitnan')]
fig = figure,
fig.Position = [318 145 1659 1192]
fig.Units = 'pixels'
tiledlayout('flow', 'Padding','compact','tilespacing', 'tight')
ct = 1
plottime(out)
time = time/60/60 % Change to hours
nexttile,
plot(time, six_60i, time, ten_30i, time, five_40i, time, fifteen_30i)
all_av = mean([six_60i, ten_30i, five_40i, fifteen_30i], 2,'omitnan')
set(gca, 'Visible','off')
set(gca, 'Color', [0.9400 0.9400 0.9400])
set(gca, 'Box', 'off')
figure
plot(time, six_60i, 'Color', [.75 .75, 1], time, ten_30i, time, five_40i, time, fifteen_30i)
plot(time, six_60i, [.75 .75, 1], time, ten_30i, time, five_40i, time, fifteen_30i)
pl = plot(time, six_60i,  time, ten_30i, time, five_40i, time, fifteen_30i)
pl(1).Color
pl(1).Color = [.75, .75, 1]
pl(1).LineWidth
.75*256
c = [174, 227, 154;
42, 104, 102;
191, 213, 250;
87, 78, 106]./255