%This script plot the results from the output of simulation for each
%scenario

%% Plot the different parameters of energy storages using spider charts.
figure_settings;

% spider([1 2 3 4 5; 4 5 6 7 8; 7 8 9 10 11; 10 11 12 13 14; 13 14 15 16 17; ...
%  	16 17 18 19 18; 19 20 21 22 14; 22 23 24 25 14; 25 26 27 28 20],'test plot', ...
%  	[[0:3:24]' [5:3:29]'],[],{'LA' 'LI' 'UC' 'FW' 'CAES'});

%% %%%%%%%%%%%%%%%%%% General Figures %%%%%%%%%%%%%%%%%

%% Plot the total demand & supply
figure_settings; 
load('results/init_settings.mat');
% load('results/init_settings_15.mat');
yArray = (dc_power + grid_load_data)*15;
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
plot(xArray,yArray, '-k', 'LineWidth', lineWitdth);
ylabel('Energy (MWh)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'Load demand'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.3]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_demand.eps']);
end


%% PV generation
figure_settings; load('results/init_settings.mat');  

% irrad_time = Feb26Irrad(1:sampling_interval:T*sampling_interval);
% day = 6;
% irrad_time = Feb2012Irrad(1+day*1440:sampling_interval:T*sampling_interval+day*1440);
% pct_flux = irrad_time/1000;
% pv_pwr = pct_flux*PVcapacity; 
yArray = pv_pwr;
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
plot(xArray,yArray, '-k', 'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize', fontAxis);
xlabel('Hours','FontSize', fontAxis);
% legendStr = {'PV generation'};
% legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,60]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'pv_generation.eps']);
end

mean(pv_pwr)

%% load
figure_settings; load('results/init_settings.mat');  
figure('units','inches', 'Position', figure_size_scr);
is_printed = true;
xArray = (1:T)/HOUR;
numLoadBuses = length(loadBus);
% if numLoadBuses > 1
%     for b=1:numLoadBuses   
%         hold on;
%         plot(xArray,grid_load_data(b,:), 'LineWidth', 1);
%     end
% else
%     plot(xArray,grid_load_data(:), 'LineWidth', 1);
% end

plot(xArray,sum(active_load,1), patternES, 'LineWidth', 2);
hold on;
plot(xArray,sum(reactive_load,1), 'LineWidth', 2);
strLegend = {'active','reactive'};
legend(strLegend, 'Location','northeast','FontSize',fontLegend);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
ylim([0,60]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'residential_load.eps']);
end

%% supply & demand


%% data center power
figure_settings; load('results/init_settings.mat');  

yArray = dc_power;
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
plot(xArray,yArray, '-r', 'LineWidth', 1);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'DC power'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,60]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'dc_power.eps']);
end

%% %%%%%%%%%%%%%%%%%% 2. Voltage regulation %%%%%%%%%%%%%%%%%

%% Interactive workload
figure_settings;
load('results/script_interactive.mat');  

figure('units','inches', 'Position', figure_size_scr);
yArray = violationFreq(1,:);
xArray = 100*QoS_delay_relax;
plot(xArray,yArray, '-ok', 'LineWidth', lineWitdth);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel(strDelayFlexibility,'FontSize',fontAxis);
legendStr = {'Interactive'};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'script_interactive.eps']);
end

violationFreq(1,:)/violationFreq(1,1)

figure('units','inches', 'Position', figure_size_scr);
idxes = [1 6];
xArray = (1:T)/HOUR;
for q=1:length(idxes)
    hold on;
    plot(xArray,a_qos(idxes(q),:), 'LineWidth', 1);
end
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% legendStr = strread(num2str(QoS_delay_relax(idxes)*100),'%s');
legendStr = {'Orginal','25%'};
legend(legendStr,'Location','south','FontSize',fontLegend);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
% change the style of the first line
hline = findobj(gcf, 'type', 'line')
set(hline(1), 'LineStyle', patternCost)
if is_printed
    print ('-depsc', [fig_path 'power_interactive.eps']);
end

% plot the PDF of QoS_delay_after
idxes = [6];
figure('units','inches', 'Position', figure_size_scr);
normalized_delay = zeros(length(idxes), T);
for i=1:length(idxes)
    normalized_delay(i,:) = QoS_delay_after(idxes(i),:)./QoS_delay';
    [f,xi] = ksdensity(normalized_delay(i,:));
    hold on;
    plot(xi,f);
