%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

% init_settings_15
init_settings
IS_LOAD = false;
is_save = true;
verbose = false;
%% Simulation
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of
% analysis

server_power = PP; % equal to peak power.
M = a/server_power; % number of servers.
lamda = M*util_level;
%util_level = arrival_rate/M;
QoS_delay = ones(T,1)./(mu-util_level);
% a = M*server_power

%% workload configuration
 % INPUT:
QoS_delay_relax = [0.0:0.05:0.25];

%%
% aFlexiblitiesUpperBound & aFlexiblitiesLowerBound
qos_length              = length(QoS_delay_relax);
aFlexiblitiesUpperBound = zeros(qos_length, length(a));
aFlexiblitiesLowerBound = zeros(qos_length, length(a));
QoS_delay_after         = zeros(qos_length,T);
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

% numLoadLevels = 50;
a_qos= zeros(qos_length,T);
dc_power_qos= zeros(qos_length,T);
%% Run simulation.
% vary the bugdet
for b = 1:length(dcBus)    
    pvIrradi = irrad_time;% Feb26Irrad(1:sampling_interval:T*sampling_interval);    
    for qos = 1:qos_length
        %TODO: step 2: convert interactive_QoS_delay to aFlexiblities
        [violationFreq(b,qos), a_qos(qos,:), dc_power_qos(qos,:)] = nonviolationInteractive(power_case, PVcapacity, pvIrradi, ...
            minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
            dc_power, a, dc_cap, ...
            aFlexiblitiesUpperBound(qos,:), aFlexiblitiesLowerBound(qos,:), ...
            opt, dcBus, numBuses, pvBus, grid_load_data,loadBus, numLoadLevels, verbose);  
        m = a_qos(qos,:)/server_power;
        QoS_delay_after(qos,:) = ones(1,T)./(mu-lamda'./m);
    end
end
violationFreq
if is_save
    save([RESULT_PATH 'script_interactive.mat']);
end
%%
plot(QoS_delay_relax(:), violationFreq(1,:), '-ok', 'LineWidth', 4);
% plot(x,[optimalBus,optimalBus], '--r', 'LineWidth', 4);
% plot(x,[optimal,optimal],'-b', 'LineWidth', 2);

h_legend = legend('QoS');
    
x_label = xlabel('Extended delay (%)');
y_label = ylabel('Violation Frequency');
set(x_label, 'FontSize', 14);
set(y_label, 'FontSize', 14);
set(h_legend,'FontSize', 14);  

ylim([0, 0.4])

%% 
figure;
plot(dc_power);
hold on;
plot(a);
for q=1:qos_length
    hold on;
    plot(a_qos(q,:));
end