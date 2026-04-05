function Total_LCOS = CC_SA(Input, SolarData, WindData, HourlyElectricityPrices, year)

%% Establish case variables
LC. Iron_ore_Cost     = Input(1) ; % $/tonne (DRI)
LC. Wind_Total_CAPEX  = Input(2) ; % AUD/kW  %2020 and 2050 values
LC. PV_Total_CAPEX    = Input(3) ; % AUD/kW  %2020 and 2050 values
LC. GH_CAPEX          = Input(4) ; % AUD/kWe %2020 and 2050 values
LC. S_CAPEX           = Input(5) ; % AUD/kgH2
LC. CapEx_H2_DR_Shaft = Input(6) ; % $/tonne/annum
LC. CapEx_EAF         = Input(7) ; % $/tonne/annum

LC. S_Disc_Rate          = Input(8)    ; % percentage
LC. GH_Disc_Rate         = Input(8)    ; % percentage
LC. BH_Disc_Rate         = Input(8)    ; % percentage
LC. TRA_Disc_Rate        = Input(8)    ; % %
LC. Elec_Disc_Rate       = Input(8)    ; % %
LC.Representative_Disc_Rate = Input(8) ; % %

LC. Emission_Price       = Input(9)   ; % $/tCO2
LC. C_Tax                = Input(9)   ; % AUD/tCO2

%% Establish 2020 or 2050 variables and optimal cases
if year == 1 %2020
    LC. BH_CAPEX             = 2517    ; % AUD/kWH2
    LC. BH_Spec_Cons         = 3.73    ; % kgNG/kgH2
    LC. NG_Cost              = 12      ; % AUD/GJ
    
    LC. GH_Life              = 15      ; % yrs
    LC. GH_Spec_Cons          = 49.9   ; % kWh/kgH2

    LC. PV_gen_share   = 0.43 ; % Percentage of solar wind splits
    LC. ReM            = 3.4 ; % Renewable Multiple
    LC. ReM_OcM_Ratio  = 0.5 ;
    LC. Storage_hrs    = 19.0 ; % hrs

elseif year == 2 %2050
    LC. BH_CAPEX             = 1969.2  ; % AUD/kWH2
    LC. BH_Spec_Cons         = 3.65    ; % kgNG/kgH2
    LC. NG_Cost              = 11      ; % AUD/GJ
    
    LC. GH_Life              = 19      ; % yrs
    LC. GH_Spec_Cons         = 45      ; % kWh/kgH2

    LC. PV_gen_share   = 0.71 ; % Percentage of solar wind splits
    LC. ReM            = 3.3 ; % Renewable Multiple
    LC. ReM_OcM_Ratio  = 0.5 ;
    LC. Storage_hrs    = 11.0 ; % hrs

else
    fprtinf("error");
end

%% Struct Variables from Mass Balance Excel Sheet
LC. OcM = LC.ReM_OcM_Ratio * LC.ReM;
LC. HourlyDemandedHydrogen = 8546.86487 + 1771.14228; %kg/hr % 10,318.00715456914
LC. Nom_H2_flow = LC.HourlyDemandedHydrogen*24; %kg/day
LC. HourlyCapacitywithOversize = LC.OcM * LC.HourlyDemandedHydrogen; % kg/hr
LC. LiquidSteelSpecificElectricityConsumption = 753000; % MWh/kgLS (to be deleted)

%% Determine Simulated Time Period
TimePeriod = 366; % days
LC.TimePeriodHours = TimePeriod*24; % hours

