import matlab.engine
import time
import pandas as pd
import os
class MatlabModel:
    def __init__(self):
        print("Starting MATLAB Engine... This might take a minute.")
        self.eng = matlab.engine.start_matlab()
        
        # Point to the MATLAB folder
        model_path = os.path.abspath("C:\\Users\\adity\\OneDrive - University of Adelaide\\INFO 3901\\MATLAB Model\\[OPTIMISATION IN PROGRESS] MATLAB Techno-economic Model\\")
        self.eng.cd(model_path, nargout=0)
        
        # CRITICAL FIX: Tell MATLAB to "Add with Subfolders" so it can see your Functions and Data!
        self.eng.eval("addpath(genpath(pwd))", nargout=0)
        
        print("MATLAB Engine Ready!")

    def run_optimisation(self, location="Whyalla", year=2020):
        print(f"Injecting parameters: Location={location}, Year={year}")
        
        # 1. Inject variables directly into the MATLAB workspace
        self.eng.workspace['TargetLocation'] = location
        self.eng.workspace['TargetYear'] = float(year) 

        start_time = time.time()
        
        # 2. Run the driver script
        print("Running Optimisation_algorithm.m...")
        # Since we added everything to the path above, we can just call the file by its name!
        self.eng.eval("Optimisation_algorithm", nargout=0)
        
        end_time = time.time()
        print(f"Simulation completed in {end_time - start_time:.2f} seconds.")
        
        # 3. Load the results
        # NOTE: Make sure this path is pointing exactly to where your MATLAB model is saved
        model_path = os.path.abspath("C:\\Users\\adity\\OneDrive - University of Adelaide\\INFO 3901\\MATLAB Model\\[OPTIMISATION IN PROGRESS] MATLAB Techno-economic Model\\")
        results_path = os.path.join(model_path, r"Drivers\Optimisation\Saved Data\Optimising Backup and System_LCOH.txt")
        
        if os.path.exists(results_path):
            df = pd.read_csv(results_path)
            return df
        else:
            raise FileNotFoundError("Simulation finished, but output file was not found.")

# Create the instance so app.py can use it
matlab_instance = MatlabModel()