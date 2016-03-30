%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the
%TODO: The code may not co-locate the batch jobs.

init_settings_shaving
% IS_LOAD_VIOLATION_MATRIX = true;
%% cooling parameters
t_differences = 2:4:10; % acceptable temperature.
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
cm = 10;
%% Run simulation
dc_power_after = zeros(length(t_differences),T);
P_cooling_after = zeros(length(t_differences),T);
for c = 1:length(t_differences)        
    TempRange  = [t_RA_avg - t_differences(c) t_RA_avg + t_differences(c)];        
    [dc_power_after(c,:), P_cooling_after(c,:)] = min_peak_shaving_cooling(P_IT, alpha, gamma, beta,...
            TempRange, cm);
end

%%
save('results/peak_shaving_cooling.mat');

if 1
    figure;
%     plot(raw_dc_power);
%     hold on;
    plot(dc_power);
    hold on;
    plot(dc_power_after');
end