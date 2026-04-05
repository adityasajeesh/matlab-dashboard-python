%% Optimisation_algorithm
%   Description:
%       Driver script to run optimisation cases as defined in arrays below
%       and collate the needed output data in a table for further analysis.
%       

%% Clear Data
clear
clc

%% Obtain Data
OutputFileName = "Optimising Backup and System_LCOH";

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

% Hourly electricity prices are based on 2020, 36.5833 is added to give the prices a more present real value.
HourlyElectricityPrices = HourlyElectricityPrices + 36.5833;

% Array creation determining the scenarios the code is being run for
PV_gen_share = 0:0.05:1; % percentage as a decimal 21 cases
ReM_OcM_Ratio = 0.5:0.5:3; % 6 cases
REM = 1:0.5:5; % 9 cases
Storage_hrs = 1:25; % 26 cases

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

                % if overcapacity multiple is greater than 1, run the case, otherwise skip this one
                if(REM(k) * ReM_OcM_Ratio(j) < 1); continue; end 
                Output = CombinedCases(PV_gen_share(i), ReM_OcM_Ratio(j), REM(k), Storage_hrs(l), SolarData, WindData, HourlyElectricityPrices);
                DemandedEnergy = Output.HourlyDemandedHydrogen * 24 * 366 * 49.9; % yearly amount of demanded energy

                Table.PV_gen_share = PV_gen_share(i);
                Table.OcM = ReM_OcM_Ratio(j);
                Table.REM = REM(k);
                Table.Storage_hrs = Storage_hrs(l);
                Table.BackupShare = sum(Output.Backup)/DemandedEnergy;

                Table.Storage_LCOH = Output.Storage_LCOH;
                Table.GreenHydrogen_LCOH = Output.GreenHydrogen_LCOH_Optimisation;
                Table.Transport_LCHS = Output.Transport_LCHS;
                Table.Electricity_LCOH = Output.Electricity_LCOH;
                Table.Total_LCOH = sum([Output.Storage_LCOH, Output.GreenHydrogen_LCOH_Optimisation, Output.Transport_LCHS, Output.Electricity_LCOH]);

                Table1 = [Table1; Table];

            end        
        end
    end

end

% command to export data from each case iteration
writetable(Table1, strcat("Drivers\Optimisation\Saved Data\", OutputFileName, ".txt"))

% outputs time elapsed from tic call
time = toc
