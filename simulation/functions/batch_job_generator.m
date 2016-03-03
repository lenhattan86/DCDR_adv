function [A_bj,BS,S,E] = batch_job_generator(T,BN,O1,A1,B1,BM)
% A_bj matrix of [S,E]
% BS is power for each job
S = ceil(sort(random('Uniform',1,T-1,BN,1)));
BS_raw = ones(BN,1); % BN jobs
E = S + ceil(random(O1,A1,B1));
A_bj = zeros(BN, T);
for i = 1:1:BN
    if E(i) > T
        A_bj(i,S(i):T) = ones(1,T-S(i)+1);
        A_bj(i,1:E(i)-T) = ones(1,E(i)-T);
    else
        A_bj(i,S(i):E(i)) = ones(1,E(i)-S(i)+1);
    end    
end

BS = BS_raw/(mean(BS_raw))*BM*T/BN; % convert to total power consumption of each batch job.
