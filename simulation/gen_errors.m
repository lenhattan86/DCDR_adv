dc_load_errs = randn(T,1)*ERR*mean(dc_power);
BS_errs = randn(length(BS),1)*ERR*mean(BS);
a_errs = randn(T,1)*ERR*mean(a);
grid_load_data_errs = randn(T,1)*ERR*mean(grid_load_data);

dc_power_pred = max(dc_power + dc_load_errs,0);
BS_pred = max(BS+BS_errs,0);
a_pred = max(a + a_errs,0);
grid_load_data_pred = max(grid_load_data_errs+grid_load_data,0);