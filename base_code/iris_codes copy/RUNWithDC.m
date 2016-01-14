% test function nonviolationfraction

load testdayirrad.mat

% generate data center demand traces
interactive_raw = load('traces/SAPnew/sapTrace.tab');
col = 4; % column of the data loaded
time_interval = 5; % in minutes
required_length = 1440; % per minute data
t_raw = linspace(0,required_length,required_length/time_interval+1);
t = linspace(0,required_length,required_length+1);
inter_tmp = interp1q(t_raw',interactive_raw(1:required_length/time_interval+1,4),t');
interactive = inter_tmp(1:required_length);

batch_ratio = 1; % mean of batch / mean of interactive
% batch workload
num_batch = 2;
for i = 1:1:num_batch % batch workload demand, from model
    B(i) = batch_ratio*sum(interactive(1:required_length))/num_batch;
end
A = zeros(required_length, num_batch); % availability
S = [1,required_length/2+1]; % start time
E = [required_length/2,required_length]; % end time
D = 1; % total number of days
b_flat = zeros(required_length,num_batch);
for d = 1:1:D
    for n = 1:1:num_batch
        A((d-1)*24+S(n):(d-1)*24+E(n),n) = ones(E(n)-S(n)+1,1);
        b_flat(S(n)+(d-1)*24:E(n)+(d-1)*24,n) = B(n)/(E(n)-S(n)+1);
    end
end
PUE_orig = [1.16,1.17,1.16,1.20,1.22,1.22,1.24,1.26,1.35,1.32,1.25,1.30,1.29,1.35,1.32,1.40,1.40,1.25,1.29,1.30,1.28,1.29,1.18,1.13]';
PUE = reshape((1+0.2*(rand(required_length/24,1)-0.5))*PUE_orig',required_length,1);
demand_flat = PUE.*(interactive + sum(b_flat,2));
dc_power = demand_flat;
dc_ratio = 1;
%dc_power = zeros(required_length,1);

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make changes here
power_case = case47custom;
numBuses = 47;
% DCcapacities = 23.47;
% DCcapacities = [7.8,8,10,12,14,16,18,20,22,24,26,28];
% DCcapacities = [70,80,90,95,100,105,110,115,120,125];
% DCcapacities = 118.8700;
DCcapacities = 20;
p = [0.5];
dcBus = 45;
pvBus = 45;

PVcapacity = 30;
violationFreq = zeros(length(dcBus), length(p));
busoutbounds = zeros(length(dcBus), length(p));
avg_cap = zeros(length(dcBus), length(p));


for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    for c = 1:length(p)
        tic
        [violationFreq(b,c), busoutbounds(b,c), avg_cap(b,c)] =...
            nonviolationfractiondc(power_case, PVcapacity,...
            Feb26Irrad, minuteloadFeb2012(36001:37440), ...
            repmat(dc_power,size(Feb2012Irrad,1)/length(dc_power),1),...
            dc_ratio, ...
            DCcapacities,...
            p(c),...
            opt,...
            dcBus(b),...
            numBuses,...
            pvBus,...
            false);
        toc
        fprintf('DC: bus %d \n Flex Value: %d \n Non-Viol Frac: %d \n Num Viol: %d \n Avg Cap: %d \n',...
            dcBus(b), p(c), violationFreq(b,c), busoutbounds(b,c), avg_cap(b,c));
    end
end

disp('Violation Fractions:');
disp(violationFreq)
disp('Number of Violations:');
disp(busoutbounds)
disp('Average DC flexbility range:');
disp(avg_cap)

optimal = 0.2395;
optimalBus = 0.2680;
plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);

