%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

Cases = 4;
CaseNames = ["HSH = 1", "HSH = 12", "HSH = 24", "0% Solar"]; % Each is optimised
OptimisedCases = [0.40 0.40 0.40 0.00;  % PV gen share (wind, solar, hybrid)
                  0.50 0.50 0.50 0.50;  % ReM OcM Ratio
                  2.00 2.00 2.00 2.00;  % ReM
                  1.00 12.0 24.0 1.0]; % Storage hours

hours = 1000;

x1 = 1:hours;

tic;

figure;

for i=1:Cases
    LevelisedCostIndex = 1;
    
    Output = CombinedCases(OptimisedCases(4*i-3), OptimisedCases(4*i-2), OptimisedCases(4*i-1), OptimisedCases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    
    if i ~= 4; subplot(2,2,i); else; figure; end
    % yyaxis left
    plot([1 hours], [Output.HourlyDemandedHydrogen*49.9 Output.HourlyDemandedHydrogen*49.9], ...
         x1, Output.TotalPower(1:hours), ...
         x1, Output.HydrogenCharge(1:hours)*49.9, ...
         x1, Output.Backup(1:hours), ...
         x1, Output.Curtailment(1:hours), ...
         'LineWidth', 2);

    xlabel("Time (hours)");
    ylabel("Power (kW)");
    title(CaseNames(i));
    set(gca, 'LineStyleOrder', '-', 'ColorOrder', 'default');
    ylim([-100*10^3 1200*10^3]);

    yyaxis right
    plot(x1, Output.StoredHydrogen(1:hours)*49.9, '-or');
    ylabel("Energy (kWh)");
    ylim([-100*10^3 1200*10^3]);
    legend('Demanded Power', 'Renewable Power', 'Charged Power', 'Backup Power', 'Curtailed Power', 'Stored Energy');
    % 'Stored Energy');



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
