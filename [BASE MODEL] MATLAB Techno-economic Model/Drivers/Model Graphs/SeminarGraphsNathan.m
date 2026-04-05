%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

% NumCases = 6;
% CaseNames = ["Baseline", "100% Solar", "100% Wind", "Increased ReM OcM Ratio", "Increased ReM", "Increased Storage Hours"];
% Cases = [0.5  1   0  0.5 0.5 0.5; % PV gen share (baseline, 100% solar, 100% wind, increased ReM OcM Ratio, increased ReM, increased Storage Hours)
%          0.5 0.5 0.5  1  0.5 0.5; % ReM OcM Ratio
%           3   3   3   3   5   3 ; % ReM
%           2   2   2   2   2   4]; % Storage hours

NumCases = 4;
CaseNames = ["Baseline", "Increased ReM OcM Ratio", "Increased ReM", "Increased Storage Hours"];
Cases = [0.5 0.5 0.5 0.5; % PV gen share (baseline, 100% solar, 100% wind, increased ReM OcM Ratio, increased ReM, increased Storage Hours)
         0.5  1  0.5 0.5; % ReM OcM Ratio
          3   3   5   3 ; % ReM
          2   2   2   4]; % Storage hours

hours = 48;

x1 = 1:hours;

tic;

for i=1:NumCases
    % if i == 2 || i == 3; continue; end
    LevelisedCostIndex = 1;
    
    Output = CombinedCases(Cases(4*i-3), Cases(4*i-2), Cases(4*i-1), Cases(4*i), SolarData, WindData, HourlyElectricityPrices);       
    
    subplot(2,2,i);
    % yyaxis left
    plot([1 hours], [Output.HourlyDemandedHydrogen*49.9/1000 Output.HourlyDemandedHydrogen*49.9/1000], ...
         x1, Output.SolarPower(1:hours)/1000, ...
         x1, Output.WindPower(1:hours)/1000,...
         x1, Output.HydrogenCharge(1:hours)*49.9/1000, ...
         x1, Output.Backup(1:hours)/1000, ...
         x1, Output.Curtailment(1:hours)/1000, ...
         'LineWidth', 2);

    xlabel("Time (hours)");
    ylabel("Power (MW)");
    title(CaseNames(i));
    set(gca, 'LineStyleOrder', '-', 'ColorOrder', 'default');
    ylim([-5.5*10^2 26*10^2]);

    yyaxis right
    plot(x1, Output.StoredHydrogen(1:hours)*49.9/1000, '-or');
    ylabel("Energy (MWh)");
    ylim([-5.5*10^2 26*10^2]);
    legend('Demanded Power', 'Solar Power', 'Wind Power', 'Charged Power', 'Backup Power', 'Curtailed Power','Stored Energy');
    
    fontname('Times New Roman');
    fontsize(10,"points");

end   

Table = array2table(Cases, 'VariableNames', CaseNames, 'RowNames', {'PV Generation Share','ReM OcM Ratio','ReM','Storage Hours'});

% outputs time elapsed from tic call
time = toc
