%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings
IS_LOAD = false;
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%% workload configuration


%% Grid settings
power_case = case47custom;
numBuses = 47;
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

violationFreq = zeros(length(dcBus), length(ramp_time));

%% Run simulation.

for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    pvIrradi = Feb26Irrad(1:sampling_interval:T*sampling_interval);
    for c = 1:length(ramp_time)
         %% step 1: compute weights of violation frequency
        % Prepare the matrix of violation frequencies for the given power consumption level of data center
        [W, loadLevels] =  comp_vio_wei_2(power_case, PVcapacity,...
                    pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                    r_charge(c) + dc_cap, 0 - r_discharge(c),...
                    POWER_UNIT, ...  
                    opt, dcBus(b), numBuses, pvBus, false);
                
        %% step 2: Optimize the violation frequency via scheduling the workload  
        [violationFreq(b,c)] = opt_vio_freq_ups(W, loadLevels, ...
             POWER_UNIT, dc_power, ups_cap, r_charge(c), r_discharge(c), ...
             DoD(c), eff_coff(c), ramp_time(c),...
             true);
    end
end
violationFreq
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/script_ups.mat');