end
legendStr = strread(num2str(QoS_delay_relax(idxes)*100),'%s');
legend(legendStr,'Location','northeast','FontSize',fontLegend);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'qos_pdf.eps']);
end

% Histogram
idxes = [6];
figure('units','inches', 'Position', figure_size_scr);
normalized_delay = zeros(length(idxes), T);
for i=1:length(idxes)
    normalized_delay(i,:) = QoS_delay_after(idxes(i),:)./QoS_delay';
    [f,xi] = ksdensity(normalized_delay(i,:));
    hold on;
    plot(xi,f);
end
legendStr = strread(num2str(QoS_delay_relax(idxes)*100),'%s');
legend(legendStr,'Location','northeast','FontSize',fontLegend);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'qos_histogram.eps']);
end


% Switching costs
figure('units','inches', 'Position', figure_size_scr);
switchingCosts = sum(pos(dc_power_qos(:,2:T)-dc_power_qos(:,1:T-1)),2);
yArray = switchingCosts;
bar(yArray,'stacked'); 
ylabel('Power (MW)','FontSize',fontAxis);
% xlabel('Hours','FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'switching_cost_interactive.eps']);
end

%% Batch job
figure_settings;
load('results/script_batchjob.mat');  
% is_printed =  false;

figure('units','inches', 'Position', figure_size_scr);
yArray = violationFreq;
xArray = bjEnd/HOUR;
plot(xArray,yArray, '-ok', 'LineWidth', lineWitdth);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel(strBJDeandline,'FontSize',fontAxis);
legendStr = {'Batch jobs'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
 xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'script_batchjob.eps']);
end

