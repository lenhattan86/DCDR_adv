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
PUEs = [1.1:0.1:1.6];
t_Range = [68 72]; % acceptable temperature.
t_RA_avg = 70;
% compute power cooling acceptable power range
% P_cooling = gamma/(tRA - tOA)*a.^3;
a_avg = mean(a);
P_cooling_avg = mean((PUE-1).*a);
P_cooling = P_cooling_avg/mean(PUE) * PUEs;
gamma = P_cooling*(t_RA_avg-mean(t_OA))/(a_avg^3);
% P_cooling_default = (1/gamma)*(t_RA_avg-t_OA)'.*a.^3;
% power_dc = P_cooling_default+ a;

%% Grid settings
power_case = case47custom;
numBuses = 47;
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

violationFreq = zeros(length(dcBus), length(PUEs));

%% Run simulation.

POWER_UNIT =  dc_cap/100;

for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    pvIrradi = Feb26Irrad(1:sampling_interval:T*sampling_interval);
    for c = 1:length(PUEs)
        pue = PUEs(c);
        [violationFreq(b,c)] = nonviolation_cooling(power_case, PVcapacity, pvIrradi,...
            minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval),...
            a, dc_cap, ...
            pue, t_Range, t_OA, gamma(c), ...
            opt, dcBus, numBuses, pvBus, false);
    end
end
violationFreq
%%
% plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);
save('results/script_cooling.mat');