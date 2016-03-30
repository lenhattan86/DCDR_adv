function [dc_power_after, energy_storage_power] = min_peak_shaving_ups(dc_power, ...
         ups_cap, r_charge, r_discharge, ...
         DoD, eff_coff, ramp_time, N_cycles_per_T)
    
    T  = length(dc_power);
    life_cycle_rate = 1;
    P_D_e = life_cycle_rate*N_cycles_per_T * DoD *ups_cap;
    %% Optimzie the violation frequency      
    E_0 = ups_cap/2;
    %X_e_lower_bound = max(- ups_cap* r_discharge, - ups_cap* r_discharge/ramp_time);
    X_e_lower_bound = - ups_cap* r_discharge;
    discharge_speed_bound = ups_cap* r_discharge/ramp_time;
    cvx_begin 
        variables E(T) X_e(T); 
        variable dc_power_after(T);
        variable peak_power;
        minimize( peak_power);
        subject to
            peak_power >= dc_power_after;
            dc_power_after == dc_power + X_e;
            X_e  <= ups_cap  * r_charge;
            X_e  >= X_e_lower_bound;
            if discharge_speed_bound < -X_e_lower_bound
                -X_e(2:T) - (-X_e(1:T-1)) <= discharge_speed_bound; % TODO: need to be corrected!!
            end
            E >= (1-DoD)*ups_cap;
            E <= ups_cap;
            E(1)   == E_0 + eff_coff*X_e(1);
            E(2:T) == eff_coff*(X_e(2:T)) +  E(1:T-1);
            E(T)   == E_0;
            sum(pos(-X_e)) <= P_D_e; % life-time
    cvx_end
     
    if ~strcmp(cvx_status,'Solved');
        cvx_status        
        error('cannot solve CVX problem');
    end
    
    energy_storage_power =  X_e;
end
