function [violationFreq] = nonviolation_cooling(pwr_case, pv_cap, irrad_time,...
    pct_load, workload_power, dc_cap, ...
    t_Range, t_OA, alpha, gamma, temp_power_oac, temp_power_wc,  ...
    options, dcBus, numBuses, pvBus, verbose)

    numLoads = 20;   
    out_bounds = 0;
    tsteps = length(irrad_time);
%     dc_power = dc_power/mean(dc_power)*mean(irrad_time/1000*pv_cap)*dc_ratio;

    total_ranges = 0;

    for i = 1:tsteps
        temp_case = pwr_case;
        temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);

        pct_flux = irrad_time(i)/1000;
        pv_pwr = pct_flux*pv_cap; 

        % Set up PV and DC bus loads
        temp_case.bus(pvBus,3) = temp_case.bus(pvBus,3) - pv_pwr;

        % Bounds of DC
        lowerBound = workload_power(i) ...
            + alpha/((t_Range(1)-t_OA(i))^temp_power_oac)*workload_power(i)^3 ...
            + gamma/(t_Range(1)^temp_power_wc)*workload_power(i);
        PUE_low = lowerBound/workload_power(i);
        
        upperBound = workload_power(i) ...
            + alpha/((t_Range(2)-t_OA(i))^temp_power_oac) * workload_power(i)^3 ...
            + gamma/(t_Range(2)^temp_power_wc) * workload_power(i);
        PUE_up = upperBound/workload_power(i);        
       
        maxVoltage = temp_case.bus(1,12);
        minVoltage = temp_case.bus(1,13);

        [results, success] = runpf(temp_case, options);
        if success == 0
            fprintf('Initial onvergence failure: PV_capacity = %d, time = %d\n',...
                pv_cap, i);
            break;
        end

        % Select n evenly distributed loads between the bounds of DC
        if upperBound < lowerBound
            % Never happens...
            disp('Upper bound less than lower bound.');
            selectedLoadsForDC = dc_power(i);
        else
            loadIntervals = 0:1:numLoads;
            selectedLoadsForDC = ((upperBound - lowerBound)/numLoads).*loadIntervals + lowerBound;
            total_ranges = total_ranges + (upperBound - lowerBound);
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

            violatedBuses = findViolated(newResults.bus(:,8), maxVoltage, minVoltage);
            violations(idx) = length(violatedBuses);
            previousLoad = selectedLoadsForDC(idx);
        end

        smallestViolations = min(violations);
        out_bounds = out_bounds + smallestViolations;
    end

    violationFreq = out_bounds / (tsteps*numBuses);
end
