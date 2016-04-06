function [violationFreq, X, G] = opt_vio_freq_gen(W, loadLevels, ...
             dc_power, gen_power_cap, ramp_time_generator, ...
             isPlot)    
    T  = size(W,2);
    L  = size(W,1);
    ramp_rate = gen_power_cap/ramp_time_generator;
    %% Optimize the violation frequency      
    cvx_begin 
        variable X(L,T) binary;
        variables G(T); 
        minimize( sum(sum(W.*X)) );
        subject to
            sum(X,1)==ones(1,T); % load selection constraint.
            sum(loadLevels.*X,1)' == dc_power - G;
            G  <= gen_power_cap;
            G  >= 0;
            G(1) <= ramp_rate;
            G(2:T) - G(1:T-1)  <= ramp_rate;
    cvx_end
     
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
    
    
    %% return results     
    violationFreq = sum(sum(W.*X));
    
    if isPlot
        stairs(1:T,G);        
    end
end
