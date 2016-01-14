function [in_bounds,v_13,v_17,v_19,v_23,v_24] =...
    nonviolationfraction47(pwr_case, pv_cap, irrad_time,pct_load, options)
% Function takes case56customv2 and solar irradiance data as inputs. The
% resistance at bus 45 is altered to account for the installed solar
% capacity. It
% then calculates the power flows in the circuit for each time step t and
% returns all voltages. If a voltage is within the tolerance bounds it
% corresponds to a 1; if outside, a zero. Calculates the fraction of time
% steps t each bus spends out of tolerance.
% pv_cap should be given in MW

out_bounds = 0;
tsteps = length(irrad_time);
v_13 = zeros(length(irrad_time),1);
v_17 = v_13;
v_19 = v_13;
v_23 = v_13;
v_24 = v_13;

for i = 1:length(irrad_time)
    temp_case = pwr_case; % reset mpc to base case
    
    temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]); % weight
    % peak load power and reactive power demand values by pct_loading(time)
    % to get actual load power and reactive power demand
    
    % Set PV load
    pct_flux = irrad_time(i)/1000;
    pv_pwr = pct_flux*pv_cap; % MW output from PV installation with
    
    % nameplate capacity of 1MW
    temp_case.bus(13,3) = -pv_pwr*1.5; % MW output from PV at bus 13
    temp_case.bus(17,3) = -pv_pwr*0.4; % MW output from PV at bus 17
    temp_case.bus(19,3) = -pv_pwr*1.5; % MW output from PV at bus 19
    temp_case.bus(23,3) = -pv_pwr*1; % MW output from PV at bus 23
    temp_case.bus(24,3) = -pv_pwr*2; % MW output from PV at bus 24
    
    [results, success] = runpf(temp_case, options); % Simulate the power
    % flow
    if success == 0
        sprintf('Convergence failure: PV_capacity = %d, time = %d', pv_cap,...
            i)
    end
    
    v_res = results.bus(:,8);
    v_hi = results.bus(1,12);
    v_lo = results.bus(1,13);
    v_13(i) = results.bus(13,8);
    v_17(i) = results.bus(17,8);
    v_19(i) = results.bus(19,8);
    v_23(i) = results.bus(23,8);
    v_24(i) = results.bus(24,8);
    
    for j = 1:length(v_res)
        if v_res(j) >= v_hi || v_res(j) <= v_lo
            out_bounds = out_bounds + 1;
            break
        end
    end

    % pick out the relevant result quantities, translate them into
    % tolerance exceptions, calculate fraction each bus is out of tolerance
    % or fraction feeder out of tolerance (have to change from fixed
    % voltage) or fraction _something_ is out of tolerance
end

    in_bounds = (tsteps - out_bounds) / tsteps;

end

% Ratio of flux to nominal flux
