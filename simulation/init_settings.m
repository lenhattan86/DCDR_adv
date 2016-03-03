clear all; close all; clc;
cvx_solver Gurobi;
s_quiet = cvx_quiet(true);
s_pause = cvx_pause(false);
cvx_precision low;

addpath('lib/matpower4.1');
addpath('lib/matpower4.1/t');
addpath('functions');

FIG_PATH = 'figs/';
RESULT_PATH = 'results/';
TRACE_PATH = 'traces/';

IS_GENERATE_DATA = 1;
if IS_GENERATE_DATA
    %% common constants
    sampling_interval = 5; % minutes.
    time_interval = 5; % in minutes
    HOUR = 60/sampling_interval; % number of timeslots an hour.
    DAY = 24*HOUR; % number of timeslots a day.
    T = 1*DAY; %1440; % per minute data
    
    
    %% PV generation
    load([TRACE_PATH 'testdayirrad.mat']);
    PVcapacity = 30;
    
    %% data center
    PUE_orig = [1.16,1.17,1.16,1.20,1.22,1.22,1.24,1.26,1.35,1.32,1.25, ...
        1.30,1.29,1.35,1.32,1.40,1.40,1.25,1.29,1.30,1.28,1.29,1.18,1.13]';
    PUE = reshape((1+0.2*(rand(T/24,1)-0.5))*PUE_orig',T,1);
    dc_cap = 20;
    dc_ratio = 1;
    %dc_power = zeros(T,1);
    
    POWER_UNIT =  dc_cap/40;
    %% workload
    % generate data center demand traces
    interactive_raw = load('traces/SAPnew/sapTrace.tab');
    col = 4; % column of the data loaded

    t_raw = linspace(0,T,T/time_interval+1);
    t = linspace(0,T,T+1);
    inter_tmp = interp1q(t_raw',interactive_raw(1:T*sampling_interval/time_interval+1,4),t');
    a = inter_tmp(1:T); % interactive workload
    
    
    au = 0.4; % average utilization of a workloads
    con = 0.9; % maximum utilization after consolidation
    peak_to_cap_ratio = 0.7;
    
    BN = 10; % average number of jobs per time slot.
    BM = 0.5; % power ratio of batch jobs vs. interactive workload.
    
    % generate the raw Batch jobs and a workload
    [A_bj, BS, S, E] = batch_job_generator(T,BN*T, 'Uniform',1,1, ...
        BM/(1-BM)*sum(mean(a)./au)/con); % generate batch jobs based on statistical properties
    % compute the weight matrix of violation frequency  
    b_flat = BS./sum(A_bj,2)*ones(1,T).*A_bj;
    dc_power = a + sum(b_flat,1)';
    dc_scale = peak_to_cap_ratio*dc_cap/max(dc_power);
    a = a *dc_scale;
    BS = BS * dc_scale;   
    
    
    BS = round(BS/POWER_UNIT)*POWER_UNIT;
    b_flat = BS./sum(A_bj,2)*ones(1,T).*A_bj;
    a = round(a/POWER_UNIT)*POWER_UNIT;
    dc_power = a + sum(b_flat,1)';
    
    %% temperature in a day
    %  http://www.accuweather.com/en/us/new-york-ny/10007/hourly-weather-forecast/349727?hour=0
    hourly_temp = [42 41 39 38 36 35 34 34 35 38 42 44 45 46 47 47 46 45 42 40 39 39 38 36]; % in Fahrenheit
%     t_raw = 1:24;
%     t = 1:0.5:24+0.5
%     temp = interp1q(t_raw, hourly_temp, t);
    t_OA = ones(1,T)*mean(hourly_temp);
    
    %% electricity grid

    %% DR programs        
    

    %% Save the prepared data 
    save([RESULT_PATH 'init_settings.mat']) 
else
    load([RESULT_PATH 'init_settings.mat']);
end