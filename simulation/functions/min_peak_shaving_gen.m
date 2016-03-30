function [dc_power_after, G]  = min_peak_shaving_gen(dc_power, gen_power_cap, ramp_time_generator)
    T  = length(dc_power);
    ramp_rate = gen_power_cap/ramp_time_generator;
    %% Optimize the violation frequency      
    cvx_begin 
        variables G(T); 
        variables dc_power_after(T) peak_power;
        minimize(peak_power);
        subject to     
            peak_power >= dc_power_after;
            dc_power_after == dc_power - G;
            dc_power_after >= 0;
            G  <= gen_power_cap;
            G  >= 0;
            G(1) <= gen_power_cap/ramp_time_generator;
            G(2:T) - G(1:T-1)  <= gen_power_cap/ramp_time_generator;
    cvx_end
     
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end   
end
