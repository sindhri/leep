function exclusion_vector = leep_get_exclusion_vector(exclusions, srate, n_dpt)


    % create an exclusion_vector based on exclusions
    % exclusions has 1 value for every second
    % exclusion_vector has 1 value for every data point
    % make an exclusions vector and map it back onto the data length
    % (interpret every second)
    
    exclusion_vector = [];
    for i = 1:length(exclusions)
        exclusion_vector(end + 1 : end + srate) = exclusions(i);
    end
    % adjusting the last second of exclusion_vector to match the length of
    % the data
    if length(exclusion_vector) < size(data, 1)
        exclusion_vector(end:n_dpt) = 0;
    else
        exclusion_vector(n_dpt + 1:end)=[];
    end
end