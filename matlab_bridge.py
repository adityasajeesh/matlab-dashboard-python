import matlab.engine
import time

class MatlabModel:
    def __init__(self):
        print("Starting MATLAB Engine... This may take a few seconds.")
        self.eng = matlab.engine.start_matlab()
        
        # Base path of MATLAB model - adjust as needed
        base_path = r'C:\Users\adity\OneDrive - University of Adelaide\INFO 3901\MATLAB Model\[OPTIMISATION IN PROGRESS] MATLAB Techno-economic Model'

        # CWD to model dir
        self.eng.cd(base_path, nargout=0)

        # Add necessary paths for MATLAB functions
        self.eng.addpath(self.eng.genpath(base_path), nargout=0)
        print("MATLAB Engine started, CWD set, paths configured.")

    def run_single_case(self, pv_share, rem_ocm_ratio, rem, storage_hrs):
        """
        Executes the MATLAB model without needing to write to a text file.
        Passes variables natively from Python to MATLAB workspace.
        """
        try:
            # Import data within MATLAB workspace
            self.eng.eval("[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();", nargout=0)
            
            # Execute CombinedCases directly
            # Note: inputs must be cast to float for MATLAB double compatibility
            output = self.eng.CombinedCases(
                float(pv_share), 
                float(rem_ocm_ratio), 
                float(rem), 
                float(storage_hrs), 
                self.eng.workspace['SolarData'], 
                self.eng.workspace['WindData'], 
                self.eng.workspace['HourlyElectricityPrices'],
                nargout=1
            )
            
            # Helper function to safely extract a scalar float from MATLAB objects
            def to_float(val):
                try:
                    # Try direct cast (works if MATLAB returns a standard number)
                    return float(val)
                except TypeError:
                    # If MATLAB returned a 1x1 matlab.double array (e.g., [[3.14]])
                    return float(val[0][0])

            # Backup is a time-series array (8760 hours), we must sum the first row
            backup_raw = output['Backup']
            try:
                # matlab.double arrays are structured like nested lists: [[val1, val2, ...]]
                backup_total = sum(backup_raw[0])
            except TypeError:
                backup_total = to_float(backup_raw)

            # Extract results back to Python dict natively
            results = {
                "Storage_LCOH": to_float(output['Storage_LCOH']),
                "GreenHydrogen_LCOH": to_float(output['GreenHydrogen_LCOH_Optimisation']),
                "BlueHydrogen_LCOH": to_float(output['BlueHydrogen_LCOH']),
                "Transport_LCHS": to_float(output['Transport_LCHS']),
                "Electricity_LCOE": to_float(output['Electricity_LCOE']),
                "Electricity_LCOH": to_float(output['Electricity_LCOH']),
                "Steel_LCOS": to_float(output['Steel_LCOS']),
                "Backup": float(backup_total)
            }
            return results
        except Exception as e:
            print(f"Error running MATLAB model: {e}")
            return None

    def close(self):
        self.eng.quit()

# Global instance initialized on server start
matlab_instance = MatlabModel()