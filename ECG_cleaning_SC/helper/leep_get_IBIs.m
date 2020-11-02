% calculate IBI based on the distance between peak offsets
% then adjust it to zero if any offsets in range is excluded
% input smoothed data, peaks_combined
% if use peaks_clean, still need to check with exclusion
% Should reached the same results using peaks_combined, or peaks_clean

% output IBIs_with_latency, first column latency, second column IBI
% latency is the distance from the current peak to the next peak

function [IBIs_with_latency, IBI_vector_clean] = leep_get_ibi(data, peaks, exclusion_vector,...
    pathname_IBIs, pathname_IBIs_latency)
    % go through data and compute distances between peaks (=IBIs)

    IBIs_with_latency = [];
    IBI_vector = zeros(length(data),1); %same length as data
    IBI_vector_clean =  zeros(length(data),1);
    
    startpos = find(peaks == 1,1);
    lastpeak = startpos;
    
    % iterating from the datapoint after the first peak to the end of data
    % IBI is the duration from the current peak to the next peak
    
    for i = startpos + 1:length(data)
        if peaks(i) == 1
            distance = (i - lastpeak) * 1000/srate; %measures the distance to the last peak in ms
            IBI_vector(lastpeak : i) = distance;
            if sum(exclusion_vector(lastpeak : i)) == 0
               IBIs_with_latency(end + 1 , 1:2) = [i, distance];
               IBI_vector_clean(lastpeak : i) = IBI_vector(lastpeak:i);
            else
                % If part of the duration of the IBI as excluded, 
                % do not add to the IBIs list. 
                % update IBI_vector to be 0
                IBI_vector_clean(lastpeak : i) = 0; %default IBI to be zero if excluded
            end
            lastpeak = i;
        end
    end
    
    fid = fopen(filename_IBIs, 'wt');
    for z = 1:length(IBIs_with_latency)
        fprintf(fid, '%d\n',IBIs_with_latency(z,2)); %only IBIs
    end
    fclose(fid);

    fid = fopen(filename_IBIs_with_latency, 'wt');
    for z = 1:length(IBIs_with_latency)
        fprintf(fid, '%d\t%d\n',IBIs_with_latency(z,1), IBIs_with_latency(z,2));
    end
    fclose(fid);

end
