function [W, loadLevels] = comp_vio_wei_2(pwr_case, pv_cap, irrad_time,...
    pct_load, up_cap, low_cap, POWER_UNIT, ...    
    options, dcBus, numBuses, pvBus, verbose)

    % Scale the power consumption of data center corresponding to the
    % PV generation.       
    T = length(irrad_time);       
          
    numLoads = floor(up_cap/mean(POWER_UNIT)) + floor(low_cap/mean(POWER_UNIT));
   
    upperBound = POWER_UNIT*numLoads;
    lowerBound = low_cap;
    
    loadIntervals = 0:1:numLoads;
    selectedLoadsForDC = ((upperBound - lowerBound)/numLoads).*loadIntervals + lowerBound;
    loadLevels =  repmat(selectedLoadsForDC',1,T);

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
            W(idx, i) = length(violatedBuses);
            previousLoad = selectedLoadsForDC(idx);            
        end
    end
    W = W/(T*numBuses);
end