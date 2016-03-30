%% This script is to evaluate the impact of flexiblity of backup generators' performance on the grid.
init_settings_shaving
% init_settings
%% parameters
IS_LOAD = false;
IS_SAVE = true;
G_array = zeros(length(ramp_time_generator), T);
%% Run simulation.
for c = 1:length(ramp_time_generator)
    %% step 2: Optimize the violation frequency via scheduling the workload  
    [dc_power_after(c,:), G] = min_peak_shaving_gen(dc_power, ...
         gen_power_cap(c), ramp_time_generator(c));
    G_array(c, :) = G;
end

%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
if IS_SAVE
    save('results/peak_shaving_generator.mat');
end

%%
if 1
    figure;
%     plot(raw_dc_power);
%     hold on;
    plot(dc_power);
    hold on;
    plot(dc_power_after');
end