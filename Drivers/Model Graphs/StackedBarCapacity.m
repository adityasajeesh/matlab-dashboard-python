%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

orange = [1 0.698 0.4];
blue = [0.282 0.820 0.8];
green = [0.6 0.870 0.410];
pink = [1 0.713 0.757];
violet = [0.576 0.439 0.859];
grey = [0.5 0.5 0.5];

Cases = 3;
CaseNames = ["100% Wind", "100% Solar", "Hybrid"]; % Each is optimised
OptimisedCases = [0.00 1.00 0.43;  % PV gen share (wind, solar, hybrid)
                  0.50 0.50 0.40;  % ReM OcM Ratio
                  2.90 4.60 3.40;  % ReM
                  21.0 15.0 19.0]; % Storage hours

Capacities = [];
StorageCapacity = [];
LCOH = [];
count = 1;

tic;

figure;

for i=1:Cases
    LevelisedCostIndex = 1;
    
    Output = CombinedCases(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    arr = [Output.PVCapacity/1000, Output.WindCapacity/1000, Output.PEMCapacity/1000];
    arr2 = Output.StorageCapacity/1000;
    arr3 = [Output.GreenHydrogen_LCOH_Reporting_All NaN Output.Electricity_LCOH, Output.Storage_LCOH];
    Capacities = [Capacities; arr];
    StorageCapacity = [StorageCapacity, arr2];
    LCOH = [LCOH; arr3];

end   

subplot(1,2,1);
graph = bar(CaseNames, Capacities, 'stacked');

fontname('Times New Roman');
fontsize(10,"points");

set(graph, 'FaceColor', 'Flat');
graph(1).CData = [0 0 1];
graph(2).CData = [0 1 0];
graph(3).CData = [1 0 0];
set(graph, {'CData'}, mat2cell([orange;blue;green], ones(3,1), 3));

for i = 1:Cases
    % Find the total height of the stacked bar for each case
    totalHeight = sum(Capacities(i, :));
    
    % LCOH label positioned above the stacked bar
    text(i, totalHeight + 200, ... % Add a small offset to position the text above the bar
        sprintf('Solar/Wind LCOH: %.4f', LCOH(i, 1)), 'HorizontalAlignment', 'center');

    text(i, totalHeight + 100, ... % Add a small offset to position the text above the bar
        sprintf('PEM LCOH: %.4f', LCOH(i, 3)), 'HorizontalAlignment', 'center');
end

legend('Photovoltaics', 'Wind Turbines', 'Electrolysis');
ylabel("Capacity (MW)");


subplot(1,2,2);
bar(CaseNames, StorageCapacity, 'FaceColor', pink);
ylabel("Hydrogen Storage Capacity (tH_{2})");
legend('Hydrogen Storage');

for i = 1:Cases

    % LCOH label positioned above the stacked bar
    text(i, StorageCapacity(i), ... % Add a small offset to position the text above the bar
        sprintf('Storage LCOH: %.4f', LCOH(i, 4)), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end

fontname('Times New Roman');
fontsize(10,"points");

% outputs time elapsed from tic call
time = toc
