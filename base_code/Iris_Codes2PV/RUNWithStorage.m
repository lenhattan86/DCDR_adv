load testdayirrad.mat

% Change stuff here
power_case = case47custom;
numBuses = 47;
pvBus = 45;

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

PVcapacity = 30;
storageCap = 60;

%storageBus = 1:1:numBuses;
storageBus = 44;
violationFrac = zeros(1,length(storageBus));
busoutbounds = zeros(1,length(storageBus));

% No storage case
% [n, noStorage_busoutbounds] = nonviolationfraction(power_case, PVcapacity,...
%         Feb26Irrad, minuteloadFeb2012(36001:37440), opt, storageCap,...
%         storageBus(1), numBuses, pvBus, false, false)

for b = 1:length(storageBus)
    disp('-----------------------------------------------------------');
    tic
    [violationFrac(b), busoutbounds(b)] = nonviolationfraction(power_case, PVcapacity,...
        Feb26Irrad, minuteloadFeb2012(36001:37440), opt, storageCap,...
        storageBus(b), numBuses, pvBus, true, false); % Feb 26, 2013
    toc
    if b == 1
        noStorage_fracinbounds = violationFrac(b)
    end
    
    fprintf('Storage bus: %d \n Storage Cap: %d \n Non-Viol Frac: %d \n Num Viol: %d \n',...
        storageBus(b), storageCap, violationFrac(b), busoutbounds(b));
end

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

%save('storage2PV-zhenhua-1126.mat')
