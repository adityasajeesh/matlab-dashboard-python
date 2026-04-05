function [] = PlotHeatMaps(data, dataType)

MonthArray2 = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]; % data based on 2020

data1 = data(:, 1:32);
emptyDay = ones(24,1)*1.5;
data1 = cat(2, data1, emptyDay);

for i = 2:12
    arr = data(:, MonthArray2(i)+1:MonthArray2(i+1));
    test = 32 - (MonthArray2(i+1)-MonthArray2(i));
    if test ~= 0
        for j = 1:test
            if i==12 && j==test; break; end
            arr = cat(2, arr, emptyDay);
        end
    end
    data1 = cat(2, data1, arr);
end

% Create a figure
figure;

% Display the heatmap using imagesc
h = imagesc(data1);

% Customize colormap to match the heatmap style
if strcmp("Solar", dataType) == 1
    cmap = colormap('hot');
    title('Hourly Solar PV Capacity Factor');
else
    cmap = colormap(slanCM('viridis'));
    title('Hourly Wind Capacity Factor');
end

cmap = [cmap; 1, 1, 1];  % Append white color to the colormap
colormap(cmap);

% Add colorbar
colorbar;

% Set axis labels and ticks
set(gca, 'YTick', 0:1:23, 'YTickLabel', 0:1:23);  % Hours on the y-axis
set(gca, 'XTick', [16, 48, 80, 112, 144, 176, 208, 240, 272, 304, 336, 368], ...
         'XTickLabel', {'J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'});  % Months on the x-axis

% Title and labels
xlabel('Day/Month');
ylabel('Hour');

% Optionally, set limits for the color axis to match the capacity factor range
clim([0 1]);  % Adjust according to your data range

% Manually set the color data to make sure white_value appears as white
cdata = get(h, 'CData');  % Get the CData of the image
cdata(cdata == 1.5) = max(data1(:)) + 1;  % Map white_value to the maximum+1 index in colormap
set(h, 'CData', cdata);  % Update the CData with new values

end