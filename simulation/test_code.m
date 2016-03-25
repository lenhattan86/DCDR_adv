cvx_solver Gurobi;
s_quiet = cvx_quiet(true);
s_pause = cvx_pause(false);
cvx_precision low;

c = 2;
[violation, X, G] = opt_vio_freq_gen(W, loadLevels, ...
             dc_power, gen_power_cap(c), ramp_time_generator(c), ...
             false);
         
violation