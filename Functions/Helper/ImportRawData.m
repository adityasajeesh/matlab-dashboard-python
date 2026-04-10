function [SolarRawData, WindRawData, HourlyElectricityPrices, LocationConfig] = ImportRawData(locationName, yearValue)
%ImportRawData Import weather and electricity data using a single location variable
%   If there are no arguments  supplied, the function defaults to Whyalla and 2020
%
%   Inputs
%       locationName - e.g. "Whyalla". Used for both weather and electricity mapping
%       yearValue    - data year used in file naming
%
%   Outputs
%       SolarRawData, WindRawData, HourlyElectricityPrices - hourly vectors
%       LocationConfig - struct containing mapped weather prefix and NEM region

    delimiter = ',';
    headerlines = 1;

    if nargin < 1 || strlength(string(locationName)) == 0
        locationName = "Whyalla";
    end

    if nargin < 2 || isempty(yearValue)
        yearValue = 2020;
    end

    LocationConfig = BuildLocationConfig(locationName);
    weatherPrefix = string(LocationConfig.WeatherFilePrefix);

    solarMat = "Model Data/" + string(yearValue) + weatherPrefix + "SolarData.mat";
    solarCsv = "Model Data/" + string(yearValue) + weatherPrefix + "SolarData.csv";
    windMat  = "Model Data/" + string(yearValue) + weatherPrefix + "WindData.mat";
    windCsv  = "Model Data/" + string(yearValue) + weatherPrefix + "WindData.csv";

    if isfile(solarMat)
        SolarRawData = importdata(solarMat);
    else
        SolarRawData = importdata(solarCsv, delimiter, headerlines);
    end

    if isfile(windMat)
        WindRawData = importdata(windMat);
    else
        WindRawData = importdata(windCsv, delimiter, headerlines);
    end

    HourlyElectricityPrices = LoadElectricityPriceData(LocationConfig, yearValue);

    SolarRawData = SolarRawData.data(:,2);
    WindRawData = WindRawData.data(:,2);
end
