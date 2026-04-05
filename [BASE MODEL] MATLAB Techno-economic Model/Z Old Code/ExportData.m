function [] = ExportData(x1, OutputHydrogen, Hydrogen, ChargedEnergy, GridEnergy, WastedHydrogen, StoredHydrogen, HSH)

    % Code for exporting data
    Time = x1';
    DemandedPower = OutputHydrogen*0.033 + zeros(size(Hydrogen));
    RenewableHydrogenPower = Hydrogen*0.033;
    ChargedPower = ChargedEnergy*0.033;
    OutsourcedPower = GridEnergy;
    WastedHydrogenPower = WastedHydrogen*-0.033;
    StoredEnergy = StoredHydrogen*0.033;
    HydrogenStorageHours = zeros(size(Hydrogen)) + HSH;

    T = table(Time, DemandedPower, RenewableHydrogenPower, ChargedPower, OutsourcedPower, WastedHydrogenPower, StoredEnergy, HydrogenStorageHours);
    writetable(T, strcat("Results\Data\Seminar Graphs\HSH", string(HSH), ".txt"))
    % End of Code for exporting data

end