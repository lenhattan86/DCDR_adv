i_day = 1;
temp = interp1q(t_raw',ERCOT((i_day-1)*24+1:i_day*24),t');
plot(temp);
ylim([0 max(temp)]);