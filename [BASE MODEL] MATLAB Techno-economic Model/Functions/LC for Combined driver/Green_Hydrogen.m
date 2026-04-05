function [GH] = Green_Hydrogen(LC)
%% Green_Hydrogen
%   Description:
%       Function to calculate levelised cost of hydrogen and steel for the electrolysers
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%
%   Output: 
%       GH: Output struct containing most variables calculated throughout this function

%% Code
% ASSUMPTIONS
nom_H2_flow = LC.HourlyProducedHydrogen*24 * 366; % hydrogen flow with renewables and backup
nom_H2_flow_only_renewables = LC.HourlyProducedRenewableHydrogen*24 * 366; % hydrogen flow with renewables 

% CALCULATION
GH.Sys_eff = LC.H2_energy_density / LC.GH_Spec_Cons; % assumed percentage
GH.Full_load_hrs = LC.GH_Avail * 366 * 24; % hrs
GH.Req_hourly_cap = LC.HourlyCapacitywithOversize*24*366 / GH.Full_load_hrs; % kgH2/h
GH.Installed_electrolyser_stack_cap_kWe = GH.Req_hourly_cap * LC.GH_Spec_Cons; % kWe
GH.Installed_electrolyser_stack_cap_kW_H2 = GH.Req_hourly_cap * LC.H2_energy_density; % kWH2
GH.Annual_elec_cons = nom_H2_flow * LC.GH_Spec_Cons; % kWh: this value is 0

GH.Annual_water_cons = LC.GH_Water_use * nom_H2_flow * 10^-3; % kL
GH.Annual_water_cons_renewables = LC.GH_Water_use * nom_H2_flow_only_renewables * 10^-3; %kL

% TOTAL CAPEX
GH.Total_CAPEX = GH.Installed_electrolyser_stack_cap_kWe * LC.GH_CAPEX; % AUD

% TOTAL OPEX
GH.OandM = GH.Total_CAPEX * LC.GH_OandM_pct_CAPEX; % AUD
GH.Elec_Cost = GH.Annual_elec_cons * LC.Avg_elec_cost; % AUD

GH.Water_Cost = GH.Annual_water_cons * LC.Water_Cost; % AUD
GH.Water_Cost_renewables = GH.Annual_water_cons_renewables * LC.Water_Cost; % AUD

GH.Total_OPEX = GH.OandM + GH.Elec_Cost + GH.Water_Cost; % AUD
GH.Total_OPEX_renewables = GH.OandM + GH.Elec_Cost + GH.Water_Cost_renewables; % AUD

GH.Annuity_Factor = (LC.GH_Disc_Rate * (1 + LC.GH_Disc_Rate)^LC.GH_Life) / ((1 + LC.GH_Disc_Rate)^LC.GH_Life - 1);

% RESULT	
% GH.LCOH_Hourly = (GH.Annuity_Factor * GH.Total_CAPEX + GH.Total_OPEX) ./ nom_H2_flow; % AUD/kgH2 hourly

% LCOH of green hydrogen: optimisation (Denominator is only renewable hydrogen, Backup electricity cost is included)
GH.LCOH_Optimisation = (GH.Annuity_Factor * GH.Total_CAPEX + mean(GH.Total_OPEX) + LC.SumElectPrice) / sum(LC.HourlyProducedRenewableHydrogen); % AUD/kgH2 yearly
GH.LCOS_Optimisation = GH.LCOH_Optimisation * LC.HydrogenReqTonneSteel; % AUD/tLS 

% LCOH of green hydrogen: reporting renewables (Denominator is only renewable hydrogen, Backup electricity cost is not included)
GH.LCOH_Reporting_Renewables = (GH.Annuity_Factor * GH.Total_CAPEX + mean(GH.Total_OPEX_renewables)) / sum(LC.HourlyProducedRenewableHydrogen); % AUD/kgH2 yearly
GH.LCOS_Reporting_Renewables = GH.LCOH_Reporting_Renewables * LC.HydrogenReqTonneSteel; % AUD/tLS 

% LCOH of green hydrogen: reporting everything (Denominator includes all hydrogen, backup costs included)
GH.LCOH_Reporting_All = (GH.Annuity_Factor * GH.Total_CAPEX + mean(GH.Total_OPEX) + LC.SumElectPrice) / sum(LC.HourlyProducedHydrogen); % AUD/kgH2 yearly
GH.LCOS_Reporting_All = GH.LCOH_Reporting_All * LC.HydrogenReqTonneSteel; % AUD/tLS 

% LCOH of green hydrogen: reporting everything (Denominator includes all hydrogen, backup costs included)
GH.LCOH_Reporting_All_PPA = (GH.Annuity_Factor * GH.Total_CAPEX + mean(GH.Total_OPEX) + LC.ElectPricePPA) / sum(LC.HourlyProducedHydrogen); % AUD/kgH2 yearly
GH.LCOS_Reporting_All_PPA = GH.LCOH_Reporting_All_PPA * LC.HydrogenReqTonneSteel; % AUD/tLS 

end