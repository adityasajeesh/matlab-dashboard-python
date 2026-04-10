function [BH_OP] = Blue_Hydrogen(LC)
%% Blue_Hydrogen
%   Description:
%       Function to calculate levelised cost of hydrogen and steel for the blue hydrogen production
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%
%   Output: 
%       BH_OP: Output struct containing most variables calculated throughout this function

%% Code
% ASSUMPTIONS
yearlyHydrogen = LC.HourlyDemandedHydrogen * 24 * 366; % kg/yr
NG_Cost_MJ = LC.NG_Cost * (1 / 10^3); % AUD/MJ

% CALCULATION
BH_OP.Hours_prod = LC.BH_Cap_fac * 366 * 24; % hrs
BH_OP.Req_hourly_cap = yearlyHydrogen / BH_OP.Hours_prod; % kgH2/h
BH_OP.Cap_SMR = BH_OP.Req_hourly_cap * LC.H2_energy_density; % kWH2
BH_OP.Annual_water_cons = yearlyHydrogen * LC.BH_Water_use * (1 / 10^3); % kL
BH_OP.Annual_nat_gas_cons = yearlyHydrogen * LC.BH_Spec_Cons; % kgNG
BH_OP.Annual_nat_gas_cons_MJ = BH_OP.Annual_nat_gas_cons * LC.NG_energy_density; % MJ
BH_OP.Carbon_footprint = LC.GHG_emissions * (1 - LC.Capture_Rate); % kgCO2/kgH2
BH_OP.Annual_carbon_fp = yearlyHydrogen * BH_OP.Carbon_footprint; % kgCO2
BH_OP.Annual_carbon_fp_tons = BH_OP.Annual_carbon_fp / 1000; % tCO2
BH_OP.Carbon_stored = LC.GHG_emissions * LC.Capture_Rate; % kgCO2/kgH2
BH_OP.Annual_carbon_stored = BH_OP.Carbon_stored * yearlyHydrogen; % kgCO2
BH_OP.Annual_carbon_stored_tons = BH_OP.Annual_carbon_stored * 10^-3;

% Total CAPEX
BH_OP.Total_CAPEX = BH_OP.Cap_SMR * LC.BH_CAPEX; % AUD

% OPEX
BH_OP.OandM = BH_OP.Total_CAPEX * LC.BH_OandM_pct_CAPEX; % AUD
BH_OP.Water_cost_total = BH_OP.Annual_water_cons * LC.Water_Cost; % AUD
BH_OP.Carbon_transport_storage_cost_total = BH_OP.Annual_carbon_stored_tons * LC.CCS_Cost; % AUD
BH_OP.Carbon_tax_output = LC.C_Tax * BH_OP.Annual_carbon_fp_tons; % AUD
BH_OP.NG_Cost_total = BH_OP.Annual_nat_gas_cons_MJ * NG_Cost_MJ; % AUD
BH_OP.Total_OPEX = BH_OP.OandM + BH_OP.Water_cost_total + BH_OP.Carbon_transport_storage_cost_total + BH_OP.Carbon_tax_output + BH_OP.NG_Cost_total; % AUD

% Annuity Factor
BH_OP.Annuity_Factor = (LC.BH_Disc_Rate * (1 + LC.BH_Disc_Rate)^LC.BH_Life) / ((1 + LC.BH_Disc_Rate)^LC.BH_Life - 1);

% RESULT
BH_OP.LCOH_Hourly = (BH_OP.Annuity_Factor * BH_OP.Total_CAPEX + BH_OP.Total_OPEX) ./ yearlyHydrogen; % AUD/kgH2

BH_OP.LCOH = (BH_OP.Annuity_Factor * BH_OP.Total_CAPEX + BH_OP.Total_OPEX) / yearlyHydrogen; % AUD/kgH2
BH_OP.LCOS = (BH_OP.Annuity_Factor * BH_OP.Total_CAPEX + BH_OP.Total_OPEX) / yearlyHydrogen * LC.HydrogenReqTonneSteel; % AUD/tLS


end