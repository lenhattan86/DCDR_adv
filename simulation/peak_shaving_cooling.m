%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the
%TODO: The code may not co-locate the batch jobs.

init_settings_15_min
% IS_LOAD_VIOLATION_MATRIX = true;
%% cooling parameters
t_differences = t_differences(2:length(t_differences));
%% Run simulation
dc_power_after = zeros(length(t_differences),T);
P_cooling_after = zeros(length(t_differences),T);
Temp_dc = zeros(length(t_differences),T);
for c = 1:length(t_differences)        
    TempRange  = [t_RA_avg - t_differences(c) t_RA_avg + t_differences(c)];        
    P_IT = dc_power_pred/PUE;
    [dc_power_after(c,:), P_cooling_after(c,:), Temp_dc(c,:)] = min_peak_shaving_cooling(grid_load_data_pred ,P_IT, gamma, beta,...
            TempRange, cm);
end

%%
pue = P_cooling_after./dc_power_after;
max_pue = max(pue')
min_pue = min(pue')

save('results/peak_shaving_cooling.mat');
close all;
if 1
    figure;
    plot(dc_power+grid_load_data);
    for c = 1:length(t_differences)
        hold on;
        plot(dc_power_after(c,:)' + grid_load_data);
    end
end

if false
    for c = 1:length(t_differences)
        figure;        
        y_array = [P_IT' ; P_cooling_after(c,:)];
        bar(y_array',1,'stacked');
        legend('IT power','Cooling power');
    end
end