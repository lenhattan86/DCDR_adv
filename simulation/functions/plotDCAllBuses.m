function [] = plotDCAllBuses(dcFrac, storageFrac, optimalStorageFrac)

b = bar([dcFrac, storageFrac], 'grouped');

set(b(2),'FaceColor','m');
set(b(1),'FaceColor','k')
    
x_label = xlabel('Bus Location');
y_label = ylabel('Violation Frequency');

set(x_label, 'FontSize', 14);
set(y_label, 'FontSize', 14);

l = legend('Data Center', 'Storage');
set(l, 'FontSize', 14);

hold on;

x = [0,length(storageFrac)+1];
plot(x,[optimalStorageFrac,optimalStorageFrac],'-b', 'LineWidth', 2);

xlim(x);
end

