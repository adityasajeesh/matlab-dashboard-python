function [Elect] = ElectrolyserAndStorage(LC, RenewablePower)
%% ElectrolyserAndStorage
%   Description:
%       Function to take the renewable power produced from solar and wind and determine the amount of power going into the electrolysers, 
%       the amount of backup power required, the amount of power curtailed, and the rate of hydrogen storage       
%
%   Input: 
%       LC: Input struct containing all needed constant values for calculations
%       Renewable Power: Array containing the amount of renewable power produced each hour for the year    
%
%   Output: 
%       Elect: Output struct containing most variables calculated throughout this function
%

%% Code
% Calculate the number of electrolysers based on the oversized requirements of the system
Elect.NumElectrolysers = ceil((LC.HourlyCapacitywithOversize*24) / LC.MassOutput); % Round up as cannot have a fractional number of electrolysers

% Define the total power required for the system, the max input power of the electrolysers and the storage capacity of the hydrogen storage.
Elect.TotalPowerRequired = LC.GH_Spec_Cons * (LC.HourlyDemandedHydrogen);% kW IRON AND STEEL
MaxInputPower = Elect.NumElectrolysers * (LC.MassOutput/24) * LC.GH_Spec_Cons; % kW %IRON OVERSIZED AND STEEL
StorageCapacity = LC.HourlyDemandedHydrogen * LC.Storage_hrs; %kgH2

% Initialise used arrays
StoredHydrogen = zeros(1,length(RenewablePower));
Elect.ElectrolyserInputPower = zeros(1,length(RenewablePower));
Elect.BackUpElectricity = zeros(1,length(RenewablePower));
Elect.Curtailment = zeros(1,length(RenewablePower));
Elect.HydrogenStorageRate = zeros(1,length(RenewablePower));

for i = 1:length(RenewablePower) % for every hour in the renewable power array
    if RenewablePower(i) < 0; fprintf("TotalPower is negative"); end % flag an error

    if RenewablePower(i) >= Elect.TotalPowerRequired % if there is more power than required

        if StoredHydrogen(i) == StorageCapacity % if storage is full
            Elect.Curtailment(i) = RenewablePower(i) - Elect.TotalPowerRequired; % curtailment consists of power obtained minus what is needed
            Elect.ElectrolyserInputPower(i) = RenewablePower(i) + Elect.BackUpElectricity(i) - Elect.Curtailment(i); % power going into electrolyser is power obtained minus curtailment
            StoredHydrogen(i+1) = StorageCapacity; % storage stays full

        elseif StoredHydrogen(i) >= -0.001 && StoredHydrogen(i) < StorageCapacity % storage not full
            AvailableStorage = (StorageCapacity - StoredHydrogen(i)) * LC.GH_Spec_Cons; % available storage is total capacity minus last hours storage level

            % power for storage is the minimum of the remaining space in the storage, the excess power obtained from renewables, or
            % the maximum amount of power the electrolysers can take minus what is required for the system.
            PowerForStorage = min([AvailableStorage, RenewablePower(i) - Elect.TotalPowerRequired, MaxInputPower - Elect.TotalPowerRequired]); 

            % even though this minimum isn't needed, the MATLAB code would set the stored hydrogen value to just above the storage capacity causing errors
            StoredHydrogen(i+1) = min([StorageCapacity, StoredHydrogen(i) + PowerForStorage/LC.GH_Spec_Cons]); % fill the storage with leftover energy

            % curtailment is the power received from renewables minus what was stored minus what was used
            Elect.Curtailment(i) = RenewablePower(i) - PowerForStorage - Elect.TotalPowerRequired;

            % the power going into the electrolysers is equal to renewable power minus curtailment
            Elect.ElectrolyserInputPower(i) = RenewablePower(i) + Elect.BackUpElectricity(i) - Elect.Curtailment(i);

        else
            fprintf("Storage Error1: iteration %d", i);
        end

    elseif RenewablePower(i) < Elect.TotalPowerRequired % if there is not enough power than what is needed

        if StoredHydrogen(i) >= (Elect.TotalPowerRequired / LC.GH_Spec_Cons) % If storage has enough for hydrogen reduction and EAF
            
            % the storage level for this hour is the last hours minus the difference between power required and the power received from renewables
            StoredHydrogen(i+1) = StoredHydrogen(i) - ((Elect.TotalPowerRequired - RenewablePower(i))/LC.GH_Spec_Cons);
            
            % In this case electrolyser input power only equals renewable power, the other values are 0
            Elect.ElectrolyserInputPower(i) = RenewablePower(i) + Elect.BackUpElectricity(i) - Elect.Curtailment(i);

        elseif StoredHydrogen(i) >= -0.001 && StoredHydrogen(i) < (Elect.TotalPowerRequired / LC.GH_Spec_Cons) % Not enough for reduction and EAF
            storagePowerRequired = Elect.TotalPowerRequired - RenewablePower(i);% how much power is needed from storage (might not have enough storage)
            availablePowerinStorage = StoredHydrogen(i)*LC.GH_Spec_Cons; % how much energy is in storage
            powerFromStorage = min([availablePowerinStorage, storagePowerRequired]); % how much power can be taken from storage
            StoredHydrogen(i+1) = StoredHydrogen(i) - powerFromStorage/LC.GH_Spec_Cons; % calculate how much storage is left

            % backup equals 0 or the power we require minus renewable power minus the power in storage
            Elect.BackUpElectricity(i) = max(0, Elect.TotalPowerRequired - RenewablePower(i) - StoredHydrogen(i)*LC.GH_Spec_Cons);
            
            % power going into the electrolysers equals renewable power plus backup power
            Elect.ElectrolyserInputPower(i) = RenewablePower(i) + Elect.BackUpElectricity(i) - Elect.Curtailment(i);
            
        else
            fprintf("Storage Error2: iteration %d", i);
        end
        
    else
        fprintf("Error in data / renewable power calculations");
    end

    % MATLAB would make storage a really small negative number, this if statement sets those values to zero to prevent future errors.
    if StoredHydrogen(i+1) >= -0.001 && StoredHydrogen(i+1) < 0
        StoredHydrogen(i+1) = 0;
    end

    Elect.HydrogenStorageRate(i) = StoredHydrogen(i+1) - StoredHydrogen(i);

    if Elect.Curtailment(i) < -0.0000001
        fprintf("negative");
    end

end

Elect.StoredHydrogen = StoredHydrogen(1, 2:length(RenewablePower)+1);
Elect.Hydrogen = Elect.ElectrolyserInputPower/LC.GH_Spec_Cons*1; % total amount of hydrogen produced by electrolysers
Water = Elect.Hydrogen*LC.GH_Water_use; %LC.GH_Water_use is the demineralised water consumption in L/kgH2. The units are currently L/Nm^3 so this has to be altered in Combined.m.
Elect.Water = sum(Water);

end