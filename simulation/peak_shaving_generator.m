%% This script is to evaluate the impact of flexiblity of backup generators' performance on the grid.
init_settings_15_min
%% parameters
IS_LOAD = false;
IS_SAVE = true;
G_array = zeros(length(ramp_time_generator), T);
%% Run simulation.
progressbar
for c = 1:length(gen_price)
    %% step 2: Optimize the violation frequency via scheduling the workload  
    [dc_power_after(c,:), G] = min_peak_shaving_gen(grid_load_data_pred, dc_power_pred, ...
         gen_power_cap, ramp_time_generator(1), gen_budget(c), gen_price(c));
    G_array(c, :) = G;
    progressbar(c/length(gen_price))
end

%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
if IS_SAVE
    save('results/peak_shaving_generator.mat');
end

%%
if false
    figure;
%     plot(raw_dc_power);
%     hold on;
    plot(dc_power);
    hold on;
    plot(dc_power_after');
end

if false
    figure;
    plot(dc_power+grid_load_data);
    for c = 1:length(gen_price)
        hold on;
        plot(dc_power_after(c,:)' + grid_load_data);
    end
end