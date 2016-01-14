function [ violatedBuses ] = findViolated( voltages, max_voltage, min_voltage )

violatedBuses = find((voltages(:) >= max_voltage) | (voltages(:) <= min_voltage));

end

