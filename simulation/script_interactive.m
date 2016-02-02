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
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis
service_rate = max(a)*2;
QoS_delay = (service_rate - a).^(-1);
max_QoS_delay = max(QoS_delay);

%% workload configuration
 % INPUT:
interactive_QoS_delay = [1.1:0.1:1.5]*max_QoS_delay;

%%
%TODO: step 1: use max_QoS_delay & interactive_QoS_delay to compute 
% aFlexiblitiesUpperBound & aFlexiblitiesLowerBound

aFlexiblitiesUpperBound = [0.1:0.1:0.5]; % max (dc_cap, interactive)
aFlexiblitiesLowerBound = [0.1:0.1:0.5]; % min (0, a).


%% Grid settings
power_case = case47custom;
numBuses = 47;
dc_cap = 20;
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

violationFreq = zeros(length(dcBus), length(aFlexiblitiesUpperBound));

%% Run simulation.

for b = 1:length(dcBus)    
    pvIrradi = Feb26Irrad(1:sampling_interval:T*sampling_interval);
    
    for c = 1:length(aFlexiblitiesUpperBound)
        %TODO: step 2: convert interactive_QoS_delay to aFlexiblities
        violationFreq(b,c) = nonviolationInteractive(power_case, PVcapacity, pvIrradi,...
        minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval),...
        dc_power, a, dc_cap, ...
        aFlexiblitiesUpperBound(c), aFlexiblitiesLowerBound(c), ...
        opt, dcBus, numBuses, pvBus, verbose);
    end
end
violationFreq
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save([RESULT_PATH 'script_interactive.mat']);