%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings_15
IS_LOAD = false;
IS_SAVE = true;
%% parameters

%% Run simulation.
dc_power_after =  zeros(length(ramp_time), T);
energy_storage_power =  zeros(length(ramp_time), T);
progressbar
for c = 1:length(ramp_time)
    [dc_power_after(c,:), energy_storage_power(c,:)] = min_peak_shaving_ups(grid_load_data ,dc_power, ...
         ups_cap(c), r_charge(c), r_discharge(c), ...
         DoD(c), eff_coff(c), ramp_time(c), N_cycles_per_T(c));
    progressbar(c/length(ramp_time))
end
%%
if IS_SAVE
    save('results/peak_shaving_ups.mat');
end
%%

if 1
    figure;
    plot(dc_power+grid_load_data);
    for c = 1:length(ramp_time)
        hold on;
        plot(dc_power_after(c,:)' + grid_load_data);
    end
end