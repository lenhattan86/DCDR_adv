%This script plot the results from the output of simulation for each
%scenario

%% Plot the different parameters of energy storages using spider charts.
figure_settings;

% spider([1 2 3 4 5; 4 5 6 7 8; 7 8 9 10 11; 10 11 12 13 14; 13 14 15 16 17; ...
%  	16 17 18 19 18; 19 20 21 22 14; 22 23 24 25 14; 25 26 27 28 20],'test plot', ...
%  	[[0:3:24]' [5:3:29]'],[],{'LA' 'LI' 'UC' 'FW' 'CAES'});

%% PV generation

figure_settings;
load('results/script_batchjob.mat');  

rawPVGeneration = Feb26Irrad(1:sampling_interval:T*sampling_interval);
figure;
yArray = ;
xArray = 1:T;
plot(xArray,yArray, '-k', 'LineWidth', lineWitdth);
ylabel('Generation (KW)','FontSize',fontAxis);
xlabel(,'FontSize',fontAxis);
legendStr = {strDataCenter};
legend(legendStr,'Location','northeast','FontSize',fontLegend);
ylim([0,max(max(yArray))*1.1]);
 xlim([0,max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);
if is_printed
    print ('-depsc', [fig_path 'script_batchjob.eps']);
end

%% residential load

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
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);
if is_printed
    print ('-depsc', [fig_path 'script_batchjob.eps']);
end

%% Flexibility by degrading the QoS (Delay) of interactive workload.




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
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);

if is_printed
    print ('-depsc', [fig_path 'script_cooling.eps']);
end

%% UPS types
figure_settings;
load('results/script_ups.mat');  
figure;
yArray = violationFreq(1,:);
xArray = 1:length(yArray);
bar(xArray, yArray, 0.2);
ylabel(strViolationFreq,'FontSize',fontAxis);
xlabel('UPS types','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);

% xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);
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
xlabel('UPS types','FontSize',fontAxis);
set(gca,'xticklabel',battery_types,'FontSize',fontAxis);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);
legend({'charge','discharge'},'Location','northwest','FontSize',fontLegend);
if is_printed
    print ('-depsc', [fig_path 'script_ups_power.eps']);
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
% xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);
if is_printed
    print ('-depsc', [fig_path 'script_generator.eps']);
end

figure;
temp = squeeze(G_array(1,:,:));
yArray = sum(temp,2)/HOUR;
xArray = 1:length(yArray);
bar(xArray, yArray, 0.2);
ylabel('Power generation (MWh)','FontSize',fontAxis);
xlabel('Generator types','FontSize',fontAxis);
set(gca,'xticklabel',generator_type,'FontSize',fontAxis);
ylim([0,max(max(yArray))*1.1]);
% xlim([min(xArray),max(xArray)]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.0 0 4.0 3.5]);
if is_printed
    print ('-depsc', [fig_path 'script_generator_power.eps']);
end

% figure
% plot(squeeze(G_array(1,2,:))')
% figure;
% plot(squeeze(G_array(1,3,:))')
% figure
% plot(squeeze(G_array(1,4,:))')
