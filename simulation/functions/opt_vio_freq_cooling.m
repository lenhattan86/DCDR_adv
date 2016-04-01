function [ violationFreq, P_IT, P_cooling, PUEs, Temp_dc] = ...
    opt_vio_freq_cooling(W, loadLevels, dc_power, PUE, beta,...
                TempRange, cm, POWER_UNIT)

%     save('temp/opt_vio_freq_cooling');
    %% main code     
    Temp_low = TempRange(1);
    Temp_high = TempRange(2);   
    P_IT = dc_power/PUE;
    L = size(W,1);
    T = size(W,2);
    Q = beta*P_IT;
    temp_init = (Temp_low+Temp_high)/2;
%     save('temp/temp');
    accuracy = 0.5;
    %% Optimzie the violation frequency                
    cvx_begin 
        variable X(L,T) binary;
        variable Q_r(T); % removed heat
        variable Temp_dc(T); % data center temperature
%         variable P_cooling(T);
        minimize( sum(sum(W.*X)));
        subject to
            P_cooling = (PUE-1)*Q_r/beta;
            Q_r >= 0;
%             sum(loadLevels.*X)' == P_IT + P_cooling;
            sum(loadLevels.*X)' <= P_IT + P_cooling + accuracy*POWER_UNIT;
            sum(loadLevels.*X)' >= P_IT + P_cooling - accuracy*POWER_UNIT;
            sum(X,1) == ones(1,T); % load selection constraint  
            Temp_dc >= Temp_low;
            Temp_dc <= Temp_high;            
            Temp_dc(2:T) == Temp_dc(1:T-1) + (Q(2:T)-Q_r(2:T))/cm;
            Temp_dc(1) == temp_init + (Q(1)-Q_r(1))/cm;            
    cvx_end   
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        disp('suggestion: increase accuracy!');
        error('cannot solve CVX problem');        
    end
    
    violationFreq = sum(sum(W.*X))
    PUEs = (P_cooling+P_IT)/P_IT;
end