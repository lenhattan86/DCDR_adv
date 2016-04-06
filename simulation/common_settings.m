
time_interval = 5; % in minutes
HOUR = 60/sampling_interval; % number of timeslots an hour.
MINUTE = 1/sampling_interval;
DAY = 24*HOUR; % number of timeslots a day.
T = 1*DAY; %1440; % per minute data
% T = 2*HOUR; % 

numLoadLevels = 50;
% numLoadLevels = 100;
% numLoadLevels = 200;

MWh = sampling_interval/HOUR; % energy a sampling interval.


%% Grid settings
power_case = case47custom; dcBus = 5; pvBus = 45; loadBus = 20;
%     power_case = case47custom; dcBus = 2; pvBus = 2; loadBus = 2;
%     power_case = case57; dcBus = 4; pvBus = 11; loadBus = 40;
numBuses = size(power_case.bus,1);

%% PV generation
load([TRACE_PATH 'testdayirrad.mat']);
PVcapacity = 60;
%     PVcapacity = 0;
day = 6;
irrad_time = Feb2012Irrad(1+day*1440:sampling_interval:T*sampling_interval+day*1440);
pct_flux = irrad_time/1000;
pv_pwr = pct_flux*PVcapacity; 

%% load demand in the electricity grid.
IS_GRID_LOAD = true;

load_mean = 5; % MW

[Hour_End,COAST,EAST,FAR_WEST,NORTH,NORTH_C,SOUTHERN,SOUTH_C,WEST,ERCOT] ...
    = import_grid_load('traces/ecort_load_2016.xls');    

if isscalar(loadBus)
    t_raw = linspace(0,T,24);
    t = linspace(0,T,T);
    i_day = 10;
    temp = interp1q(t_raw',ERCOT((i_day-1)*24+1:i_day*24),t');
%         plot(temp); ylim([0 max(temp)]);
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

ON_OFF =  true;
MAX_IDLE_POWER = dc_cap*IP/PP;


POWER_UNIT =  dc_cap/numLoadLevels;
MAX_IDLE_POWER = round(MAX_IDLE_POWER/POWER_UNIT)*POWER_UNIT;
%% UPS
battery_types   = {'LA','LI','UC','FW','CAES'};    
ups_capacity_investment = [500:500:2500]; % k$
len_investment = length(ups_capacity_investment);
ups_energy_cost = [200 525 10000 5000 50]; % $/kWh
%ups_cap     = 10/sampling_interval * dc_cap * ones(1,length(ups_energy_cost))./ups_energy_cost;
%     ups_cap     = 10/sampling_interval * dc_cap  * ones(1,length(ups_energy_cost))./ups_energy_cost;
ups_cap = zeros(len_investment, length(battery_types));
for i=1:len_investment
    ups_cap(i,:)     = ups_capacity_investment(i)  * ones(1,length(ups_energy_cost))./ups_energy_cost; % MWh
end

charge_rate = [10 5 1 1 4];
power_investement = 100; %k$
power_cost  = [125 175 100  250 600]; % $/kW
%charging_power    = power_investement*ones(1, length(charge_rate))./power_cost; % MW
%     r_charge = charging_power./ups_cap;
%     r_discharge = charge_rate.*r_charge;
discharging_power = dc_cap*ones(len_investment, length(charge_rate));
r_discharge = discharging_power./ups_cap;
r_charge = r_discharge./(ones(len_investment,1)*charge_rate);

DoD         = [0.8 0.8 1 1 1];
eff_coff    = [0.75 0.85 0.95 0.95 0.68];
ramp_time   = [0.001 0.001 0.001 0.001 600]/(sampling_interval*60);    
energy_cost = [200 525 10000 5000  50];   % $/kWh
life_cycle  = [2 5 1000 200 15] * 1000; % discharge times
float_life  = [4 8 12 12 12]; % years
N_cycles_per_T = life_cycle./(float_life*365); % number of discharges per day

%% Generators
is_backup = true;
if ~is_backup
    generator_type       = {'Oil/Steam', 'Oil/CT', 'Coal/Steam', 'Nuclear', 'Gas CT'};
    ramp_time_generator  = [33 6.7 50 20 10.2]/sampling_interval; % minutes --> time slots
    gen_cap              = [inf inf inf inf inf];
    gen_power_cap        = dc_cap;

    emission_cap         = [inf inf inf inf inf];
    emission_rate        = [443 443 443 443 443];

    gen_budget           = 1000*[1 1 1 1 1]; % M$/MW
    gen_price            = [10 20 25 100 8]*1e-3; % $/kWh -> $/MW

    % operational cost
    OM_cost = 0.6;
    capital_cost = 0;
else
    generator_type       = {'Diesel', 'D. DPF', 'Gas', 'Gas Micro.'};
