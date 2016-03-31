clear all; close all; clc;
cvx_solver Gurobi;
s_quiet = cvx_quiet(true);
s_pause = cvx_pause(false);
cvx_precision low;

addpath('lib/matpower4.1');
addpath('lib/matpower4.1/t');
addpath('functions');
addpath('testcases');

FIG_PATH = 'figs/';
RESULT_PATH = 'results/';
TRACE_PATH = 'traces/';

IS_GENERATE_DATA = 1;
IS_LOAD_VIOLATION_MATRIX = false;
verbose = false;
if IS_GENERATE_DATA
    %% common constants
    sampling_interval = 15; % minutes.
    time_interval = 5; % in minutes
    HOUR = 60/sampling_interval; % number of timeslots an hour.
    DAY = 24*HOUR; % number of timeslots a day.
    T = 1*DAY; %1440; % per minute data
    
    numLoadLevels = 50;
    
    
    %% Grid settings
    power_case = case47custom;
%     power_case = case57;
    numBuses = size(power_case.bus,1);
    
    % grid
    dcBus = 2; % dc bus location
    pvBus = 2; % bus location of PV
%     loadBus = 0;
    loadBus = 2;
%     loadBus = 1:numBuses;
    
    %% PV generation
    load([TRACE_PATH 'testdayirrad.mat']);
    PVcapacity = 30;
%     PVcapacity = 0;
    day = 6;
    irrad_time = Feb2012Irrad(1+day*1440:sampling_interval:T*sampling_interval+day*1440);

    %% load demand in the electricity grid.
    IS_GRID_LOAD = true;
    
    load_mean = 15; % MW
    
    [Hour_End,COAST,EAST,FAR_WEST,NORTH,NORTH_C,SOUTHERN,SOUTH_C,WEST,ERCOT] ...
        = import_grid_load('traces/ecort_load_2016.xls');    
    
    if isscalar(loadBus)
        t_raw = linspace(0,T,24);
        t = linspace(0,T,T);
        temp = interp1q(t_raw',ERCOT(1:24),t');
        grid_load_data = temp*load_mean/mean(ERCOT);
    else        
        numLoadBuses = length(loadBus);
        grid_load_avg = load_mean/numLoadBuses;
        grid_load_std = grid_load_avg/10;
        grid_loads    = pos(random('norm',grid_load_avg,grid_load_std,[1 numBuses]));        
        daily_load = reshape(ERCOT,24,length(ERCOT)/24); % need to change
        grid_load_data = zeros(numLoadBuses, T);
        t_raw = linspace(0,T,24);
        t = linspace(0,T,T);
        
        for b = 1: numLoadBuses
            temp = interp1q(t_raw',daily_load(:,b),t');
            scale_tmp = grid_loads(b)/mean(temp);
            grid_load_data(b,:) = temp*scale_tmp;
        end
    end
    
    %% data center
