%% Clear Data
clear
clc

%% Data

[SolarData, WindData, HourlyElectricityPrices] = ImportRawData();

orange = [1 0.698 0.4];
blue = [0.282 0.820 0.8];
green = [0.6 0.870 0.410];
pink = [1 0.713 0.757];
violet = [0.576 0.439 0.859];
grey = [0.5 0.5 0.5];

xlimit = 250;
xdata = linspace(0, xlimit); % $AUD/tCO2
y_lower = 400/0.65; % AUD/tLS   % Lower y-value of the shaded region
y_upper = 500/0.65; % AUD/tLS   % Upper y-value of the shaded region

Output = CombinedCases(0.43, 0.4, 3.4, 19, SolarData, WindData, HourlyElectricityPrices);
Output2050 = CombinedCases2050(0.71, 0.5, 3.3, 11, SolarData, WindData, HourlyElectricityPrices);

Total_LCOS_green_hydrogen = sum([Output.Storage_LCOS, Output.GreenHydrogen_LCOS_Reporting_All, Output.Transport_LCOS, Output.Electricity_LCOS, Output.Steel_LCOS]);
Total_LCOS_blue_hydrogen = sum([Output.Transport_LCOS, Output.Steel_LCOS, Output.BlueHydrogen_LCOS]);

Total_LCOS_green_hydrogen2050 = sum([Output2050.Storage_LCOS, Output2050.GreenHydrogen_LCOS_Reporting_All, Output2050.Transport_LCOS, Output2050.Electricity_LCOS, Output2050.Steel_LCOS]);
Total_LCOS_blue_hydrogen2050 = sum([Output2050.Transport_LCOS, Output2050.Steel_LCOS, Output2050.BlueHydrogen_LCOS]);

y_blast_furnace_lower = 2.1 * xdata + y_lower;
y_blast_furnace_upper = 2.1 * xdata + y_upper;

y_green_hydrogen = 0.24 * xdata + Total_LCOS_green_hydrogen; %tCO2/tLS
y_green_hydrogen2050 = 0.24 * xdata + Total_LCOS_green_hydrogen2050;
% tCO2/tLS * $/tCO2 + $/tLS

y_blue_hydrogen = (1 * 72.819289/1000 + 0.24) * xdata + Total_LCOS_blue_hydrogen;
y_blue_hydrogen2050 = (1 * 72.19289/1000 + 0.24) * xdata + Total_LCOS_blue_hydrogen2050;
% tCO2/tH2 * tH2/tLS * $/tCO2

% Define slopes
slope_green_hydrogen = 0.24;
slope_blue_hydrogen = (1 * 72.819289/1000 + 0.24);
slope_y_blast_furnace = 2.1;

% Solve for x where the two lines intersect
green_x_intersect_lower = (Total_LCOS_green_hydrogen - y_lower) / (slope_y_blast_furnace - slope_green_hydrogen);
green_x_intersect_upper = (Total_LCOS_green_hydrogen - y_upper) / (slope_y_blast_furnace - slope_green_hydrogen);
blue_x_intersect_lower = (Total_LCOS_blue_hydrogen - y_lower) / (slope_y_blast_furnace - slope_blue_hydrogen);

green_x_intersect_lower2050 = (Total_LCOS_green_hydrogen2050 - y_lower) / (slope_y_blast_furnace - slope_green_hydrogen);
blue_x_intersect_lower2050 = (Total_LCOS_blue_hydrogen2050 - y_lower) / (slope_y_blast_furnace - slope_blue_hydrogen);

green_blue_x_intersect = (Total_LCOS_green_hydrogen2050 - Total_LCOS_blue_hydrogen2050) / (slope_blue_hydrogen - slope_green_hydrogen);


% Find the corresponding y value
green_y_intersect_lower = slope_green_hydrogen * green_x_intersect_lower + Total_LCOS_green_hydrogen;
green_y_intersect_upper = slope_green_hydrogen * green_x_intersect_upper + Total_LCOS_green_hydrogen;
blue_y_intersect_lower = slope_blue_hydrogen * blue_x_intersect_lower + Total_LCOS_blue_hydrogen;

green_y_intersect_lower2050 = slope_green_hydrogen * green_x_intersect_lower2050 + Total_LCOS_green_hydrogen2050;
blue_y_intersect_lower2050 = slope_blue_hydrogen * blue_x_intersect_lower2050 + Total_LCOS_blue_hydrogen2050;

green_blue_y_intersect = slope_green_hydrogen * green_blue_x_intersect + Total_LCOS_green_hydrogen2050;

figure;

subplot(1,2,1)

hold on
plot(xdata, y_green_hydrogen, LineWidth=1.5, Color=green);
plot(xdata, y_blue_hydrogen, 'b', LineWidth=1.5);
plot(green_x_intersect_lower, green_y_intersect_lower, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(green_x_intersect_upper, green_y_intersect_upper, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(blue_x_intersect_lower, blue_y_intersect_lower, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
title("2020");

% Create the shaded region
% hold on;
fill([0 xlimit xlimit 0], [y_lower y_lower+xlimit*2.1  y_upper+xlimit*2.1 y_upper], [0.2 0.2 0.2], 'FaceAlpha', 0.3);

legend("Green Hydrogen", "Blue Hydrogen", "Blast Furnace Cost Range")

fontname("Times New Roman");
fontsize(10, "points");

grid on;
xlabel("Cost of Carbon Dioxide ($AUD/tCO_{2})");
ylabel("Levelised Cost of Steel ($AUD/tLS)");

ylim([0 1500]);
xlim([0 xlimit]);
xticks(0:50:xlimit);


subplot(1,2,2)
hold on
plot(xdata, y_green_hydrogen2050, LineWidth=1.5, Color=green);
plot(xdata, y_blue_hydrogen2050, 'b', LineWidth=1.5);
plot(green_x_intersect_lower2050, green_y_intersect_lower2050, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(blue_x_intersect_lower2050, blue_y_intersect_lower2050, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
plot(green_blue_x_intersect, green_blue_y_intersect, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r', 'HandleVisibility', 'off');
title("2050");

% Create the shaded region
% hold on;
fill([0 xlimit xlimit 0], [y_lower y_lower+xlimit*2.1  y_upper+xlimit*2.1 y_upper], [0.2 0.2 0.2], 'FaceAlpha', 0.3);

legend("Green Hydrogen", "Blue Hydrogen", "Blast Furnace Cost Range")

fontname("Times New Roman");
fontsize(10, "points");

ylim([0 1500]);
xlim([0 xlimit]);
xticks(0:50:xlimit);

grid on;
xlabel("Cost of Carbon Dioxide ($AUD/tCO_{2})");
ylabel("Levelised Cost of Steel ($AUD/tLS)");

hold off

