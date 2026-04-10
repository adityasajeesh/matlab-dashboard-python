# MATLAB energy prices model notes

## What was changed/added
- Created file `Functions/Helper/BuildLocationConfig.m` which maps a single location variable to:
  - weather file prefix
  - NEM electricity region
- Created file `Functions/Helper/LoadElectricityPriceData.m` so it can load hourly electricity prices from region-specific files, while also checking for sheet size
- Updated `Functions/Helper/ImportRawData.m` so that one location variable is now used for both the weather and electricity data
- Updated `Drivers/Optimisation/Optimisation_algorithm.m` which now will call the new import flow
- Downloaded data `Model Data/2020SA1HourlyElectricityData.csv` for a region-specific copy of the already exisisting hourly electricity price file for SA

## New expected usage
```matlab
LocationName = "Whyalla";
YearValue = 2020;
[SolarData, WindData, HourlyElectricityPrices, LocationConfig] = ImportRawData(LocationName, YearValue);
```

## File naming convention for future datasets
- Weather solar: `Model Data/<year><WeatherPrefix>SolarData.csv`
- Weather wind: `Model Data/<year><WeatherPrefix>WindData.csv`
- Electricity prices by region: `Model Data/<year><NEMRegion>HourlyElectricityData.csv`
Example for Whyalla/SA in 2020:
- `Model Data/2020WhyallaSolarData.csv`
- `Model Data/2020WhyallaWindData.csv`
- `Model Data/2020SA1HourlyElectricityData.csv`
