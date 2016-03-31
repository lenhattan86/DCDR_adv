%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% degrading the quality of service (such as delay) of serving interactive
% workload.

% Discription: Given flexibility of delaying interactive workload, how the

%TODO: The code may not co-locate the batch jobs.

init_settings_15
% init_settings
IS_LOAD = false;
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%% workload configuration
bjEnd = [1:0.5:2]*HOUR;

%% Grid settings
dc_power_after =  zeros(length(bjEnd), T);
bj_after = zeros(length(bjEnd), T);

%% Run simulation.

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
    [dc_power_after(c,:), bj_after(c,:)] = min_peak_using_batch_jobs...
        ( grid_load_data ,a, BS, A_bj,PP, IP, false);
%     [dc_power_after(c,:), bj_after(c,:)] = min_peak_using_batch_jobs( a_plus, BS_plus, A_bj, false);
end
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/peak_shaving_batch_jobs.mat');

%% Plot figures
if 1
    figure;
%     plot(raw_dc_power);
%     hold on;
    plot(dc_power+grid_load_data);
    for c = 1:length(bjEnd)
        hold on;
        plot(dc_power_after(c,:)' + grid_load_data);
    end
end