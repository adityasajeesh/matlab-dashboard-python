import matlab.engine
import time
import pandas as pd
import os

class MatlabModel:
    def __init__(self):
        print("Starting MATLAB Engine... This might take a minute.")
        self.eng = matlab.engine.start_matlab()
        self.model_path = r"C:\Users\adity\OneDrive - University of Adelaide\INFO 3901\MATLAB Model\[OPTIMISATION IN PROGRESS] MATLAB Techno-economic Model"
        self.eng.cd(self.model_path, nargout=0)
        self.eng.eval("addpath(genpath(pwd))", nargout=0)
        print("MATLAB Engine Ready!")

    def run_optimisation(self, location="Whyalla", year=2020, rem_bounds=[1, 5], storage_bounds=[1, 25]):
        print(f"Executing: {location} ({year}) | REM: {rem_bounds} | Storage: {storage_bounds}")
        
        self.eng.workspace['TargetLocation'] = location
        self.eng.workspace['TargetYear'] = float(year) 
        
        # Inject dynamic bounds
        self.eng.workspace['RemMin'] = float(rem_bounds[0])
        self.eng.workspace['RemMax'] = float(rem_bounds[1])
        self.eng.workspace['StorageMin'] = float(storage_bounds[0])
        self.eng.workspace['StorageMax'] = float(storage_bounds[1])

        start_time = time.time()
        self.eng.eval("Optimisation_algorithm", nargout=0)
        end_time = time.time()
        print(f"Simulation completed in {end_time - start_time:.2f} seconds.")
        
        results_path = os.path.join(self.model_path, "Drivers", "Optimisation", "Saved Data", "Optimising Backup and System_LCOH.txt")
        if os.path.exists(results_path):
            return pd.read_csv(results_path)
        else:
            raise FileNotFoundError("Output file was not found.")

matlab_instance = MatlabModel()