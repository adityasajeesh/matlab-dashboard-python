%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

PV_gen_share = 0.43; % percentage as a decimal
ReM_OcM_Ratio = 0.5;
REM = 2.5:0.5:4; % 5 cases
Storage_hrs = 1:24; % 24 cases

iterations = length(PV_gen_share);

Wind_gen_share = ones(1, iterations) - PV_gen_share;
LevelisedCost = zeros(1,iterations);
Backup = zeros(1,iterations);
Curtailment = zeros(1,iterations);
HSH_Index = 1;

tic;

figure;

for i=1:length(PV_gen_share)
    for j=1:length(ReM_OcM_Ratio)
        for k=1:length(REM)
            HSH_Index = 1;
            for l=1:length(Storage_hrs)
                Output = CombinedCases(PV_gen_share(i), ReM_OcM_Ratio(j), REM(k), Storage_hrs(l), SolarData, WindData, HourlyElectricityPrices);

                LevelisedCost(HSH_Index) = sum([Output.Storage_LCOH, Output.GreenHydrogen_LCOH_Optimisation, Output.Transport_LCHS, Output.Electricity_LCOH]);
                Backup(HSH_Index) = sum(Output.Backup);
                Curtailment(HSH_Index) = sum(Output.Curtailment);

                HSH_Index = HSH_Index + 1;
            end
        
            subplot(2,2,1);
            plot(Storage_hrs, Backup, 'DisplayName', strcat("ReM = ", string(REM(k))));
            xlabel("Hours of storage");
            ylabel("Backup Energy (kWh)");
            title("Backup")
            legend show;
            hold on;
            
            subplot(2,2,2);
            plot(Storage_hrs, Curtailment, 'DisplayName', strcat("ReM = ", string(REM(k))));
            xlabel("Hours of storage");
            ylabel("Curtailment (kWh)");
            title("Curtailment");
            legend show;
            hold on;

            subplot(2,2,3);
            plot(Storage_hrs, LevelisedCost, 'DisplayName', strcat("ReM = ", string(REM(k))));
            xlabel("Hours of storage");
            ylabel("Levelised cost of Hydrogen ($AUD/kgH2)");
            title("Levelised Cost")
            legend show;
            hold on;
        
        
        end
    end

end   

fontname('Times New Roman');
fontsize(10,"points");

hold off;

% outputs time elapsed from tic call
time = toc