figure('units','inches', 'Position', figure_size_scr);
c = length(bjEnd);
dc_power_after = [idle_power(c,:); a_power(c,:); b_power(c,:)];
bar(dc_power_after',1,'stacked'); 
% plot(idle_power(c,:)');
% hold on;
% plot(idle_power(c,:)' + a_power(c,:)');
% hold on;
% plot(idle_power(c,:)' + a_power(c,:)'+ b_power(c,:)');
% bar(dc_power_after,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
% xlabel('Hours','FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'power_batchjobs.eps']);
end

% Switching costs

% figure('units','inches', 'Position', figure_size_scr);
% dc_power_after = idle_power + a_power + b_power;
% switchingCosts = sum(pos(dc_power_qos(:,2:T)-dc_power_qos(:,1:T-1)),2);
% yArray = switchingCosts;
% bar(yArray); 
% ylabel('Power (MW)','FontSize',fontAxis);
% % xlabel('Hours','FontSize',fontAxis);
% set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
% if is_printed
%     print ('-depsc', [fig_path 'switching_cost_interactive.eps']);
% end

% Workload Power consumption.


%% Cooling systems.
figure_settings;
load('results/script_cooling.mat');  
violationFreq(1,:)/violationFreq(1,1)
figure('units','inches', 'Position', figure_size_scr);
yArray = violationFreq(1,:);
xArray = t_differences;
plot(xArray, yArray, '-ok', 'LineWidth', lineWitdth);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel(strRelaxTemperature,'FontSize',fontAxis);
% xLabels = {'70','68-72','66-74','64-76';'62-78','60-80'};
% set(gca,'xticklabel',xLabels,'FontSize',fontAxis);
legendStr = {'Cooling subsystem'};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);

if is_printed
    print ('-depsc', [fig_path 'script_cooling.eps']);
end
% Power profile & temperature
if 0
    for c = 1:length(t_differences)
        figure('units','inches', 'Position', figure_size_scr);        
        y_array = [P_IT' ; P_cooling_after(c,:)];
        bar(y_array',1,'stacked');
        legend('IT power','Cooling power');
        ylim([0 dc_cap]);
    end
    for c = 1:length(t_differences)
        figure('units','inches', 'Position', figure_size_scr);        
        y_array = Temp_dc(c,:);
        plot(y_array');
        legend('Temperature');        
    end
end

% histogram of temperature
c = length(t_differences);
figure('units','inches', 'Position', figure_size_scr);        
histogram(round(Temp_dc(c,:)))
ylabel('histogram','FontSize',fontAxis);
xlabel(strTemperature,'FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'temperature_historgram.eps']);
end

% Cooling energy consumption

figure('units','inches', 'Position', figure_size_scr);
yArray = sum(P_cooling_after,2)/HOUR;
xArray = t_differences;
plot(xArray, yArray, patternCooling, 'LineWidth', lineWitdth);
ylabel('Energy consumption (MWh)','FontSize',fontAxis);
xlabel(strRelaxTemperature,'FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);

if is_printed
    print ('-depsc', [fig_path 'energy_consumption_cooling.eps']);
end

%% Energy Storages
% figure_settings; load('results/script_ups.mat');  
figure_settings; load('results/script_ups_v1.mat');  

vio_default = 1.7; max_vio = max(max(violationFreq(:,:))); violationFreq= violationFreq/max_vio*vio_default;

figure('units','inches', 'Position', figure_size_scr);
yArray = violationFreq/max_vio*vio_default;
xArray = ups_capacity_investment;
plot(xArray, yArray,'LineWidth', 1);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('Cost (k$)','FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);
legend(battery_types,'Location','southeast','FontSize',fontLegend);

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
eline = findobj(gcf, 'type', 'line');
set(eline(1), 'LineStyle', patternVoltageFreq, 'Color', [0 0 0])
set(eline(2), 'LineStyle', patternCost, 'Color', [0 0 0])
set(eline(3), 'LineStyle', patterndot, 'Color', [0 0 0])
set(eline(4), 'LineStyle', patterntemp, 'Color', [0 0 0])

if is_printed
    print ('-depsc', [fig_path 'script_ups_curves.eps']);
end

figure('units','inches', 'Position', figure_size_scr);
yArray = violationFreq(1,:);
xArray = 1:length(yArray);
bar(xArray, yArray, 0.2);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('Energy storages','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'script_ups.eps']);
end

figure('units','inches', 'Position', figure_size_scr);
temp = squeeze(X_e_array(1,:,:));
R_e = max(temp,0);
D_e = max(-temp,0);
y = [sum(R_e,2)/HOUR,sum(D_e,2)/HOUR];
bar(y, 0.6);
ylabel('Power generation (MWh)','FontSize',fontAxis);
xlabel('Energy storages','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
legend({'charge','discharge'},'Location','northwest','FontSize',fontLegend);
if is_printed
    print ('-depsc', [fig_path 'script_ups_power.eps']);
end

figure('units','inches', 'Position', figure_size_scr);
xArray = (1:T)/HOUR;
yArray = squeeze(X_e_array(1,:,:));
plot(xArray,yArray,'LineWidth', 1);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
% legendStr = {strDataCenter};
legend(battery_types,'Location','southeast','FontSize',fontLegend);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
% legend({'charge','discharge'},'Location','northwest','FontSize',fontLegend);
if is_printed
    print ('-depsc', [fig_path 'script_ups_power_profile.eps']);
end

%% Backup generators
figure_settings;
fontAxis = 10;
load('results/script_generator.mat');  

figure('units','inches', 'Position', figure_size_scr);
yArray = violationFreq(1,:);
generation = sum(G_array,2)/HOUR;
% xArray = 1:length(yArray);
xArray = ramp_time_generator;
% bar(xArray, yArray, 0.2);
plot(xArray, yArray, patternVoltageFreq, 'LineWidth', lineWitdth);
% [hAx, hLine1, hLine2] =  plotyy(xArray, yArray, xArray, generation);
% ylabel(strViolationFreq,'FontSize',fontAxis);
% set(hLine1,'LineStyle', patternVoltageFreq, 'LineWidth', 2)
% set(hLine2,'LineStyle', patternCost, 'LineWidth', 2)
% ylabel(hAx(1), strViolationFreq) % left y-axis
% ylabel(hAx(2), 'Generation(MWh)') % right y-axis
% xlabel('Generator types','FontSize',fontAxis);
xlabel('Ramp time (mins)','FontSize',fontAxis);
% set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'script_generator.eps']);
end

figure('units','inches', 'Position', figure_size_scr);
temp = squeeze(G_array(1,:,:));
yArray = sum(temp,2)/HOUR;
xArray = (1:T)/HOUR;
% bar(xArray, yArray, 0.2);
plot(xArray,temp);
ylabel('Power generation (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
legend(generator_type,'Location','southeast','FontSize',fontLegend);
ylim([0,dc_cap]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'script_generator_power.eps']);
end

% figure
% plot(squeeze(G_array(1,2,:))')
% figure('units','inches', 'Position', figure_size_scr);
% plot(squeeze(G_array(1,3,:))')
% figure
% plot(squeeze(G_array(1,4,:))')

% Operating cost
figure('units','inches', 'Position', figure_size_scr);
xArray = 1:length(yArray);
yArray = zeros(1,length(xArray));
bar(xArray, yArray, 0.2);
ylabel('Operational cost','FontSize',fontAxis);
xlabel('Generator types','FontSize',fontAxis);
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
% ylim([0,max(max(yArray))*1.1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'gen_operational_cost.eps']);
end
% emissions
figure('units','inches', 'Position', figure_size_scr);
xArray = 1:length(yArray);
yArray = zeros(1,length(xArray));
bar(xArray, yArray, 0.2);
ylabel('emissions','FontSize',fontAxis);
xlabel('Generator types','FontSize',fontAxis);
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
% ylim([0,max(max(yArray))*1.1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'gen_emissions.eps']);
end

%% %%%%%%%%%%%%%%%%%% 3. Peak Shaving %%%%%%%%%%%%%%%%%

%% Interactive workload

figure_settings; load('results/peak_shaving_interactive.mat'); 
load_demand = dc_power+grid_load_data;
peak_demand = max(load_demand);

figure('units','inches', 'Position', figure_size_scr);
total_load = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = (peak_demand-max(total_load'))/peak_demand*100;
xArray = QoS_delay_relax*100;
plot(xArray,yArray, patternPeakShaving, 'LineWidth', lineWitdth);
ylabel(strPeakReduction,'FontSize',fontAxis);
xlabel(strDelayFlexibility,'FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([min(yArray),peak_reduction_max]);
xlim([0,max(xArray)]);
grid on;
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_interactive.eps']);
end

temp = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = temp(length(temp(:,1)),:)';
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
plot(xArray,dc_power+grid_load_data,'LineWidth', lineWitdth, 'LineStyle', patternCost);
hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'original','25 %'};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
% ylim([0,max(max(yArray))*1.3]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_interactive_power.eps']);
end

%% batch job
figure_settings; load('results/peak_shaving_batch_jobs.mat'); 
load_demand = dc_power+grid_load_data;
peak_demand = max(load_demand);

figure('units','inches', 'Position', figure_size_scr);

total_load = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = (peak_demand-max(total_load'))/peak_demand*100;

yArray = [yArray];
xArray = [bjEnd/HOUR];

plot(xArray,yArray, patternPeakShaving, 'LineWidth', lineWitdth);
ylabel(strPeakReduction,'FontSize',fontAxis);
xlabel(strBJDeandline,'FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','northeast','FontSize',fontLegend);
% ylim([0,max(dc_power + grid_load_data)*1.1]);
ylim([0,peak_reduction_max]);
xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_batch_jobs.eps']);
end

temp = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = temp([14],:)';
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
plot(xArray,load_demand,'LineWidth', lineWitdth);
hold on;
plot(xArray,yArray,'LineWidth', lineWitdth, 'LineStyle', patternCost);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'original','7 hours'};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(dc_power + grid_load_data)*1.1]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_batch_jobs_power.eps']);
end


%% cooling

figure_settings; load('results/peak_shaving_cooling.mat');  
load_demand = dc_power+grid_load_data;
peak_demand = max(load_demand);

figure('units','inches', 'Position', figure_size_scr);
total_load = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = (peak_demand-max(total_load'))/peak_demand*100;
xArray = t_differences;
plot(xArray,yArray, patternPeakShaving, 'LineWidth', lineWitdth);
ylabel(strPeakReduction,'FontSize',fontAxis);
xlabel(strRelaxTemperature,'FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,peak_reduction_max]);
xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_cooling.eps']);
end

temp = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = temp([4],:)';
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
plot(xArray,load_demand,'LineWidth', lineWitdth);
hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'original',sprintf('64-76(%cF)', char(176))};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
% ylim([0,max(max(yArray))*1.3]);
ylim([0,max(dc_power + grid_load_data)*1.1]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_cooling_power.eps']);
end

if 0
    figure('units','inches', 'Position', figure_size_scr);
    plot(dc_power+grid_load_data);
    for c = 1:length(t_differences)
        hold on;
        plot(dc_power_after(c,:)' + grid_load_data);
    end
end

if 0
    for c = 1:length(t_differences)
        figure('units','inches', 'Position', figure_size_scr);        
        y_array = [P_IT' ; P_cooling_after(c,:)];
        bar(y_array',1,'stacked');
        legend('IT power','Cooling power');
    end
end
xline = findobj(gcf,'type', 'line');
set(xline(1), 'LineStyle', patternCost)

%% energy storages
figure_settings; load('results/peak_shaving_ups.mat');  
load_demand = dc_power+grid_load_data;
peak_demand = max(load_demand);

figure('units','inches', 'Position', figure_size_scr);
total_load = dc_power_after + ones(size(dc_power_after,1),1)*grid_load_data';
yArray = (peak_demand-max(total_load'))/peak_demand*100;
xArray = 1:length(yArray);
bar(xArray, yArray, 0.2);
xlabel('Energy storages','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
ylabel(strPeakReduction,'FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,peak_reduction_max]);
% xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_ups.eps']);
end

yArray = total_load;
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
% plot(xArray,raw_dc_power,'LineWidth', lineWitdth);
% hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)', 'FontSize', fontAxis);
xlabel('Hours', 'FontSize', fontAxis);
legendStr = battery_types;
legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(dc_power + grid_load_data)*1.1]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
eline = findobj(gcf, 'type', 'line');
set(eline(1), 'LineStyle', patternVoltageFreq)
set(eline(2), 'LineStyle', patternCost)
set(eline(3), 'LineStyle', patterndot)
set(eline(4), 'LineStyle', patterntemp)
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_ups_power.eps']);
end

%% Back-up generators
figure_settings; load('results/peak_shaving_generator.mat'); 
fontAxis = 10;
load_demand = dc_power+grid_load_data;
peak_demand = max(load_demand);

figure('units','inches', 'Position', figure_size_scr);
xArray = gen_budget;
for b = 1:length(ramp_time_generator)
    dc_power_after_tmp = squeeze(dc_power_after(b,:,:));
    total_load = dc_power_after_tmp + ones(size(dc_power_after_tmp,1),1)*grid_load_data';
    yArray = (peak_demand-max(total_load'))/peak_demand*100;
%     plot(xArray,yArray,patternPeakShaving,'LineWidth', lineWitdth);
    hold on;
%     plot(xArray,yArray,patternPeakShaving,'LineWidth', lineWitdth);
    plot(xArray,yArray,'LineWidth', lineWitdth);
end
legendStr = generator_type;
legend(legendStr,'Location','southeast','FontSize',fontLegend-2);
% bar(xArray, yArray, 0.2);
xlabel('Generation bugdet (USD)','FontSize',fontAxis);
ylim([0,peak_reduction_max]);
% set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
ylabel(strPeakReduction,'FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_generator.eps']);
end




yArray = total_load;
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);
% plot(xArray,raw_dc_power,'LineWidth', lineWitdth);
% hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% legendStr = generator_type;
% legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,peak_reduction_max]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_generator_power.eps']);
end

b = 1;
c=3;
emissions_NO = NOx*sum(G_array(b, c, :))/HOUR;
emissions_CO = CO*sum(G_array(b, c, :))/HOUR;
emissions_HC = HC*sum(G_array(b, c, :))/HOUR;
emissions_PM = PM*sum(G_array(b, c, :))/HOUR;
emissions_SO2 = SO2*sum(G_array(b, c, :))/HOUR;
emissions = [emissions_NO; emissions_CO; emissions_HC; emissions_PM; emissions_SO2]';

yArray = total_load;
xArray = (1:T)/HOUR;
figure('units','inches', 'Position', figure_size_scr);

bar(emissions, 'grouped');
ylabel('Emissions (kg)','FontSize',fontAxis);
generator_type       = {'Diesel', 'D. DPF', 'Gas', 'Gas Micro.'};
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
legendStr = {'NOx','CO','HC','PM','SO2'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', figure_size);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_generator_emission.eps']);
end

%% %%%%%%%%%%%%%%%%%% 4. Others %%%%%%%%%%%%%%%%%