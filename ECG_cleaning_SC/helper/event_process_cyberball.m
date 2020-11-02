% process cyberball event file and export IBI_split
function event_process_cyberball(events, IBIs_with_latency,...
    pathname_IBIs_split)
    
    fair_index1 = find(events(:,2) == 350); %fair
    fair_index2 = find(events(:,2) == 550); %not_my_turn
    % find the beginning and end of fair play
    fair_start_index = min(fair_index1(1),fair_index2(1));
    fair_end_index = max(fair_index1(end),fair_index2(end));
    
    fair_duration = events(fair_start_index,1):events(fair_end_index,1);
    fair_duration_midpoint = round(mean([events(fair_start_index,1),events(fair_end_index,1)]));
    fair_duration1 = events(fair_start_index,1):fair_duration_midpoint;
    fair_duration2 = fair_duration_midpoint+1:events(fair_end_index,1);
    fprintf('fair start is %d datapoint, fair end is %d datapoint\n',fair_start_index,fair_end_index);
    fprintf('fair play duration is %d datapoints\n', fair_duration);    
    fprintf('fair midpoint is %d datapoint\n',fair_duration_midpoint);
    
    unfair_index = find(events(:,2)==850); %exclusion
    unfair_start_index = unfair_index(1);
    unfair_end_index = unfair_index(end);
    unfair_duration = events(unfair_start_index,1):events(unfair_end_index,1);
    fprintf('unfair start is %d dataopint, unfair end is %d datapoint\n',unfair_start_index,unfair_end_index);
    fprintf('unfair play duration is %d datapoints\n', unfair_duration);    

    fid1 = fopen([pathname_IBIs_split 'IBIs_fair1_' subject_no '_' task '.txt'], 'wt');
    fid2 = fopen([pathname_IBIs_split 'IBIs_fair2_' subject_no '_' task '.txt'], 'wt');
    fid3 = fopen([pathname_IBIs_split 'IBIs_unfair_' subject_no '_' task '.txt'], 'wt');
    
    temp = find(IBIs_with_latency(:,1) > fair_duration1(end),1);
    IBI_fair1_last_index = temp-1;

    temp = find(IBIs_with_latency(:,1) > fair_duration2(end),1);
    IBI_fair2_last_index = temp-1;

    temp = find(IBIs_with_latency(:,1) > unfair_index(1),1);
    IBI_unfair_first_index = temp;

    temp = find(IBIs_with_latency(:,1) > unfair_index(end),1);
    IBI_unfair_last_index = temp-1;

    for i = 1:IBI_fair1_last_index
        fprintf(fid1, '%d\n',IBIs_with_latency(i,2));
    end

    for i = IBI_fair1_last_index + 1 : IBI_fair2_last_index
        fprintf(fid2, '%d\n',IBIs_with_latency(i,2));
    end
    
    for i = IBI_unfair_first_index : IBI_unfair_last_index
        fprintf(fid2, '%d\n',IBIs_with_latency(i,2));
    end

    fclose(fid1);
    fclose(fid2);
    fclose(fid3);

end
