%This script plot the results from the output of simulation for each
%scenario



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
print ('-depsc', [fig_path 'script_batchjob.eps']);

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
print ('-depsc', [fig_path 'script_cooling.eps']);

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
% print ('-depsc', [fig_path 'script_ups.eps']);
