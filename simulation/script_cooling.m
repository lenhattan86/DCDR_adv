%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the
%TODO: The code may not co-locate the batch jobs.

init_settings
% IS_LOAD_VIOLATION_MATRIX = true;
%% Simulation
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

is_plot = true;

%% workload configuration
t_differences = 0:2:10; % acceptable temperature.
t_RA_avg = 70;
% compute power cooling acceptable power range
% P_cooling = gamma/(tRA - tOA)*a.^3;
a_avg = mean(a);
P_cooling = (mean(PUE)-1) * a_avg;
cooling_ratio = 0.5;
P_oac = cooling_ratio*P_cooling;
P_wc = (1-cooling_ratio)* P_cooling;
temp_power_oac = 1.5;
temp_power_wc = 1.1;
% outside air cooler
alpha = P_oac*((t_RA_avg - mean(t_OA))^temp_power_oac)/(a_avg^3); % P_oac = alpha/((t_RA - t_OA)^temp_power) * d^3
% water chiller
%gamma = P_wc *(t_RA_avg^temp_power_wc)/(a_avg); % P_wc  = gamma/(t_RA^temp_power) * d
gamma = 0.3;
beta = 1;
cm = 20;

lower_bound = P_IT;
upper_bound = min(2*P_IT,dc_real_cap);

%% Grid settings
power_case = case47custom;
numBuses = 47;
dcBus =  2;  % dc bus location
pvBus = 45; % bus location of PV
violationFreq = zeros(length(dcBus), length(t_differences));


%% Run simulation
for b = 1:length(dcBus)
    disp('---------------------------------------------------')  
    %% step 1: estimate the utility function (e.g. violation frequency)
    pvIrradi = irrad_time;% Feb26Irrad(1:sampling_interval:T*sampling_interval);
    if IS_LOAD_VIOLATION_MATRIX
        load('results/matrix_script_cooling');
    else
        [W, loadLevels] =  comp_vio_wei_bounds(power_case, PVcapacity,...
                    pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                    lower_bound, upper_bound, numLoadLevels, ...  ...                    
                    opt, dcBus(b), numBuses, pvBus, grid_load_data, loadBus,  false);
        save('results/matrix_script_cooling', 'W', 'loadLevels');
    end
    
    for c = 1:length(t_differences)        
    %% Step 2: optimize the utility based in the range of acceptable temperature
        TempRange  = [t_RA_avg - t_differences(c) t_RA_avg + t_differences(c)];        
        
        [ violationFreq(b,c), PUEs] = opt_vio_freq_cooling(W, loadLevels, P_IT, alpha, gamma, beta,...
                TempRange, cm, is_plot);
    end
end
violationFreq
%%
save('results/script_cooling.mat');