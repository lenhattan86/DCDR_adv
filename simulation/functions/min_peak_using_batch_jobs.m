function [dc_power, bj_after] = min_peak_using_batch_jobs( dc_cap, grid_load_data , a, BS, A_bj, PP, IP, T_sw, isPlot)
    % Scale the power consumption of data center corresponding to the
    % PV generation.    
    T  = length(a); 
    total_BN = size(BS,1); % total number of batch jobs.
    
    if isPlot
        figure; 
        b_flat = BS./sum(A_bj,2)*ones(1,T).*A_bj;
        plot(a + sum(b_flat,1)');
    end
    
    %% Optimzie the violation frequency            
    cvx_begin 
        variables peak_energy dc_power(T);
        variable b(total_BN,T);
        minimize peak_energy;
        subject to   
            dc_power == sum(b,1)' + a + (sum(b,1)' + a)*IP/(PP-IP);
            peak_energy >= dc_power + grid_load_data;
            b >= 0;
            sum(b,2) == BS;
            sum(A_bj.*b,2) == BS;
            dc_power(1) <= dc_cap/T_sw;
            dc_power(2:T)-dc_power(1:T-1) <= dc_cap/T_sw;
    cvx_end       
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end    
    %% return results
    bj_after = sum(A_bj.*b, 1) ;
    if isPlot
        hold on;        
        plot(sum(A_bj.*b, 1) + a');
    end
   
end