%     ramp_time_generator  = [1.5 1.5 1.5 1.5] /sampling_interval; % minutes --> time slots
    ramp_time_generator  = [1:15:46, 47:2:55] /sampling_interval; % minutes --> time slots
    gen_cap              = [inf inf inf inf inf];
    gen_power_cap        = dc_cap;

    emission_cap         = [inf inf inf inf inf];
    NOx             = [8.1 8.1 5.8 0.3];
    CO              = [2.3 2.3 1.7 0.4];
    HC              = [0.9 0.9 0.8 0.1];
    PM              = [0.5 0.03 0.03 0.03];
    SO2             = [2.3 0.01 0 0];
    
    gen_budget      = 0:500:5000; % $
%     gen_price       = [16 20 18 22]/100/HOUR*1000;%($kWh --> $/MW-interval)
    gen_price       = 16*ones(1,length(gen_budget))/100/HOUR*1000;%($kWh --> $/MW-interval)
    
end

%% workload power with necessasy cooling power
% generate data center demand traces
interactive_raw = load('traces/SAPnew/sapTrace.tab');
col = 4; % column of the data loaded

t_raw = linspace(0,T,T/time_interval+1);
t = linspace(0,T,T+1);
inter_tmp = interp1q(t_raw',interactive_raw(1:T*sampling_interval/time_interval+1,4),t');
a = inter_tmp(1:T); % interactive workload   

au = 0.4; % average utilization of a workloads
con = 0.9; % maximum utilization after consolidation

%     BN = 10; % average number of jobs per time slot.
BN = 5; % average number of jobs per time slot.
BM = 0.5; % power ratio of batch jobs vs. interactive workload.

% generate the raw Batch jobs and a workload
[A_bj, BS, S, E] = batch_job_generator(T,BN*T, 'Uniform',1,1, ...
    BM/(1-BM)*sum(mean(a)./au)/con); % generate batch jobs based on statistical properties    
% compute the weight matrix of violation frequency      
b_flat = BS./sum(A_bj,2)*ones(1,T).*A_bj;
P_IT_plus = a + sum(b_flat,1)';
dc_scale = peak_to_cap_ratio*(dc_cap-MAX_IDLE_POWER)/max(P_IT_plus);
a = a *dc_scale;
BS = BS * dc_scale;  
b_flat= BS./sum(A_bj,2)*ones(1,T).*A_bj;
P_IT_plus = a + sum(b_flat,1)';    
if ON_OFF
    IDLE_POWER = P_IT_plus*IP/(PP-IP);
    raw_dc_power = P_IT_plus + IDLE_POWER;
else
    raw_dc_power = P_IT_plus + MAX_IDLE_POWER;
    IDLE_POWER = MAX_IDLE_POWER;
end

%     BS_plus = repmat(PUEs, BN,1) .* BS;
BS_plus = round(BS/POWER_UNIT)*POWER_UNIT;
b_flat_plus = BS_plus./sum(A_bj,2)*ones(1,T).*A_bj;

%     a_plus = PUEs.*a;
a_plus = round(a/POWER_UNIT)*POWER_UNIT;
dc_power = a_plus+ sum(b_flat_plus,1)' + IDLE_POWER;   

% switching cost
p_SW = 0.4;

% interactive & QoS
util_level = 0.3; 
mu = 1;

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

t_differences = 0:2:10; % acceptable temperature.
t_RA_avg = 70;
% compute power cooling acceptable power range
% P_cooling = gamma/(tRA - tOA)*a.^3;
%     a_avg = mean(a);
%     P_cooling = (mean(PUE)-1) * a_avg;
%     cooling_ratio = 0.5;
%     P_oac = cooling_ratio*P_cooling;
%     P_wc = (1-cooling_ratio)* P_cooling;
%     temp_power_oac = 1.5;
%     temp_power_wc = 1.1;
% outside air cooler
%     alpha = P_oac*((t_RA_avg - mean(t_OA))^temp_power_oac)/(a_avg^3); % P_oac = alpha/((t_RA - t_OA)^temp_power) * d^3
% water chiller
%gamma = P_wc *(t_RA_avg^temp_power_wc)/(a_avg); % P_wc  = gamma/(t_RA^temp_power) * d
gamma = PUE-1;
beta = 1;
cm = 2*(sampling_interval/15);

%% Electricity grid
total_load = dc_power +grid_load_data;
%% Prediction errors
ERR = 0.05;

dc_load_errs = randn(T,1)*ERR*mean(dc_power);
BS_errs = randn(length(BS),1)*ERR*mean(BS);
a_errs = randn(T,1)*ERR*mean(a);
grid_load_data_errs = randn(T,1)*ERR*mean(grid_load_data);

dc_power_pred = max(dc_power + dc_load_errs,0);
BS_pred = max(BS+BS_errs,0);
a_pred = max(a + a_errs,0);
grid_load_data_pred = max(grid_load_data_errs+grid_load_data,0);

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