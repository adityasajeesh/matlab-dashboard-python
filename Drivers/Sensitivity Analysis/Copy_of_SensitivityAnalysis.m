%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

blue = [0.282 0.820 0.8];
green = [0.6 0.870 0.410];

variables_2020 = ["Electrolysis", "Discount rate", "Iron ore pellets", "Wind turbines", "Photovoltaics", "Direct reduction", "Electric arc furnace", "Hydrogen storage"];
variables_2050 = ["Iron ore pellets", "Discount rate", "Electrolysis", "Wind turbines", "Photovoltaics", "Direct reduction", "Electric arc furnace", "Hydrogen storage"];
    
% Left graph (25% change data)
data_left = flip([-9.13, -7.71, -4.98, -4.53, -1.7, -1.06, -0.76, -0.56]);
data_right = flip([9.13, 8.19, 4.98, 4.53, 1.7, 1.06, 0.76, 0.56]);

% Right graph (50% change data)
data_left_50 = flip([-18.25, -14.88, -9.95, -9.05, -3.4, -2.12, -1.52, -1.12]);
data_right_50 = flip([18.25, 16.77, 9.95, 9.05, 3.4, 2.12, 1.52, 1.12]);

% Plot settings
figure;
hold on;

% Plot for 25% change
subplot(1, 2, 1); % Left subplot
plot = barh(variables_2020, data_left, 'stacked', 'FaceColor', green); % Left side bars

xtips1 = plot(1).YEndPoints + 0.3;
ytips1 = plot(1).XEndPoints;
labels1 = strcat(string(round(plot(1).YData,2)), "%");
text(xtips1,ytips1,labels1,'VerticalAlignment','middle');

hold on;
plot = barh(variables_2020, data_right, 'stacked', 'FaceColor', blue); % Right side bars

xtips1 = plot(1).YEndPoints - 4.5;
ytips1 = plot(1).XEndPoints;
labels1 = strcat(string(round(plot(1).YData,2)), "%");
text(xtips1,ytips1,labels1,'VerticalAlignment','middle');

title('Percent Change: 25%');
xlabel('Percent (%)');
xlim([-25 25]);

% Plot for 50% change
subplot(1, 2, 2); % Right subplot
plot = barh(variables_2020, data_left_50, 'stacked', 'FaceColor', green); % Left side bars

xtips1 = plot(1).YEndPoints + 0.3;
ytips1 = plot(1).XEndPoints;
labels1 = strcat(string(round(plot(1).YData,2)), "%");
text(xtips1,ytips1,labels1,'VerticalAlignment','middle');

hold on;
plot = barh(variables_2020, data_right_50, 'stacked', 'FaceColor', blue); % Right side bars

xtips1 = plot(1).YEndPoints - 4.5;
ytips1 = plot(1).XEndPoints;
labels1 = strcat(string(round(plot(1).YData,2)), "%");
text(xtips1,ytips1,labels1,'VerticalAlignment','middle');

title('Percent Change: 50%');
xlabel('Percent (%)');
xlim([-25 25]);
sgtitle("2020");
fontname("Times New Roman");
fontsize(10, "points");



hold off;
    
% for j = 1:length(Data2050_50percent);
% 
%     subplot(1,2,1);
%     sgtitle("2020");
%     title("Percent Change: 25%");
%     xlim([-25 25]);f
%     xlabel("Percent (%)")
% 
%     plot = barh(variables_2020(j), Data2020_25percent(1), 'stacked', 'FaceColor', blue);
% 
%     xtips1 = plot(1).YEndPoints + 0.3;
%     ytips1 = plot(1).XEndPoints;
%     labels1 = strcat(string(round(plot(1).YData,2)), "%");
%     text(xtips1,ytips1,labels1,'VerticalAlignment','middle');
% 
%     hold on;
%     plot = barh(variables_2020(j), result(2), 'stacked', 'FaceColor', green);
% 
%     xtips1 = plot(1).YEndPoints - 4.5;
%     ytips1 = plot(1).XEndPoints;
%     labels1 = strcat(string(round(plot(1).YData,2)), "%");
%     text(xtips1,ytips1,labels1,'VerticalAlignment','middle');
% 
%     fontname('Times New Roman');
%     fontsize(10, "points");
% 
%     hold off;
% 
% end