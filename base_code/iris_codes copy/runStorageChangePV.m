load testdayirrad.mat

% Change stuff here
power_case = case47custom;
numBuses = 47;
pvBus = 45;

opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0);

pv_cap = 0:10:100;
storageCap = 130;

storageBus = [3];
fracinbounds = zeros(1,length(pv_cap));
busoutbounds = zeros(1,length(pv_cap));

for b = 1:length(pv_cap)
    disp('-----------------------------------------------------------');
    tic
    [fracinbounds(b), busoutbounds(b)] = nonviolationfraction(power_case, pv_cap(b),...
        Feb26Irrad, minuteloadFeb2012(36001:37440), opt, storageCap,...
        storageBus, numBuses, pvBus, false, false); % Feb 26, 2013
    toc
%     fprintf('Storage bus: %d \n Storage Cap: %d \n Non-Viol Frac: %d |\n Num Viol: %d \n',...
%         storageBus, storageCap, fracinbounds(b), busoutbounds(b));
end

disp('Non-violation Fractions:');
disp(fracinbounds)
disp('Number of Violations:');
disp(busoutbounds)

% Plots
hold on
plot(pv_cap(:),fracinbounds(:), 'ro')
xlabel('Location of Storage Bus');
ylabel('Non-Violation Fraction');
hold off;
