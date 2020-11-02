function leep_output_results_IBI(events, subject_id,...
    preevent_IBI, postevent_IBI, IBI_vector, exclusion_vector,...
    filename_results_IBI)

triallist=[];

% iterate through all the events
for i=1:length(events)
    triallist(end+1,1) = str2num(subject_id);
    triallist(end, 2) = events(i, 2); % event type
    tp = events(i,1);

    % used peaks_combined instead of peaks_clean
    % because even when part of the 
    peak_in_data = find(peaks_combined == 1); % get the peak indices

    %find the first peak whoes onset is larer than the current event's onset
    event_first_IBI_index = find(peak_in_data > tp,1);

    for j = -preevent_IBI:postevent_IBI
        peak_latency = peak_in_data(event_first_IBI_index + j);
        localIBI = IBI_vector(peak_latency);
        if exclusion_vector(peak_latency)==1
            localIBI = nan; 
        end
        triallist(end, j+3) = localIBI;
    end

    dlmwrite(filename_results_IBI,triallist,'\t');
end
end