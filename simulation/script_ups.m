%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

% init_settings
init_settings_5_min
% init_settings_15_min
IS_LOAD = false;
IS_SAVE = true;
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%% Grid settings

violationFreq = zeros(length(dcBus), length(ramp_time));
X_e_array = zeros(length(dcBus), length(ramp_time_generator), T);
%% Run simulation.
numOfUPS = length(ramp_time);
% numOfUPS = 1;
disp('---------------------------------------------------')
pvIrradi = irrad_time; 

upper_bound = (dc_cap+ dc_power);
lower_bound = dc_power - dc_cap;
%         upper_bound = (r_charge(b,c)*ups_cap(b,c) + dc_power);
%         lower_bound = dc_power - r_discharge(b,c)*ups_cap(b,c);
[W, loadLevels] = comp_vio_wei_bounds(power_case, PVcapacity,...
                pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                lower_bound, upper_bound, numLoadLevels, ...    
                opt, dcBus, numBuses, pvBus, grid_load_data, loadBus, false);
SCALE = 10000;
W = SCALE*W;            
dc_power_round = on_load_levels(dc_power, loadLevels);

count = 0;
progressbar
for b = 1:len_investment    
    for c = 1:numOfUPS       
        %% step 2: Optimize the violation frequency via scheduling the workload
%         P_D_e = N_cycles_per_T(c) * DoD(c) *ups_cap(b,c)
        [violationFreq(b,c), X , X_e] = opt_vio_freq_ups(W, loadLevels, ...
             POWER_UNIT, dc_power_round, ups_cap(b,c), r_charge(b,c), r_discharge(b,c), ...
             DoD(c), eff_coff(c), ramp_time(c), N_cycles_per_T(c), HOUR, ...
             false);
         X_e_array(b, c, :) = X_e;
         count = count + 1;
         progressbar(count/(len_investment*numOfUPS))
    end
end
% re-scale the violationFreq

violationFreq = violationFreq/SCALE;

% only DC without scheduling
violationFreq_upperbound_default = computeViolationFrequency (power_case, PVcapacity, pvIrradi,...
    minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), dc_power,  ...
    opt, dcBus, numBuses, pvBus, grid_load_data, loadBus, verbose)

violationFreq_upperbound_round = computeViolationFrequency (power_case, PVcapacity, pvIrradi,...
    minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), dc_power,  ...
    opt, dcBus, numBuses, pvBus, grid_load_data, loadBus, verbose)

violationFreq = violationFreq * violationFreq_upperbound_default/violationFreq_upperbound_round;

%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
if IS_SAVE
    save('results/script_ups.mat');
end