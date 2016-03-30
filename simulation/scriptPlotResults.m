%This script plot the results from the output of simulation for each
%scenario

%% Plot the different parameters of energy storages using spider charts.
figure_settings;

% spider([1 2 3 4 5; 4 5 6 7 8; 7 8 9 10 11; 10 11 12 13 14; 13 14 15 16 17; ...
%  	16 17 18 19 18; 19 20 21 22 14; 22 23 24 25 14; 25 26 27 28 20],'test plot', ...
%  	[[0:3:24]' [5:3:29]'],[],{'LA' 'LI' 'UC' 'FW' 'CAES'});

%% PV generation
figure_settings; load('results/script_generator.mat');  

% irrad_time = Feb26Irrad(1:sampling_interval:T*sampling_interval);
day = 6;
irrad_time = Feb2012Irrad(1+day*1440:sampling_interval:T*sampling_interval+day*1440);
pct_flux = irrad_time/1000;
pv_pwr = pct_flux*PVcapacity; 
yArray = pv_pwr;
xArray = (1:T)/HOUR;
figure;
plot(xArray,yArray, '-k', 'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'PV generation'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.3]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'pv_generation.eps']);
end

%% residential load
figure_settings; load('results/script_generator.mat');  
figure;
is_printed = true;
xArray = (1:T)/HOUR;
numLoadBuses = length(loadBus);
if numLoadBuses > 1
    for b=1:numLoadBuses   
        hold on;
        plot(xArray,grid_load_data(b,:), 'LineWidth', 1);
    end
else
    plot(xArray,grid_load_data(:), 'LineWidth', 1);
end

ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
ylim([0,max(max(grid_load_data))*1.1]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'residential_load.eps']);
end

%% data center power
figure_settings; load('results/script_generator.mat');  

yArray = raw_dc_power;
xArray = (1:T)/HOUR;
figure;
plot(xArray,yArray, '-r', 'LineWidth', 1);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'DC power'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.3]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'dc_power.eps']);
end

%% Flexibility of interactive workload
figure_settings;
load('results/script_interactive.mat');  

figure;
yArray = violationFreq(1,:);
xArray = 100*QoS_delay_relax;
plot(xArray,yArray, '-ok', 'LineWidth', lineWitdth);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('Extended delay (%)','FontSize',fontAxis);
legendStr = {'QoS'};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'script_interactive.eps']);
end

figure;
xArray = (1:T)/HOUR;
plot(xArray,a);
for q=1:qos_length
    hold on;
    plot(xArray,a_qos(q,:),'LineWidth', 1);
end
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'power_interactive.eps']);
end

%% Flexibility of Batch job deadlines
figure_settings;
load('results/script_batchjob.mat');  

figure;
yArray = violationFreq(1,:);
xArray = bjEnd/HOUR;
plot(xArray,yArray, '-ok', 'LineWidth', lineWitdth);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel(strBJDeandline,'FontSize',fontAxis);
legendStr = {strDataCenter};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
 xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'script_batchjob.eps']);
end

figure;
xArray = (1:T)/HOUR;
dc_power_after = sum(loadLevels.*X)
% bar(load_prof,'stacked'); 
plot(xArray,dc_power_after,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
% xlabel('Hours','FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'power_batchjobs.eps']);
end


%% Switching costs

figure_settings;
load('results/script_batchjob.mat');  

figure;
xArray = bjEnd/HOUR;
yArray = zeros(1, length(xArray));
bar(yArray, 0.2);
ylabel('Switching power cost (MW)','FontSize',fontAxis);
xlabel('Batchjob delay','FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','northeast','FontSize',fontLegend);
xtickLabels = {'Original','','','','','',''};
set(gca,'xticklabel',xtickLabels,'FontSize',fontAxis);

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'switching_cost_bj.eps']);
end

%% Workload Power consumption.


%% Flexiblity of cooling systems.
figure_settings;
load('results/script_cooling.mat');  

figure;
yArray = violationFreq(1,:);
xArray = t_differences;
plot(xArray, yArray, '-ok', 'LineWidth', lineWitdth);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('Relaxed temperature (F)','FontSize',fontAxis);
legendStr = {strDataCenter};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);

if is_printed
    print ('-depsc', [fig_path 'script_cooling.eps']);
end

%% Cooling energy consumption
figure_settings;
load('results/script_cooling.mat');  

figure;
yArray = violationFreq(1,:);
xArray = t_differences;
plot(xArray, yArray, '-ok', 'LineWidth', lineWitdth);
ylabel('Energy consumption','FontSize',fontAxis);
xlabel('Relaxed temperature (F)','FontSize',fontAxis);
% legendStr = {strDataCenter};
% legend(legendStr,'Location','southeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);

if is_printed
    print ('-depsc', [fig_path 'energy_consumption_cooling.eps']);
end

%% UPS types
figure_settings;
load('results/script_ups.mat');  
figure;
yArray = violationFreq(1,:);
xArray = 1:length(yArray);
bar(xArray, yArray, 0.2);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('Energy storages','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);

set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'script_ups.eps']);
end

