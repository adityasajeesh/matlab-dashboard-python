function LocationConfig = BuildLocationConfig(locationName)
%BuildLocationConfig Maps a location string to weather and electricity settings
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
            LocationConfig.Latitude = -33.0321;
            LocationConfig.Longitude = 137.5610;
        case {"adelaide", "adelaide sa", "adelaide, sa"}
            LocationConfig.LocationName = "Adelaide";
            LocationConfig.WeatherFilePrefix = "Adelaide";
            LocationConfig.NEMRegion = "SA1";
            LocationConfig.State = "SA";
            LocationConfig.Latitude = -34.9285;
            LocationConfig.Longitude = 138.6007;
        otherwise
            error("Unsupported location '%s'. Add a mapping in BuildLocationConfig.m.", string(locationName));
    end
end