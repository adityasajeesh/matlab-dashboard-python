function [S_OP] = LCStorage(LC)
%% LCStorage
%   Description:
%       Function to calculate levelised cost of hydrogen and steel for the hydrogen storage
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%
%   Output: 
%       S_OP: Output struct containing most variables calculated throughout this function

%% Code
% ASSUMPTIONS
S_OP.nom_H2_flow_yr = LC.HourlyProducedHydrogen*24 * 366; % kgH2/yr
S_OP.Storage_cap = LC.HourlyDemandedHydrogen*24 / 24 * LC.Storage_hrs; % kgH2 

% Total CAPEX
S_OP.Total_CAPEX = S_OP.Storage_cap * LC.S_CAPEX; % AUD

% OPEX
S_OP.Total_Annual_OPEX = S_OP.Total_CAPEX * LC.S_OandM_pct_CAPEX; % AUD

% Annuity Factor
S_OP.Annuity_Factor = (LC.S_Disc_Rate * (1 + LC.S_Disc_Rate)^LC.S_Life) / ((1 + LC.S_Disc_Rate)^LC.S_Life - 1);

% RESULT
S_OP.LCOH_Hourly = (S_OP.Annuity_Factor * S_OP.Total_CAPEX + S_OP.Total_Annual_OPEX) ./ S_OP.nom_H2_flow_yr; % AUD/kgH2
S_OP.LCOH = (S_OP.Annuity_Factor * S_OP.Total_CAPEX + S_OP.Total_Annual_OPEX) / sum(LC.HourlyProducedHydrogen); % AUD/kgH2

S_OP.LCOS = (S_OP.Annuity_Factor * S_OP.Total_CAPEX + S_OP.Total_Annual_OPEX) / sum(LC.HourlyProducedHydrogen) * LC.HydrogenReqTonneSteel; % AUD/kgH2

end
