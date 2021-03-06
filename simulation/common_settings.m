
time_interval = 5; % in minutes
HOUR = 60/sampling_interval; % number of timeslots an hour.
MINUTE = 1/sampling_interval;
DAY = 24*HOUR; % number of timeslots a day.
days = 1;
T = days*DAY; %1440; % per minute data
% T = 2*HOUR; % 

numLoadLevels = 50;
% numLoadLevels = 100;
% numLoadLevels = 200;

MWh = sampling_interval/HOUR; % energy a sampling in`````terval.

numOfTests = 100;

ISPV = true;

%% Grid settings
power_case = case47custom; dcBus = 10; pvBus = 45; loadBus = 0;
%     power_case = case47custom; dcBus = 2; pvBus = 2; loadBus = 2;
%     power_case = case57; dcBus = 4; pvBus = 11; loadBus = 40;
numBuses = size(power_case.bus,1);

%% PV generation
load([TRACE_PATH 'testdayirrad.mat']);
PVcapacity = 30;
%     PVcapacity = 0;
day = 3;
% day = 1;
% irrad_time = Feb2012Irrad(1+(day-1)*1440:sampling_interval:T*sampling_interval+(day-1)*1440);
irrad_time = Feb26Irrad;
pct_flux = irrad_time/1000;
pv_pwr = pct_flux*PVcapacity; 
pv_pwr_mean = mean(pv_pwr);

%% Todo:(for Jie) Allow us to switch from PV generator to a wind generator
% if ISPV
    

%% load demand in the electricity grid.
IS_GRID_LOAD = true;

pct_factors = minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval);
% bus_loads = zeros(numBuses, 2, T);
active_load = ones(numBuses, T) ;
reactive_load = ones(numBuses, T);
for t=1:T
    active_load(:,t) = power_case.bus(:,3)*pct_factors(t);
    reactive_load(:,t) = power_case.bus(:,4)*pct_factors(t);
    active_load_mean = mean(sum(active_load));
    reactive_load_mean = mean(sum(reactive_load));
end

load_mean = 15; % MW

if ismac
    [Hour_End,COAST,EAST,FAR_WEST,NORTH,NORTH_C,SOUTHERN,SOUTH_C,WEST,ERCOT] ...
    = import_grid_load_mac('traces/ecort_load_2016.xls'); 
elseif ispc
    [Hour_End,COAST,EAST,FAR_WEST,NORTH,NORTH_C,SOUTHERN,SOUTH_C,WEST,ERCOT] ...
    = import_grid_load('traces/ecort_load_2016.xls');
end

if loadBus == 0
    grid_load_data = sum(active_load,1)';
    load_mean = mean(grid_load_data)
elseif isscalar(loadBus)
    t_raw = linspace(0,T,24);
    t = linspace(0,T,T);
    i_day = 10;
    temp = interp1q(t_raw',ERCOT((i_day-1)*24+1:i_day*24),t');
%         plot(temp); ylim([0 max(temp)]);
    grid_load_data = temp*load_mean/mean(temp);
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
%% Todo:(for Jie) Adding a conventional generator
conv_power_level = 10; % MW
conv_power = conv_power_level*ones(1, T);
conv_power_bus = 5;



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
    generator_type       = {'Diesel', 'Die. DPF', 'Gas', 'Gas Micro.'};
    ramp_time_generator  = [1.5 1.5 1.5 1.5] /sampling_interval; % minutes --> time slots
%     ramp_time_generator  = [1:15:46, 47:2:55] /sampling_interval; % minutes --> time slots
    gen_cap              = [inf inf inf inf inf];
    gen_power_cap        = dc_cap;

    emission_cap         = [inf inf inf inf inf];
    NOx             = [8.1 8.1 5.8 0.3]; % g/kWh
    CO              = [2.3 2.3 1.7 0.4];
    HC              = [0.9 0.9 0.8 0.1];
    PM              = [0.5 0.03 0.03 0.03];
    SO2             = [2.3 0.01 0 0];
    
    gen_budget      = 200:200:5000; % $
    gen_price       = [16 20 18 22]/100*1000/HOUR;%(cents/kWh --> $/MWh)
    
end

%% workload power with necessasy cooling power
% generate data center demand traces
interactive_raw = load('traces/SAPnew/sapTrace.tab');
col = 4; % column of the data loaded

t_raw = linspace(0,T,T/time_interval+1);
t = linspace(0,T,T+1);
if sampling_interval <= time_interval
    inter_tmp = interp1q(t_raw',interactive_raw(1:T*sampling_interval/time_interval+1,4),t');
    a = inter_tmp(1:T); % interactive workload
else
    inter_tmp = interactive_raw(1:T*sampling_interval/time_interval,4);
    temp = reshape (inter_tmp, sampling_interval/time_interval, T);
    a = sum(temp)'; % interactive workload
end
 

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
dc_power_mean = mean(dc_power)

% switching cost
p_SW = 0.4;

% interactive & QoS
util_level = 0.4; 
mu = 1;

T_sw = 5/sampling_interval ;% mins.

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
beta = 0.9; % heat to IT power ratio /pi
cm = 2*(sampling_interval/15);

%% Electricity grid
total_load = dc_power +grid_load_data;
%% Prediction errors
ERR = 0.05;
%  ERR = 0;

gen_errors;

%% DR programs  
noti_ahead = 1*HOUR;
dr_noti_timestamps = 1;

T_schedule = 12*HOUR;

dr_timestamps = dr_noti_timestamps + noti_ahead;
t_dr_events     = zeros(1,T); % Timestamp of DR event
t_dr_events(dr_timestamps)  = 1; %

dr_frequency = 1;

T_duration = 1*HOUR;
durationsOfDR = zeros(1,T); % Duration of DR event
durations = dr_timestamps + 0:(T_duration-1);
durationsOfDR(durations) = 1;

%P_target = 0.1; % MW increase
% P_target = -0.1; % MW reduction
P_target = -0.01; % MW reduction

dr_rate = 0.5; % USD/kWh
dr_rates = dr_rate*ones(1,T); %