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


Cases = 4;
CaseNames = ["Existing Hybrid with 2020 Costs", "Existing Hybrid with Updated Best Case Costs", "Best Case Hybrid", "Best Case Blue Hydrogen"];
OptimisedCases = [0.43 0.43 0.71 0.71;  % PV gen share (wind, solar, hybrid)
                  0.40 0.40 0.50 0.50;  % ReM OcM Ratio
                  3.40 3.40 3.30 3.30;  % ReM
                  19.0 19.0 11.0 11.0]; % Storage hours

LevelisedCost = [];
count = 1;

tic;

figure;

for i=1:Cases
    LevelisedCostIndex = 1;
    
    Output = CombinedCases2050(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    if i == 2 || i == 3
        Output = CombinedCases2050(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
        arr = [Output.Electricity_LCOS, Output.Storage_LCOS, Output.Transport_LCHS, Output.GreenHydrogen_LCOS_Reporting_All, Output.Steel_LCOS, 0];
    elseif i == 4
        Output = CombinedCases2050(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
        arr = [0, 0, Output.Transport_LCOS, 0,  Output.Steel_LCOS, Output.BlueHydrogen_LCOS];
    else
        Output = CombinedCases(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
        arr = [Output.Electricity_LCOS, Output.Storage_LCOS, Output.Transport_LCHS, Output.GreenHydrogen_LCOS_Reporting_All_PPA, Output.Steel_LCOS, 0];
    end
    LevelisedCost = [LevelisedCost; arr];

end   

graph = bar(CaseNames, LevelisedCost, 'stacked');

% Define your custom x-axis labels with manual line breaks
xtick_labels = {
    'Existing Hybrid\newlinewith 2020 Costs', 
    '    Existing Hybrid with\newlineUpdated Best Case Costs',
    'Best Case Hybrid', 
    '     Best Case\newlineBlue Hydrogen'
};

% Get the positions of the x-ticks
xtick_pos = get(gca, 'XTick');

% Clear the default x-tick labels
xticklabels([]);

% Add custom wrapped labels using 'text' function
for i = 1:length(xtick_labels)
    % Add each label with line breaks using 'newline'
    text(xtick_pos(i), -10, xtick_labels{i}, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 10, 'Interpreter', 'tex');
end

set(graph, 'FaceColor', 'Flat');
graph(1).CData = [0 0 0 0 0 1];
graph(2).CData = [0 0 0 0 1 0];
graph(3).CData = [0 0 0 1 0 0];
graph(4).CData = [0 0 1 0 0 0];
graph(5).CData = [0 1 0 0 0 0];
graph(6).CData = [1 0 0 0 0 0];
set(graph, {'CData'}, mat2cell([orange;pink;violet;green;grey;blue], ones(6,1), 3));

% Define the y-limits for shading
y_lower = 400/0.65;  % Lower y-value of the shaded region
y_upper = 500/0.65; % Upper y-value of the shaded region

% Create the shaded region
hold on;
fill([0 5 5 0], [y_lower y_lower y_upper y_upper], [0.2 0.2 0.2], 'FaceAlpha', 0.3);

fontname('Times New Roman');
fontsize(10, "points");

legend('Electricity', 'Storage', 'Transport', 'Green Hydrogen', 'DRI EAF', 'SMR', 'Blast Furnace');
ylabel("Levelised Cost of Steel ($AUD/tLS)");

% outputs time elapsed from tic call
time = toc
