%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings
% init_settings_shaving
IS_LOAD = false;
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%% workload configuration
bjEnd = [2:2:12]*HOUR;

%% Grid settings

violationFreq = zeros(length(bjEnd));
idle_power = zeros(length(bjEnd), T);
a_power = zeros(length(bjEnd), T);
b_power = zeros(length(bjEnd), T);

%% Run simulation.
count = 0;
progressbar
pvIrradi = irrad_time;% Feb26Irrad(1:sampling_interval:T*sampling_interval);
% step 1: compute weights of violation frequency
% Prepare the matrix of violation frequencies for the given power consumption level of data center
if IS_LOAD
    load('results/violation_frequency_matrix');
else
    [W, loadLevels] =  comp_vio_wei(power_case, PVcapacity,...
                pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                dc_cap,...
                POWER_UNIT, ...  
                opt, dcBus, numBuses, pvBus, grid_load_data,loadBus, false);
    save('results/violation_frequency_matrix', 'W', 'loadLevels');
end
% step 2: Optimize the violation frequency via scheduling the workload      
for c = 1:length(bjEnd)
    c
    % create the matrix of arrival and deadline times.
    A_bj = zeros(BN*T,T);
    E = S + ceil(random('Uniform',bjEnd(c),bjEnd(c)));
    for i = 1:1:BN*T
        if E(i) > T
            A_bj(i,S(i):T)    = ones(1,T-S(i)+1);
            A_bj(i,1:E(i)-T)  = ones(1,E(i)-T);
        else
            A_bj(i,S(i):E(i)) = ones(1,E(i)-S(i)+1);
        end    
    end        
    [violationFreq(c), idle_power(c,:), a_power(c,:), b_power(c,:)] = opt_vio_freq_batchjob(W, loadLevels, ...
        dc_power, a_plus, BS_plus, A_bj, POWER_UNIT, IDLE_POWER,ON_OFF,IP,PP);
    count = count + 1;
    progressbar(count/length(bjEnd))
end
violationFreq

% compute the switching costs.
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/script_batchjob.mat');