function [violationFreq, idle_power, a_power, b_power] = ...
    opt_vio_freq_batchjob(W, loadLevels, dc_power, a, BS, A_bj, POWER_UNIT, IDLE_POWER,IP,PP)
    
%     SCALE = 1;
%     loadLevels = round(loadLevels*SCALE);
%     dc_power = round(dc_power*SCALE);
%     a= round(a*SCALE);
%     BS = round(BS*SCALE);
%     POWER_UNIT = round(POWER_UNIT*SCALE);
    
    % Scale the power consumption of data center corresponding to the
    % PV generation.    
    T  = length(dc_power);
    L = size(W,1);
    total_BN = size(BS,1); % total number of batch jobs.
    dc_pwr_cap = max(loadLevels);
    epsilon = POWER_UNIT; % acceptable errors
    
    ON_OFF = true;
    
    
    %% Optimzie the violation frequency            
    cvx_begin 
        variable X(L,T) binary;
        variable b(total_BN,T);
        minimize( sum(sum(W.*X)) );
        subject to
            sum(X,1)==ones(1,T); % load selection constraint.
%             sum(sum(loadLevels.*X)) == sum(dc_power);
            b >= 0;
            if ON_OFF
%                 idle_power = (sum(A_bj.*b, 1) + a')*IP/PP;
                sum(A_bj.*b, 1) + a' + (sum(A_bj.*b, 1) + a')*IP/PP == sum(loadLevels.*X,1);
            else    
                sum(A_bj.*b, 1) + a' + IDLE_POWER == sum(loadLevels.*X,1);
            end
            sum(b,2) == BS;
            sum(A_bj.*b,2) == BS;
    cvx_end   
    total_power_err = sum(sum(loadLevels.*X)) - sum(dc_power);
    bj_err = sum(A_bj.*b, 1) + a' - sum(loadLevels.*X,1);
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
    if ON_OFF
        idle_power = (sum(A_bj.*b, 1) + a')*IP/PP;
    else    
       idle_power = IDLE_POWER;
    end
    %% return results
    a_power = a;
    b_power = sum(A_bj.*b, 1);    
    violationFreq = sum(sum(W.*X));
end
