%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings
IS_LOAD = false;
IS_SAVE = false;
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%% Grid settings

violationFreq = zeros(length(dcBus), length(ramp_time));
violationFreq_upperbound = zeros(1, length(dcBus));
X_e_array = zeros(length(dcBus), length(ramp_time_generator), T);
%% Run simulation.

for b = 1:len_investment
    disp('---------------------------------------------------')
    pvIrradi = irrad_time; %Feb26Irrad(1:sampling_interval:T*sampling_interval);
    
    % only DC without scheduling
    violationFreq_upperbound(b) = computeViolationFrequency (power_case, PVcapacity, pvIrradi,...
        minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), dc_power,  ...
        opt, dcBus, numBuses, pvBus, grid_load_data, loadBus, verbose);
    
    for c = 1:length(ramp_time)    
        upper_bound = (r_charge(c)*ups_cap(c) + dc_power);
        lower_bound = dc_power - r_discharge(c)*ups_cap(c);
        [W, loadLevels] = comp_vio_wei_bounds(power_case, PVcapacity,...
                        pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                        lower_bound, upper_bound, numLoadLevels, ...    
                        opt, dcBus, numBuses, pvBus, grid_load_data, loadBus, false);
                        
        dc_power = on_load_levels(dc_power, loadLevels);
        %% step 2: Optimize the violation frequency via scheduling the workload
        [violationFreq(b,c), X , X_e] = opt_vio_freq_ups(W, loadLevels, ...
             POWER_UNIT, dc_power, ups_cap(b,c), r_charge(b,c), r_discharge(b,c), ...
             DoD(c), eff_coff(c), ramp_time(c), N_cycles_per_T(c), ...
             false);
         X_e_array(b, c, :) = X_e;
    end
end
violationFreq
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
if IS_SAVE
    save('results/script_ups.mat');
end