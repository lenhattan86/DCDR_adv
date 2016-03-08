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
t_differences = 0:2:8; % acceptable temperature.
t_RA_avg = 70;
% compute power cooling acceptable power range
% P_cooling = gamma/(tRA - tOA)*a.^3;
a_avg = mean(a);
workload_power = dc_power./PUE;
P_cooling = (mean(PUE)-1) * a_avg;
cooling_ratio = 0.5;
P_oac = cooling_ratio*P_cooling;
P_wc = (1-cooling_ratio)* P_cooling;
temp_power_oac = 1.5;
temp_power_wc = 1.1;
% outside air cooler
alpha = P_oac*((t_RA_avg - mean(t_OA))^temp_power_oac)/(a_avg^3); % P_oac = alpha/((t_RA - t_OA)^temp_power) * d^3
% water chiller
gamma = P_wc *(t_RA_avg^temp_power_wc)/(a_avg); % P_wc  = gamma/(t_RA^temp_power) * d

%% Grid settings
power_case = case47custom;
numBuses = 47;
dcBus =  2;  % dc bus location
pvBus = 45; % bus location of PV
violationFreq = zeros(length(dcBus), length(t_differences));

%% Run simulation
POWER_UNIT =  dc_cap/100;
for b = 1:length(dcBus)
    disp('---------------------------------------------------')    
    for c = 1:length(t_differences)
        irrad_time = Feb26Irrad(1:sampling_interval:T*sampling_interval);
        t_Range    = [t_RA_avg - t_differences t_RA_avg + t_differences];
        pct_load   = minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval);
        
        [violationFreq(b,c)] = nonviolation_cooling(power_case, PVcapacity, irrad_time, ...
                pct_load, workload_power, dc_cap, ...
                t_Range , t_OA, alpha, gamma, temp_power_oac, temp_power_wc, ...
                opt, dcBus, numBuses, pvBus, verbose);
            
        
    end
end
violationFreq
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/script_cooling.mat');