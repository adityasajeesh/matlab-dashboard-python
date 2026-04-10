function LocationConfig = BuildLocationConfig(locationName)
%BuildLocationConfig will map a single location string to weather and electricity settings
% a single location variable used for both weather data and electricity costs
% switch block can be extended if more project locations are needing to be  supported

    if nargin < 1 || strlength(string(locationName)) == 0
        locationName = "Whyalla";
    end

    locationKey = lower(strtrim(string(locationName)));

    switch locationKey
        case {"whyalla", "whyalla sa", "whyalla, sa"}
            LocationConfig.LocationName = "Whyalla";
            LocationConfig.WeatherFilePrefix = "Whyalla";
            LocationConfig.NEMRegion = "SA1";
            LocationConfig.State = "SA";
        case {"adelaide", "adelaide sa", "adelaide, sa"}
            LocationConfig.LocationName = "Adelaide";
            LocationConfig.WeatherFilePrefix = "Adelaide";
            LocationConfig.NEMRegion = "SA1";
            LocationConfig.State = "SA";
        otherwise
            error("Unsupported location '%s'. Add a mapping in BuildLocationConfig.m.", string(locationName));
    end
end
