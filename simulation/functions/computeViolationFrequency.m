function [violationFrequency] = computeViolationFrequency (pwr_case, pv_cap, irrad_time,...
    pct_load, dc_power,  ...
    options, dcBus, numBuses, pvBus, grid_load_data, loadBus, verbose)

    % Scale the power consumption of data center corresponding to the
    % PV generation.       
    T = length(irrad_time);       
    W = zeros(1,T);

    for i = 1:T
        temp_case = pwr_case;
        temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]);        
        pct_flux = irrad_time(i)/1000;
        pv_pwr = pct_flux*pv_cap; 
        
        %% Todo:(for Jie) Adding a conventional generator
        
%         conventional_power = 10;
%         pv_pwr = conventional_power + pv_pwr;
        
        % set up the grid load for every bus
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

        violations = 0;
        
        temp_case.bus(dcBus,3) = temp_case.bus(dcBus,3) + dc_power(i);

        [newResults, success] = runpf(temp_case, options);
        if success == 0
            fprintf('Convergence failure: PV_capacity = %d, time = %d\n',...
                pv_cap, i);
            % Set a place holder. This can never be the number of
            % violations, so it is ignored.
            violations(idx) = numBuses + 1;
            continue;
        end

        violatedBuses = findViolated(newResults.bus(:,8), maxVoltage, minVoltage);
        W(i) = length(violatedBuses);
    end
    violationFrequency = sum(W)/(T*numBuses);
end

