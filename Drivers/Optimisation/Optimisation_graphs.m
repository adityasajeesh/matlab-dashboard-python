clear

data = importdata("Drivers/Optimisation/Saved Data/optimisation_data_LCOHRenewables_higherresolution.mat");
renewable_share = ones(length(data.BackupShare),1);

renewable_share = renewable_share - data.BackupShare;
LCOH = data.Total_LCOH;
increment = 0.001;
increments = 0:increment:1;

min_LCOH = zeros(size(increments));

% Loop through each increment
for i = 1:length(increments)
    % Define the range for the current increment
    lower_bound = increments(i)-0.5*increment;
    upper_bound = lower_bound + increment;
    
    % Find the backup share values within this range
    in_range = (renewable_share >= lower_bound) & (renewable_share < upper_bound);
    
    % If there are any values in this range, find the minimum LCOH
    if any(in_range)
        min_LCOH(i) = min(LCOH(in_range));
    else
        % If no values fall within the range, assign NaN (or any placeholder)
        min_LCOH(i) = NaN;
    end
end

% Remove NaN values for the line of best fit calculation
valid_id = ~isnan(min_LCOH);
valid_renewable_share = increments(valid_id);
valid_min_LCOH = min_LCOH(valid_id);

% Fit a first-order polynomial (linear fit)
p = polyfit(valid_renewable_share, valid_min_LCOH, 10); % 1 means linear

% Evaluate the polynomial at the original data points
fitted_LCOH = polyval(p, valid_renewable_share);

% figure;
% scatter(renewable_share*100, LCOH);
% 
% xlabel("Renewable Share (%)");
% ylabel("LCOH ($AUD/kgH_{2})");
% title("Backup Share against LCOH");
% fontname('Times New Roman');
% fontsize(10,"points");

% Display or use the result
figure;
plot(increments*100, min_LCOH, 'o');
hold on;
plot(valid_renewable_share * 100, fitted_LCOH, 'r-', 'LineWidth', 1.5);
xlabel("Renewable Share (%)");
ylabel("LCOH ($AUD/kgH_{2})");
title("Minimum LCOH for each 0.1% backup share increment");
fontname('Times New Roman');
fontsize(10,"points");
