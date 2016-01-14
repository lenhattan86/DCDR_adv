function [violationFraction, out_bounds, storage_level] = nonviolationfraction(pwr_case, pv_cap, irrad_time,...
    pct_load, options, storageCap, storageBus, initial, numBuses, pvBus, withStorage, verbose)

numUsages = 10;

out_bounds = 0;
tsteps = length(irrad_time);

currentStorageLoad = storageCap*initial;
specialViolations = 0;

ramp_rate = 0.2;

for i = 1:tsteps
%     fprintf('Iteration: %d\n', i);
%     fprintf('Current Number of Violations: %d\n', out_bounds);
    
    temp_case = pwr_case;
    temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);
    
    pct_flux = irrad_time(i)/1000;
    pv_pwr = pct_flux*pv_cap;
    

    temp_case.bus(pvBus(1),3) = temp_case.bus(pvBus(1),3) - pv_pwr;
    
    [results, success] = runpf(temp_case, options);
    if success == 0
        fprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
            pv_cap, i);
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
    
    v_hi = results.bus(1,12);
    v_lo = results.bus(1,13);
    
    initViolatedBuses = findViolated(results.bus(:,8), v_hi, v_lo); 
    if (length(initViolatedBuses) >= 1)
       specialViolations = specialViolations + 1; 
    end

    if withStorage
        upperBound = min(ramp_rate*storageCap, storageCap - currentStorageLoad);
        lowerBound = max(-ramp_rate*storageCap, -currentStorageLoad);

        usageIntervals = 0:1:numUsages;
        selectedUsages = ((upperBound - lowerBound)/numUsages).*usageIntervals + lowerBound;
        violations = zeros(1, length(selectedUsages));

        previousUsage = 0;
        for idx = 1:length(selectedUsages)
            temp_case.bus(storageBus,3) = temp_case.bus(storageBus,3) - previousUsage;
            temp_case.bus(storageBus,3) = temp_case.bus(storageBus,3) + selectedUsages(idx);

            [newResults, success] = runpf(temp_case, options);
            if success == 0
                %fprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
                %    pv_cap, i);
                % Set a place holder. This can never be the number of
                % violations, so it is ignored.
                violations(idx) = numBuses + 1;
                previousUsage = selectedUsages(idx);
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

            initViolatedBuses = findViolated(newResults.bus(:,8), v_hi, v_lo); 
            violations(idx) = length(initViolatedBuses);
            previousUsage = selectedUsages(idx);
        end

        [smallestViolation, idx_smallestViolation] = min(violations);

        choosenUsage = selectedUsages(idx_smallestViolation);
        currentStorageLoad = currentStorageLoad + choosenUsage;
        storage_level(i) = currentStorageLoad;
        
        % L(t) must be in the range of 0 and C
        if (currentStorageLoad > storageCap)
            currentStorageLoad = storageCap;
            out_bounds = out_bounds + length(initViolatedBuses);
        elseif (currentStorageLoad < 0)
            currentStorageLoad = 0;
            out_bounds = out_bounds + length(initViolatedBuses);
        else
            out_bounds = out_bounds + smallestViolation;
        end
    else
        [results, success] = runpf(temp_case, options);
        if success == 0
            sprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
                    pv_cap, i);
            break;
        end

        out_bounds = out_bounds + length(findViolated(results.bus(:,8), v_hi, v_lo));
    end
end
%     fprintf('--------------> %d\n', specialViolations);
%     fprintf('--------------> %d\n', (tsteps - specialViolations)/tsteps);

    violationFraction = (out_bounds) / (tsteps*numBuses);
    tsteps
    numBuses
    out_bounds
    
end
