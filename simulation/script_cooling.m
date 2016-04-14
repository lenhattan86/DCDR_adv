%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the
%TODO: The code may not co-locate the batch jobs.

init_settings
% init_settings_15
% IS_LOAD_VIOLATION_MATRIX = true;
%% Simulation
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

is_plot = false;

%% workload configuration
t_differences = 0:2:10; % acceptable temperature.
lower_bound = dc_power/PUE;
upper_bound = dc_cap;

%% Grid settings
violationFreq = zeros(length(dcBus), length(t_differences));
P_cooling_after = zeros(length(t_differences),T);
Temp_dc = zeros(length(t_differences),T);

violationFreq_upperbound = computeViolationFrequency (power_case, PVcapacity, irrad_time,...
    minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), dc_power,  ...
    opt, dcBus, numBuses, pvBus, grid_load_data, loadBus, verbose);

%% Run simulation
count = 0;
progressbar
for b = 1:length(dcBus)
    disp('---------------------------------------------------')  
    %% step 1: estimate the utility function (e.g. violation frequency)
    pvIrradi = irrad_time;
    [W, loadLevels] =  comp_vio_wei_bounds(power_case, PVcapacity,...
                pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                lower_bound, upper_bound, numLoadLevels, ...  ...                    
                opt, dcBus(b), numBuses, pvBus, grid_load_data, loadBus, conv_power, false);
    SCALE = 10000;
    W = SCALE*W; 
    for c = 1:length(t_differences)        
    %% Step 2: optimize the utility based in the range of acceptable temperature
        TempRange  = [t_RA_avg - t_differences(c) t_RA_avg + t_differences(c)];        
        
        [ violationFreq(b,c), P_IT, P_cooling_after(c,:), PUEs, Temp_dc(c,:)] ...
            = opt_vio_freq_cooling(W, loadLevels, dc_power, PUE, beta,...
                TempRange, cm, POWER_UNIT);
        count = count + 1;
        progressbar(count/length(t_differences) *length(dcBus));    
    end
end
violationFreq = violationFreq/SCALE;
violationFreq
%%
save('results/script_cooling.mat');
%%
if is_plot
    for c = 1:length(t_differences)
        figure;        
        y_array = [P_IT' ; P_cooling_after(c,:)];
        bar(y_array',1,'stacked');
        legend('IT power','Cooling power');
        ylim([0 dc_cap]);
    end
    for c = 1:length(t_differences)
        figure;        
        y_array = Temp_dc(c,:);
        plot(y_array');
        legend('Temperature');        
    end
end