%% Clear Data
clear
clc

%% Data
OutputFileName = "Optimising Backup and Renewables_LCOH (higher resolution)";

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

HourlyElectricityPrices = HourlyElectricityPrices + 36.5833;

% Based on last case of PV: 0.4, ReM_OcM: 0.5, ReM: 3, Storage_hrs 18

PV_gen_share = 0.3:0.01:0.5; % percentage as a decimal 21 cases
ReM_OcM_Ratio = 0:0.1:2; % 21 cases
REM = 2:0.1:4; % 21 cases
Storage_hrs = 10:25; % 16 cases

% outcome of this code was PV: 0.43, ReM_OcM: 0.4, ReM: 3.4, Storage_hrs 19
% with 19.9% backup share and $9.8659 / kgH2 levelised cost

Table = table;
Table1 = table;

caseNumber = 0;
TotalCases = length(PV_gen_share)*length(ReM_OcM_Ratio)*length(REM)*length(Storage_hrs);

tic;

for i=1:length(PV_gen_share)
    for j=1:length(ReM_OcM_Ratio)
        for k=1:length(REM)
            for l=1:length(Storage_hrs)
                caseNumber = caseNumber + 1;
                
                % Update algorithm progress status
                if mod(caseNumber,round(TotalCases/100,0)) == 0
                    fprintf("Progress: %.0f%%\tTime Elapsed: %.0f seconds\tEstimated Time Remaining: %.0f seconds\n", caseNumber/TotalCases*100, toc, toc*(TotalCases/caseNumber-1));
                end

                if(REM(k) * ReM_OcM_Ratio(j) < 1); continue; end
                Output = CombinedCases(PV_gen_share(i), ReM_OcM_Ratio(j), REM(k), Storage_hrs(l), SolarData, WindData, HourlyElectricityPrices);
                DemandedEnergy = Output.HourlyDemandedHydrogen * 24 * 366 * 49.9; % yearly amount of demanded energy

                Table.PV_gen_share = PV_gen_share(i);
                Table.OcM = ReM_OcM_Ratio(j);
                Table.REM = REM(k);
                Table.Storage_hrs = Storage_hrs(l);
                Table.BackupShare = sum(Output.Backup)/DemandedEnergy;

                Table.Storage_LCOH = Output.Storage_LCOH;
                Table.GreenHydrogen_LCOH = Output.GreenHydrogen_LCOH_Reporting_Renewables;
                Table.Transport_LCHS = Output.Transport_LCHS;
                Table.Electricity_LCOH = Output.Electricity_LCOH;
                Table.Total_LCOH = sum([Output.Storage_LCOH, Output.GreenHydrogen_LCOH_Reporting_Renewables, Output.Transport_LCHS, Output.Electricity_LCOH]);

                Table1 = [Table1; Table];

            end        
        end
    end

end

% command to export data from each case iteration
writetable(Table1, strcat("Drivers\Optimisation\Saved Data\", OutputFileName, ".txt"))

% outputs time elapsed from tic call
time = toc
