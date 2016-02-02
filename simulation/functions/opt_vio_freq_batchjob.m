function [violationFreq X] = ...
    opt_vio_freq_batchjob(W, loadLevels, dc_power, a, BS, A_bj, POWER_UNIT, isPlot)

    % Scale the power consumption of data center corresponding to the
    % PV generation.    
    T  = length(dc_power);
    L = size(W,1);
    BN = size(BS,1); % total number of batch jobs.
    dc_pwr_cap = max(loadLevels);
    epsilon = POWER_UNIT/2; % acceptable errors
        
    %% Optimzie the violation frequency            
    cvx_begin 
        variable X(L,T) binary;
        variable bColo(BN,T);
        minimize( sum(sum(W.*X)) );
        subject to
            sum(X,1)==ones(1,T); % load selection constraint.
            sum(sum(loadLevels.*X))  <= sum(dc_power) + epsilon; % total power constraint.  
            sum(sum(loadLevels.*X))  >= sum(dc_power) - epsilon; % total power constraint.  
            bColo >= 0;
%             sum(A_bj.*bColo, 1) + a' <= dc_pwr_cap;
            sum(A_bj.*bColo, 1) + a' - sum(loadLevels.*X,1)  <= epsilon; % mapping colocating power with load levels
            sum(A_bj.*bColo, 1) + a' - sum(loadLevels.*X,1)  >= -epsilon;
            sum(bColo,2) - BS <= epsilon; % batchjob colocation constraint    
            sum(bColo,2) - BS >= -epsilon;
            sum(A_bj.*bColo,2) - BS <= epsilon; % batchjob colocation constraint            
            sum(A_bj.*bColo,2) - BS >= -epsilon;
    cvx_end   
    total_power_err = sum(sum(loadLevels.*X)) - sum(dc_power);
    bj_err = sum(A_bj.*bColo, 1) + a' - sum(loadLevels.*X,1);
    
    if ~strcmp(cvx_status,'Solved');
        cvx_status
        error('cannot solve CVX problem');
    end
    
    %% return results
    violationFreq = sum(sum(W.*X));
    load_prof = [a';sum(A_bj.*bColo, 1)]';
    
    if isPlot
        figure
        bar(load_prof,'stacked');  
    end    
end
