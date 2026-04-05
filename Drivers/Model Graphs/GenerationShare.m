%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

green = [0.6 0.870 0.410];

PV_gen_share = 0:0.01:1; % percentage as a decimal
ReM_OcM_Ratio = 0.4;
REM = 3.4;
Storage_hrs = [2 4 8 16 19 24];

iterations = length(PV_gen_share);

Wind_gen_share = ones(1, iterations) - PV_gen_share;
LevelisedCost = zeros(1,iterations);
Backup = zeros(1,iterations);
Curtailment = zeros(1,iterations);
LeveliesdCostIndex = 1;

tic;

figure;

for i=1:length(Storage_hrs)
    LevelisedCostIndex = 1;
    for j=1:length(ReM_OcM_Ratio)
        for k=1:length(REM)
            for l=1:length(PV_gen_share)
                Output = CombinedCases(PV_gen_share(l), ReM_OcM_Ratio(j), REM(k), Storage_hrs(i), SolarData, WindData, HourlyElectricityPrices);
                DemandedEnergy = Output.HourlyDemandedHydrogen * 24 * 366 * 49.9; % yearly amount of demanded energy

                LevelisedCost(LevelisedCostIndex) = sum([Output.Storage_LCOH, Output.GreenHydrogen_LCOH_Reporting_Renewables, Output.Transport_LCHS, Output.Electricity_LCOH]);
                Backup(LevelisedCostIndex) = sum(Output.Backup)/DemandedEnergy*100;
                Curtailment(LevelisedCostIndex) = sum(Output.Curtailment)/DemandedEnergy*100;

                LevelisedCostIndex = LevelisedCostIndex + 1;
            end
        end
    end

    % Find index where Backup is closest to 20%
    [~, backup_20_index] = min(abs(Backup - 20)); 

    subplot(3,2,i);
    fontname('Times New Roman');
    fontsize(10,"points");
    
    yyaxis left;
    plot(PV_gen_share, Backup, PV_gen_share, Curtailment, 'LineWidth', 1.5);
    xline(PV_gen_share(backup_20_index), ':k', 'LineWidth', 1.5);
    xlabel("Solar's Share of Renewable Energy");
    ylabel("Share (%)");
    title(strcat("Generation Share with HSH = ", string(Storage_hrs(i))));
    % ylim([0 10*10^9]);

    yyaxis right;
    plot(PV_gen_share, LevelisedCost, 'LineWidth', 1.5, 'Color', green);
    hold on;
    [min_value, min_index] = min(LevelisedCost);
    plot(PV_gen_share(min_index), min_value, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    xlabel("Solar's Share of Renewable Energy");
    ylabel("LCOH (AUD/kgH_{2})");
    legend('Backup Share', 'Curtailment Share', 'Optimal Solar Share', 'LevelisedCost', 'Minimum LCOH');
    % ylim([23 50]);
    ax = gca;
    ax.YAxis(2).Color = green;

    % if Storage_hrs(i) == 19
    %     array = [PV_gen_share; Backup; Curtailment; LevelisedCost]
    %     writematrix(array, "MoreDataForRino.txt");
    % end



    hold off;

end

% outputs time elapsed from tic call
time = toc
