% write an output file result_dp based on events
% header: latency (not time)
function leep_output_results_dp(IBI_vector_clean, ...
    events, preevent_dp, postevent_dp, filename_results_dp)

%events: first column - latency, second column - marker

% export without event marker as the first column
results_dp = zeros(size(events,1), postevent_dp + preevent_dp - 1);

for i = 1:size(events,1)
    clatency = events(i,1);
    %baseline_dp, postevent_dp
    % write a row of latency, not time point
    cdata = IBI_vector_clean(clatency - preevent_dp : clatency + postevent_dp-1)';
    cdp = -preevent_dp : postevent_dp - 1;
    if i == 1
        results_dp = [0,cdp]; %latency row
    end
    
    % replace 0 to nan in cdata, for IBIs=0 indicating excluded area
    if ~isempty(find(cdata == 0))
        for j = 1:length(cdata)
            if cdata(j)==0
                cdata(j) = nan;
            end
        end
    end
    results_dp(i,:) = cdata;
end
% add event marker column
results_dp = [events(:,2), results_dp];

dlmwrite(filename_results_dp,results_dp,'\t');

end