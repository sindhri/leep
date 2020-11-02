%input rawdata
%output smoothed data and peaks

function [data_smoothed, peaks, minh]=leep_find_peaks(data, srate)

% smooth data (to facilitate peak detection )
% data channel 1 is turned to smoothed data
data_smoothed=smooth(data,5);

% initiate peak data
peaks = zeros(length(data),1);

% find the peaks
threshold=.5; % for R-peak detection: all peaks that have a height of at least threshold*max_height are selected
minh=max(data_smoothed)*threshold; % assume that they have at least half the height of data's maximum
%minh=mean(data)+std(data)*2;
[pks, peaklocs] = findpeaks(data_smoothed, 'minpeakheight', minh, 'minpeakdistance', 75);


% mark the peaks in the data (channel 2)
% peaks from smoothed data
peaks(peaklocs)=1;
        
% clear peaks from first 400ms, as those are often spurious
peaks(1:400*srate/1000,2)=0;
            
% these peak detections are based on smoothed data. This makes it
% much more reliable (all peaks get detected), however a bit less accurate
% in a second step we thus revisit all the found peaks and check in
% the unsmoothed data

% iterating through each datapoint latency (not time latency) of data
for i = 1:length(data_smoothed)
   if peaks(i)==1 
       % when we have a peak               
       % check whether there is a higher point somewhere in the
                % raw data
        highestvalue = data_smoothed(i); 
        divergence = 0;
        for j = -5:5 %check 10 data points around the peak
            if i+j <= length(data_smoothed) %make sure it does not go beyond the end of the file
                if data(i+j,1) > highestvalue %if a higher peak exists
                   highestvalue = data_smoothed(i+j); 
                   divergence = j; 
                end
            end
        end
        % replace original marker by new marker
        peaks(i)=0;
        peaks(i + divergence) = 1; %update the new peak latency
   end
end
end