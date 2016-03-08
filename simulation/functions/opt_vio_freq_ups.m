function [violationFreq X] = opt_vio_freq_ups(W, loadLevels, ...
            POWER_UNIT, dc_power, ups_cap, r_charge, r_discharge, DoD, eff_coff , ramp_time,...
             isPlot)
    
    T  = size(W,2);
    L  = size(W,1);
    epsilon = POWER_UNIT; % acceptable errors
    
    
    %% Optimzie the violation frequency            
    cvx_begin 
        variable X(L,T) binary;
        variables E(T) R_e(T) D_e(T);
        minimize( sum(sum(W.*X)) );
        subject to
            sum(X,1)==ones(1,T); % load selection constraint.
            sum(loadLevels.*X,1)' == dc_power + R_e(1:T) - D_e(1:T);
            E >= (1-DoD)*ups_cap;
            E <= ups_cap;
            E(1)  ==  ups_cap + eff_coff*R_e(1) - D_e(1);
            E(2:T) == eff_coff*R_e(2:T) - D_e(2:T) + E(1:T-1);
            D_e(2:T)- D_e(1:T-1) <= ups_cap*r_discharge/ramp_time;  
            E(2:T)  - E(1:T-1) <= ups_cap  * r_charge;
            E(2:T)  - E(1:T-1) >= - ups_cap* r_discharge;
%            R_e.*D_e == 0;
    cvx_end   
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
    
    %% return results    
    violationFreq = sum(sum(W.*X));
end
