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
dc_ratio = 1;
plot(dc_power, '-r');
xlabel('Time');
ylabel('DC Power');
