function [peaks_manual, exclusions] = leep_get_marker_exclusion(filename_markers,...
    filename_exclusions, n_dpt, srate)

% load markers and excluded sections (if they exist)
% read in the existing markers for marking channels bad
if exist(filename_markers, 'file')
   load(filename_markers)
else
   peaks_manual = zeros(n_dpt,1);
end

% read in the existing exclusion marked from previous iteration if any
% time period involving any excluded area would results in nan
% in calculating dp and IBI in relation to events
if exist(filename_exclusions, 'file')
   load(filename_exclusions)
else
   exclusions(1: round(n_dpt/srate)) = 0; 
end

end