function [E_OP] = Electricity(LC)
%% Electricity
%   Description:
%       Function to calculate levelised cost of hydrogen and steel for the renewable power production
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%
%   Output: 
%       E_OP: Output struct containing most variables calculated throughout this function

%% Code
% Transmission lines calculation
% CAPEX and OPEX for transmission lines
if LC.Feeder_len == 5
    E_OP.Trans_CAPEX = (0.0636 * LC.REZ_net_volt + 19.833) * 10^6; % AUD
else
    E_OP.Trans_CAPEX = (0.0726 * LC.REZ_net_volt + 27.957) * 10^6; % AUD
end
E_OP.Trans_OPEX = E_OP.Trans_CAPEX * LC.Trans_OandM_pct_CAPEX; % AUD

% Annual fixed charge rate for transmission lines
E_OP.Ann_fixed_charge_rate = LC.Elec_Disc_Rate * (1 + LC.Elec_Disc_Rate)^LC.Trans_Life / ((1 + LC.Elec_Disc_Rate)^LC.Trans_Life - 1);

% Levelized cost of electricity (LCOE) for transmission lines
E_OP.LCOE_trans = (E_OP.Ann_fixed_charge_rate * E_OP.Trans_CAPEX + E_OP.Trans_OPEX) / (LC.Ann_energy_prod); % AUD/kWh

% CAPEX and OPEX for PV
E_OP.PV_Installed_cap = LC.PVCapacity; %kW
E_OP.PV_Total_CAPEX = LC.PV_Total_CAPEX * E_OP.PV_Installed_cap; % AUD

E_OP.PV_OandM = E_OP.PV_Total_CAPEX * LC.PV_OandM_pct_CAPEX; % AUD
E_OP.PV_Total_OPEX = E_OP.PV_OandM; % AUD

% Annuity Factor for PV
E_OP.PV_Annuity_Factor = LC.Elec_Disc_Rate * (1 + LC.Elec_Disc_Rate)^LC.PV_Life / ((1 + LC.Elec_Disc_Rate)^LC.PV_Life - 1);

% CAPEX and OPEX for Wind
E_OP.Wind_Installed_cap = LC.WindCapacity;
E_OP.Wind_Total_CAPEX = LC.Wind_Total_CAPEX * E_OP.Wind_Installed_cap; % AUD

E_OP.Wind_OandM = E_OP.Wind_Total_CAPEX * LC.Wind_OandM_pct_CAPEX; % AUD
E_OP.Wind_Total_OPEX = E_OP.Wind_OandM; % AUD

% Annuity Factor for Wind
E_OP.Wind_Annuity_Factor = LC.Elec_Disc_Rate * (1 + LC.Elec_Disc_Rate)^LC.Wind_Life / ((1 + LC.Elec_Disc_Rate)^LC.Wind_Life - 1);

% Total LCOE and LCOH
E_OP.Total_LCOE = ((E_OP.PV_Annuity_Factor * E_OP.PV_Total_CAPEX) + (E_OP.Wind_Annuity_Factor * E_OP.Wind_Total_CAPEX) + E_OP.PV_Total_OPEX + E_OP.Wind_Total_OPEX) ./ (LC.Ann_energy_prod); % AUD/kWh
E_OP.Total_LCOH = LC.GH_Spec_Cons * E_OP.Total_LCOE; % AUD/kgH2
E_OP.Total_LCOS = E_OP.Total_LCOH * LC.HydrogenReqTonneSteel;

end