%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

blue = [0.282 0.820 0.8];
green = [0.6 0.870 0.410];

variables = ["Iron ore pellets", "Wind turbines", "Photovoltaics", "Electrolysis", "Hydrogen storage", "Direct reduction", "Electric arc furnace", "Discount rate", "Carbon Emission Price"];
BaseCase = zeros(1,9);

data_left = flip([-9.13, -7.71, -4.98, -4.53, -1.7, -1.06, -0.76, -0.56]);
data_right = flip([9.13, 8.19, 4.98, 4.53, 1.7, 1.06, 0.76, 0.56]);

for k = 1:2
     BaseCase(1) = 158.2     ; % iron_ore_pellet_cost | LC.Iron_ore_Cost %%%%%%%%%%%%%%%%%%%%%%%%
     BaseCase(5) = 1662      ; % storage_capex | LC.S_CAPEX
     BaseCase(6) = 369.8     ; % HBDR_capex | LC.CapEx_H2_DR_Shaft
     BaseCase(7) = 265.6     ; % EAF_capex | LC.CapEx_EAF
     BaseCase(8) = 0.07      ; % Annuities | Range %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % BaseCase(9) = 138.46    ; % CO2_emission_price | LC.Emission_Price and LC.C_Tax
    if k == 1
        BaseCase(2) = 1325/0.61 ; % wind_capex | LC.Wind_Total_CAPEX
        BaseCase(3) = 628/0.61  ; % PV_capex | LC.PV_Total_CAPEX
        BaseCase(4) = 3104.91   ; % electrolyser_capex | LC.GH_CAPEX %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    elseif k == 2
        BaseCase(2) = 1619      ; % wind_capex | LC.Wind_Total_CAPEX
        BaseCase(3) = 552       ; % PV_capex | LC.PV_Total_CAPEX
        BaseCase(4) = 968       ; % electrolyser_capex | LC.GH_CAPEX
    end
    
    Base_LCOS = CC_SA(BaseCase, SolarData, WindData, HourlyElectricityPrices, k);
    
    percent_change = [0.25 0.50]; % percent as decimal
    
    figure;
    
    for i = 1:length(percent_change)
        for j = [5 7 6 3 2 1 8 4]
            NewCase = BaseCase;
            NewCase(j) = BaseCase(j) * (1+percent_change(i));
            LCOH1 = CC_SA(NewCase, SolarData, WindData, HourlyElectricityPrices,k);
    
            NewCase(j) = BaseCase(j) * (1-percent_change(i));
            LCOH2 = CC_SA(NewCase, SolarData, WindData, HourlyElectricityPrices,k);
    
            result = [(LCOH1 - Base_LCOS)/Base_LCOS*100, (LCOH2 - Base_LCOS)/Base_LCOS*100];
    
            subplot(1,2,i);
            if k == 1; sgtitle("2020"); else; sgtitle("2050"); end
            title(strcat("Percent Change: ", string(percent_change(i)*100), "%"));
            xlim([-25 25]);
            xlabel("Percent (%)")
    
            plot = barh(variables(j), result(1), 'stacked', 'FaceColor', blue);
    
            xtips1 = plot(1).YEndPoints + 0.3;
            ytips1 = plot(1).XEndPoints;
            labels1 = strcat(string(round(plot(1).YData,2)), "%");
            text(xtips1,ytips1,labels1,'VerticalAlignment','middle');
            
            hold on;
            plot = barh(variables(j), result(2), 'stacked', 'FaceColor', green);
    
            xtips1 = plot(1).YEndPoints - 4.5;
            ytips1 = plot(1).XEndPoints;
            labels1 = strcat(string(round(plot(1).YData,2)), "%");
            text(xtips1,ytips1,labels1,'VerticalAlignment','middle');

            fontname('Times New Roman');
            fontsize(10, "points");
    
            hold on;
    
        end
        hold off;
    end
end