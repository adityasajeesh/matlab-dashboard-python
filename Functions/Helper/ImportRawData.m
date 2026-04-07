function [SolarRawData, WindRawData, HourlyElectricityPrices] = ImportRawData()
% ImportRawData
% Weather data is now retrieved from API instead of static local weather files.
% Electricity prices are still loaded from local files.

    %% -------------------------
    % 1) Settings
    %% -------------------------
    lat = -33.0321;   % Whyalla approximate latitude
    lon = 137.5610;   % Whyalla approximate longitude

    startDate = '2020-01-01';
    endDate   = '2020-12-31';

    %% -------------------------
    % 2) Read weather data from Open-Meteo Historical API
    %% -------------------------
    baseUrl = "https://archive-api.open-meteo.com/v1/archive";

    hourlyVars = [
        "shortwave_radiation", ...
        "wind_speed_10m"
    ];

    url = baseUrl + ...
        "?latitude=" + string(lat) + ...
        "&longitude=" + string(lon) + ...
        "&start_date=" + startDate + ...
        "&end_date=" + endDate + ...
        "&hourly=" + strjoin(hourlyVars, ",") + ...
        "&timezone=Australia/Adelaide";

    opts = weboptions("ContentType","json","Timeout",30);
    data = webread(url, opts);

    SolarRawData = data.hourly.shortwave_radiation(:);
    WindRawData  = data.hourly.wind_speed_10m(:);

    %% -------------------------
    % 3) Read electricity prices locally for now
    %% -------------------------
    delimiter = ',';
    headerlines = 1;

    if isfile("Model Data/2020HourlyElectricityData.mat")
        HourlyElectricityPrices = importdata("Model Data/2020HourlyElectricityData.mat");
    else
        HourlyElectricityPrices = importdata("Model Data/2020HourlyElectricityData.csv", delimiter, headerlines);
    end

    HourlyElectricityPrices = HourlyElectricityPrices.data(:,1);

    %% -------------------------
    % 4) Make sure lengths match
    %% -------------------------
    n = min([length(SolarRawData), length(WindRawData), length(HourlyElectricityPrices)]);

    SolarRawData = SolarRawData(1:n);
    WindRawData = WindRawData(1:n);
    HourlyElectricityPrices = HourlyElectricityPrices(1:n);

end
