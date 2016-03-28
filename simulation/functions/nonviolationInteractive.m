function [violationFreq, a_qos, dc_power_qos] = nonviolationInteractive(pwr_case, pv_cap, irrad_time,...
    pct_load, dc_power, interactive, dc_cap, ...
    aFlexiblitiesUpperBound, aFlexiblitiesLowerBound, ...
    options, dcBus, numBuses, pvBus, grid_load_data, loadBus, numLoadLevels, verbose)

    out_bounds = 0;
    tsteps = length(irrad_time);
%     dc_power = dc_power/mean(dc_power)*mean(irrad_time/1000*pv_cap)*dc_ratio;

    total_ranges = 0;
    B = dc_power - interactive;
    X = zeros(1, tsteps);
    for i = 1:tsteps
        temp_case = pwr_case;
        temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);

        pct_flux = irrad_time(i)/1000;
        pv_pwr = pct_flux*pv_cap;
        
        % set up the grid load on a bus
        if isscalar(loadBus)
            if loadBus > 0
                temp_case.bus(loadBus,3) = temp_case.bus(loadBus,3) + grid_load_data(i);
            end
        else
            numLoadBuses = length(loadBus);
            for b=1:numLoadBuses
                temp_case.bus(b,3) = temp_case.bus(b,3) + grid_load_data(b,i);
            end
        end

        % Set up PV and DC bus loads
        temp_case.bus(pvBus,3) = temp_case.bus(pvBus,3) - pv_pwr;

        % Bounds of DC
        upperBound = min(dc_power(i) - interactive(i) + aFlexiblitiesUpperBound(i), dc_cap);
        lowerBound = max(dc_power(i) - interactive(i) + aFlexiblitiesLowerBound(i), 0);

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
            boundGap = upperBound - lowerBound
            selectedLoadsForDC = dc_power(i);
        else
            loadIntervals = 0:1:numLoadLevels;
            selectedLoadsForDC = ((upperBound - lowerBound)/numLoadLevels).*loadIntervals + lowerBound;
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

        [smallestViolations, idx] = min(violations);
        X(i) = selectedLoadsForDC(idx);
        out_bounds = out_bounds + smallestViolations;
    end
    a_qos = X - B';
    dc_power_qos = X;    
    violationFreq = out_bounds / (tsteps*numBuses);
end