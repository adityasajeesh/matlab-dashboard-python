function [St_OP] = LCSteel(LC)
%% LCSteel
%   Description:
%       Function to calculate levelised cost of steel for the direct reduction of hydrogen and electric arc casting
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%
%   Output: 
%       St_OP: Output struct containing most variables calculated throughout this function

%% Code
% ASSUMPTIONS
Production_capacity = 1000000;
St_OP.Electricity_Usage = LC.EAF_Spec_Cons * 1000 * Production_capacity; % MWh/year

% Calculations
% CAPEX
St_OP.CapEx_EAF = LC.CapEx_EAF * Production_capacity; % $
St_OP.CapEx_H2_DRSF = LC.CapEx_H2_DR_Shaft * Production_capacity; % $
St_OP.Total_CAPEX = St_OP.CapEx_EAF + St_OP.CapEx_H2_DRSF; % $

% OPEX
St_OP.Non_fuel_OpEx = LC.Non_fuel_OandM * Production_capacity; % $
St_OP.Labour_Cost = LC.Labour * Production_capacity; % $
St_OP.Iron_Ore_Cost = LC.Iron_Ore_Input * LC.Iron_ore_Cost; % $
St_OP.Fixed_OpEx = LC.Fixed_OandM * St_OP.Total_CAPEX; % $
St_OP.Insurance_and_Taxes = LC.Insurance_and_Taxes * St_OP.Total_CAPEX; % $
St_OP.Administrative_Cost = LC.Administrative_Cost * St_OP.Labour_Cost; % $
St_OP.Oxygen_Revenue = LC.Oxygen_Revenues * Production_capacity; % $
St_OP.Electricity_Cost = LC.Average_Electricity_Cost * St_OP.Electricity_Usage * 1000; % $ (Converted from MWh to kWh)

% Emissions
St_OP.Direct_Emissions = LC.Direct_Emissions * Production_capacity; % kgCO2
St_OP.Indirect_Emissions = LC.Indirect_Emissions * Production_capacity; % kgCO2
St_OP.Total_Emissions = St_OP.Direct_Emissions + St_OP.Indirect_Emissions; % kgCO2
St_OP.Emissions_Tax = St_OP.Total_Emissions / 1000 * LC.Emission_Price; % $ (Converted from kgCO2 to tCO2)

% Total OPEX
St_OP.Total_OPEX = St_OP.Non_fuel_OpEx + St_OP.Labour_Cost + St_OP.Iron_Ore_Cost + ...
                  St_OP.Fixed_OpEx + St_OP.Insurance_and_Taxes + St_OP.Administrative_Cost - ...
                  St_OP.Oxygen_Revenue + St_OP.Electricity_Cost + St_OP.Emissions_Tax; % $

% Annuity Factor
St_OP.Annuity_Factor = (LC.Representative_Disc_Rate * (1 + LC.Representative_Disc_Rate)^LC.Lifetime) / ...
                      ((1 + LC.Representative_Disc_Rate)^LC.Lifetime - 1);

% RESULT
St_OP.Total_LCOS = (St_OP.Annuity_Factor * St_OP.Total_CAPEX + St_OP.Total_OPEX) / Production_capacity; % $/tLS
end
