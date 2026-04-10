function [T_OP] = LCTransport(LC)
%% Green_Hydrogen
%   Description:
%       Function to calculate levelised cost of hydrogen and steel for the transport of hydrogen
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%
%   Output: 
%       T_OP: Output struct containing most variables calculated throughout this function

%% Code
%ASSUMPTIONS
nom_H2_flow_w_S_loss = LC.HourlyProducedHydrogen*24 * 366;

% CALCULATION
T_OP.Peak_hydrogen_mass_flow_rate = LC.HourlyCapacitywithOversize / 3600; % kg/s %same one as times by capex in green hydrogen, 2.37 kg/s hourly hydrogen demand
T_OP.Internal_pipeline_diameter = sqrt((4*T_OP.Peak_hydrogen_mass_flow_rate)/(LC.Gas_vel*LC.H2_gas_density*pi)); % m
T_OP.Minimum_pipeline_diameter = 0.1; % m
T_OP.Pipeline_diameter = max(T_OP.Internal_pipeline_diameter, T_OP.Minimum_pipeline_diameter); % m
T_OP.Pipeline_CAPEX_per_km = (4000000 * (T_OP.Pipeline_diameter^2) + 598600 * T_OP.Pipeline_diameter + 329000) / 0.65; % AUD/km

T_OP.Total_CAPEX = T_OP.Pipeline_CAPEX_per_km * LC.Distance; % AUD

% OPEX Calculation
T_OP.Total_OPEX = T_OP.Total_CAPEX * LC.TRA_OandM_pct_CAPEX; % AUD

% Annuity Factor Calculation
T_OP.Annuity_Factor = (LC.TRA_Disc_Rate * (1 + LC.TRA_Disc_Rate).^LC.TRA_Life) / ((1 + LC.TRA_Disc_Rate).^LC.TRA_Life - 1);

% RESULT
T_OP.LCHS_Hourly = (T_OP.Annuity_Factor * T_OP.Total_CAPEX + T_OP.Total_OPEX) ./ nom_H2_flow_w_S_loss; % AUD/kgH2
T_OP.LCHS = (T_OP.Annuity_Factor * T_OP.Total_CAPEX + T_OP.Total_OPEX) / sum(LC.HourlyProducedHydrogen); % AUD/kgH2

T_OP.LCOS = T_OP.LCHS * LC.HydrogenReqTonneSteel; % AUD/tLS

end