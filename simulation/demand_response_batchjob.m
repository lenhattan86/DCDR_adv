%% This script is simulate the data center responding to an DR program
% input: DR signals (speed, duration, frequency, rate)
% Data center predict workload & schedule follow the DR

% TODO: The code may not co-locate the batch jobs.
% TODO: make platform independent.
init_settings;
IS_LOAD = false;
%% Simulation

%% workload configuration
bjEnd = [1:1:5]*HOUR;

%% Grid settings
idle_power = zeros(length(bjEnd), T);
a_power = zeros(length(bjEnd), T);
b_power = zeros(length(bjEnd), T);

%% Run simulation.
% step 1: 

% step 2: Optimize the violation frequency via scheduling the workload      
count = 0;
progressbar
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
    % TODO: 
    [DR_profit(c), a_power(c,:), b_power(c,:), idle_power(c,:)] ...
        = respond_DR_by_batchjobs(P_target, t_dr_events, durationsOfDR, dr_rates, T_schedule, ...
                dc_power, dc_cap, a_plus, BS_plus, A_bj, IDLE_POWER, ON_OFF, IP, PP);
    count = count + 1;
    progressbar(count/length(bjEnd))
end

% compute the switching costs.
%%
save('results/demand_response_batchjob.mat');