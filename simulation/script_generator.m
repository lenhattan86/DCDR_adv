%% This script is to evaluate the impact of flexiblity of backup generators' performance on the grid.
init_settings
IS_LOAD = false;
IS_SAVE = true;
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%% power consumption
violationFreq = zeros(length(dcBus), length(ramp_time_generator));
violationFreq_upperbound = zeros(1, length(dcBus));
G_array = zeros(length(dcBus), length(ramp_time_generator), T);
%% Run simulation.
% dc_power =  dc_power * 2; % hard code here? need to get rid of this line.
for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    pvIrradi = irrad_time;% Feb26Irrad(1:sampling_interval:T*sampling_interval);
    % only DC without scheduling
    violationFreq_upperbound(b) = computeViolationFrequency (power_case, PVcapacity, pvIrradi,...
        minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), dc_power,  ...
        opt, dcBus(b), numBuses, pvBus, grid_load_data,loadBus, verbose);
    
    %% step 1: compute weight matrix
    upper_bound = dc_power;
    lower_bound = dc_power - gen_power_cap(1);
    [W, loadLevels] =  comp_vio_wei_bounds(power_case, PVcapacity,...
                    pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                    lower_bound, upper_bound, numLoadLevels, ...    
                    opt, dcBus(b), numBuses, pvBus, grid_load_data,loadBus, false);
    
    for c = 1:length(ramp_time_generator)
        %% step 2: Optimize the violation frequency via scheduling the workload  
        [violationFreq(b,c), X, G] = opt_vio_freq_gen(W, loadLevels, ...
             dc_power, gen_power_cap(c), ramp_time_generator(c), ...
             false);
        G_array(b, c, :) = G;
    end
end

%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
if IS_SAVE
    save('results/script_generator.mat');
end
violationFreq