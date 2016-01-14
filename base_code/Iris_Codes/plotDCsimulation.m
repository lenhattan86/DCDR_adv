function plotDCsimulation( fracInBounds, flexValues, storageAtSameBusFrac, optimalStorageFrac, optimalLoc)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

x = [0,(max(flexValues(:))) + 0.1];

if optimalLoc
    hold on
    plot(flexValues(:),fracInBounds(:), '-ok', 'LineWidth', 4);
    plot(x,[optimalStorageFrac,optimalStorageFrac],'-b', 'LineWidth', 4);
    h_legend = legend('Data Center', 'Optimal Storage');
else
    hold on
    plot(flexValues(:),fracInBounds(:), '-ok', 'LineWidth', 4);
    plot(x,[storageAtSameBusFrac,storageAtSameBusFrac], '--r', 'LineWidth', 4);
    plot(x,[optimalStorageFrac,optimalStorageFrac],'-b', 'LineWidth', 2);

    h_legend = legend('Data Center', 'Co-located Storage', 'Optimal Storage');
end
    
x_label = xlabel('Average Amount of Data Center Flexibility (KW)');
y_label = ylabel('Violation Frequency');
set(x_label, 'FontSize', 14);
set(y_label, 'FontSize', 14);
set(h_legend,'FontSize',14);  

xlim(x);
ylim([0, 0.4])

end

