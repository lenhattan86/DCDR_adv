% test function nonviolationfraction

load testdayirrad.mat

% Load CVX libraries.
cvx_setup
cvx_quiet true
cvx_solver sedumi
cvx_precision low

power_case = case56customv2;

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

capacities = linspace(0.7, 1, 16);
businbounds = zeros(length(capacities),1);
violation_log10 = zeros(length(capacities),1);

for k = 1:length(capacities)
    tic
%     [businbounds(k), v_pv] = nvfcvx56(power_case, capacities(k),...
%         Feb2012Irrad, minuteloadFeb2012, opt); % All of Feb 2012
    [businbounds(k), v_pv] = nvfcvx56(power_case, capacities(k),...
        Feb26Irrad, minuteloadFeb2012(36001:37440), opt); % Feb 26, 2013
    toc

    violation_log10(k) = log10(1-businbounds(k));
    if k == 1
        v_nopv = v_pv;
    end
    
    if k == length(capacities)
        figure()
        hold on
        plot(timeofday(:,2),10^4*(v_pv(1:1440)-v_nopv(1:1440)),'k-')
        plot(timeofday(:,2),Feb2012Irrad(1:1440),'r-')
        legend('\Delta V_P_V/10^-^4', 'Irradiance')
        hold off
    end
    
end

figure()
hold on
plot(capacities(:),businbounds(:), 'ro')
plot(capacities(:),violation_log10(:), 'bs')
axis([0 max(capacities) -4 1.05])
hold off

