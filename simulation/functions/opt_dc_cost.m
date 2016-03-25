function [a, b, X_e, G] = opt_dc_cost(p_DR, dc_power, a, BS, A_bj)

cvx_begin
variables b(T) X_e(T) G(T)
minimize sum( p_DR.*( sum(A_bj.*b, 1) + a' + X_e - G(T) ) +  )
subject to
    
cvx_end

if strcmp(cvx_status, 'Solved') == 0
    cvx_status
    error('Increase given capacities');
end

end