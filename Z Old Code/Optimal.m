function [Output] = CombinedCases(PV_gen_share, OcM, ReM, Storage_hrs, SolarData, WindData, HourlyElectricityPrices)

%% Establish case variables
LC. PV_gen_share   = PV_gen_share  ; % Percentage of solar wind splits
LC. ReM            = ReM           ; % Renewable Multiple
LC. OcM            = OcM           ; % Overcapacity multiple
LC. Storage_hrs    = Storage_hrs   ; % hrs

%% Struct Variables from Mass Balance Excel Sheet
% LC. OcM = LC.ReM_OcM_Ratio * LC.ReM;
LC. HourlyDemandedHydrogen = 8546.86487 + 88380/49.9; %kg/hr % 10,318.00715456914
LC. Nom_H2_flow = LC.HourlyDemandedHydrogen*24; %kg/day
LC. HourlyCapacitywithOversize = LC.OcM * LC.HourlyDemandedHydrogen; % kg/hr
LC. LiquidSteelSpecificElectricityConsumption = 753000; % MWh/kgLS (to be deleted)

%% Determine Simulated Time Period
TimePeriod = 366; % days
LC.TimePeriodHours = TimePeriod*24; % hours

%% Obtain Raw Solar and Wind Data and define needed variables
LC. ReferenceHeight       = 9.3       ; % function of weather station (from Nathan's data)
LC. H2_energy_density    = 33.33      ; % kWh/kgH2
LC. Cp                   = 0.505      ; % coefficient of performance
LC. AirDensity           = 1.2250     ; % kg/m^3 (@15deg Celcius)

%% Solar
LC. ConvEfncy             = 0.19      ; % conversion efficiency (from solar panel datasheet)
LC. Degradation           = 0.003     ; % 
LC. EAF_Spec_Cons         = 753       ; % kWh/tLS
LC. GH_Spec_Cons          = 49.9      ; % kWh/kgH2
LC. PlantAge              = 0         ; % yrs

LC. SolarRatedPower       = 0.48      ; % kW (from solar panel datasheet)
LC. AreaPanel             = 2.52      ; % m^2 (from solar panel datasheet)
LC. Prod_Cap              = 1000000   ; % LC.Prod_Cap is the per annum production capacity of liquid steel (To be assigned)
LC. PVCapacityFactor      = 0.2223    ; % was previously 1; this value came from solar code

%% Wind
LC. WindRatedPower        = 5200      ; % kW
LC. RotorRadius           = 82.5      ; % m
LC. HubHeight             = 100       ; % m
LC. CutInSpeed            = 3         ; % m/s
LC. CutOutSpeed           = 24        ; % m/s
LC. RatedSpeed            = 10.3      ; % m/s

LC. GSC                   = 0.15      ; % Ground surface coefficient is a funciton of the site
LC. WindCapacityFactor    = 0.38      ; % WindCapacity Factor is a function of the site (constant, needs to be calculated, Wind power for the year divided by rated power *8760)

%% Determine Solar and Wind Power
[SolarPower, LC.PVCapacity] = Solar(LC, SolarData);
[WindPower, LC.WindCapacity] = Wind(LC, WindData);
TotalPower = SolarPower + WindPower;

%% Determine Hydrogen Produced from Electrolyser and Storage
LC. GH_Water_use            = 10.23    ; % L/kgH2
LC. MassOutput              = 4250     ; % kgH2/day (of single electrolyser)

ElectStorageOutput = Scenario1(LC, TotalPower);

LC.HourlyProducedRenewableHydrogen = (ElectStorageOutput.ElectrolyserInputPower - ElectStorageOutput.BackUpElectricity)/LC.GH_Spec_Cons;

LC.HourlyProducedHydrogen = ElectStorageOutput.ElectrolyserInputPower/LC.GH_Spec_Cons; % does include backup

LC.Ann_energy_prod = sum(TotalPower) - sum(ElectStorageOutput.Curtailment); %kW

SumElectPrice = ElectStorageOutput.BackUpElectricity .* reshape(HourlyElectricityPrices, 1, 8784);
LC.SumElectPrice = sum(SumElectPrice);

ElectPricePPA = ElectStorageOutput.BackUpElectricity * 97.5;
LC.ElectPricePPA = mean(ElectPricePPA);

%% Storage
LC. S_CAPEX              = 1662.00    ; % AUD/kgH2
LC. Storage_loss_pct_yr  = 0.015      ; % percentage/yr
LC. S_OandM_pct_CAPEX    = 0.0254     ; % percentage
LC. S_Life               = 35         ; % yrs
LC. S_Disc_Rate          = 0.07       ; % percentage

LC. HydrogenReqTonneSteel = 72.819289 ; %kgH2/tLS

StorageOutput = LCStorage(LC);

%% Green Hydrogen
LC. GH_Avail             = 0.85       ; % percentage
LC. GH_CAPEX             = 3104.91    ; % AUD/kWe
LC. GH_OandM_pct_CAPEX   = 0.035      ; % percent/yr
LC. Water_Cost           = 0.7        ; % AUD/kL
LC. Avg_elec_cost        = 0          ; % AUD/kWh
LC. GH_Life              = 15         ; % yrs
LC. GH_Disc_Rate         = 0.07       ; % percentage
    
GreenHydrogenOutput = Green_Hydrogen(LC);

%% Blue Hydrogen
LC. BH_Cap_fac           = 0.95       ; % percentage
LC. BH_CAPEX             = 2517       ; % AUD/kWH2
LC. BH_OandM_pct_CAPEX   = 0.0325     ; % percent/yr
LC. BH_Water_use         = 9.74       ; % kgH2O/kgH2
LC. NG_Cost              = 12         ; % AUD/GJ
LC. BH_Spec_Cons         = 3.73       ; % kgNG/kgH2
LC. GHG_emissions        = 10         ; % kgCO2/kgH2
LC. C_Tax                = 0          ; % AUD/tCO2
LC. Capture_Rate         = 0.90       ; % percentage
LC. CCS_Cost             = 31         ; % AUD/tCO2
LC. BH_Life              = 30         ; % yrs
LC. BH_Disc_Rate         = 0.07       ; % percentage
LC. NG_energy_density    = 55         ; % MJ/kg

BlueHydrogenOutput = Blue_Hydrogen(LC);

%% Transport
LC. Distance             = 51         ; % km
LC. Gas_vel              = 15         ; % m/s
LC. H2_gas_density       = 7.9        ; % kg/m^3
LC. TRA_OandM_pct_CAPEX  = 0.04       ; % %/yr
LC. TRA_Life             = 50         ; % yrs
LC. TRA_Disc_Rate        = 0.07       ; % %

TransportOutput = LCTransport(LC);

%% Electricity
LC. PV_Module_CAPEX      = 268/0.61   ; % AUD/kW
LC. PV_Inverter_CAPEX    = 103/0.61   ; % AUD/kW
LC. PV_Racks_CAPEX       = 103/0.61   ; % AUD/kW
LC. PV_Other_CAPEX       = 154/0.61   ; % AUD/kW
LC. PV_Total_CAPEX       = 628/0.61   ; % AUD/kW
LC. PV_OandM_pct_CAPEX   = 0.013      ; % %/yr
LC. PV_Life              = 28         ; % yrs
LC. PV_deg               = 0.003      ; % %

LC. Wind_Turbine_CAPEX   = 1064/0.61  ; % AUD/kW
LC. Wind_Foundation_CAPEX = 69/0.61   ; % AUD/kW
LC. Wind_Other_CAPEX     = 192/0.61   ; % AUD/kW
LC. Wind_Total_CAPEX     = 1325/0.61  ; % AUD/kW
LC. Wind_OandM_pct_CAPEX = 0.011      ; % %/yr
LC. Wind_Life            = 31         ; % yrs
LC. Wind_deg             = 0.0005     ; % %

LC. Elec_Disc_Rate       = 0.07       ; % %

LC. Feeder_len           = 5          ; % km
LC. REZ_net_volt         = 275        ; % kV
LC. Trans_OandM_pct_CAPEX = 0.01      ; % %/yr
LC. Sys_trans_losses     = 0.05       ; % %kW/feeder length
LC. Trans_Life           = 50         ; % yrs

ElectricityOutput = Electricity(LC);

%% Steel
LC.CapEx_EAF              = 265.6     ; % $/tonne/annum
LC.CapEx_H2_DR_Shaft      = 369.8     ; % $/tonne/annum
LC.Non_fuel_OandM         = 51        ; % $/tonne
LC.Fixed_OandM            = 0.0225    ; % % of CapEx
LC.Labour                 = 38.7      ; % $/tonne
LC.Iron_ore_Cost          = 158.2     ; % $/tonne (DRI)
LC.Lifetime               = 20        ; % years
LC.Oxygen_Revenues        = 24.4      ; % $/tonne
LC.Emission_Price         = 153.8     ; % $/tCO2
LC.Insurance_and_Taxes    = 0.02      ; % % of CapEx
LC.Administrative_Cost    = 0.15      ; % % of Labour
LC.Average_Electricity_Cost = 0.0     ; % $/kWh
LC.Iron_Ore_Input         = 1504000   ; % tonne/annum
LC.Direct_Emissions       = 73        ; % kgCO2/tLS
LC.Indirect_Emissions     = 167       ; % kgCO2/tLS
LC.Representative_Disc_Rate = 0.07    ; % %

SteelOutput = LCSteel(LC);

%% Function Output
Output.HourlyDemandedHydrogen = LC.HourlyDemandedHydrogen;

Output.TotalPower = TotalPower;
Output.SolarPower = SolarPower;
Output.WindPower = WindPower;

Output.PVCapacity = LC.PVCapacity;
Output.WindCapacity = LC.WindCapacity;
Output.PEMCapacity = ElectStorageOutput.NumElectrolysers * 10000; %Number of electrolysers times 10MW (10000kW)
Output.StorageCapacity = LC.HourlyDemandedHydrogen * LC.Storage_hrs; %kgH2

Output.HydrogenCharge = ElectStorageOutput.HydrogenStorageRate;
Output.ProducedHydrogen = LC.HourlyProducedRenewableHydrogen; % does not include backup
Output.StoredHydrogen = ElectStorageOutput.StoredHydrogen;
Output.Backup = ElectStorageOutput.BackUpElectricity;
Output.Curtailment = ElectStorageOutput.Curtailment;

Output.Storage_LCOH = StorageOutput.LCOH;
Output.Storage_LCOS = StorageOutput.LCOS;

Output.GreenHydrogen_LCOH_Optimisation = GreenHydrogenOutput.LCOH_Optimisation;
Output.GreenHydrogen_LCOH_Reporting_Renewables = GreenHydrogenOutput.LCOH_Reporting_Renewables;
Output.GreenHydrogen_LCOH_Reporting_All = GreenHydrogenOutput.LCOH_Reporting_All;
Output.GreenHydrogen_LCOS_Optimisation = GreenHydrogenOutput.LCOS_Optimisation;
Output.GreenHydrogen_LCOS_Reporting_Renewables = GreenHydrogenOutput.LCOS_Reporting_Renewables;
Output.GreenHydrogen_LCOS_Reporting_All = GreenHydrogenOutput.LCOS_Reporting_All;

Output.BlueHydrogen_LCOH = BlueHydrogenOutput.LCOH;
Output.BlueHydrogen_LCOS = BlueHydrogenOutput.LCOS;

Output.Transport_LCHS = TransportOutput.LCHS;
Output.Transport_LCOS = TransportOutput.LCOS;

Output.Electricity_LCOE = ElectricityOutput.Total_LCOE;
Output.Electricity_LCOH = ElectricityOutput.Total_LCOH;
Output.Electricity_LCOS = ElectricityOutput.Total_LCOS;

Output.Steel_LCOS = SteelOutput.Total_LCOS;

end