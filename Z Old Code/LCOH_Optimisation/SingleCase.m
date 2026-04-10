%% Clear Data
clear
clc

%% Data
[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

PV_gen_share = 0.6; % percentage as a decimal
ReM_OcM_Ratio = 2/3;
REM = 3;
Storage_hrs = 16;
CaseNumber = 1;

Table = table;

tic;

Output = CombinedCases(PV_gen_share, ReM_OcM_Ratio, REM, Storage_hrs, SolarData, WindData, HourlyElectricityPrices);

% Code to put data into table
Table.PV_gen_share = PV_gen_share;
Table.ReM_OcM_Ratio = ReM_OcM_Ratio;
Table.REM = REM;
Table.Storage_hrs = Storage_hrs;
Table.Storage_LCOH = Output.Storage_LCOH;
Table.GreenHydrogen_LCOH = Output.GreenHydrogen_LCOH_Optimisation;
Table.BlueHydrogen_LCOH = Output.BlueHydrogen_LCOH;
Table.Transport_LCHS = Output.Transport_LCHS;
Table.Electricity_LCOE = Output.Electricity_LCOE;
Table.Electricity_LCOH = Output.Electricity_LCOH;
Table.Steel_LCOS = Output.Steel_LCOS;
Table.Backup = sum(Output.Backup);

% command to export data from each case iteration
writetable(Table, strcat("Results\Data\Single Case Model Output.txt"))

% outputs time elapsed from tic call
time = toc
