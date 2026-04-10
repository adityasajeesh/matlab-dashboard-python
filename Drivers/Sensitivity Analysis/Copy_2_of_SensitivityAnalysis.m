%% Clear Data
clear
clc

%% Data

blue = [0.282 0.820 0.8];
green = [0.6 0.870 0.410];

variables_2020 = ["Hydrogen storage", "Electric arc furnace", "Direct reduction", "Photovoltaics", "Wind turbines", "Iron ore pellets", "Discount rate", "Electrolysis"];
    
% % Left graph (25% change data)
% data_left = flip([-9.13, -7.71, -4.98, -4.53, -1.7, -1.06, -0.76, -0.56]);
% data_right = flip([9.13, 8.19, 4.98, 4.53, 1.7, 1.06, 0.76, 0.56]);
% 
% % Right graph (50% change data)
% data_left_50 = flip([-18.25, -14.88, -9.95, -9.05, -3.4, -2.12, -1.52, -1.12]);
% data_right_50 = flip([18.25, 16.77, 9.95, 9.05, 3.4, 2.12, 1.52, 1.12]);

% Left graph (25% change data)
data_left = flip([-8.28, -6.09, -4.12, -2.77, -2.43, -1.76, -1.27, -0.54]);
data_right = flip([8.28, 6.48, 4.12, 2.77, 2.43, 1.76, 1.27, 0.54]);

% Right graph (50% change data)
data_left_50 = flip([-16.57, -11.72, -8.24, -5.55, -4.87, -3.53, -2.53, -1.08]);
data_right_50 = flip([16.57, 13.29, 8.24, 5.55, 4.87, 3.53, 2.53, 1.08]);

% Plot settings
figure;
hold on;

%% Plot for 25% change
subplot(1, 2, 1); % Left subplot

% Left side bars (negative values)
barh(variables_2020, data_left, 'stacked', 'FaceColor', green); % Left side bars

% Position the labels dynamically
for i = 1:length(data_left)
    text(data_left(i) - 0.5, i, strcat(string(data_left(i)), "%"), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle'); 
end

hold on;

% Right side bars (positive values)
barh(variables_2020, data_right, 'stacked', 'FaceColor', blue); % Right side bars

% Position the labels dynamically
for i = 1:length(data_right)
    text(data_right(i) + 0.5, i, strcat(string(data_right(i)), "%"), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
end

title('Percent Change: 25%');
xlabel('Percent (%)');
xlim([-25 25]);

%% Plot for 50% change
subplot(1, 2, 2); % Right subplot

% Left side bars (negative values)
barh(variables_2020, data_left_50, 'stacked', 'FaceColor', green); % Left side bars

% Position the labels dynamically
for i = 1:length(data_left_50)
    text(data_left_50(i) - 0.5, i, strcat(string(data_left_50(i)), "%"), 'HorizontalAlignment', 'right', 'VerticalAlignment', 'middle'); 
end

hold on;

% Right side bars (positive values)
barh(variables_2020, data_right_50, 'stacked', 'FaceColor', blue); % Right side bars

% Position the labels dynamically
for i = 1:length(data_right_50)
    text(data_right_50(i) + 0.5, i, strcat(string(data_right_50(i)), "%"), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');
end

title('Percent Change: 50%');
xlabel('Percent (%)');
xlim([-25 25]);
sgtitle("2050");
fontname("Times New Roman");
fontsize(10, "points");

hold off;
