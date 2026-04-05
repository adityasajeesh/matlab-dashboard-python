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

Colors = [blue; orange; green; violet];

PV_gen_share = 0.43; % percentage as a decimal
ReM_OcM_Ratio = 0.4;
REM = 2.5:0.5:4; % 5 cases
Storage_hrs = 1:50; % 100 cases

MaxBackupPercentage = 20; % in percent

iterations = length(PV_gen_share);

Wind_gen_share = ones(1, iterations) - PV_gen_share;
LevelisedCost = zeros(1,iterations);
Backup = zeros(1,iterations);
Curtailment = zeros(1,iterations);
Renewables = zeros(1,iterations);
HSH_Index = 1;

tic;

for i=1:length(PV_gen_share)
    for j=1:length(ReM_OcM_Ratio)
        figure;
        for k=1:length(REM)
            HSH_Index = 1;
            for l=1:length(Storage_hrs)
                Output = CombinedCases(PV_gen_share(i), ReM_OcM_Ratio(j), REM(k), Storage_hrs(l), SolarData, WindData, HourlyElectricityPrices);

                DemandedEnergy = Output.HourlyDemandedHydrogen * 24 * 366 * 49.9; % yearly amount of demanded energy
                LevelisedCost(HSH_Index) = sum([Output.Storage_LCOH, Output.GreenHydrogen_LCOH_Reporting_Renewables, Output.Transport_LCHS, Output.Electricity_LCOH]);
                Backup(HSH_Index) = sum(Output.Backup);
                Curtailment(HSH_Index) = sum(Output.Curtailment);
                Renewables(HSH_Index) = sum(Output.ProducedRenewableHydrogen)*49.9;

                HSH_Index = HSH_Index + 1;
            end

            [min_value, min_index] = min(LevelisedCost);
            
            subplot(2,2,1);
            if k == 1
                plot(Storage_hrs(min_index), Backup(min_index)/DemandedEnergy*100, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Backup Share at Minimum LCOH');
            else
                plot(Storage_hrs(min_index), Backup(min_index)/DemandedEnergy*100, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            end
            
            hold on;
            plot(Storage_hrs, Backup/DemandedEnergy*100, 'DisplayName', strcat("ReM = ", string(REM(k))), 'LineWidth', 1.5, 'Color', Colors(k,:));
            if k==length(REM); yline(MaxBackupPercentage, 'k--', 'DisplayName', 'Maximum Backup', 'LineWidth', 1.5); end
            ylim([0 100]);
            xlabel("Hours of storage");
            ylabel("Backup Share (%)");
            title("Backup");
            legend show;
            hold on;
            
            subplot(2,2,2);
            if k == 1
                plot(Storage_hrs(min_index), Curtailment(min_index)/DemandedEnergy*100, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Curtailment Share at Minimum LCOH');
            else
                plot(Storage_hrs(min_index), Curtailment(min_index)/DemandedEnergy*100, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            end      
                
            hold on;
            
            plot(Storage_hrs, Curtailment/DemandedEnergy*100, 'DisplayName', strcat("ReM = ", string(REM(k))), 'LineWidth', 1.5, 'Color', Colors(k,:));
            xlabel("Hours of storage");
            ylabel("Curtailment Share (%)");
            title("Curtailment");
            legend show;
            hold on;

            subplot(2,2,3);
            if k == 1
                plot(Storage_hrs(min_index), Renewables(min_index)/DemandedEnergy*100, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Renewable Share at Minimum LCOH');
            else
                plot(Storage_hrs(min_index), Renewables(min_index)/DemandedEnergy*100, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            end
                
            hold on;
               
            plot(Storage_hrs, Renewables/DemandedEnergy*100, 'DisplayName', strcat("ReM = ", string(REM(k))), 'LineWidth', 1.5, 'Color', Colors(k,:));
            xlabel("Hours of storage");
            ylabel("Renewable Share (%)");
            title("Renewable Hydrogen");
            legend show;
            hold on;

            subplot(2,2,4);
            if k == 1
                plot(Storage_hrs(min_index), LevelisedCost(min_index), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'DisplayName', 'Minimum LCOH');
            else
                plot(Storage_hrs(min_index), LevelisedCost(min_index), 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
            end
                
            hold on;
            
            plot(Storage_hrs, LevelisedCost, 'DisplayName', strcat("ReM = ", string(REM(k))), 'LineWidth', 1.5, 'Color', Colors(k,:));
            xlabel("Hours of storage");
            ylabel("Levelised cost of Hydrogen ($AUD/kgH2)");
            title("Levelised Cost");
            legend show;
            hold on;

            sgtitle(strcat("OcM Ratio = ", string(ReM_OcM_Ratio(j))));
        
        end
        fontname('Times New Roman');
        fontsize(10,"points");
        hold off;
    end

end

hold off;

% outputs time elapsed from tic call
time = toc
