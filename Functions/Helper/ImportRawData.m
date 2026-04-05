function [SolarRawData, WindRawData, HourlyElectricityPrices] = ImportRawData()
%ImportRawData - imports RawData.mat if it exists, otherwises sources data
%from csv

delimiter = ',';
headerlines = 1;

    if isfile("Model Data/2020WhyallaSolarData.mat")
        SolarRawData = importdata("Model Data/2020WhyallaSolarData.mat");
    else
        SolarRawData = importdata("Model Data/2020WhyallaSolarData.csv", delimiter, headerlines);
    end

    if isfile("Model Data/2020WhyallaWindData.mat")
        WindRawData = importdata("Model Data/2020WhyallaWindData.mat");
    else
        WindRawData = importdata("Model Data/2020WhyallaWindData.csv", delimiter, headerlines);
    end

    if isfile("Model Data/2020HourlyElectricityData.mat")
        HourlyElectricityPrices = importdata("Model Data/2020HourlyElectricityData.mat");
    else
        HourlyElectricityPrices = importdata("Model Data/2020HourlyElectricityData.csv", delimiter, headerlines);
    end

    SolarRawData = SolarRawData.data(:,2);
    WindRawData = WindRawData.data(:,2);
    HourlyElectricityPrices = HourlyElectricityPrices.data(:,1);

end