%% Obtain Raw Solar and Wind Data and define needed variables
LC. ReferenceHeight       = 9.3       ; % function of weather station (from Nathan's data)
LC. Cp                   = 0.505      ; % coefficient of performance
LC. AirDensity           = 1.2250     ; % kg/m^3 (@15deg Celcius)
LC. H2_energy_density    = 33.33      ; % kWh/kgH2

%% Solar
LC. ConvEfncy             = 0.19      ; % conversion efficiency (from solar panel datasheet)
LC. Degradation           = 0.003     ; % 
LC. EAF_Spec_Cons         = 753       ; % kWh/tLS
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

ElectStorageOutput = ElectrolyserAndStorage(LC, TotalPower);

LC.HourlyProducedRenewableHydrogen = (ElectStorageOutput.ElectrolyserInputPower - ElectStorageOutput.BackUpElectricity)/LC.GH_Spec_Cons;

LC.HourlyProducedHydrogen = ElectStorageOutput.ElectrolyserInputPower/LC.GH_Spec_Cons; % does include backup

LC.Ann_energy_prod = sum(TotalPower) - sum(ElectStorageOutput.Curtailment); %kW

SumElectPrice = ElectStorageOutput.BackUpElectricity .* reshape(HourlyElectricityPrices, 1, 8784);
LC.SumElectPrice = sum(SumElectPrice);

ElectPricePPA = ElectStorageOutput.BackUpElectricity * 97.5;
LC.ElectPricePPA = sum(ElectPricePPA);

%% Storage
LC. Storage_loss_pct_yr  = 0.015      ; % percentage/yr
LC. S_OandM_pct_CAPEX    = 0.0254     ; % percentage
LC. S_Life               = 35         ; % yrs

LC. HydrogenReqTonneSteel = 72.819289 ; %kgH2/tLS

StorageOutput = LCStorage(LC);

%% Green Hydrogen
LC. GH_Avail             = 0.85       ; % percentage
LC. GH_OandM_pct_CAPEX   = 0.035      ; % percent/yr
LC. Water_Cost           = 0.7        ; % AUD/kL
LC. Avg_elec_cost        = 0          ; % AUD/kWh

GreenHydrogenOutput = Green_Hydrogen(LC);

%% Blue Hydrogen
LC. BH_Cap_fac           = 0.95       ; % percentage
LC. BH_OandM_pct_CAPEX   = 0.0325     ; % percent/yr
LC. BH_Water_use         = 9.74       ; % kgH2O/kgH2
LC. GHG_emissions        = 10         ; % kgCO2/kgH2
LC. Capture_Rate         = 0.90       ; % percentage
LC. CCS_Cost             = 31         ; % AUD/tCO2
LC. BH_Life              = 30         ; % yrs
LC. NG_energy_density    = 55         ; % MJ/kg

BlueHydrogenOutput = Blue_Hydrogen(LC);

%% Transport
LC. Distance             = 51         ; % km
LC. Gas_vel              = 15         ; % m/s
LC. H2_gas_density       = 7.9        ; % kg/m^3
LC. TRA_OandM_pct_CAPEX  = 0.04       ; % %/yr
LC. TRA_Life             = 50         ; % yrs

TransportOutput = LCTransport(LC);

%% Electricity
LC. PV_Module_CAPEX      = 268/0.61   ; % AUD/kW
LC. PV_Inverter_CAPEX    = 103/0.61   ; % AUD/kW
LC. PV_Racks_CAPEX       = 103/0.61   ; % AUD/kW
LC. PV_Other_CAPEX       = 154/0.61   ; % AUD/kW
LC. PV_OandM_pct_CAPEX   = 0.013      ; % %/yr
LC. PV_Life              = 28         ; % yrs
LC. PV_deg               = 0.003      ; % %

LC. Wind_Turbine_CAPEX   = 1064/0.61  ; % AUD/kW
LC. Wind_Foundation_CAPEX = 69/0.61   ; % AUD/kW
LC. Wind_Other_CAPEX     = 192/0.61   ; % AUD/kW
LC. Wind_OandM_pct_CAPEX = 0.011      ; % %/yr
LC. Wind_Life            = 31         ; % yrs
LC. Wind_deg             = 0.0005     ; % %


LC. Feeder_len           = 5          ; % km
LC. REZ_net_volt         = 275        ; % kV
LC. Trans_OandM_pct_CAPEX = 0.01      ; % %/yr
LC. Sys_trans_losses     = 0.05       ; % %kW/feeder length
LC. Trans_Life           = 50         ; % yrs

ElectricityOutput = Electricity(LC);

%% Steel
LC.Non_fuel_OandM         = 51        ; % $/tonne
LC.Fixed_OandM            = 0.0225    ; % % of CapEx
LC.Labour                 = 38.7      ; % $/tonne
LC.Lifetime               = 20        ; % years
LC.Oxygen_Revenues        = 24.4      ; % $/tonne
LC.Insurance_and_Taxes    = 0.02      ; % % of CapEx
LC.Administrative_Cost    = 0.15      ; % % of Labour
LC.Average_Electricity_Cost = 0.0     ; % $/kWh
LC.Iron_Ore_Input         = 1504000   ; % tonne/annum
LC.Direct_Emissions       = 73        ; % kgCO2/tLS
LC.Indirect_Emissions     = 167       ; % kgCO2/tLS

SteelOutput = LCSteel(LC);

%% Output
Total_LCOS = sum([StorageOutput.LCOS, GreenHydrogenOutput.LCOS_Reporting_Renewables, TransportOutput.LCOS, ElectricityOutput.Total_LCOS, SteelOutput.Total_LCOS]);

end