figure;
temp = squeeze(X_e_array(1,:,:));
R_e = max(temp,0);
D_e = max(-temp,0);
y = [sum(R_e,2)/HOUR,sum(D_e,2)/HOUR];
bar(y, 0.6);
ylabel('Power generation (MWh)','FontSize',fontAxis);
xlabel('Energy storages','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
legend({'charge','discharge'},'Location','northwest','FontSize',fontLegend);
if is_printed
    print ('-depsc', [fig_path 'script_ups_power.eps']);
end

figure;
xArray = (1:T)/HOUR;
yArray = squeeze(X_e_array(1,:,:));
plot(xArray,yArray,'LineWidth', 1);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
% legendStr = {strDataCenter};
legend(battery_types,'Location','southeast','FontSize',fontLegend);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
% legend({'charge','discharge'},'Location','northwest','FontSize',fontLegend);
if is_printed
    print ('-depsc', [fig_path 'script_ups_power_profile.eps']);
end

%% generator types
figure_settings;
fontAxis = 10;
load('results/script_generator.mat');  

figure;
yArray = violationFreq(1,:);
xArray = 1:length(yArray);
bar(xArray, yArray, 0.2);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('Generator types','FontSize',fontAxis);
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'script_generator.eps']);
end

figure;
temp = squeeze(G_array(1,:,:));
yArray = sum(temp,2)/HOUR;
xArray = 1:length(yArray);
% bar(xArray, yArray, 0.2);
plot(temp');
ylabel('Power generation (MW)','FontSize',fontAxis);
% xlabel('Generator types','FontSize',fontAxis);
% set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
legend(generator_type,'Location','southeast','FontSize',fontLegend);
ylim([0,dc_cap]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'script_generator_power.eps']);
end

% figure
% plot(squeeze(G_array(1,2,:))')
% figure;
% plot(squeeze(G_array(1,3,:))')
% figure
% plot(squeeze(G_array(1,4,:))')

% Operating cost
figure;
xArray = 1:length(yArray);
yArray = zeros(1,length(xArray));
bar(xArray, yArray, 0.2);
ylabel('Operational cost','FontSize',fontAxis);
xlabel('Generator types','FontSize',fontAxis);
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
% ylim([0,max(max(yArray))*1.1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'gen_operational_cost.eps']);
end
% emissions
figure;
xArray = 1:length(yArray);
yArray = zeros(1,length(xArray));
bar(xArray, yArray, 0.2);
ylabel('emissions','FontSize',fontAxis);
xlabel('Generator types','FontSize',fontAxis);
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
% ylim([0,max(max(yArray))*1.1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'gen_emissions.eps']);
end

%% Peak-shaving %%%%%%%%%%%%
%% batch job
figure_settings; load('results/peak_shaving_batch_jobs.mat');  

yArray = dc_power_after';
xArray = (1:T)/HOUR;
figure;
plot(xArray,raw_dc_power,'LineWidth', lineWitdth);
hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
legendStr = {'original','0.5 hour','1 hour', '1.5 hours', '2 hours'};
legend(legendStr,'Location','southeast','FontSize',fontLegend);
% ylim([0,max(max(yArray))*1.3]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_batch_jobs.eps']);
end
%% cooling
%% batch job
figure_settings; load('results/peak_shaving_cooling.mat');  

yArray = dc_power_after';
xArray = (1:T)/HOUR;
figure;
% plot(xArray,raw_dc_power,'LineWidth', lineWitdth);
% hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% legendStr = {'original','0.5 hour','1 hour', '1.5 hours', '2 hours'};
% legend(legendStr,'Location','southeast','FontSize',fontLegend);
% ylim([0,max(max(yArray))*1.3]);
ylim([0,dc_cap]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_cooling.eps']);
end

%% energy storages
figure_settings; load('results/peak_shaving_ups.mat');  

yArray = dc_power_after';
xArray = (1:T)/HOUR;
figure;
% plot(xArray,raw_dc_power,'LineWidth', lineWitdth);
% hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% legendStr = {battery_types};
legend(battery_types,'Location','southeast','FontSize',fontLegend);
% ylim([0,max(max(yArray))*1.3]);
ylim([0,dc_cap]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_ups.eps']);
end

%% Back-up generators
figure_settings; load('results/peak_shaving_generator.mat');  

yArray = dc_power_after';
xArray = (1:T)/HOUR;
figure;
% plot(xArray,dc_power,'LineWidth', lineWitdth);
% hold on;
plot(xArray,yArray,'LineWidth', lineWitdth);
ylabel('Power (MW)','FontSize',fontAxis);
xlabel('Hours','FontSize',fontAxis);
% legendStr = {battery_types};
legend(generator_type,'Location','northeast','FontSize',fontLegend);
ylim([0,dc_cap]);
xlim([0,max(xArray)+1]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.0]);
if is_printed
    print ('-depsc', [fig_path 'peak_shaving_generator.eps']);
end