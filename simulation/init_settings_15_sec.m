clear all; close all; clc;
cvx_solver Gurobi;
s_quiet = cvx_quiet(true);
s_pause = cvx_pause(false);
cvx_precision low;
% cvx_precision high;

addpath('lib/matpower4.1');
addpath('lib/matpower4.1/t');
addpath('functions');
addpath('testcases');

FIG_PATH = 'figs/';
RESULT_PATH = 'results/';
TRACE_PATH = 'traces/';

IS_OFFICIAL = true;

IS_TESTING_THE_GRID = false;

IS_GENERATE_DATA = 1;
IS_LOAD_VIOLATION_MATRIX = false;
verbose = false;

if IS_GENERATE_DATA
    %% common constants    
    sampling_interval = 0.25; % minutes.
    
    common_settings;
    %% Save the prepared data 
    
    save([RESULT_PATH 'init_settings.mat']) 
    % Test the grid setting
    if IS_TESTING_THE_GRID
        opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
        [W, loadLevels] =  comp_vio_wei(power_case, PVcapacity,...
            irrad_time, minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), ...
            dc_cap,...
            POWER_UNIT, ...  
            opt, dcBus, numBuses, pvBus, grid_load_data,loadBus, false);
        
        figure;
        plot(W');   
        
        violationFreq_default = computeViolationFrequency (power_case, PVcapacity, irrad_time,...
        minuteloadFeb2012(36001:sampling_interval:36000+T*sampling_interval), dc_power,  ...
        opt, dcBus, numBuses, pvBus, grid_load_data,loadBus, verbose)
    end
    
else
    load([RESULT_PATH 'init_settings.mat']);
end