%% This script is to evaluate the impact of flexiblity of backup generators' performance on the grid.
init_settings_15_min
%% parameters
IS_LOAD = false;
IS_SAVE = true;
G_array = zeros(length(ramp_time_generator),length(gen_budget), T);
dc_power_after = zeros(length(ramp_time_generator),length(gen_budget), T);
%% Run simulation.
count = 0 ;
len = length(gen_budget)*length(ramp_time_generator);
progressbar
for b = 1:length(ramp_time_generator)
    for c = 1:length(gen_budget)
        %% step 2: Optimize the violation frequency via scheduling the workload  
%         [dc_power_after(b, c,:), G] = min_peak_shaving_gen(grid_load_data_pred, dc_power_pred, ...
%              gen_power_cap, ramp_time_generator(b), gen_budget(c), gen_price(b));
        [dc_power_after(b, c,:), G] = min_peak_shaving_gen(grid_load_data, dc_power, ...
            gen_power_cap, ramp_time_generator(b), gen_budget(c), gen_price(b));
        G_array(b, c, :) = G;
        count = count + 1;
        progressbar(count/(len))
    end
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