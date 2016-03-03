%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings
IS_LOAD = false;
verbose = false;
%% Simulation
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of
% analysis
QoS_delay    = 1;
service_rate = 1/QoS_delay + a;

%% workload configuration
 % INPUT:
QoS_delay_relax = [0.1:0.1:0.5];

%%
% aFlexiblitiesUpperBound & aFlexiblitiesLowerBound
qos_length              = length(QoS_delay_relax);
aFlexiblitiesUpperBound = zeros(qos_length, length(a));
aFlexiblitiesLowerBound = zeros(qos_length, length(a));

for qos = 1:qos_length
    QoS_delay_slow_down = (1 + QoS_delay_relax(qos)) * QoS_delay;
    QoS_delay_speed_up  = (1 - QoS_delay_relax(qos)) * QoS_delay;
    
    aFlexiblitiesUpperBound(qos,:) = service_rate - QoS_delay_slow_down;
    aFlexiblitiesLowerBound(qos,:) = service_rate - QoS_delay_speed_up;
end

%% Grid settings
power_case = case47custom;
numBuses = 47;
dc_cap = 20;
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

violationFreq = zeros(length(dcBus), qos_length);

%% Run simulation.
for b = 1:length(dcBus)    
    pvIrradi = Feb26Irrad(1:sampling_interval:T*sampling_interval);
    
    for qos = 1:qos_length
        %TODO: step 2: convert interactive_QoS_delay to aFlexiblities
        violationFreq(b,qos) = nonviolationInteractive(power_case, PVcapacity, pvIrradi,...
            minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval),...
            dc_power, a, dc_cap, ...
            aFlexiblitiesUpperBound(qos,:), aFlexiblitiesLowerBound(qos,:), ...
            opt, dcBus, numBuses, pvBus, verbose);
    end
end
% violationFreq
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

save([RESULT_PATH 'script_interactive.mat']);