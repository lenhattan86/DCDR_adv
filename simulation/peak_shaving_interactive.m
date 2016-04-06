%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings_15_min
IS_LOAD = false;
verbose = false;
%% Simulation
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of
% analysis
M = a_pred/PP; % number of servers.
lamda = M*util_level;

%util_level = arrival_rate/M;
QoS_delay = ones(T,1)./(mu-util_level);
% a = M*server_power
server_power = PP;
%% workload configuration
 % INPUT:
QoS_delay_relax = [0.05:0.05:0.25];
qos_length              = length(QoS_delay_relax);
aFlexiblitiesUpperBound = zeros(qos_length, length(a_pred));
aFlexiblitiesLowerBound = zeros(qos_length, length(a_pred));

for qos = 1:qos_length
    QoS_delay_slow_down = (1 + QoS_delay_relax(qos)) * QoS_delay;
    QoS_delay_speed_up  = (1 - QoS_delay_relax(qos)) * QoS_delay;

%     aFlexiblitiesUpperBound(qos,:) = service_rate - QoS_delay_slow_down;
%     aFlexiblitiesLowerBound(qos,:) = service_rate - QoS_delay_speed_up;
    aFlexiblitiesUpperBound(qos,:) = server_power*lamda./(mu - ones(T,1)./QoS_delay_speed_up);
    aFlexiblitiesLowerBound(qos,:) = server_power*lamda./(mu - ones(T,1)./QoS_delay_slow_down);
end

%% Grid settings

violationFreq = zeros(length(dcBus), qos_length);
numLoadLevels = 50;
a_qos= zeros(qos_length,T);
dc_power_qos= zeros(qos_length,T);
%% Run simulation.
for qos = 1:qos_length
    [dc_power_after(qos,:), a_after(qos,:)] = min_peak_interactive...
        ( grid_load_data_pred, a_pred,  aFlexiblitiesLowerBound(qos,:), b_flat, PP, IP);
end
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/peak_shaving_interactive.mat');

%% Plot figures
if 1
    figure;
%     plot(raw_dc_power+grid_load_data);
    plot(dc_power+grid_load_data);
    for c = 1:qos_length
        hold on;
        plot(dc_power_after(c,:)' + grid_load_data);
    end
end