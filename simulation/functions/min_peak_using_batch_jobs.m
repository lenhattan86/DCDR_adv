function [dc_power, bj_after] = min_peak_using_batch_jobs( a, BS, A_bj, isPlot)
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
            dc_power == sum(b,1)' + a;
%             dc_power <= dc_cap;
            peak_energy >= dc_power;
            b >= 0;
            sum(b,2) == BS;
            sum(A_bj.*b,2) == BS;
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

