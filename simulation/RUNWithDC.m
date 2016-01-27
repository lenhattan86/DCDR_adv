init_settings
%%
opt = mpoption('VERBOSE', 0, 'OUT_ALL', 0); % Verbose = 0 suppresses
% convergence printed output, out_all = 0 suppresses printed results of pf
% analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Make changes here
power_case = case47custom;
numBuses = 47;
% DCcapacities = 23.47;
% DCcapacities = [7.8,8,10,12,14,16,18,20,22,24,26,28];
% DCcapacities = [70,80,90,95,100,105,110,115,120,125];
% DCcapacities = 118.8700;
DCcapacities = 20;
p = 0:0.1:0.5; % flexibility of data centers
dcBus = 2; % dc bus location
pvBus = 45; % bus location of PV

PVcapacity = 30;
violationFreq = zeros(length(dcBus), length(p));
busoutbounds = zeros(length(dcBus), length(p));
avg_cap = zeros(length(dcBus), length(p));


for b = 1:length(dcBus)
    disp('---------------------------------------------------')
    for c = 1:length(p)
        tic
        [violationFreq(b,c), busoutbounds(b,c), avg_cap(b,c)] =...
            nonviolationfractiondc(power_case, PVcapacity,...
            Feb26Irrad, minuteloadFeb2012(36001:37440), ...
            repmat(dc_power,size(Feb2012Irrad,1)/length(dc_power),1),...
            dc_ratio, ...
            DCcapacities,...
            p(c),...
            opt,...
            dcBus(b),...
            numBuses,...
            pvBus,...
            false);
        toc
        fprintf('DC: bus %d \n Flex Value: %d \n Non-Viol Frac: %d \n Num Viol: %d \n Avg Cap: %d \n',...
            dcBus(b), p(c), violationFreq(b,c), busoutbounds(b,c), avg_cap(b,c));
    end
end

disp('Violation Fractions:');
disp(violationFreq)
disp('Number of Violations:');
disp(busoutbounds)
disp('Average DC flexbility range:');
disp(avg_cap)

optimal = 0.2344;
optimalBus = 0.3060;
plotDCsimulation(violationFreq(1,:), p(:), optimalBus, optimal, false);

