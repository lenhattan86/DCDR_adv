function [violationFreq] = ...
    nonviolation_workload(pwr_case, pv_cap, irrad_time,...
    pct_load, dc_power, dc_ratio, dc_cap, ...
    A_bj, BS, a, ...
    options, dcBus, numBuses, pvBus, verbose)

    % Scale the power consumption of data center corresponding to the
    % PV generation.    
    T  = length(dc_power);
    dc_rate = 0.8*dc_cap/max(dc_power);%mean(irrad_time/1000*pv_cap)*dc_ratio/mean(dc_power);
    dc_pwr  = dc_power*dc_rate;
    a = a*dc_rate;
    BS = BS * dc_rate;
    
    BN = size(BS,1); % total number of batch jobs.
    
    %% Step 1: Get the matrix of violation frequency weights W
    
    % Prepare the matrix of possible loads
    % Select n evenly distributed loads between the bounds of DC
            % Bounds of DC
    POWER_UNIT =  mean(BS);
            
            
    numLoads = floor(dc_cap/mean(POWER_UNIT));
    L = numLoads+1;
    
    upperBound = mean(BS)*numLoads;
    lowerBound = 0;
    
    loadIntervals = 0:1:numLoads;
    selectedLoadsForDC = ((upperBound - lowerBound)/numLoads).*loadIntervals + lowerBound;
    loadLevels = repmat(selectedLoadsForDC',1,T);
    

    W = zeros(numLoads, T);
    for i = 1:T
        temp_case = pwr_case;
        temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);

        pct_flux = irrad_time(i)/1000;
        pv_pwr = pct_flux*pv_cap; 

        % Set up PV and DC bus loads
        temp_case.bus(pvBus,3) = temp_case.bus(pvBus,3) - pv_pwr;

        maxVoltage = temp_case.bus(1,12);
        minVoltage = temp_case.bus(1,13);

        [results, success] = runpf(temp_case, options);
        if success == 0
            fprintf('Initial onvergence failure: PV_capacity = %d, time = %d\n',...
                pv_cap, i);
            error('Power consumption may be too high?');
            break;
        end

        if verbose
            disp('------------------------------------------------------')
            fprintf('Initial From Bus: \n')
            disp(results.branch(:,14))
            fprintf('Initial To Bus: \n')
            disp(results.branch(:,16))
            fprintf('Initial Voltages: \n')
            disp(results.bus(:,8))
            fprintf('Initial Demand: \n')
            disp(results.bus(:,3))
        end        

        violations = zeros(1,length(selectedLoadsForDC));
        previousLoad = 0;
        for idx = 1:length(selectedLoadsForDC)
            temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) - previousLoad;
            temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) + selectedLoadsForDC(idx);

            [newResults, success] = runpf(temp_case, options);
            if success == 0
                fprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
                    pv_cap, i);
                % Set a place holder. This can never be the number of
                % violations, so it is ignored.
                violations(idx) = numBuses + 1;
                previousLoad = selectedLoadsForDC(idx);
                continue;
            end

            if verbose
                disp('------------------------------------------------------')
                fprintf('From Bus: \n')
                disp(newResults.branch(:,14))
                fprintf('To Bus: \n')
                disp(newResults.branch(:,16))
                fprintf('Voltages: \n')
                disp(newResults.bus(:,8))
                fprintf('Demand: \n')
                disp(newResults.bus(:,3))
            end

            violatedBuses = findViolated(newResults.bus(:,8), maxVoltage, minVoltage);
            W(idx, i) = length(violatedBuses);
            previousLoad = selectedLoadsForDC(idx);            
        end
    end
    
    %% Step 2: Optimzie the violation frequency    

    cvx_begin
        variable X(L,T) binary;
        variable bColo(BN,T);
        minimize( sum(sum(W.*X)) );
        subject to
            sum(X)==ones(1,T); % load selection constraint.
            sum(sum(loadLevels.*X)) <= sum(dc_pwr) + POWER_UNIT/2; % total power constraint.  
            sum(sum(loadLevels.*X)) >= sum(dc_pwr) - POWER_UNIT/2; % total power constraint.  
            sum(A_bj.*bColo, 1) + a' >= sum(loadLevels.*X,1); % mapping colocating power with load levels
            sum(bColo,2) == BS; % batchjob colocation constraint     
            bColo(BN,T) >=0;
    cvx_end   
    total_power_err = sum(sum(loadLevels.*X)) - sum(dc_pwr);
    bj_err = sum(A_bj.*bColo, 1) + a' - sum(loadLevels.*X,1);
    
    %% step 3: return results
    violationFreq = sum(sum(W.*X))/(T*numBuses);