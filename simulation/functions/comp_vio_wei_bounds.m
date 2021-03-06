function [W, loadLevels] = comp_vio_wei_bounds(pwr_case, pv_cap, irrad_time,...
    pct_load, ...
    lower_bound, upper_bound, numLoadLevels, ...    
    options, dcBus, numBuses, pvBus, grid_load_data, loadBus, conv_power, conv_power_bus, verbose)

    % Scale the power consumption of data center corresponding to the
    % PV generation.       
    T = length(irrad_time);       
    
    loadIntervals = 0:1:(numLoadLevels-1);
    selectedLoadsForDC = ((upper_bound - lower_bound)/(numLoadLevels-1))*loadIntervals...
        + repmat(lower_bound, 1, numLoadLevels);
    loadLevels =  selectedLoadsForDC';

    W = zeros(numLoadLevels, T);
    for i = 1:T
        temp_case = pwr_case;
        temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);

        pct_flux = irrad_time(i)/1000;
        pv_pwr = pct_flux*pv_cap; 
        
        %% Todo:(for Jie) Adding a conventional generator
        if conv_power_bus > 0
            temp_case.bus(conv_power_bus,3) = temp_case.bus(conv_power_bus,3) - conv_power(i);
        end
        
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
        

        maxVoltage = temp_case.bus(1,12);
        minVoltage = temp_case.bus(1,13);

        [results, success] = runpf(temp_case, options);
        if success == 0
            fprintf('Initial onvergence failure: PV_capacity = %d, time = %d\n',...
                pv_cap, i);            
            break;
        end

        violations = zeros(1,numLoadLevels);
        previousLoad = 0;
        for idx = 1:numLoadLevels
            temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) - previousLoad;
            temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) + loadLevels(idx, i);

            [newResults, success] = runpf(temp_case, options);
            if success == 0
                fprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
                    pv_cap, i);
                % Set a place holder. This can never be the number of
                % violations, so it is ignored.
                violations(idx) = numBuses + 1;
                previousLoad = loadLevels(idx, i);
                continue;
            end

            violatedBuses = findViolated(newResults.bus(:,8), maxVoltage, minVoltage);
            W(idx, i) = length(violatedBuses);
            previousLoad = loadLevels(idx, i);            
        end
    end
    W = W/(T*numBuses);
end