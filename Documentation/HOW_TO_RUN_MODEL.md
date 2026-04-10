# HOW TO RUN THE MODIFIED MATLAB MODEL FOR ELECTRICITY PRICES ##########################################################################################################################################################################################
## Overview
A modified version of the MATLAB techno-economic model has been changed so that electricity pricing is loaded from an external hourly electricity price file gathered by AEMO instead of using a flat electricity price. As well, the model uses a single location input so weather data and electricity pricing can be linked more consistently

## Required Files
Before running the model make sure that the following files are present in the project:

### Main project folders
- `Drivers`
- `Functions`
- `Model Data`

### Key modified and added files
- `Drivers/Optimisation/Optimisation_algorithm.m`
- `Functions/Helper/ImportRawData.m`
- `Functions/Helper/LoadElectricityPriceData.m`
- `Functions/Helper/BuildLocationConfig.m`

### Required data files
The `Model Data` folder must contain:
- weather data files for the selected year and location
- an hourly electricity price file for the mapped electricity region
Example
- `2020WhyallaSolarData.csv`
- `2020WhyallaWindData.csv`
- `2020SA1HourlyElectricityData.csv`

## Important Notes
- The electricity price file must be placed inside the `Model Data` folder
- The model expects hourly electricity prices
- The current prototype supports public-source-based electricity pricing input through external CSV files
- If a short public data sample is used instead of a full-year file, the loader may repeat values to match the model’s required yearly input length for testing purposes

## Running the Model ##########################################################################################################################################################################################
### Step 1: Open MATLAB
Open MATLAB and navigate to the main project folder.

This should be the folder that contains:
- `Drivers`
- `Functions`
- `Model Data`

### Step 2: Confirm current folder
In the MATLAB Command Window, run:

```matlab
pwd
```
Make sure MATLAB is currently inside the project root folder.

### Step 3: Add project folders to path
Run:

```matlab
addpath(genpath(pwd))
```

This ensures MATLAB can locate all scripts and helper functions in subfolders.
### Step 4: Set model inputs
Open:

`Drivers/Optimisation/Optimisation_algorithm.m`

Check or update the location and year values, for example:

```matlab
LocationName = "Whyalla";
YearValue = 2020;
```

These values must match the available weather and electricity files in `Model Data`.

### Step 5: Run the optimisation model
In the MATLAB Command Window, run:

```matlab
run('Drivers/Optimisation/Optimisation_algorithm.m')
```

### Step 6: Wait for completion
If the model runs successfully, progress updates will appear in the Command Window, for example:

- `Progress: 5%`
- `Progress: 50%`
- `Progress: 95%`

At the end, MATLAB should display a total runtime value such as:

```matlab
time = 230.5809
```
## Viewing Saved Results
After the model finishes, check the saved output files by running:

```matlab
dir('Drivers/Optimisation/Saved Data')
```

This folder should contain result files such as:
- `.txt` output files
- `.mat` optimisation result files

## Viewing Graphs
To generate result graphs, change into the graph folder:

```matlab
cd('Drivers/Model Graphs')
```

Then run the graph scripts one at a time:

```matlab
StackedBarLCOS
StackedBarCapacity
GenerationShare
BreakevenGraphs
```

These scripts will display the model outputs as graphs.

## Troubleshooting ########################################################################################################################################################################################################################################################

### Error: file not found
Check that:
- the correct year is set in `Optimisation_algorithm.m`
- the required weather files exist in `Model Data`
- the electricity price file name matches the expected naming format

### Error: electricity price vector too short
If the electricity price file is only a short public sample and not a full-year dataset, the model may require the loader to repeat values for testing. This is acceptable for prototype testing but not for final production use.

### Error: model cannot find helper functions
Make sure you ran:

```matlab
addpath(genpath(pwd))
```

from the project root folder.

## Prototype Limitation ########################################################################################################################################################################################################################################################
The current model can accept externally sourced hourly electricity price data however, if a short public sample is used instead of a full-year aligned dataset, the results should be treated as a prototype demo rather than a final production-ready implementation
