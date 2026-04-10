%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

Cases = 3;
CaseNames = ["100% Wind", "100% Solar", "Hybrid"]; % Each is optimised
OptimisedCases = [0.00 1.00 0.43;  % PV gen share (wind, solar, hybrid)
                  0.50 0.50 0.40;  % ReM OcM Ratio
                  2.90 4.60 3.40;  % ReM
                  21.0 15.0 19.0]; % Storage hours

hours = 48;

x1 = 1:hours;

tic;

figure;

for i=1:Cases
    LevelisedCostIndex = 1;
    
    Output = CombinedCases(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    
    subplot(2,2,i);
    % yyaxis left
    plot([1 hours], [Output.HourlyDemandedHydrogen*49.9/1000 Output.HourlyDemandedHydrogen*49.9/1000], ...
         x1, Output.TotalPower(1:hours)/1000, ...
         x1, Output.HydrogenCharge(1:hours)*49.9/1000, ...
         x1, Output.Backup(1:hours)/1000, ...
         x1, Output.Curtailment(1:hours)/1000, ...
         'LineWidth', 2);

    xlabel("Time (hours)");
    ylabel("Power (MW)");
    title(CaseNames(i));
    set(gca, 'LineStyleOrder', '-', 'ColorOrder', 'default');
    ylim([-750 3000]);

    yyaxis right
    plot(x1, Output.StoredHydrogen(1:hours)*49.9/1000, '-or');
    ylabel("Energy (MWh)");
    ylim([0 8000]);
    legend('Demanded Power', 'Renewable Power', 'Charged Power', 'Backup Power', 'Curtailed Power', 'Stored Energy');



end   


% x1 = StartIndex:FinishIndex;
% 
% for i=1:4
%     HydrogenStorageHours = 2^(i-1);
%     [OutputHydrogen, StoredHydrogen, ChargedEnergy, GridEnergy, WastedHydrogen] = Storage(Hydrogen, HydrogenRequired, HydrogenStorageHours);
% 
%     ExportData(x1, OutputHydrogen, Hydrogen, ChargedEnergy, GridEnergy, WastedHydrogen, StoredHydrogen, HydrogenStorageHours);
% 
%     subplot(2,2,i);
%     yyaxis left
%     % plot([StartIndex FinishIndex], [OutputHydrogen*0.033 OutputHydrogen*0.033], xaxis, Hydrogen*0.033, xaxis, StoredHydrogen*0.033, xaxis, ChargedEnergy*0.033, xaxis, GridEnergy, xaxis, WastedHydrogen*-0.033, 'LineWidth', 2);
%     plot([StartIndex FinishIndex], [OutputHydrogen*0.033 OutputHydrogen*0.033], x1, Hydrogen*0.033, x1, ChargedEnergy*0.033, x1, GridEnergy, x1, WastedHydrogen*-0.033, 'LineWidth', 2);
% 
%     xlabel("Time (hours)");
%     ylabel("Power (MW)");
%     if i==4, ylim([-20 60]); else, ylim([-20 35]); end
%     title(strcat("Hours of Storage = ", string(HydrogenStorageHours)));
%     set(gca, 'LineStyleOrder', '-', 'ColorOrder', 'default');
%     yyaxis right
%     plot(x1, StoredHydrogen*0.033, '-or');
%     if i==4, ylim([-20 60]); else, ylim([-20 35]); end
%     ylabel("Energy (MWh)");
%     legend('Demanded Power', 'Renewable Hydrogen Power', 'Charged Power', 'Outsourced Power', 'Wasted Hydrogen Power', 'Stored Energy');
% end


% outputs time elapsed from tic call
time = toc
