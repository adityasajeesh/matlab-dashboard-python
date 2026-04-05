function [WindPower, WindCapacity] = Wind(LC, WindData)
%% WindTurbine
%   Description:
%       Function to size wind farm and determine the amount of power produced throughout the year from obtained wind data
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%       WindData: array containing obtained wind data for the year
%
%   Output:
%       WindPower: The amount of power produced by the wind farm (kW)
%       WindCapacity: The production capacity of the wind farm (kW)

%% Code
RequiredPower = (LC.ReM*(LC.Nom_H2_flow*LC.GH_Spec_Cons*366+LC.EAF_Spec_Cons*LC.Prod_Cap))/(366*24); % kW/tLS
WindGenerationShare = 1-LC.PV_gen_share;
WindCapacity = RequiredPower * WindGenerationShare;

NumberTurbines = ceil(WindCapacity/LC.WindRatedPower); % Round up as a fractional turbine is not possible

% Assumptions for for ideal gas law, density of air and other calculations
Cp = 0.505; %Rotor power coefficient (from wind turbine data)
EfficiencyGenerator = 0.8; %High-quality grid-connected horizontal axis wind turbine
EfficiencyGearbox = 0.9; %Losses in the electronics
AirDensity = 1.2250; %kg/m^3 (@standard reference temperature)
MolarMass = 0.02894; %kg/mol
UniversalGasConstant = 8.314; %J/molK
ReferenceTemperature = 288.15; %K
Gravity = 9.81; %m/s^2
ReferencePressure = 101325; %Pa
TemperatureLapse = 0.0098; %K/m

% Pressure at the hub height elevation
Pressure = ReferencePressure*(1-(TemperatureLapse*LC.HubHeight/ReferenceTemperature))^((Gravity*MolarMass)/(UniversalGasConstant*TemperatureLapse));

% Density of air at the hub height elevation
AirDensity = (Pressure*MolarMass)/(UniversalGasConstant*(ReferenceTemperature-TemperatureLapse*LC.HubHeight));

% Atomspheric boundary layer using power law approximation
WindSpeed = WindData.*(LC.HubHeight/LC.ReferenceHeight)^LC.GSC;

% WindSpeed = WindSpeed/3.6; %Converting from km/hr to m/s
WindSpeed = WindSpeed/3.6;

WindPower = zeros(length(WindSpeed), 1);

% Maximum power extractable from a horizontal axis wind turbine
for i = 1:length(WindSpeed)
    if WindSpeed(i) >= LC.CutInSpeed && WindSpeed(i) <= LC.RatedSpeed
        WindPower(i) = (0.5*Cp*EfficiencyGearbox*EfficiencyGenerator*AirDensity*pi*LC.RotorRadius^2*WindSpeed(i)^3/1000*NumberTurbines); % kW OR kWh/h
    elseif WindSpeed(i) < LC.CutInSpeed
        WindPower(i) = 0;
    elseif WindSpeed(i) > LC.RatedSpeed && WindSpeed(i) <=LC.CutOutSpeed
        WindPower(i) = (0.5*Cp*EfficiencyGearbox*EfficiencyGenerator*AirDensity*pi*LC.RotorRadius^2*LC.RatedSpeed^3/1000*NumberTurbines); % kW OR kWh/h;
    elseif WindSpeed(i) > LC.CutOutSpeed
        WindPower(i) = 0;
    end
    CapFacHourly(i) = WindPower(i)/(LC.WindRatedPower*NumberTurbines); %Only for heatmap graphs not for rest
end

% CapFacWind = sum(WindPower) / (LC.WindRatedPower * 8760); % to run this line, calculate wind power for single wind turbine in lines above

% % Code to plot wind heatmap
% CapFacHourly = reshape(CapFacHourly, 24, 366);
% PlotHeatMaps(CapFacHourly, "Wind");

end
