function [violationFreq, X, X_e] = opt_vio_freq_ups(W, loadLevels, ...
            POWER_UNIT, dc_power, ups_cap, r_charge, r_discharge, DoD, eff_coff ...
            , ramp_time, N_cycles_per_T, HOUR,...
             isPlot)
    
    T  = size(W,2);
    L  = size(W,1);
    life_cycle_rate = 1;
    ups_cap = ups_cap*HOUR; % normalize the energy unit
    P_D_e = life_cycle_rate*N_cycles_per_T * DoD *ups_cap;
    epsilon = POWER_UNIT/2;
    %% Optimzie the violation frequency      
    E_0 = ups_cap/2;
    %X_e_lower_bound = max(- ups_cap* r_discharge, - ups_cap* r_discharge/ramp_time);
    X_e_lower_bound = - ups_cap* r_discharge;
    discharge_speed_bound = ups_cap* r_discharge/ramp_time;
    cvx_begin 
        variable X(L,T) binary;
        variables E(T) X_e(T); % X_e = R_e - D_e
        minimize( sum(sum(W.*X)) );
        subject to
            sum(X,1)==ones(1,T); % load selection constraint.
%             sum(loadLevels.*X,1)' == dc_power + X_e;
            sum(loadLevels.*X,1)' <= dc_power + X_e + epsilon;
            sum(loadLevels.*X,1)' >= dc_power + X_e - epsilon;
            X_e  <= ups_cap  * r_charge;
            X_e  >= X_e_lower_bound;
            if discharge_speed_bound < -X_e_lower_bound
                -X_e(2:T) - (-X_e(1:T-1)) <= discharge_speed_bound; % TODO: need to be corrected!!
            end
            E >= (1-DoD)*ups_cap;
            E <= ups_cap;
            E(1)   == E_0 + eff_coff*(X_e(1));
            E(2:T) == eff_coff*(X_e(2:T)) + E(1:T-1);
            E(T)   == E_0;
            sum(pos(-X_e)) <= P_D_e; % life-time
    cvx_end
     
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        disp('Suggestion: life-time constraint is violated');
        error('cannot solve CVX problem');
    end
    
    %% return results    
    violationFreq = sum(sum(W.*X));
    R_e = pos(X_e);
    D_e = pos(-X_e);
    if isPlot
        figure
%         stairs(1:T, R_e);
%         hold on;
%         stairs(1:T, D_e);
        stairs(1:T, X_e);
%         legend('Discharge','Charge');
    end
end
