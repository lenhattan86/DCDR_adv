% test function nonviolationfraction

load([trace_path 'testdayirrad.mat']); % load one-month PV data for every minute

power_case = case47custom;

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

capacities = linspace(0, 1, 6);

lcap = length(capacities);

businbounds = zeros(lcap,1);
violation_log10 = zeros(lcap,1);

for k = 1:lcap
    tic
    [businbounds(k), v_pv13, v_pv17, v_pv19, v_pv23, v_pv24] = ...
        nonviolationfraction47(power_case, capacities(k),...
        Feb2012Irrad, minuteloadFeb2012, opt); % All of Feb 2012
%     [businbounds(k), v_pv13, v_pv17, v_pv19, v_pv23, v_pv24] =...
%         nonviolationfraction47(power_case, capacities(k),...
%         Feb26Irrad, minuteloadFeb2012(36001:37440), opt); % Feb 26, 2012
    toc

    violation_log10(k) = log10(1-businbounds(k));
    if k == 1
        v_nopv13 = v_pv13;
        v_nopv17 = v_pv17;
        v_nopv19 = v_pv19;
        v_nopv23 = v_pv23;
        v_nopv24 = v_pv24;
    end
    
    if k == lcap
        ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0];
        figure()
        hold on
        plot(timeofday(:,2),10^4*(v_pv13(1:1440)-v_nopv13(1:1440)),'Color',ColorSet(1,:))
        plot(timeofday(:,2),10^4*(v_pv17(1:1440)-v_nopv17(1:1440)),'Color',ColorSet(2,:))
        plot(timeofday(:,2),10^4*(v_pv19(1:1440)-v_nopv19(1:1440)),'Color',ColorSet(3,:))
        plot(timeofday(:,2),10^4*(v_pv23(1:1440)-v_nopv23(1:1440)),'Color',ColorSet(4,:))
        plot(timeofday(:,2),10^4*(v_pv24(1:1440)-v_nopv24(1:1440)),'Color',ColorSet(5,:))
        plot(timeofday(:,2),Feb2012Irrad(1:1440),'k-')
        legend('\Delta V_P_V_1_3/10^-^4', '\Delta V_P_V_1_7/10^-^4', ...
            '\Delta V_P_V_1_9/10^-^4', '\Delta V_P_V_2_3/10^-^4', ...
            '\Delta V_P_V_2_4/10^-^4', 'Irradiance')
        hold off
    end
    
end

figure()
hold on
plot(capacities(:),businbounds(:), 'ro')
plot(capacities(:),violation_log10(:), 'bs')
axis([0 max(capacities) 0 1.05])
hold off

save('zhenhua-test-0509a')