%% This script is to evaluate the impact of flexiblity of interactive workload on the grid.
% The idea is, we can reduce the power consumption of data center by
% relaxing the ending time of batch jobs.

% Discription: Given flexibility of batch jobs, we need to evaluate the
% impact on reliability of the electricity grid.

init_settings
%% Simulation

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis
%% Main inputs
bjDelay = 1*HOUR; % hours
% todo: generate the batch jobs based on number of batch jobs
% batch job
BN = 1; % average number of batch job arrivals per timeslot
BM = 0.25; % batch job ratio, compared with interactive workload
au = 0.4; % average utilization of interactive workloads
con = 0.9; % maximum utilization after consolidation


% create the matrix of 

%% Grid settings
power_case = case47custom;
numBuses = 47;
% DCcapacities = 23.47;
% DCcapacities = [7.8,8,10,12,14,16,18,20,22,24,26,28];
% DCcapacities = [70,80,90,95,100,105,110,115,120,125];
% DCcapacities = 118.8700;
DCcapacities = 20;
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

PVcapacity = 30;
violationFreq = zeros(length(dcBus), length(bjDelay));
busoutbounds = zeros(length(dcBus), length(bjDelay));
avg_cap = zeros(length(dcBus), length(bjDelay));

%% Run simulation.
for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    for c = 1:length(bjDelay)
        tic
        [A_SE,BS,S,E] = batch_job_generator(required_length,BN*required_length,'Uniform',bjDelay(c),bjDelay(c),'Uniform',1,1, ...
        BM/(1-BM)*sum(mean(interactive)./au)/con); % generate batch jobs based on statistical properties
        b_flat = BS./sum(A_SE,2)*ones(1,required_length).*A_SE;
        dc_power = PUE.*(interactive + sum(b_flat,2));
       
        [violationFreq(b,c)] =...
            nonviolationBatchjobs(power_case, PVcapacity,...
            Feb26Irrad, minuteloadFeb2012(36001:37440), ...
            repmat(dc_power,size(Feb2012Irrad,1)/length(dc_power),1),...
            dc_ratio, ...
            DCcapacities,...
            bjDelay(c), A_SE, BS, b_flat, interactive ,...
            opt,...
            dcBus(b),...
            numBuses,...
            pvBus,...
            false);
        toc
        fprintf('DC: bus %d \n Flex Value: %d \n Non-Viol Frac: %d \n Num Viol: %d \n Avg Cap: %d \n',...
            dcBus(b), bjDelay(c), violationFreq(b,c), busoutbounds(b,c), avg_cap(b,c));
    end
end

%% display results.
disp('Violation Fractions:');
disp(violationFreq)


optimal = 0.2344;
optimalBus = 0.3060;
plotDCsimulation(violationFreq(1,:), bjDelay(:), optimalBus, optimal, false);