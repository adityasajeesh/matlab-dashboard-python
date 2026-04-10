%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

variables = ["Iron ore pellets cost", "Wind", "PV", "Electrolysis Capex ($AUD)", "H2 storage", "DRI", "EAF", "Discount Rate", "CO2 Emission Price"];
BaseCase = zeros(1,9);

green = [0.6 0.870 0.410];

for k = 1:1
     BaseCase(1) = 158.2     ; % iron_ore_pellet_cost | LC.Iron_ore_Cost %%%%%%%%%%%%%%%%%%%%%%%%
     BaseCase(5) = 1662      ; % storage_capex | LC.S_CAPEX
     BaseCase(6) = 369.8     ; % HBDR_capex | LC.CapEx_H2_DR_Shaft
     BaseCase(7) = 265.6     ; % EAF_capex | LC.CapEx_EAF
     BaseCase(8) = 0.07      ; % Annuities | Range %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     BaseCase(9) = 138.46    ; % CO2_emission_price | LC.Emission_Price and LC.C_Tax
    if k == 1
        BaseCase(2) = 1325/0.61 ; % wind_capex | LC.Wind_Total_CAPEX
        BaseCase(3) = 628/0.61  ; % PV_capex | LC.PV_Total_CAPEX
        BaseCase(4) = 3104.91   ; % electrolyser_capex | LC.GH_CAPEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif k == 2
        BaseCase(2) = 1619      ; % wind_capex | LC.Wind_Total_CAPEX
        BaseCase(3) = 552       ; % PV_capex | LC.PV_Total_CAPEX
        BaseCase(4) = 968       ; % electrolyser_capex | LC.GH_CAPEX
    end
        
    parameter_index = [4 8];
    Annuities = linspace(0, 2*BaseCase(8));
    PEM_Capex = linspace(0, 2*BaseCase(4));
    arr = [PEM_Capex Annuities];
    
    figure;
    
    for i = 1:length(parameter_index) % discount rate and PEM_capex
        yvalues = zeros(1,length(Annuities));
        for j = 1:length(Annuities)
            NewCase = BaseCase;
            NewCase(parameter_index(i)) = arr((i-1)*length(Annuities)+j);
            LCOH1 = CC_SA(NewCase, SolarData, WindData, HourlyElectricityPrices,k);

            yvalues(j) = LCOH1;
    
    
        end
        subplot(1,2,i)
        if i == 1
            plot(arr((i-1)*length(Annuities)+1:i*length(Annuities)), yvalues, 'LineWidth', 1.5, 'Color', green);
            xlim([0 6000]);
        else
            plot(arr((i-1)*length(Annuities)+1:i*length(Annuities)), yvalues, 'LineWidth', 1.5);
            xlim([0 0.14]);
            xticks([0 0.035 0.07 0.105 0.14]);
        end

        % title(variables(parameter_index(i)));
        xlabel(variables(parameter_index(i)));
        ylabel("Levelised Cost of Hydrogen ($AUD/kgH_{2})");
        ylim([600 1800]);

        fontname('Times New Roman');
        fontsize(10, "points");
        hold on
    end
    hold off
end