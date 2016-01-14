clear
load testdayirrad.mat


opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

% Change stuff here
%{
power_case = case47custom;
numBuses = 47;
pvBus = 45;
PVcapacity = 30;
storageCap = [60 180 300 600 900];
%}

power_case = case56customv2;
numBuses = 56;
pvBus = 45;
PVcapacity = 6;
storageCap = [6 18 30 60 90];

%storageBus = 1:1:numBuses;
storageBus = 53;
violationFrac = zeros(1,length(storageBus));
busoutbounds = zeros(1,length(storageBus));

ramping_rate = [0.02, 0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 1];
% No storage case
% [n, noStorage_busoutbounds] = nonviolationfraction(power_case, PVcapacity,...
%         Feb26Irrad, minuteloadFeb2012(36001:37440), opt, storageCap,...
%         storageBus(1), numBuses, pvBus, false, false)
for i = 1:length(storageCap)   
    for b = 1:length(ramping_rate)
        disp('-----------------------------------------------------------');
        tic
        storageCap(i)
        ramping_rate(b)
        [violationFrac(b,i), busoutbounds(b,i)] = nonviolationfraction_storage_rate(power_case, PVcapacity,...
            Feb26Irrad, minuteloadFeb2012(36001:37440), opt, storageCap(i),...
            storageBus(1), 0, ramping_rate(b), numBuses, pvBus, true, false) % Feb 26, 2013
        toc
        if b == 1
            noStorage_fracinbounds = violationFrac(b,i)
        end

        %fprintf('Storage bus: %d \n Storage Cap: %d \n Non-Viol Frac: %d \n Num Viol: %d \n',...
        %    storageBus(b), storageCap, violationFrac(b), busoutbounds(b));
    end
end
%{
figure;
plot(1/60:1/60:24*7, Feb2012Irrad(1440*21+1:1440*21+1440*7)/1000,'g-','LineWidth',2)
xlabel('hour');
ylabel('Normalized PV generation');
xlim([0,24*7]);
ylim([0,1]);
set(gca,'XTick',[0:24:24*7]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 6.0 2.0]);
print ('-depsc', 'solar.eps');
eps2pdf('solar.eps','/usr/local/bin/gs');
%}

%{
figure;
plot(ramping_rate,violationFrac(:,1),'k-','LineWidth',2)
hold on;
plot(ramping_rate(1:8),violationFrac(1:8,2),'r-','LineWidth',2)
hold on;
plot(ramping_rate(1:6),violationFrac(1:6,3),'b-','LineWidth',2)
hold on;
hold on;
plot(ramping_rate(1:4),violationFrac(1:4,4),'g-','LineWidth',2)
hold on;
plot(ramping_rate(1:4),violationFrac(1:4,5),'y-','LineWidth',2)
legend('capacity = 1MWh','capacity = 3MWh','capacity = 5MWh','capacity = 10MWh','capacity = 15MWh')
xlabel('charging rate (fraction in one minute)');
ylabel('Violation Frequency');
xlim([0.02,1]);
ylim([0.03,0.5]);
set(gca,'XTick',[0.02, 0.2, 0.4, 0.6, 0.8, 1]);
set(gca,'YTick',[0.03, 0.1, 0.2, 0.3, 0.4, 0.5]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.4]);
print ('-depsc', 'SCE47_Storage_Ramp.eps');
eps2pdf('SCE47_Storage_Ramp.eps','/usr/local/bin/gs');
%}

%{
figure;
plot(ramping_rate,violationFrac(:,1),'k-','LineWidth',2)
hold on;
plot(ramping_rate(1:8),violationFrac(1:8,2),'r-','LineWidth',2)
hold on;
plot(ramping_rate(1:7),violationFrac(1:7,3),'b-','LineWidth',2)
hold on;
hold on;
plot(ramping_rate(1:5),violationFrac(1:5,4),'g-','LineWidth',2)
hold on;
plot(ramping_rate(1:5),violationFrac(1:5,5),'y-','LineWidth',2)
legend('capacity = 0.1MWh','capacity = 0.3MWh','capacity = 0.5MWh','capacity = 1MWh','capacity = 1.5MWh')
xlabel('charging rate (fraction in one minute)');
ylabel('Violation Frequency');
xlim([0.02,1]);
ylim([0.03,0.5]);
set(gca,'XTick',[0.02, 0.2, 0.4, 0.6, 0.8, 1]);
set(gca,'YTick',[0.03, 0.1, 0.2, 0.3, 0.4, 0.5]);
set (gcf, 'PaperUnits', 'inches', 'PaperPosition', [0.1 0 3.6 2.4]);
print ('-depsc', 'SCE56_Storage_Ramp.eps');
eps2pdf('SCE56_Storage_Ramp.eps','/usr/local/bin/gs');
%}

%{
xlim([0,numBuses + 1])
x = 0:0.05:numBuses+1;
y = noStorage_fracinbounds*ones(1,length(x));

disp('Non-violation Fractions:');
disp(violationFrac)
disp('Number of Violations:');
disp(busoutbounds)
[minViolations, minIdx] = min(violationFrac);
fprintf('Optimal storage location at bus: %d\n', minIdx);

% Plots
hold on
plot(storageBus(:),violationFrac(:), 'ro')
plot(x,y,'-b');
xlabel('Location of Storage Bus');
ylabel('Non-Violation Fraction');
hold off;
%}
%save('storage-60-zhenhua-1127.mat')