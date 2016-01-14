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
demand_flat = interactive + sum(b_flat,2);
dc_power = demand_flat;

power_case = case56customv2;

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

capacities = linspace(0, 1, 51);
businbounds = zeros(length(capacities),1);
violation_log10 = zeros(length(capacities),1);

for k = 1:length(capacities)
    tic
    [businbounds(k), v_pv] = nonviolationfraction(power_case, capacities(k),...
        Feb2012Irrad, minuteloadFeb2012, dc_power, opt); % All of Feb 2012
%     [businbounds(k), v_pv] = nonviolationfraction(power_case, capacities(k),...
%         Feb26Irrad, minuteloadFeb2012(36001:37440), opt); % Feb 26, 2013
    toc

    violation_log10(k) = log10(1-businbounds(k));
    if k == 1
        v_nopv = v_pv;
    end
    
    if k == length(capacities)
        figure()
        hold on
        plot(timeofday(:,2),10^4*(v_pv(1:1440)-v_nopv(1:1440)),'k-')
        plot(timeofday(:,2),Feb2012Irrad(1:1440),'r-')
        legend('\Delta V_P_V/10^-^4', 'Irradiance')
        hold off
    end
    
end

figure()
hold on
plot(capacities(:),businbounds(:), 'ro')
plot(capacities(:),violation_log10(:), 'bs')
axis([0 max(capacities) -4 1.05])
hold off

