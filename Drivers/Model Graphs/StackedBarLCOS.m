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


HourlyElectricityPrices = HourlyElectricityPrices + 36.5833;

Cases = 4;
CaseNames = ["100% Wind", "100% Solar", "Hybrid", "Blue Hydrogen", "PPA"]; % Each is optimised
OptimisedCases = [0.00 1.00 0.43 0.43 0.43;  % PV gen share (wind, solar, hybrid)
                  0.50 0.50 0.40 0.40 0.40;  % ReM OcM Ratio
                  2.90 4.60 3.40 3.40 3.40;  % ReM
                  21.0 15.0 19.0 19.0 19.0]; % Storage hours

LevelisedCost = [];
count = 1;

tic;

figure;

for i=1:Cases
    LevelisedCostIndex = 1;
    
    Output = CombinedCases(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    if i < 4
        arr = [Output.Electricity_LCOS, Output.Storage_LCOS, Output.Transport_LCHS, Output.GreenHydrogen_LCOS_Reporting_All, Output.Steel_LCOS, 0];
    elseif i == 4
        arr = [0, 0, Output.Transport_LCOS, 0,  Output.Steel_LCOS, Output.BlueHydrogen_LCOS];
    else
        arr = [Output.Electricity_LCOS, Output.Storage_LCOS, Output.Transport_LCHS, Output.GreenHydrogen_LCOS_Reporting_All_PPA, Output.Steel_LCOS, 0];
    end
    LevelisedCost = [LevelisedCost; arr];

end   

graph = bar(CaseNames(1:Cases), LevelisedCost, 'stacked');

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

% yline(500/0.65);
% yline(400/0.65);
legend('Renewables', 'Storage in Compressed Tanks', 'Transport in Pipelines', 'Electrolysis',...
     'Direct Reduction and Electric Arc Furnace', 'Steam Methane Reforming', 'Blast Furnace Cost Region');
ylabel("Levelised Cost of Steel ($AUD/tLS)");

fontname("Times New Roman");
fontsize(10, "points");

% outputs time elapsed from tic call
time = toc
