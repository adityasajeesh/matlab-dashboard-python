function HourlyElectricityPrices = LoadElectricityPriceData(LocationConfig, yearValue)
%LoadElectricityPriceData Loads the  hourly electricity prices for a mapped NEM region
%Priority order IMPORTANT:
%1 Region-specific MAT file: Model Data/<year><region>HourlyElectricityData.mat
%2 Region-specific CSV file: Model Data/<year><region>HourlyElectricityData.csv
%3L egacy MAT file: Model Data/<year>HourlyElectricityData.mat
%4 Legacy CSV file: Model Data/<year>HourlyElectricityData.csv

%Expected CSV columns can be one of:
%Hour, Price
%DATETIME, RRP
%SETTLEMENTDATE, RRP
%a single numeric price column

    if nargin < 2 || isempty(yearValue)
        yearValue = 2020;
    end

    region = string(LocationConfig.NEMRegion);
    baseDir = fullfile(fileparts(fileparts(fileparts(mfilename('fullpath')))), 'Model Data');


    candidates = [ ...
        string(fullfile(baseDir, sprintf('%d%sHourlyElectricityData.mat', yearValue, region)));
        string(fullfile(baseDir, sprintf('%d%sHourlyElectricityData.csv', yearValue, region)));
        string(fullfile(baseDir, sprintf('%dHourlyElectricityData.mat', yearValue)));
        string(fullfile(baseDir, sprintf('%dHourlyElectricityData.csv', yearValue)))];

    selectedPath = "";
    for i = 1:numel(candidates)
        if isfile(candidates(i))
            selectedPath = candidates(i);
            break;
        end
    end

    if strlength(selectedPath) == 0
        error("No electricity price file found for location %s / region %s.", LocationConfig.LocationName, region);
    end

    [~,~,ext] = fileparts(selectedPath);

    if strcmpi(ext, ".mat")
        imported = importdata(selectedPath);
        if isstruct(imported) && isfield(imported, 'data')
            data = imported.data;
        else
            data = imported;
        end

        if isvector(data)
            HourlyElectricityPrices = data(:);
        else
            HourlyElectricityPrices = data(:,1);
        end
    else
        opts = detectImportOptions(selectedPath, 'VariableNamingRule', 'preserve');
        tbl = readtable(selectedPath, opts);
        vars = string(tbl.Properties.VariableNames);
        varsLower = lower(vars);

        preferredColumns = ["Price", "RRP", "RegionalReferencePrice", "SpotPrice", "PRICE"];
        priceIdx = [];
        for name = preferredColumns
            idx = find(vars == name | varsLower == lower(name), 1);
            if ~isempty(idx)
                priceIdx = idx;
                break;
            end
        end

        if isempty(priceIdx)
            numericMask = varfun(@isnumeric, tbl, 'OutputFormat', 'uniform');
            numericIdx = find(numericMask, 1);
            if isempty(numericIdx)
                error("No numeric electricity price column found in %s", selectedPath);
            end
            priceIdx = numericIdx;
        end

        HourlyElectricityPrices = tbl{:, priceIdx};
    end

    HourlyElectricityPrices = HourlyElectricityPrices(:);

expectedLen = 8784;

if numel(HourlyElectricityPrices) ~= expectedLen %for the demonstration model, this statmtnet had to be included as the 2026 updated hourly sheet doesnt have the expected number of rows
    warning("Electricity price sheet has %d rows and is expected %d. Repeating these values to match the model length for prototype testing!", ...
        numel(HourlyElectricityPrices), expectedLen);

    reps = ceil(expectedLen / numel(HourlyElectricityPrices));
    HourlyElectricityPrices = repmat(HourlyElectricityPrices, reps, 1);
    HourlyElectricityPrices = HourlyElectricityPrices(1:expectedLen);
end
end
