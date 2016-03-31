function [dc_power, P_cooling] = min_peak_shaving_cooling(grid_load_data, P_IT, ...
            alpha, gamma, beta, TempRange, cm)
    
    Temp_low = TempRange(1);
    Temp_high = TempRange(2);   
    T = length(P_IT);
    Q = beta*P_IT;
    temp_init = (Temp_low+Temp_high)/2;
    save('temp/test_code.mat');
    %% Optimzie the violation frequency                
    cvx_begin 
        variable Q_r(T); % removed heat
        variable Temp_dc(T); % data center temperature
        variable P_cooling(T);
        variable peak_power;
        variable dc_power(T);
        minimize peak_power;
        subject to
            peak_power >= dc_power + grid_load_data;
            dc_power == P_IT + P_cooling;
            P_cooling == gamma*Q_r;
            Q_r >= 0;
            Temp_dc >= Temp_low;
            Temp_dc <= Temp_high;            
            Temp_dc(2:T) == Temp_dc(1:T-1) + (Q(2:T)-Q_r(2:T))/cm;
            Temp_dc(1) == temp_init + (Q(1)-Q_r(1))/cm;            
    cvx_end   
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
end