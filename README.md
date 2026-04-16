# Full-Stack Python Green Hydrogen Dashboard

This project is a Python-based web dashboard built using Plotly Dash. It directly interfaces with the MATLAB underlying model using the official `matlab.engine` package to calculate the optimal configurations for Green Hydrogen and Green Steel plants.

## Architecture
- **Frontend/Backend:** Plotly Dash & Flask. Replicates modern React architecture via Python components.
- **Compute Layer:** `matlab.engine` running natively in the background. Natively passes Python floats to the MATLAB workspace arrays to avoid slow `.csv`/`.txt` disk I/O.

## Prerequisites
1. **Python 3.8 - 3.11** (MATLAB Engine for Python is strictly tied to specific Python versions).
2. **MATLAB Installation** (Tested with R2022b/R2023a).
3. The MATLAB Dashboard base model cloned on your local machine.

## Setup Instructions

**1. Install Python Dependencies**
Navigate to this directory in your terminal and run:
```bash
pip install -r requirements.txt