%     PUE_orig = [1.16,1.17,1.16,1.20,1.22,1.22,1.24,1.26,1.35,1.32,1.25, ...
%         1.30,1.29,1.35,1.32,1.40,1.40,1.25,1.29,1.30,1.28,1.29,1.18,1.13]';
%     PUE = reshape((1+0.2*(rand(T/24,1)-0.5))*PUE_orig',T,1);
    PUE = 1.3;
    PUEs = PUE * ones(T,1);
    dc_cap = 20;
    peak_to_cap_ratio = 0.7;
    dc_real_cap = peak_to_cap_ratio*dc_cap;
    dc_ratio = 1;
    %P_IT = zeros(T,1);
    
    IP = 40e-6; % server 's idle power in MW
    PP = 200e-6; % server peak power in MW.
    
    IDLE_POWER = dc_cap*IP/PP;
    
    
    POWER_UNIT =  dc_cap/numLoadLevels;
    IDLE_POWER = round(IDLE_POWER/POWER_UNIT)*POWER_UNIT;
    %% UPS
    battery_types   = {'LA','LI','UC','FW','CAES'};
    ups_capacity_investment = 2000; % k$
    ups_energy_cost = [200 525 10000 5000 50]; % $/kWh
    %ups_cap     = 10/sampling_interval * dc_cap * ones(1,length(ups_energy_cost))./ups_energy_cost;
%     ups_cap     = 10/sampling_interval * dc_cap  * ones(1,length(ups_energy_cost))./ups_energy_cost;
    ups_cap     = ups_capacity_investment  * ones(1,length(ups_energy_cost))./ups_energy_cost; % MWh
    charge_rate = [10 5 1 1 4];
    power_investement = 100; %k$
    power_cost  = [125 175 100  250 600]; % $/kW
    %charging_power    = power_investement*ones(1, length(charge_rate))./power_cost; % MW
%     r_charge = charging_power./ups_cap;
%     r_discharge = charge_rate.*r_charge;
    discharging_power = dc_cap*ones(1, length(charge_rate));
    r_discharge = discharging_power./ups_cap;
    r_charge = r_discharge./charge_rate;
    
    DoD         = [0.8 0.8 1 1 1];
    eff_coff    = [0.75 0.85 0.95 0.95 0.68];
    ramp_time   = [0.001 0.001 0.001 0.001 600]/(sampling_interval*60);    
    energy_cost = [200 525 10000 5000  50];   % $/kWh
    life_cycle  = [2 5 1000 200 15] * 1000; % discharge times
    float_life  = [4 8 12 12 12]; % years
    N_cycles_per_T = life_cycle./(float_life*365); % number of discharges per day
    
    %% Generators
    generator_type       = {'Oil/Steam', 'Oil/CT', 'Coal/Steam', 'Nuclear', 'Gas CT'};
    ramp_time_generator  = [33 6.7 50 20 10.2]/sampling_interval; % minutes --> time slots
    gen_cap              = [inf inf inf inf inf];
    gen_power_cap        = [dc_cap dc_cap dc_cap dc_cap dc_cap];
    
    emission_cap         = [inf inf inf inf inf];
    emission_rate        = [443 443 443 443 443];
    
    % operational cost
    p_BG = 0.6;
    
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
    
    BN = 10; % average number of jobs per time slot.
    BM = 0.5; % power ratio of batch jobs vs. interactive workload.
    
    % generate the raw Batch jobs and a workload
    [A_bj, BS, S, E] = batch_job_generator(T,BN*T, 'Uniform',1,1, ...
        BM/(1-BM)*sum(mean(a)./au)/con); % generate batch jobs based on statistical properties
    % compute the weight matrix of violation frequency  
    b_flat = BS./sum(A_bj,2)*ones(1,T).*A_bj;
    P_IT = a + sum(b_flat,1)';
    dc_scale = peak_to_cap_ratio*(dc_cap-IDLE_POWER)/max(P_IT);
    a = a *dc_scale;
    BS = BS * dc_scale;  
    b_flat= BS./sum(A_bj,2)*ones(1,T).*A_bj;
    P_IT = a + sum(b_flat,1)';
    
    raw_dc_power = P_IT + IDLE_POWER;
    
%     BS_plus = repmat(PUEs, BN,1) .* BS;
    BS_plus = round(BS/POWER_UNIT)*POWER_UNIT;
    b_flat_plus = BS_plus./sum(A_bj,2)*ones(1,T).*A_bj;
   
    
%     a_plus = PUEs.*a;
    a_plus = round(a/POWER_UNIT)*POWER_UNIT;
    dc_power = a_plus+ sum(b_flat_plus,1)' + IDLE_POWER;   
    
    % switching cost
    p_SW = 0.4;
    
    %% cooling
    %  http://www.accuweather.com/en/us/new-york-ny/10007/hourly-weather-forecast/349727?hour=0
    hourly_temp = [42 41 39 38 36 35 34 34 35 38 42 44 45 46 47 47 46 45 42 40 39 39 38 36]; % in Fahrenheit
%     t_raw = 1:24;
%     t = 1:0.5:24+0.5
%     temp = interp1q(t_raw, hourly_temp, t);
    t_OA = ones(1,T)*mean(hourly_temp);
    cooling_power = raw_dc_power/PUE;
    
    % cooling risk cost
    p_CL = 0.3;
    
    %% Electricity grid

    %% DR programs  
    % load data traces
    % TOU: Time of Use pricing - http://cleantechnica.com/2011/12/27/time-of-day-pricing-in-texas/
    %http://www.businesswire.com/news/home/20111117005294/en/TXU-Energy-Offers-Deep-Nighttime-Discounts-Electricity
    night_rate = 0.05;%6.8e-2; 
    peak_rate = 21.9e-2;
    off_peak_rate = 0.06;%9.2e-2;
    p_TOU_trace = off_peak_rate*ones(1,24);

    for hr = 1:24
        if hr <= 6 || hr >= 22 % night hours
            p_TOU_trace(hr) = night_rate;
        elseif hr >= 13 && hr <= 18 % peak hours
            p_TOU_trace(hr) = peak_rate;
        end
    end
    
    % Normal DR %%%%%%%%%%
    p_DR  = ones(1,T);
    
    t_raw = linspace(0,T,24);
    t = linspace(0,T,T);
    p_TOU = interp1q(t_raw',p_TOU_trace',t');    
    
    p_RTP = ones(1,T);    
    
    % Emergency based DR %%%%%%%%%%    

    %% Save the prepared data 
    save([RESULT_PATH 'init_settings.mat']) 
else
    load([RESULT_PATH 'init_settings.mat']);
end