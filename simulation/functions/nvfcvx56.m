function [in_bounds,v_45, optcase, v_all] = nvfcvx56(pwr_case, pv_cap, irrad_time,...
    pct_load, options)
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
v_45 = zeros(length(irrad_time),1);
v_all = zeros(length(pwr_case.bus(:,1)),length(irrad_time));

v_hi = pwr_case.bus(1,12);
v_lo = pwr_case.bus(1,13);

for i = 1:length(irrad_time)
    tic
    temp_case = pwr_case; % reset mpc to base case

    temp_case.bus(:,[3,4]) = pct_load(i) * temp_case.bus(:,[3,4]); % weight
    % peak load power and reactive power demand values by pct_loading(time)
    % to get actual load power and reactive power demand
    
    % Set PV load
    pct_flux = irrad_time(i)/1000;
    pv_pwr = pct_flux*pv_cap; % MW output from PV installation at bus 45
    temp_case.bus(45,3) = -pv_pwr; % Not general at this point; could do one
    % of many things to generalize here.

    [optcase, err] = cvxcrisedits5(temp_case); % Simulate the power
    % flow

    if err > 10^(-6)
        sprintf('Convergence failure: PV_capacity = %d, time = %d, error = %d',...
            pv_cap, i, err)
    end
    
    v_res = optcase.bus(:,8);
    v_45(i) = optcase.bus(45,8);
    v_all(:,i) = optcase.bus(:,8);
    
    for j = 1:length(v_res)
        if v_res(j) >= v_hi || v_res(j) <= v_lo
            out_bounds = out_bounds + 1;
            break
        end
    end
    toc
    
end

    in_bounds = (tsteps - out_bounds) / tsteps;

end

% Ratio of flux to nominal flux
