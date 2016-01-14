function [] = plotDCAllBuses(frac, cap, storage_cap, storageFrac, optimalStorageFrac, withStorage)

for i=1:length(cap)
    if cap(i) >= storage_cap
        upperIdx = i;
        break;
    end
end

lowerIdx = upperIdx - 1;
violationsFrac = zeros(1, length(frac));
for j=1:length(frac)
   fit = polyfit([cap(lowerIdx), cap(upperIdx)], [frac(j, lowerIdx), frac(j, upperIdx)], 1);

   targetFrac = fit(1)*130 + fit(2);
   violationsFrac(j) = targetFrac;
end

if withStorage
    fracDifference = violationsFrac - storageFrac;
    bar(1:length(storageFrac), [storageFrac(1:length(storageFrac))' fracDifference(1:length(storageFrac))'], 0.5, 'stack');
else
    bar(violationsFrac);
end   
    
xlabel('Bus Location of DC');
ylabel('Average DC Capacity at Same Capacity as Storage');

ylim([min(storageFrac) - 0.1, max(storageFrac) + 0.3])

hold on;

x = 0:1:length(frac)+1;
xlim([min(x), max(x)])
optimal = optimalStorageFrac*ones(1,length(x));
plot(x,optimal,'-r')


end

