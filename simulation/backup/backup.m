grid_load_avg = total_grid_load/numBuses;
grid_load_std = grid_load_avg/10;
grid_loads    = pos(random('norm',grid_load_avg,grid_load_std,[1 numBuses]));
[Hour_End,COAST,EAST,FAR_WEST,NORTH,NORTH_C,SOUTHERN,SOUTH_C,WEST,ERCOT] = import_grid_load('traces/ecort_load_2016.xls');
daily_load = reshape(ERCOT,24,length(ERCOT)/24); % need to change
grid_load_data = zeros(numBuses, T);

for b = 1: numBuses
    t_raw = linspace(0,T,24);
    t = linspace(0,T,T);
    temp = interp1q(t_raw',daily_load(:,b),t');
    scale_tmp = grid_loads(b)/mean(temp);
    grid_load_data(b,:) = temp*scale_tmp;
end