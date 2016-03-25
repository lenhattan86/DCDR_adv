function [ violationFreq, PUEs] = ...
    opt_vio_freq_cooling(W, loadLevels, P_IT, alpha, gamma, beta,...
                TempRange, cm, is_plot)


    %% test code
%     T_from = 1;
%     T_to = 4;
%     W = W(:,T_from:T_to);
%     P_IT = P_IT(T_from:T_to);
%     loadLevels = loadLevels(:,T_from:T_to);

    %% main code 
    Temp_low = TempRange(1);
    Temp_high = TempRange(2);   
    L = size(W,1);
    T = size(W,2);
    Q = beta*P_IT;
    temp_init = (Temp_low+Temp_high)/2;
%     save('temp/temp');
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
%             P_cooling >= gamma*Q_r;
%             P_cooling <= (gamma+0.3)*Q_r;
            Q_r >= 0;
            sum(loadLevels.*X)' == P_IT + P_cooling;
%             sum(sum(loadLevels.*X)) <= sum(P_IT) + P_cooling + epsilon* POWER_UNIT;               
%             sum(sum(loadLevels.*X)) >= sum(P_IT) + P_cooling - epsilon* POWER_UNIT;
            sum(X,1) == ones(1,T); % load selection constraint  
            Temp_dc >= Temp_low;
            Temp_dc <= Temp_high;            
            Temp_dc(2:T) == Temp_dc(1:T-1) + (Q(2:T)-Q_r(2:T))/cm;
            Temp_dc(1) == temp_init + (Q(1)-Q_r(1))/cm;            
    cvx_end   
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        disp('suggestion: increase cm!');
        error('cannot solve CVX problem');        
    end
    
    violationFreq = sum(sum(W.*X));
    PUEs = (P_cooling+P_IT)./P_IT;
    if is_plot
        figure;
        plot(P_IT);
        hold on; 
        plot(P_cooling);
    end
end