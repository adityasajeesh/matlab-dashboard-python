%% Clear Data
clear
clc

%% Data

OutputFileName = "HighResolutionTestingCC";

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

PV_gen_share = 0.15:0.01:0.65; % 50 cases
ReM_OcM_Ratio = 0.35:0.05:0.75; % 9 cases
REM = 1.5:0.1:3.5; %21 cases
Storage_hrs = [1 2 4 8 16 24 48]; % 7 cases
CaseNumber = 1;

Table = table;
Table1 = table;

tic;

for i=1:length(PV_gen_share)
    for j=1:length(ReM_OcM_Ratio)
        for k=1:length(REM)
            for l=1:length(Storage_hrs)
                if(REM(k) * ReM_OcM_Ratio(j) < 1); continue; end
                Output = CombinedCases(PV_gen_share(i), ReM_OcM_Ratio(j), REM(k), Storage_hrs(l), SolarData, WindData, HourlyElectricityPrices);

                % Code to gather the data outputted in each case
                Table.PV_gen_share = PV_gen_share(i);
                Table.ReM_OcM_Ratio = ReM_OcM_Ratio(j);
                Table.REM = REM(k);
                Table.Storage_hrs = Storage_hrs(l);
                Table.Storage_LCOH = Output.Storage_LCOH;
                Table.GreenHydrogen_LCOH = Output.GreenHydrogen_LCOH_Optimisation;
                % Table.BlueHydrogen_LCOH = Output.BlueHydrogen_LCOH;
                Table.Transport_LCHS = Output.Transport_LCHS;
                % Table.Electricity_LCOE = Output.Electricity_LCOE;
                Table.Electricity_LCOH = Output.Electricity_LCOH;
                Table.Electricity_LCOS = Output.Electricity_LCOS;
                % Table.Steel_LCOS = Output.Steel_LCOS;
                Table.Total_LCOH = sum([Output.Storage_LCOH, Output.GreenHydrogen_LCOH_Optimisation, Output.Transport_LCHS, Output.Electricity_LCOH]);

                % Appending the data from this case onto a table with all
                % outputs of the cases
                Table1 = [Table1; Table];
                
                CaseNumber = CaseNumber + 1;
            end
        end
    end
end   

% command to export data from each case iteration
writetable(Table1, strcat("Results\Data\", OutputFileName, ".txt"))

% outputs time elapsed from tic call
time = toc
