function [violationFreq, out_bounds, avg_cap] = nonviolationfractiondc(pwr_case, pv_cap, irrad_time,...
    pct_load, dc_power, dc_ratio, dc_cap, p, options, dcBus, numBuses, pvBus, verbose)

numLoads = 10;

out_bounds = 0;
tsteps = length(irrad_time);
dc_pwr = dc_power/mean(dc_power)*mean(irrad_time/1000*pv_cap)*dc_ratio;

total_ranges = 0;

for i = 1:tsteps
    temp_case = pwr_case;
    temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);
    
    pct_flux = irrad_time(i)/1000;
    pv_pwr = pct_flux*pv_cap; 
    
    % Set up PV and DC bus loads
    temp_case.bus(pvBus,3) = temp_case.bus(pvBus,3) - pv_pwr;
    
    % Bounds of DC
    upperBound = min((1+p)*dc_pwr(i), dc_cap);
    lowerBound = (1-p)*dc_pwr(i);

    maxVoltage = temp_case.bus(1,12);
    minVoltage = temp_case.bus(1,13);
    
    [results, success] = runpf(temp_case, options);
    if success == 0
        fprintf('Initial onvergence failure: PV_capacity = %d, time = %d\n',...
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

    % Select n evenly distributed loads between the bounds of DC
    if upperBound < lowerBound
        % Never happens...
        disp('Upper bound less than lower bound.');
        selectedLoadsForDC = dc_pwr(i);
    else
        loadIntervals = 0:1:numLoads;
        selectedLoadsForDC = ((upperBound - lowerBound)/numLoads).*loadIntervals + lowerBound;
        total_ranges = total_ranges + (upperBound - lowerBound);
    end
    
    if p ~= 0
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
            violations(idx) = length(violatedBuses);
            previousLoad = selectedLoadsForDC(idx);
        end
    else
        temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) + dc_pwr(i);
        [newResults, success] = runpf(temp_case, options);
        
        violatedBuses = findViolated(newResults.bus(:,8), maxVoltage, minVoltage);
        violations = length(violatedBuses);
    end

    smallestViolations = min(violations);
    out_bounds = out_bounds + smallestViolations;
end

    violationFreq = out_bounds / (tsteps*numBuses);
    avg_cap = total_ranges / tsteps;
end
