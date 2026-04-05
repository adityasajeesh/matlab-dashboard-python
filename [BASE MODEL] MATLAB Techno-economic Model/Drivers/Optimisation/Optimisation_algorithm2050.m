%% Clear Data
clear
clc

%% Data
OutputFileName = "Optimising Backup and Renewables_LCOH 2050";

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

% Initial testing: PV: 0.75, ReM_OcM: 0.5, REM: 3.5, Storage_hrs: 8

PV_gen_share = 0.65:0.01:0.85; % percentage as a decimal 21 cases
ReM_OcM_Ratio = 0:0.1:2; % 21 cases
REM = 2.5:0.1:4.5; % 21 cases
Storage_hrs = 4:12; % 9 cases

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
                if mod(caseNumber,round(TotalCases/20,0)) == 0
                    fprintf("Progress: %.0f%%\tTime Elapsed: %.0f seconds\tEstimated Time Remaining: %.0f seconds\n", caseNumber/TotalCases*100, toc, toc*(TotalCases/caseNumber-1));
                end

                if(REM(k) * ReM_OcM_Ratio(j) < 1); continue; end
                Output = CombinedCases2050(PV_gen_share(i), ReM_OcM_Ratio(j), REM(k), Storage_hrs(l), SolarData, WindData, HourlyElectricityPrices);
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
