% combine peaks_auto, peaks_manual, and remove peaks during exclusion
function peaks_clean = leep_get_peaks_clean(exclusion_vector,...
    peaks_auto, peaks_manual)

    % remove peaks within the excluded period
    excluded_indexes = find(exclusion_vector==1);
    peaks_clean = peaks_auto + peaks_manual;
    peaks_clean(excluded_indexes) = 0;
end