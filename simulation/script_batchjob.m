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
bjEnd = [0:2:10]*HOUR;

%% Grid settings
power_case = case47custom;
numBuses = 47;
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

violationFreq = zeros(length(dcBus), length(bjEnd));

%% Run simulation.

POWER_UNIT =  dc_cap/100;

for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    pvIrradi = Feb26Irrad(1:sampling_interval:T*sampling_interval);
    % step 1: compute weights of violation frequency
    % Prepare the matrix of violation frequencies for the given power consumption level of data center
    if IS_LOAD
        load('results/script_batchjob_data');
    else
        [W, loadLevels] =  comp_vio_wei(power_case, PVcapacity,...
                    pvIrradi, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
                    dc_cap,...
                    POWER_UNIT, ...  
                    opt, dcBus(b), numBuses, pvBus, false);
       save('results/script_batchjob_data');
    end
    % step 2: Optimize the violation frequency via scheduling the workload      
    for c = 1:length(bjEnd)
        % create the matrix of arrival and deadline times.
        A_bj = zeros(BN*T,T);
        E = S + ceil(random('Uniform',bjEnd(c),bjEnd(c)));
        for i = 1:1:BN*T
            if E(i) > T
                A_bj(i,S(i):T) = ones(1,T-S(i)+1);
                A_bj(i,1:E(i)-T) = ones(1,E(i)-T);
            else
                A_bj(i,S(i):E(i)) = ones(1,E(i)-S(i)+1);
            end    
        end        
        [violationFreq(b,c)] =  opt_vio_freq_batchjob(W, loadLevels, dc_power, a, BS, A_bj, POWER_UNIT, false);
    end
end
violationFreq
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/script_batchjob.mat');