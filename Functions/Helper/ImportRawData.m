function [SolarRawData, WindRawData, HourlyElectricityPrices] = ImportRawData(locationName, yearValue)
%ImportRawData
% Modified function: Weather data retrieved from Open-Meteo API
% Electricity prices are loaded via the LoadElectricityPriceData function

    % Default values for optional parameters
    if nargin < 1
        locationName = "Whyalla";
    end

    if nargin < 2
        yearValue = 2020;
    end

    % Build config
    LocationConfig = BuildLocationConfig(locationName);
    fprintf('Fetching weather data for %s (%d)...\n', LocationConfig.LocationName, yearValue);

    % Read weather data from Open-Meteo API
    startDate = sprintf('%d-01-01', yearValue);
    endDate = sprintf('%d-12-31', yearValue);

    baseUrl = "https://archive-api.open-meteo.com/v1/archive";
    hourlyVars = ["shortwave_radiation", "wind_speed_10m"];

    % Construct API URL with query parameters
    url = baseUrl + ...
        "?latitude=" + LocationConfig.Latitude + ...
        "&longitude=" + LocationConfig.Longitude + ...
        "&start_date=" + startDate + ...
        "&end_date=" + endDate + ...
        "&hourly=" + strjoin(hourlyVars, ",") + ...
        "&timezone=Australia/Adelaide"; % MODIFY TIMEZONE AS NEEDED

    opts = weboptions("ContentType", "json", "Timeout", 30);

    try
        weatherData = webread(url, opts);
        SolarRawData = weatherData.hourly.shortwave_radiation(:);
        WindRawData = weatherData.hourly.wind_speed_10m(:);
    catch ME
        error("Failed to fetch weather data for %s: %s", LocationConfig.LocationName, ME.message);
    end

    % Read electricity prices via Helper Function
    % Make sure LoadElectricityPriceData.m is in the same folder or on the MATLAB path
    HourlyElectricityPrices = LoadElectricityPriceData(LocationConfig.LocationName, yearValue);

    % Lengths of the data arrays should match (8760 for non-leap years)
    n = min([length(SolarRawData), length(WindRawData), length(HourlyElectricityPrices)]);

    SolarRawData = SolarRawData(1:n);
    WindRawData = WindRawData(1:n);
    HourlyElectricityPrices = HourlyElectricityPrices(1:n);

    disp('Successfully imported weather and electricity data.');
end