%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

green = [0.6 0.870 0.410];
pink = [1 0.713 0.757];

Cases = 3;
CaseNames = ["100% Wind", "100% Solar", "Hybrid"]; % Each is optimised
OptimisedCases = [0.00 1.00 0.43;  % PV gen share (wind, solar, hybrid)
                  0.50 0.50 0.40;  % ReM OcM Ratio
                  2.90 4.60 3.40;  % ReM
                  21.0 15.0 19.0]; % Storage hours

count = 1;

tic;

figure;

for i=1:Cases
    LevelisedCostIndex = 1;
    
    Output = CombinedCases(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    
    subplot(3,2,count)

    data = Output.ProducedRenewableHydrogen/Output.TotalMassOutput*100;
    data(data>100) = 100;

    histogram(data, 'FaceColor', green);
    title(strcat(CaseNames(i), ': Produced Hydrogen'));
    xlabel("Electrolyser Utilisation (%)");
    % xlabel("Hydrogen Production (tH_{2}/h)");
    ylabel("Hours");
    ylim([0 5000]);


    % send Joseph a version with this as it was before and now
    subplot(3,2,count+1)
    histogram(Output.StoredHydrogen/Output.StorageCapacity*100, 'FaceColor', pink);
    title(strcat(CaseNames(i), ': Stored Hydrogen'));
    xlabel("Storage Utilisation (%)");
    ylabel("Hours");
    ylim([0 3500]);

    fontname('Times New Roman');
    fontsize(10,"points");

    count = count + 2;

end   

% outputs time elapsed from tic call
time = toc
