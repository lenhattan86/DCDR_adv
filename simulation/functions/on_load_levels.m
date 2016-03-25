function power_out = on_load_levels(power_in, loadLevels)
    T  = size(loadLevels,2);
    L  = size(loadLevels,1); 
    power_out = zeros(T,1);
    for t=1:T
        lower_bound = loadLevels(1,t);
        upper_bound = max(loadLevels(L,t));
        interval = (upper_bound-lower_bound)/(L-1);
        l = round((power_in(t)-lower_bound)/interval)+1;
        power_out(t) = interval*l + lower_bound;
    end
end