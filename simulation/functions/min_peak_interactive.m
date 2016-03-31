function [dc_power_after, a_after] = min_peak_interactive...
        ( grid_load_data , a,  aLowerBound, b_flat, PP, IP)
    T  = length(a); 
       
    %% Optimzie the violation frequency            
    cvx_begin 
        variable a_min(T);
        variable peak_energy_max;
        minimize peak_energy_max;
        subject to   
            peak_energy_max >= sum(b_flat,1)' + a_min + (sum(b_flat,1)' + a_min)*IP/(PP-IP) + grid_load_data;
            a_min >= aLowerBound';            
    cvx_end       
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end    
    
    cvx_begin 
        variables peak_energy dc_power_after(T);
        variable a_after(T);
        maximize sum(a_after);
        subject to   
            dc_power_after == sum(b_flat,1)' + a_after + (sum(b_flat,1)' + a_after)*IP/(PP-IP);
            peak_energy >= dc_power_after + grid_load_data;
            peak_energy <= peak_energy_max;
            a_after >= a_min;
            a_after <= a;
        cvx_end
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end    
    %% return results

end