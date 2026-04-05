function [SolarPower, PVCapacity] = Solar(LC, GlobalTiltedIrradiance)
%% Photovoltaic Cell
%   Description:
%       Function to size solar farm and determine the amount of power produced throughout the year from obtained solar data
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%       GlobalTiltedIrradiance: array containing obtained solar data for the year
%
%   Output: 
%       SolarPower: The amount of power produced by the solar farm (kW)
%       PVCapacity: The production capacity of the solar farm (kW)

%% Code
GlobalTiltedIrradiance = GlobalTiltedIrradiance / 1000; % converting W/m^2 to kW/m^2

RequiredPower = (LC.ReM*(LC.Nom_H2_flow*LC.GH_Spec_Cons*366+LC.EAF_Spec_Cons*LC.Prod_Cap))/(366*24); 
PVCapacity = LC.PV_gen_share * RequiredPower; %kW

NumberPanels = ceil(PVCapacity/LC.SolarRatedPower); % Round up as a fractional turbine is not possible

LC.ConvEfncy = LC.ConvEfncy*((1-LC.Degradation)^LC.PlantAge);

SolarPower = LC.AreaPanel*GlobalTiltedIrradiance*LC.ConvEfncy; 

for i = 1:length(SolarPower)
    if SolarPower(i) >= LC.SolarRatedPower
        SolarPower(i) = LC.SolarRatedPower;
    end
    CapFacHourly(i) = SolarPower(i)/LC.SolarRatedPower; % Only needed for heatmap graphs
end

% % Calculate the capacity factor of the solar farm
% CapFacSolar = sum(SolarPower) / (LC.SolarRatedPower * 8760);

% % Code to plot solar heatmap
% CapFacHourly = reshape(CapFacHourly, 24, 366);
% PlotHeatMaps(CapFacHourly, "Solar");

SolarPower = SolarPower*NumberPanels;

end
