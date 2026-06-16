# Full-Stack Python Green Hydrogen Dashboard

This repository contains the Python-based interactive web dashboard. The tool dynamically fetches global weather data, simulates thousands of phyiscal plant configurations (solar, wind, storage, electrolyser) and calculates the Levelised Cost of Hydrogen to find the optimal system sizing.

## Prerequisites
1. **MATLAB Installation** (Tested with R2025b).
   1. Ensure that **Parallel Computing Toolbox** is installed (used for `parfor` multi-core optimisation)
2. **Python 3.9 - 3.12**
   1. Download and install from [python.org](python.org)
3. **Git**
4. The Optimised MATLAB Model stored on your local machine.

## Installation & Setup Guide
### Step 1: Clone Repository on Local Machine
If you have Git installed, open your terminal (Command Prompt, PowerShell or Terminal) and execute the following commands:
```bash
git clone https://github.com/adityasajeesh/matlab-dashboard-python
cd matlab-dashboard-python
```
_Alternatively you can download the project as a `.zip` file from GitHub (click the green Code button at the top right of the repository page, and select "Download Zip") and extract it to your computer manually._

### Step 2: Install the MATLAB Engine for Python
The Python dashboard needs to communicate with MATLAB in the background. To allow this, you must install the official MATLAB Engine API.
Open your terminal and run:
```bash
python.exe -m pip install matlabengine
```

### Step 3: Install Python Dependencies
Navigate to the `matlab-dashboard-python` directory in your terminal and install the required dependencies:
```bash
python.exe -m pip install -r requirements.txt
```
_If you do not have a `requirements.txt`, or are unable to locate it, you can manually install the packages by running: `pip install dash dash-bootstrap-components plotly pandas dash-leaflet requests`_

## [IMPORTANT] Pre-Launch Configuration
Before running the dashboard, you must tell the Python app where the MATLAB model folder is located on your machine.
1. Open `matlab_bridge.py` in a text editor (Notepad, Visual Studio Code, etc.).
2. Locate the following line of code (on line 10):
   ```python
   self.model_path = r"C:\Users\...\[OPTIMISATION IN PROGRESS] MATLAB Techno-economic Model"
   ```
3. Change the path inside the quotes to the absolute path where the `[OPTIMISATION IN PROGRESS] MATLAB Techno-economic Model` folder is located on your machine.
4. Save the file.

## Running the Dashboard
1. Open your terminal and ensure you are inside the `matlab-dashboard-python` folder.
2. Run the application using Python:
   ```python
   python.exe -m app
   ```
3. The terminal will display a message indicating the server is running. For example:
   ```bash
    ...
    MATLAB Engine Ready!
    Dash is running on http://127.0.0.1:8050/
    ...
    ```
4. Open your web browser (Chrome, Edge, Safari) and navigate to the server's address (i.e. http://127.0.0.1:8050).

# How to Use the Dashboard
- **Interactive Map**: Click anywhere on the global map to instantly send coordinates into the target input box.
- **Simulation Constraints**: Use the sliders in the left sidebar to restrict the mathematical boundaries. For example, you can force the model to only look at configurations with large storage capacities (>25h) or specific Solar vs. Wind ratios.
- **Cost Isolation**: Inside the "Relative Cost Breakdown" bar chart, you can click on any individual bar to open an isolated pop-up showing a detailed pie chart and the exact raw cost in $/kg for that specific energy configuration.
- **Raw Data**: At the very bottom of the chart, click on "View Raw Numerical Results" to view the unformatted Excel-style output of the mathematically optimal plant.

# List of features to implement
This is a list of features which are not implemented in this prototype. Further development will see this backlog of features be reduced.
- Full modification of all model parameters
- Tooltips
- Integrating model into repository
  - Unlikely, model is proprietary property of Dr. Leok Lee and his students