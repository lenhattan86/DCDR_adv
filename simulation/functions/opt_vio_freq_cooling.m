function [ violationFreq, PUEs] = ...
    opt_vio_freq_cooling(W, loadLevels, P_IT, alpha, gamma, beta,...
                TempRange, cm);
    Temp_low = TempRange(1);
    Temp_high = TempRange(2);
    L = size(W,1);
    T = size(W,2);
    Q = beta*P_IT;
    %% Optimzie the violation frequency                
    cvx_begin 
        variable X(L,T) binary;
        variable Q_r(T); % removed heat
        variable Temp_dc(T); % data center temperature
        variable P_cooling(T);
        minimize( sum(sum(W.*X)));
        subject to
%             P_cooling == alpha*pow_pos(Q_r,3) + gamma*Q_r; % compute the cooling power consumption  
            P_cooling == gamma*Q_r;
            Q_r >= 0;
%             sum(sum(loadLevels.*X)) == sum(P_IT) + P_cooling;               
            sum(X,1) == ones(1,T); % load selection constraint  
            Temp_dc >= Temp_low;
            Temp_dc <= Temp_high;            
%             Temp_dc(2:T) == Temp_dc(1:T-1) + (Q(2:T)-Q_r(2:T))/cm;
            Temp_dc(1) == (Temp_low+Temp_high)/2;
            Q_r(1) == Q(1);
    cvx_end   
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
    
    violationFreq = sum(sum(W.*X));
    PUEs = (P_cooling+P_IT)./P_IT;
end