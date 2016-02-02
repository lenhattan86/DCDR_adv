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
print ('-depsc', [FIG_PATH 'script_batchjob.eps']);

%% Flexibility by dedrading the QoS (Delay) of interactive workload.



%% Flexiblity of cooling systems.

%% 